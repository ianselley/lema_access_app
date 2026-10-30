import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/debug_log.dart';
import '../controllers/history_controller.dart';
import '../models/add_on_models.dart';
import '../models/event_models.dart' as event_models;
import '../models/history_models.dart';
import '../models/scan_models.dart';
import '../models/ticket_models.dart' as ticket_models;
import '../providers/event_providers.dart';
import '../providers/scan_providers.dart';
import '../providers/ticket_providers.dart';
import '../navigation/operator_route_observer.dart';
import '../screens/event_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import 'history_scan_result_screen.dart';
import 'recent_history_screen.dart';

bool scannerNeedsPersistentResult(AccessScanOutcome outcome) {
  if (outcome.resultCode == 'already_used') {
    return outcome.ticket?.status == 'checked_in' &&
        (outcome.ticket?.addOns.any((extra) => extra.remainingQuantity > 0) ??
            false);
  }
  return outcome.requiresValidityDecision ||
      (outcome.resultCode == 'valid' &&
          (outcome.ticket?.addOns.isNotEmpty ?? false));
}

Color scannerResultAccent(AccessScanOutcome outcome) {
  if (outcome.resultCode == 'already_used' &&
      scannerNeedsPersistentResult(outcome)) {
    return AppColors.warning;
  }
  return outcome.resultCode == 'valid' ? AppColors.success : AppColors.error;
}

/// Data class for holding the last scanned ticket information so it can be
/// displayed in the bottom row even after the scan controller state resets.
class _LastScanInfo {
  const _LastScanInfo({
    required this.eventId,
    required this.titleLabel,
    required this.subtitleLabel,
    required this.resultCode,
    required this.createdAt,
    this.ticketSelection,
    this.resultSnapshot,
    this.hasPendingExtras = false,
  });

  final String? eventId;
  final String titleLabel;
  final String subtitleLabel;
  final String resultCode;
  final bool hasPendingExtras;
  final DateTime? createdAt;
  final ticket_models.AccessTicketSelection? ticketSelection;
  final HistoryScanResultSnapshot? resultSnapshot;
}

class ScannerActiveScreen extends ConsumerStatefulWidget {
  const ScannerActiveScreen({
    super.key,
    this.onOpenManualSearch,
    this.onOpenTicketDetail,
  });

  final VoidCallback? onOpenManualSearch;
  final VoidCallback? onOpenTicketDetail;

  @override
  ConsumerState<ScannerActiveScreen> createState() =>
      _ScannerActiveScreenState();
}

class _ScannerActiveScreenState extends ConsumerState<ScannerActiveScreen>
    with WidgetsBindingObserver, RouteAware, TickerProviderStateMixin {
  static const _barcodeFormats = <BarcodeFormat>[BarcodeFormat.all];
  static const _duplicateDebounce = Duration(milliseconds: 1200);
  static const _resultDisplayDuration = Duration(milliseconds: 1500);
  static const _bottomPanelHeight = 172.0;

  MobileScannerController? _scannerController;

  bool _isSubmitting = false;
  bool _isAppActive = true;
  bool _isRouteVisible = true;
  bool _isHistoryOpen = false;
  bool _scannerNeedsReset = false;
  bool _cameraUnavailable = false;
  DateTime? _scannerCooldownUntil;
  String? _lastAcceptedInput;
  DateTime? _lastAcceptedAt;
  PageRoute<dynamic>? _pageRoute;
  Future<void> _scannerSync = Future<void>.value();

  // --- Scan result overlay state ---
  bool _showResultOverlay = false;
  String? _overlayResultCode;
  AccessScanOutcome? _overlayOutcome;
  Timer? _resultDisplayTimer;
  Set<String> _selectedAddOnIds = <String>{};
  bool _isRedeemingExtras = false;
  String? _extraValidationError;
  final _resultModalKey = GlobalKey();
  Rect? _resultExitRect;

  // --- Animation controllers ---
  late final AnimationController _checkAnimController;
  late final AnimationController _slideDownController;
  late final Animation<double> _checkOpacityAnimation;
  late final Animation<double> _slideDownAnimation;

  // --- Last scanned ticket data ---
  _LastScanInfo? _lastScanInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isAppActive = _isActiveLifecycleState(
      WidgetsBinding.instance.lifecycleState,
    );

    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _checkOpacityAnimation = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.easeOutCubic,
    );

    _slideDownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _slideDownAnimation = CurvedAnimation(
      parent: _slideDownController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    _syncScannerState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final modalRoute = ModalRoute.of(context);
    if (modalRoute is! PageRoute<dynamic> || modalRoute == _pageRoute) {
      return;
    }

    if (_pageRoute != null) {
      operatorRouteObserver.unsubscribe(this);
    }

    _pageRoute = modalRoute;
    operatorRouteObserver.subscribe(this, modalRoute);
  }

  @override
  void dispose() {
    _resultDisplayTimer?.cancel();
    _checkAnimController.dispose();
    _slideDownController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    operatorRouteObserver.unsubscribe(this);
    _isRouteVisible = false;
    unawaited(_syncScannerState());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = _isActiveLifecycleState(state);
    _syncScannerState(reset: !_isAppActive);
  }

  @override
  void didHaveMemoryPressure() {
    accessLog(
      'Memory pressure received while scanner route is mounted.',
      scope: 'scanner',
    );
    _scannerCooldownUntil = DateTime.now().add(const Duration(seconds: 3));
    unawaited(_syncScannerState(reset: true));
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      _syncScannerState();
    });
  }

  @override
  void didPushNext() {
    _isRouteVisible = false;
    _syncScannerState(reset: true);
  }

  @override
  void didPopNext() {
    _isRouteVisible = true;
    _syncScannerState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(accessScanControllerProvider.notifier).reset();
    });
  }

  bool _isActiveLifecycleState(AppLifecycleState? state) {
    return switch (state) {
      null || AppLifecycleState.resumed => true,
      AppLifecycleState.inactive ||
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
    };
  }

  bool get _isScannerCoolingDown =>
      _scannerCooldownUntil != null &&
      DateTime.now().isBefore(_scannerCooldownUntil!);

  MobileScannerController _createScannerController() {
    return MobileScannerController(
      autoStart: false,
      cameraResolution: switch (defaultTargetPlatform) {
        TargetPlatform.iOS => const Size(640, 480),
        _ => const Size(720, 1280),
      },
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 600,
      formats: _barcodeFormats,
      returnImage: false,
      torchEnabled: false,
    );
  }

  bool get _shouldRunScanner =>
      mounted && _isAppActive && _isRouteVisible && !_isScannerCoolingDown;

  Future<void> _syncScannerState({bool reset = false}) {
    _scannerNeedsReset |= reset;
    _scannerSync = _scannerSync.then((_) async {
      try {
        // Read current state when the queued operation runs, not when enqueued.
        if (_scannerNeedsReset || !_shouldRunScanner) {
          _scannerNeedsReset = false;
          await _disposeScannerController();
        }
        if (_shouldRunScanner) await _ensureScannerController();
      } catch (error, stackTrace) {
        accessLog(
          'Camera synchronization failed.',
          scope: 'scanner',
          error: error,
          stackTrace: stackTrace,
        );
        if (mounted) setState(() => _cameraUnavailable = true);
      }
    });
    return _scannerSync;
  }

  Future<void> _ensureScannerController() async {
    if (!_shouldRunScanner) return;
    var scannerController = _scannerController;
    if (scannerController == null) {
      scannerController = _createScannerController();
      _scannerController = scannerController;
      setState(() => _cameraUnavailable = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!_shouldRunScanner) return;
    await scannerController.start();
  }

  Future<void> _disposeScannerController() async {
    final scannerController = _scannerController;
    if (scannerController == null) return;
    _scannerController = null;
    if (mounted) setState(() {});
    // Release native camera resources before waiting for any frame: suspended
    // apps may not render another frame until the phone is unlocked.
    try {
      await scannerController.stop();
    } finally {
      await scannerController.dispose();
    }
  }

  Future<void> _openHistory(
    String? eventId, {
    required bool showOccupancy,
  }) async {
    setState(() => _isHistoryOpen = true);
    try {
      await showRecentHistoryBottomSheet(
        context,
        eventId: eventId,
        showOccupancy: showOccupancy,
        onOpenTicketDetail: widget.onOpenTicketDetail,
      );
    } finally {
      if (mounted) {
        setState(() => _isHistoryOpen = false);
      }
    }
  }

  Future<void> _submitDetectedCode(String rawInput) async {
    try {
      final outcome = await ref
          .read(accessScanControllerProvider.notifier)
          .submitScanInput(rawInput);

      if (!mounted || outcome == null) {
        return;
      }

      _showScanResultOverlay(outcome);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      } else {
        _isSubmitting = false;
      }
    }
  }

  void _showScanResultOverlay(AccessScanOutcome outcome) {
    _resultDisplayTimer?.cancel();
    _resultExitRect = null;
    final addOns = outcome.ticket?.addOns ?? const <AccessTicketAddOn>[];
    final canRedeem =
        outcome.ticket?.status == 'checked_in' ||
        outcome.ticket?.status == 'issued';

    setState(() {
      _showResultOverlay = true;
      _overlayResultCode = outcome.resultCode;
      _overlayOutcome = outcome;
      _selectedAddOnIds = canRedeem
          ? addOns
                .where((addOn) => addOn.remainingQuantity > 0)
                .map((addOn) => addOn.assignmentId)
                .toSet()
          : <String>{};
      _extraValidationError = null;
    });

    _checkAnimController.forward(from: 0);

    if (!scannerNeedsPersistentResult(outcome)) {
      _resultDisplayTimer = Timer(_resultDisplayDuration, _finishResultOverlay);
    }
  }

  Future<void> _validateExtras() async {
    final outcome = _overlayOutcome;
    final ticket = outcome?.ticket;
    if (outcome == null || ticket == null || _isRedeemingExtras) {
      return;
    }

    setState(() {
      _isRedeemingExtras = true;
      _extraValidationError = null;
    });
    AccessScanOutcome? confirmedOutcome;
    AccessTicketSnapshot? updatedTicket;
    try {
      if (outcome.requiresValidityDecision) {
        confirmedOutcome = await ref
            .read(accessScanControllerProvider.notifier)
            .forceConfirmTicket(ticket.id);
        if (confirmedOutcome?.resultCode != 'valid' &&
            confirmedOutcome?.resultCode != 'already_used') {
          throw StateError('Ticket confirmation was rejected.');
        }
      }

      if (_selectedAddOnIds.isNotEmpty) {
        updatedTicket = await ref
            .read(accessScanControllerProvider.notifier)
            .redeemAddOns(
              eventId: ticket.eventId,
              ticketId: ticket.id,
              assignmentIds: _selectedAddOnIds.toList(growable: false),
            );
      }
    } catch (error) {
      if (!mounted) return;
      accessLog(
        'Ticket or add-on validation failed.',
        scope: 'scanner',
        error: error,
        stackTrace: StackTrace.current,
      );
      setState(() {
        _isRedeemingExtras = false;
        _extraValidationError =
            'No se ha podido completar la validación. Inténtalo de nuevo.';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isRedeemingExtras = false;
        if (confirmedOutcome != null) {
          _overlayOutcome = confirmedOutcome;
          _overlayResultCode = confirmedOutcome.resultCode;
        }
      });
      _finishResultOverlay(ticketOverride: updatedTicket);
    }
  }

  void _finishResultOverlay({AccessTicketSnapshot? ticketOverride}) {
    if (!mounted || !_showResultOverlay) return;
    final modalBox = _resultModalKey.currentContext?.findRenderObject();
    if (modalBox is RenderBox && modalBox.hasSize) {
      _resultExitRect =
          modalBox.localToGlobal(
            Offset.zero,
            ancestor: context.findRenderObject(),
          ) &
          modalBox.size;
    }
    _lastScanInfo = _lastScanInfoFromOutcome(
      ref.read(accessCurrentEventIdProvider),
      _overlayOutcome!,
      ticketOverride: ticketOverride,
    );
    _slideDownController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _showResultOverlay = false;
        _overlayResultCode = null;
        _overlayOutcome = null;
        _selectedAddOnIds = <String>{};
        _extraValidationError = null;
      });
      _checkAnimController.reset();
      _slideDownController.reset();
    });
  }

  void _handleDetection(BarcodeCapture capture) {
    // Block scanning while showing result overlay
    if (!_shouldRunScanner ||
        _isHistoryOpen ||
        _isSubmitting ||
        _showResultOverlay) {
      return;
    }

    final rawInput = _extractRawInput(capture);
    if (rawInput == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastAcceptedInput == rawInput &&
        _lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < _duplicateDebounce) {
      return;
    }

    _lastAcceptedInput = rawInput;
    _lastAcceptedAt = now;

    setState(() {
      _isSubmitting = true;
    });

    unawaited(_submitDetectedCode(rawInput));
  }

  String? _extractRawInput(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim() ?? barcode.displayValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  IconData _iconForResultCode(String resultCode) {
    final variant = accessScanUiVariantForResultCode(resultCode);
    return switch (variant) {
      AccessScanUiVariant.valid => Icons.check_circle_rounded,
      AccessScanUiVariant.used => Icons.history_toggle_off_rounded,
      AccessScanUiVariant.invalid => Icons.cancel_rounded,
      AccessScanUiVariant.notFound => Icons.search_off_rounded,
      AccessScanUiVariant.networkError => Icons.cloud_off_rounded,
    };
  }

  String? _overlaySubjectLabel(AccessScanOutcome? outcome) {
    if (outcome == null) {
      return null;
    }

    final eventName = outcome.invalidContext?.ticketEvent?.displayName?.trim();
    if (eventName != null && eventName.isNotEmpty) {
      return eventName;
    }

    final ticket = outcome.ticket;
    final displayName = ticket?.displayName.trim();
    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName != 'Sin nombre') {
      return displayName;
    }

    final normalizedInput = outcome.normalizedInput?.trim();
    if (normalizedInput != null && normalizedInput.isNotEmpty) {
      return normalizedInput;
    }

    return null;
  }

  String? _overlayTicketLabel(AccessScanOutcome? outcome) {
    if (outcome == null) {
      return null;
    }

    final ticket = outcome.ticket;
    if (ticket != null) {
      return _joinOverlayLabelParts([
        ticket.ticketTypeLabel,
        ticket.zoneOffer?.guestCountLabel,
      ]);
    }

    final invalidContext = outcome.invalidContext;
    if (invalidContext != null) {
      final invalidSummary = _joinOverlayLabelParts([
        if (invalidContext.ticketEvent?.brandName != null)
          invalidContext.ticketEvent!.brandName!,
        if (invalidContext.ticketEvent?.startTime != null)
          _formatOverlayEventDate(invalidContext.ticketEvent!.startTime!),
        outcome.displayReasonLabel,
      ]);
      if (invalidSummary != null) {
        return invalidSummary;
      }

      final statusLabel = accessTicketStatusLabel(
        invalidContext.ticketStatus ?? outcome.ticketStatus,
      );
      if (statusLabel != 'Sin estado') {
        return statusLabel;
      }
    }

    final reasonLabel = outcome.displayReasonLabel?.trim();
    if (reasonLabel != null && reasonLabel.isNotEmpty) {
      return reasonLabel;
    }

    return null;
  }

  String? _overlayScheduleLabel(AccessScanOutcome? outcome) {
    final zoneOffer = outcome?.ticket?.zoneOffer;
    final validityWindow = outcome?.ticket?.validityWindow;
    final startsAt =
        (zoneOffer != null
                ? zoneOffer.serviceStartsAt
                : validityWindow?.startsAt)
            ?.toLocal();
    final endsAt =
        (zoneOffer != null ? zoneOffer.serviceEndsAt : validityWindow?.endsAt)
            ?.toLocal();
    if (startsAt == null && endsAt == null) return null;

    final interval = switch ((startsAt, endsAt)) {
      (final start?, final end?) =>
        '${_formatOverlayTime(start)}–${_formatOverlayTime(end)}',
      (final start?, null) => 'desde las ${_formatOverlayTime(start)}',
      (null, final end?) => 'hasta las ${_formatOverlayTime(end)}',
      _ => null,
    };
    final label = zoneOffer != null ? 'Horario de mesa' : 'Horario de acceso';
    return interval == null ? null : '$label: $interval';
  }

  String _formatOverlayTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _overlayHeadline(AccessScanOutcome? outcome, String resultCode) {
    return outcome?.displayHeadline ??
        accessScanHeadlineForResultCode(resultCode);
  }

  String _formatOverlayEventDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String? _joinOverlayLabelParts(List<String?> values) {
    final parts = <String>[];
    for (final value in values.whereType<String>()) {
      final part = value.trim();
      if (part.isNotEmpty && !parts.contains(part)) parts.add(part);
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' · ');
  }

  String? _normalizedEventId(String? eventId) {
    final normalized = eventId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  _LastScanInfo? _lastScanInfoFromHistoryState(
    String? eventId,
    AccessHistoryState? historyState,
  ) {
    final normalizedEventId = _normalizedEventId(eventId);
    if (normalizedEventId == null ||
        historyState == null ||
        historyState.items.isEmpty) {
      return null;
    }

    return _lastScanInfoFromHistoryEntry(
      normalizedEventId,
      historyState.items.first,
    );
  }

  _LastScanInfo _lastScanInfoFromHistoryEntry(
    String eventId,
    AccessHistoryEntry entry,
  ) {
    final ticket = entry.ticket;

    return _LastScanInfo(
      eventId: eventId,
      titleLabel:
          ticket?.attendee.fullName ??
          entry.actor.displayName ??
          'Sin asistente',
      subtitleLabel: _historyEntrySubtitle(entry),
      resultCode: entry.resultCode,
      hasPendingExtras:
          ticket?.addOns.any((extra) => extra.remainingQuantity > 0) ?? false,
      createdAt: entry.createdAt,
      ticketSelection:
          ticket == null || historyResultNeedsExplanation(entry.resultCode)
          ? null
          : _historyTicketSelection(entry, ticket),
      resultSnapshot: historyResultNeedsExplanation(entry.resultCode)
          ? HistoryScanResultSnapshot.fromHistoryEntry(entry)
          : null,
    );
  }

  _LastScanInfo? _lastScanInfoFromEventHome(
    String? eventId,
    event_models.AccessEventHome? home,
  ) {
    final normalizedEventId = _normalizedEventId(eventId);
    if (normalizedEventId == null ||
        home == null ||
        home.recentHistoryPreview.isEmpty) {
      return null;
    }

    final item = home.recentHistoryPreview.first;
    return _LastScanInfo(
      eventId: normalizedEventId,
      titleLabel: item.titleLabel,
      subtitleLabel: item.subtitleLabel,
      resultCode: item.resultCode ?? 'temporary_error',
      hasPendingExtras:
          item.ticket?.addOns.any((extra) => extra.remainingQuantity > 0) ??
          false,
      createdAt: item.createdAt,
      resultSnapshot: historyResultNeedsExplanation(item.resultCode)
          ? HistoryScanResultSnapshot.fromEventHistoryItem(item)
          : null,
    );
  }

  _LastScanInfo _lastScanInfoFromOutcome(
    String? currentEventId,
    AccessScanOutcome outcome, {
    AccessTicketSnapshot? ticketOverride,
  }) {
    final ticket = ticketOverride ?? outcome.ticket;
    return _LastScanInfo(
      eventId: _normalizedEventId(outcome.ticket?.eventId ?? currentEventId),
      titleLabel: _outcomeTitleLabel(outcome),
      subtitleLabel: _outcomeSubtitleLabel(outcome),
      resultCode: outcome.resultCode,
      hasPendingExtras:
          ticket?.addOns.any((extra) => extra.remainingQuantity > 0) ?? false,
      createdAt: outcome.scanLog?.createdAt ?? DateTime.now(),
      ticketSelection:
          outcome.ticket == null ||
              historyResultNeedsExplanation(outcome.resultCode)
          ? null
          : _selectionFromScanSnapshot(ticket!),
      resultSnapshot: historyResultNeedsExplanation(outcome.resultCode)
          ? _resultSnapshotFromOutcome(outcome)
          : null,
    );
  }

  String _historyEntrySubtitle(AccessHistoryEntry entry) {
    final parts = <String>[
      if (entry.ticket?.code.trim().isNotEmpty ?? false) entry.ticket!.code,
      if (entry.normalizedInput?.trim().isNotEmpty ?? false)
        entry.normalizedInput!,
    ];

    if (parts.isEmpty) {
      return 'Validación registrada';
    }

    return parts.join(' · ');
  }

  String _outcomeTitleLabel(AccessScanOutcome outcome) {
    final ticketName = outcome.ticket?.displayName.trim();
    if (ticketName != null && ticketName.isNotEmpty) {
      return ticketName;
    }

    final eventName = outcome.invalidContext?.ticketEvent?.displayName?.trim();
    if (eventName != null && eventName.isNotEmpty) {
      return eventName;
    }

    final normalizedInput = outcome.normalizedInput?.trim();
    if (normalizedInput != null && normalizedInput.isNotEmpty) {
      return normalizedInput;
    }

    return 'Sin asistente';
  }

  String _outcomeSubtitleLabel(AccessScanOutcome outcome) {
    final parts = <String>[
      if (outcome.ticket?.code.trim().isNotEmpty ?? false) outcome.ticket!.code,
      if (outcome.ticket?.ticketTypeLabel.trim().isNotEmpty ?? false)
        outcome.ticket!.ticketTypeLabel,
      if (outcome.displayReasonLabel?.trim().isNotEmpty ?? false)
        outcome.displayReasonLabel!,
    ];

    if (parts.isEmpty) {
      return 'Validación registrada';
    }

    return parts.join(' · ');
  }

  ticket_models.AccessTicketSnapshot _mapHistoryTicketSnapshot(
    AccessHistoryTicketSnapshot ticket,
  ) {
    return ticket_models.AccessTicketSnapshot(
      id: ticket.id,
      eventId: ticket.eventId,
      code: ticket.code,
      status: ticket.status,
      canCheckIn: ticket.canCheckIn,
      ticketType: ticket_models.AccessTicketType(
        id: ticket.ticketType.id,
        name: ticket.ticketType.name,
        description: ticket.ticketType.description,
      ),
      attendee: ticket_models.AccessTicketAttendee(
        id: ticket.attendee.id,
        fullName: ticket.attendee.fullName,
        email: ticket.attendee.email,
        phone: ticket.attendee.phone,
        birthDate: ticket.attendee.birthDate,
        documentId: ticket.attendee.documentId,
        isOrderBuyer: ticket.attendee.isOrderBuyer,
      ),
      buyer: ticket.buyer == null
          ? null
          : ticket_models.AccessTicketBuyer(
              id: ticket.buyer!.id,
              fullName: ticket.buyer!.fullName,
              email: ticket.buyer!.email,
              phone: ticket.buyer!.phone,
            ),
      order: ticket_models.AccessTicketOrder(
        id: ticket.order.id,
        status: ticket.order.status,
        currency: ticket.order.currency,
        paidAt: ticket.order.paidAt,
      ),
      issuedAt: ticket.issuedAt,
      checkedInAt: ticket.checkedInAt,
      updatedAt: ticket.updatedAt,
      zoneOffer: ticket.zoneOffer,
      addOns: ticket.addOns,
      validityWindow: ticket.validityWindow,
    );
  }

  _LastScanInfo? _resolveDisplayedLastScan({
    required String? eventId,
    required _LastScanInfo? historyLastScan,
    required _LastScanInfo? optimisticLastScan,
  }) {
    final normalizedEventId = _normalizedEventId(eventId);
    if (normalizedEventId == null) {
      return null;
    }

    final scopedHistoryLastScan = historyLastScan?.eventId == normalizedEventId
        ? historyLastScan
        : null;
    final scopedOptimisticLastScan =
        optimisticLastScan?.eventId == normalizedEventId
        ? optimisticLastScan
        : null;

    if (scopedHistoryLastScan == null) {
      return scopedOptimisticLastScan;
    }
    if (scopedOptimisticLastScan == null) {
      return scopedHistoryLastScan;
    }

    final optimisticCreatedAt = scopedOptimisticLastScan.createdAt;
    final historyCreatedAt = scopedHistoryLastScan.createdAt;

    if (optimisticCreatedAt == null) {
      return scopedHistoryLastScan;
    }
    if (historyCreatedAt == null) {
      return scopedOptimisticLastScan;
    }

    return optimisticCreatedAt.isBefore(historyCreatedAt)
        ? scopedHistoryLastScan
        : scopedOptimisticLastScan;
  }

  ticket_models.AccessTicketSelection _selectionFromScanSnapshot(
    AccessTicketSnapshot scanTicket,
  ) {
    return ticket_models.AccessTicketSelection(
      eventId: scanTicket.eventId,
      ticketId: scanTicket.id,
      query: scanTicket.code,
      matchReason: ticket_models.TicketSearchMatchReason.other,
      ticket: ticket_models.AccessTicketSnapshot(
        id: scanTicket.id,
        eventId: scanTicket.eventId,
        code: scanTicket.code,
        status: scanTicket.status,
        canCheckIn: scanTicket.canCheckIn,
        ticketType: ticket_models.AccessTicketType(
          id: null,
          name: scanTicket.ticketTypeName,
          description: scanTicket.ticketTypeDescription,
        ),
        attendee: ticket_models.AccessTicketAttendee(
          id: null,
          fullName: scanTicket.attendeeFullName,
          email: scanTicket.attendeeEmail,
          phone: scanTicket.attendeePhone,
          birthDate: null,
          documentId: null,
          isOrderBuyer: false,
        ),
        buyer: scanTicket.buyerFullName == null
            ? null
            : ticket_models.AccessTicketBuyer(
                id: null,
                fullName: scanTicket.buyerFullName,
                email: scanTicket.buyerEmail,
                phone: scanTicket.buyerPhone,
              ),
        order: ticket_models.AccessTicketOrder(
          id: scanTicket.orderId,
          status: scanTicket.orderStatus,
          currency: scanTicket.orderCurrency,
          paidAt: null,
        ),
        issuedAt: scanTicket.issuedAt,
        checkedInAt: scanTicket.checkedInAt,
        updatedAt: scanTicket.updatedAt,
        zoneOffer: scanTicket.zoneOffer,
        validityWindow: scanTicket.validityWindow,
        addOns: scanTicket.addOns,
      ),
      contextLabel: 'Escáner',
    );
  }

  ticket_models.AccessTicketSelection _historyTicketSelection(
    AccessHistoryEntry entry,
    AccessHistoryTicketSnapshot ticket,
  ) {
    return ticket_models.AccessTicketSelection(
      eventId: ticket.eventId,
      ticketId: ticket.id,
      query: ticket.code,
      matchReason: ticket_models.TicketSearchMatchReason.other,
      ticket: _mapHistoryTicketSnapshot(ticket),
      contextLabel: _sourceLabel(entry.source),
    );
  }

  HistoryScanResultSnapshot _resultSnapshotFromOutcome(
    AccessScanOutcome outcome,
  ) {
    return HistoryScanResultSnapshot(
      resultCode: outcome.resultCode,
      reasonCode: outcome.reasonCode,
      sourceLabel: _sourceLabel(outcome.source.name),
      referenceLabel:
          outcome.ticket?.code ?? outcome.normalizedInput ?? outcome.rawInput,
      subject: outcome.ticket?.displayName,
      ticketTypeLabel: outcome.ticket?.ticketTypeLabel,
      ticketTypeDescription:
          outcome.ticket?.ticketTypeDescriptionLabel ?? outcome.displayBody,
      attemptedAt: outcome.scanLog?.createdAt,
    );
  }

  String _sourceLabel(String? source) {
    switch (source) {
      case 'scanner':
        return 'Escáner';
      case 'manual_code':
        return 'Código manual';
      case 'manual_search':
        return 'Búsqueda manual';
      case 'manual_detail':
        return 'Detalle manual';
      default:
        return source ?? 'Otra fuente';
    }
  }

  void _openLastScan(_LastScanInfo? lastScanInfo) {
    if (lastScanInfo == null) {
      return;
    }

    final resultSnapshot = lastScanInfo.resultSnapshot;
    if (resultSnapshot != null) {
      openHistoryScanResultScreen(context, snapshot: resultSnapshot);
      return;
    }

    final selection = lastScanInfo.ticketSelection;
    if (selection != null) {
      ref.read(accessSelectedTicketProvider.notifier).state = selection;
      ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
      widget.onOpenTicketDetail?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEventId = _normalizedEventId(
      ref.watch(accessCurrentEventIdProvider),
    );
    final historyState = currentEventId == null
        ? null
        : ref
              .watch(accessHistoryControllerProvider(currentEventId))
              .valueOrNull;
    final eventHome = currentEventId == null
        ? null
        : ref.watch(accessEventHomeProvider(currentEventId)).valueOrNull;
    final showOccupancy = currentEventId == null
        ? false
        : eventHome?.canViewCurrentOccupancy ?? false;
    final displayedLastScan = _resolveDisplayedLastScan(
      eventId: currentEventId,
      historyLastScan:
          _lastScanInfoFromHistoryState(currentEventId, historyState) ??
          _lastScanInfoFromEventHome(currentEventId, eventHome),
      optimisticLastScan: _lastScanInfo,
    );
    final parentNavigationScope = OperatorNavigationScope.maybeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.viewPadding.top;
    final hasPersistentModal =
        _showResultOverlay &&
        _overlayOutcome != null &&
        scannerNeedsPersistentResult(_overlayOutcome!);

    return OperatorNavigationScope(
      canGoBack: false,
      child: PopScope(
        canPop: !hasPersistentModal,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final totalHeight = constraints.maxHeight;
              final totalWidth = constraints.maxWidth;

              // Camera area: everything above bottom panel
              final cameraAreaHeight = totalHeight - _bottomPanelHeight;

              // Calculate the scan window centered in the camera area,
              // accounting for the top bar area
              final topBarAreaHeight = topPadding + 56;
              final availableScanAreaHeight =
                  cameraAreaHeight - topBarAreaHeight;
              final availableScanAreaCenter =
                  topBarAreaHeight + availableScanAreaHeight * 0.44;

              final shortestSide = math.min(
                totalWidth,
                availableScanAreaHeight,
              );
              final frameSide = (shortestSide * 0.68)
                  .clamp(220.0, 320.0)
                  .toDouble();
              final scanWindow = Rect.fromCenter(
                center: Offset(totalWidth / 2, availableScanAreaCenter),
                width: frameSide,
                height: frameSide,
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  // -- Full-bleed camera --
                  if (_scannerController != null)
                    Positioned.fill(
                      child: MobileScanner(
                        key: ObjectKey(_scannerController),
                        controller: _scannerController!,
                        fit: BoxFit.cover,
                        scanWindow: scanWindow,
                        onDetect: _handleDetection,
                        errorBuilder: (context, error) {
                          return _CameraErrorView(
                            error: error,
                            onRetry: () {
                              unawaited(_syncScannerState(reset: true));
                            },
                          );
                        },
                        placeholderBuilder: (context) {
                          return const ColoredBox(color: Colors.black);
                        },
                      ),
                    )
                  else
                    const Positioned.fill(
                      child: ColoredBox(color: Colors.black),
                    ),

                  if (_cameraUnavailable)
                    const Center(
                      child: Text(
                        'No se pudo activar la cámara.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  // -- Scan overlay with cutout --
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ScanOverlayPainter(
                          scanWindow: scanWindow,
                          bottomPanelHeight: _bottomPanelHeight,
                        ),
                      ),
                    ),
                  ),

                  // -- Top bar (back button only, no flash) --
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(top: topPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.50),
                            Colors.black.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: hasPersistentModal
                                ? null
                                : () {
                                    final onBack =
                                        parentNavigationScope?.onBack;
                                    if (onBack != null) {
                                      onBack();
                                      return;
                                    }
                                    Navigator.of(context).maybePop();
                                  },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'Volver',
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'ESCANEAR',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // Camera switch button
                          if (_scannerController != null)
                            ValueListenableBuilder<MobileScannerState>(
                              valueListenable: _scannerController!,
                              builder: (context, value, child) {
                                if (!value.isInitialized ||
                                    !value.isRunning ||
                                    (value.availableCameras ?? 0) < 2) {
                                  return const SizedBox(width: 48);
                                }
                                return IconButton(
                                  onPressed: () async {
                                    await _scannerController?.switchCamera();
                                    if (mounted) setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.cameraswitch_rounded,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Cambiar cámara',
                                );
                              },
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  // -- Manual validation glassy button --
                  Positioned(
                    left: 0,
                    right: 0,
                    top: scanWindow.bottom + 20,
                    child: Center(
                      child: _GlassyButton(
                        label: 'Buscar ticket',
                        icon: Icons.keyboard_alt_rounded,
                        onTap: widget.onOpenManualSearch,
                      ),
                    ),
                  ),

                  // -- Processing indicator --
                  if (_isSubmitting && !_showResultOverlay)
                    Positioned(
                      left: scanWindow.left,
                      top: scanWindow.top,
                      width: frameSide,
                      height: frameSide,
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.60),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // -- Bottom panel: last scanned ticket --
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomLastScanPanel(
                      lastScan: displayedLastScan,
                      onOpenHistory: hasPersistentModal
                          ? null
                          : () => _openHistory(
                              currentEventId,
                              showOccupancy: showOccupancy,
                            ),
                      onTapLastScan: hasPersistentModal
                          ? null
                          : () => _openLastScan(displayedLastScan),
                    ),
                  ),

                  if (hasPersistentModal)
                    const Positioned.fill(
                      child: ModalBarrier(
                        dismissible: false,
                        color: Color(0x99000000),
                      ),
                    ),

                  // -- Scan result overlay (animated check/icon) --
                  if (_showResultOverlay && _overlayResultCode != null)
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _checkAnimController,
                        _slideDownController,
                      ]),
                      builder: (context, child) {
                        final requiresValidityDecision =
                            _overlayOutcome?.requiresValidityDecision ?? false;
                        final accent = scannerResultAccent(_overlayOutcome!);
                        final icon = requiresValidityDecision
                            ? Icons.schedule_rounded
                            : _iconForResultCode(_overlayResultCode!);
                        final headline = _overlayHeadline(
                          _overlayOutcome,
                          _overlayResultCode!,
                        );
                        final subjectLabel = _overlaySubjectLabel(
                          _overlayOutcome,
                        );
                        final ticketLabel = _overlayTicketLabel(
                          _overlayOutcome,
                        );
                        final scheduleLabel = _overlayScheduleLabel(
                          _overlayOutcome,
                        );
                        final entranceProgress = _checkOpacityAnimation.value;
                        final addOns =
                            _overlayOutcome?.ticket?.addOns ??
                            const <AccessTicketAddOn>[];

                        final slideProgress = _slideDownAnimation.value;
                        final expandedMargin = math.min(frameSide * 0.12, 26.0);
                        final startRect =
                            _resultExitRect ??
                            (hasPersistentModal
                                ? Rect.fromCenter(
                                    center: Offset(
                                      totalWidth / 2,
                                      topPadding +
                                          (totalHeight -
                                                  topPadding -
                                                  mediaQuery
                                                      .viewPadding
                                                      .bottom) /
                                              2,
                                    ),
                                    width: math.min(totalWidth - 16, 460),
                                    height: math.min(
                                      totalHeight -
                                          topPadding -
                                          mediaQuery.viewPadding.bottom -
                                          32,
                                      680,
                                    ),
                                  )
                                : Rect.fromCenter(
                                    center: scanWindow.center,
                                    width: math.min(
                                      totalWidth - 16,
                                      frameSide + expandedMargin * 2,
                                    ),
                                    height: frameSide + expandedMargin * 2.6,
                                  ));
                        final endWidth = math.min(frameSide * 0.9, 286.0);
                        const endHeight = 138.0;
                        final endRect = Rect.fromLTWH(
                          (totalWidth - endWidth) / 2,
                          totalHeight - _bottomPanelHeight + 20,
                          endWidth,
                          endHeight,
                        );
                        final currentRect = Rect.lerp(
                          startRect,
                          endRect,
                          slideProgress,
                        )!;
                        final opacity =
                            entranceProgress * (1.0 - slideProgress * 0.28);

                        return Positioned.fromRect(
                          rect: currentRect,
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: hasPersistentModal && slideProgress == 0
                                ? Align(
                                    child: _ExtrasScanResultModal(
                                      key: _resultModalKey,
                                      accent: accent,
                                      icon: icon,
                                      headline: headline,
                                      subjectLabel: subjectLabel,
                                      ticketLabel: ticketLabel,
                                      scheduleLabel: scheduleLabel,
                                      ticketStatus:
                                          _overlayOutcome!.ticket!.status,
                                      alreadyUsed:
                                          _overlayOutcome!.resultCode ==
                                          'already_used',
                                      addOns: addOns,
                                      selectedIds: _selectedAddOnIds,
                                      isLoading: _isRedeemingExtras,
                                      errorMessage: _extraValidationError,
                                      requiresValidityDecision:
                                          requiresValidityDecision,
                                      onChanged: (assignmentId, selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedAddOnIds.add(assignmentId);
                                          } else {
                                            _selectedAddOnIds.remove(
                                              assignmentId,
                                            );
                                          }
                                        });
                                      },
                                      onValidate: _validateExtras,
                                      onReject: _finishResultOverlay,
                                    ),
                                  )
                                : _ScanResultOverlayBadge(
                                    accent: accent,
                                    icon: icon,
                                    headline: headline,
                                    subjectLabel: subjectLabel,
                                    ticketLabel: ticketLabel,
                                    tertiaryLabel: scheduleLabel,
                                    collapseProgress: slideProgress,
                                  ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add-ons modal
// ---------------------------------------------------------------------------

class _ExtrasScanResultModal extends StatelessWidget {
  const _ExtrasScanResultModal({
    super.key,
    required this.accent,
    required this.icon,
    required this.headline,
    required this.subjectLabel,
    required this.ticketLabel,
    required this.scheduleLabel,
    required this.ticketStatus,
    required this.alreadyUsed,
    required this.addOns,
    required this.selectedIds,
    required this.isLoading,
    required this.errorMessage,
    required this.requiresValidityDecision,
    required this.onChanged,
    required this.onValidate,
    required this.onReject,
  });

  final Color accent;
  final IconData icon;
  final String headline;
  final String? subjectLabel;
  final String? ticketLabel;
  final String? scheduleLabel;
  final String ticketStatus;
  final bool alreadyUsed;
  final List<AccessTicketAddOn> addOns;
  final Set<String> selectedIds;
  final bool isLoading;
  final String? errorMessage;
  final bool requiresValidityDecision;
  final void Function(String assignmentId, bool selected) onChanged;
  final VoidCallback onValidate;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      bodyColor: AppColors.black,
      displayColor: AppColors.black,
    );
    final hasRemaining = addOns.any((addOn) => addOn.remainingQuantity > 0);
    final canRedeem = ticketStatus == 'issued' || ticketStatus == 'checked_in';
    final primaryButtonStyle = FilledButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.black.withValues(alpha: 0.6),
      disabledForegroundColor: Colors.white70,
      minimumSize: const Size.fromHeight(54),
    );

    return Theme(
      data: theme.copyWith(
        textTheme: textTheme,
        listTileTheme: const ListTileThemeData(
          textColor: AppColors.black,
          iconColor: AppColors.black,
        ),
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: AppColors.black, width: 2),
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.black
                : Colors.transparent,
          ),
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: accent,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(36),
            side: BorderSide(color: accent.withValues(alpha: 0.35)),
          ),
          shadows: [
            BoxShadow(color: accent.withValues(alpha: 0.14), blurRadius: 28),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScanResultHeading(
                icon: icon,
                headline: headline,
                supportingLabel: alreadyUsed && hasRemaining
                    ? 'Puede canjear extras'
                    : null,
                subjectLabel: subjectLabel,
                ticketLabel: ticketLabel,
                scheduleLabel: scheduleLabel,
              ),
              if (addOns.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Canjea los siguientes extras',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      if (!hasRemaining)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No quedan extras.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      for (final addOn in addOns) ...[
                        if (addOn.redeemedQuantity > 0)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.black.withValues(alpha: 0.85),
                            ),
                            title: Text(
                              '${addOn.redeemedQuantity} × ${addOn.displayName}',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.black.withValues(alpha: 0.85),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            subtitle: const Text('Consumido'),
                          ),
                        if (addOn.remainingQuantity > 0)
                          CheckboxListTile(
                            value: selectedIds.contains(addOn.assignmentId),
                            onChanged: isLoading || !canRedeem
                                ? null
                                : (selected) => onChanged(
                                    addOn.assignmentId,
                                    selected ?? false,
                                  ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.black,
                            checkColor: Colors.white,
                            title: Text(
                              '${addOn.remainingQuantity} × ${addOn.displayName}',
                              style: textTheme.bodyLarge,
                            ),
                            subtitle: addOn.description == null
                                ? null
                                : Text(addOn.description!),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (requiresValidityDecision) ...[
                FilledButton.icon(
                  onPressed: isLoading ? null : onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('No validar'),
                  style: primaryButtonStyle,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onValidate,
                  icon: Icon(
                    isLoading ? Icons.hourglass_top : Icons.verified_rounded,
                  ),
                  label: Text(
                    isLoading ? 'Procesando...' : 'Validar de todos modos',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    minimumSize: const Size.fromHeight(54),
                    side: const BorderSide(color: AppColors.black),
                  ),
                ),
              ] else
                FilledButton.icon(
                  style: primaryButtonStyle,
                  label: Text(
                    isLoading
                        ? 'Procesando...'
                        : selectedIds.isEmpty
                        ? 'Cerrar'
                        : 'Canjear extras',
                  ),
                  icon: Icon(
                    isLoading
                        ? Icons.hourglass_top
                        : selectedIds.isEmpty
                        ? Icons.close_rounded
                        : Icons.redeem_rounded,
                  ),
                  onPressed: isLoading ? null : onValidate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom panel showing the last scanned ticket
// ---------------------------------------------------------------------------

class _BottomLastScanPanel extends StatelessWidget {
  const _BottomLastScanPanel({
    required this.lastScan,
    required this.onOpenHistory,
    required this.onTapLastScan,
  });

  final _LastScanInfo? lastScan;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onTapLastScan;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF141011),
        border: Border(top: BorderSide(color: Color(0xFF2A2325), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ÚLTIMO ESCANEADO',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                if (onOpenHistory != null)
                  GestureDetector(
                    onTap: onOpenHistory,
                    child: Text(
                      'Ver todos',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (lastScan != null)
            _buildLastScanRow(context)
          else
            _buildEmpty(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLastScanRow(BuildContext context) {
    final scan = lastScan!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: AccessHistoryListRow(
        titleLabel: scan.titleLabel,
        subtitleLabel: scan.subtitleLabel,
        resultLabel: historyResultLabel(scan.resultCode),
        resultColor: historyResultColor(
          scan.resultCode,
          hasPendingExtras: scan.hasPendingExtras,
        ),
        relativeTimeLabel: formatRelativeTime(scan.createdAt),
        onTap: onTapLastScan,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          'Aún no se ha escaneado ningún ticket',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ScanResultOverlayBadge extends StatelessWidget {
  const _ScanResultOverlayBadge({
    required this.accent,
    required this.icon,
    required this.headline,
    this.subjectLabel,
    this.ticketLabel,
    this.tertiaryLabel,
    required this.collapseProgress,
  });

  final Color accent;
  final IconData icon;
  final String headline;
  final String? subjectLabel;
  final String? ticketLabel;
  final String? tertiaryLabel;
  final double collapseProgress;

  @override
  Widget build(BuildContext context) {
    final collapsed = collapseProgress > 0.55;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: accent,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(44),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: constraints.maxWidth,
            child: _ScanResultHeading(
              icon: icon,
              headline: headline,
              subjectLabel: subjectLabel,
              ticketLabel: ticketLabel,
              scheduleLabel: tertiaryLabel,
              collapsed: collapsed,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanResultHeading extends StatelessWidget {
  const _ScanResultHeading({
    required this.icon,
    required this.headline,
    required this.subjectLabel,
    required this.ticketLabel,
    required this.scheduleLabel,
    this.collapsed = false,
    this.supportingLabel,
  });

  final IconData icon;
  final String headline;
  final String? supportingLabel;
  final String? subjectLabel;
  final String? ticketLabel;
  final String? scheduleLabel;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final focusLabel = ticketLabel ?? subjectLabel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.black),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                headline.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        if (!collapsed && supportingLabel != null) ...[
          const SizedBox(height: 6),
          Text(
            supportingLabel!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.black),
          ),
        ],
        if (focusLabel != null) ...[
          const SizedBox(height: 16),
          Text(
            focusLabel,
            textAlign: TextAlign.center,
            maxLines: collapsed ? 1 : 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.black,
              fontSize: collapsed ? 22 : 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
        if (!collapsed && scheduleLabel != null) ...[
          const SizedBox(height: 12),
          Text(
            scheduleLabel!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (!collapsed && ticketLabel != null && subjectLabel != null) ...[
          const SizedBox(height: 12),
          Text(
            subjectLabel!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.black.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlassyButton extends StatelessWidget {
  const _GlassyButton({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white70),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera error view
// ---------------------------------------------------------------------------

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final message = error.errorDetails?.message ?? error.toString();
    final normalizedMessage = message.toLowerCase();
    final isPermissionIssue =
        normalizedMessage.contains('permission') ||
        normalizedMessage.contains('denied') ||
        normalizedMessage.contains('access denied') ||
        normalizedMessage.contains('not authorized');
    final helperText = isPermissionIssue
        ? 'Activa el acceso a la cámara para Lema Access en los ajustes del sistema y vuelve a intentarlo.'
        : 'Pulsa Reintentar para volver a activar el escáner.';

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: LemaPanel(
        color: AppColors.surfaceLow,
        borderColor: AppColors.error.withValues(alpha: 0.24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'No se pudo abrir la cámara',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              helperText,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceMuted.withValues(alpha: 0.84),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scan overlay painter
// ---------------------------------------------------------------------------

class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter({
    required this.scanWindow,
    required this.bottomPanelHeight,
  });

  final Rect scanWindow;
  final double bottomPanelHeight;

  @override
  void paint(Canvas canvas, Size size) {
    // Darken the entire camera area with a cutout for the scan window
    final backgroundPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(4)));
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.52),
    );

    final cornerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    const cornerLength = 28.0;
    final path = Path()
      ..moveTo(scanWindow.left, scanWindow.top + cornerLength)
      ..lineTo(scanWindow.left, scanWindow.top)
      ..lineTo(scanWindow.left + cornerLength, scanWindow.top)
      ..moveTo(scanWindow.right - cornerLength, scanWindow.top)
      ..lineTo(scanWindow.right, scanWindow.top)
      ..lineTo(scanWindow.right, scanWindow.top + cornerLength)
      ..moveTo(scanWindow.left, scanWindow.bottom - cornerLength)
      ..lineTo(scanWindow.left, scanWindow.bottom)
      ..lineTo(scanWindow.left + cornerLength, scanWindow.bottom)
      ..moveTo(scanWindow.right - cornerLength, scanWindow.bottom)
      ..lineTo(scanWindow.right, scanWindow.bottom)
      ..lineTo(scanWindow.right, scanWindow.bottom - cornerLength);

    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        bottomPanelHeight != oldDelegate.bottomPanelHeight;
  }
}
