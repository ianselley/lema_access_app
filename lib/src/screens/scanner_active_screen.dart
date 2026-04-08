import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ScannerActiveScreen extends ConsumerStatefulWidget {
  const ScannerActiveScreen({
    super.key,
    this.onOpenValid,
    this.onOpenUsed,
    this.onOpenInvalid,
    this.onOpenNotFound,
    this.onOpenNetworkError,
    this.onShowResult,
    this.onManualEntry,
    this.onManualSearch,
  });

  final VoidCallback? onOpenValid;
  final VoidCallback? onOpenUsed;
  final VoidCallback? onOpenInvalid;
  final VoidCallback? onOpenNotFound;
  final VoidCallback? onOpenNetworkError;
  final VoidCallback? onShowResult;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  ConsumerState<ScannerActiveScreen> createState() =>
      _ScannerActiveScreenState();
}

class _ScannerActiveScreenState extends ConsumerState<ScannerActiveScreen> {
  final TextEditingController _scanController = TextEditingController();

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _submitScan() async {
    final rawInput = _scanController.text.trim();
    if (rawInput.isEmpty) {
      return;
    }

    final outcome = await ref
        .read(accessScanControllerProvider.notifier)
        .submitScanInput(rawInput);

    if (!mounted || outcome == null) {
      return;
    }

    switch (outcome.resultCode) {
      case 'valid':
        widget.onOpenValid?.call();
        break;
      case 'already_used':
        widget.onOpenUsed?.call();
        break;
      case 'not_found':
        widget.onOpenNotFound?.call();
        break;
      case 'temporary_error':
        widget.onOpenNetworkError?.call();
        break;
      case 'wrong_event':
      case 'cancelled_or_invalid':
      case 'forbidden':
        widget.onOpenInvalid?.call();
        break;
      default:
        widget.onShowResult?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessScanControllerProvider);
    final isProcessing = state is AccessScanProcessing;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScannerHeader(
              eventName: _eventNameFromState(state),
              operatorLabel: _operatorLabelForState(state),
            ),
            const SizedBox(height: 20),
            const _ScannerViewport(),
            const SizedBox(height: 18),
            _ScanInputCard(
              controller: _scanController,
              isProcessing: isProcessing,
              onSubmit: _submitScan,
              onManualEntry: widget.onManualEntry,
              onManualSearch: widget.onManualSearch,
            ),
            const SizedBox(height: 16),
            _ScanOutcomeCard(state: state),
            if (state is AccessScanFailure) ...[
              const SizedBox(height: 16),
              _FailureBanner(failure: state.failure),
            ],
            const OperatorShellBottomSpacer(),
          ],
        ),
      ),
    );
  }

  String _eventNameFromState(AccessScanState state) {
    return 'Evento activo';
  }

  String _operatorLabelForState(AccessScanState state) {
    return switch (state) {
      AccessScanProcessing(:final label) => label,
      AccessScanSuccess(:final outcome) =>
        outcome.stage == AccessScanStage.preview
            ? 'Revisión manual'
            : 'Validación registrada',
      AccessScanFailure() => 'Revisar conexión',
      _ => 'Operador LEMA',
    };
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader({required this.eventName, required this.operatorLabel});

  final String eventName;
  final String operatorLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESCÁNER ACTIVO',
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(eventName, style: textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                operatorLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _NetworkBadge(),
      ],
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  const _NetworkBadge();

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surfaceLow,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Conectado',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

class _ScannerViewport extends StatelessWidget {
  const _ScannerViewport();

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceLow,
      child: AspectRatio(
        aspectRatio: 1.18,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(10),
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0x22EF8354), AppColors.backgroundAlt],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.26),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _ScannerCorners(),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.08),
                              border: Border.all(
                                color: AppColors.primaryStrong.withValues(
                                  alpha: 0.55,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Alinea el código',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: _ScanLine(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _ScannerCornerPainter()),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryStrong.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const corner = 26.0;
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, corner)
      ..moveTo(0, size.height - corner)
      ..lineTo(0, size.height)
      ..lineTo(corner, size.height)
      ..moveTo(size.width - corner, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStrong.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _ScanInputCard extends StatelessWidget {
  const _ScanInputCard({
    required this.controller,
    required this.isProcessing,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onManualSearch,
  });

  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onSubmit;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceHighest,
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Introducir lectura',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.4,
            ),
            decoration: const InputDecoration(
              labelText: 'Lectura',
              hintText: 'LEMA-4831 o scan token',
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 14),
          LemaPrimaryButton(
            label: isProcessing ? 'Procesando...' : 'Validar lectura',
            icon: isProcessing ? Icons.timelapse : Icons.check_circle_outline,
            onPressed: isProcessing ? null : onSubmit,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onManualEntry,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Manual'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onManualSearch,
                  icon: const Icon(Icons.manage_search_rounded),
                  label: const Text('Buscar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanOutcomeCard extends StatelessWidget {
  const _ScanOutcomeCard({required this.state});

  final AccessScanState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (state is AccessScanIdle) {
      return LemaPanel(
        color: AppColors.surfaceLow,
        child: Text(
          'Listo para la siguiente lectura.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      );
    }

    if (state is AccessScanProcessing) {
      final processing = state as AccessScanProcessing;
      return LemaPanel(
        color: AppColors.surfaceLow,
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${processing.label}: ${processing.rawInput}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is AccessScanFailure) {
      final failure = state as AccessScanFailure;
      return LemaPanel(
        color: AppColors.surfaceLow,
        borderColor: AppColors.error.withValues(alpha: 0.32),
        child: Text(
          failure.failure.message,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      );
    }

    final success = state as AccessScanSuccess;
    final outcome = success.outcome;
    final tone = _toneForVariant(outcome.uiVariant);

    return LemaStatusStripCard(
      accent: tone.$1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.headline,
                      style: textTheme.headlineMedium?.copyWith(color: tone.$1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      outcome.body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(tone.$2, color: tone.$1),
            ],
          ),
          if (outcome.ticket != null) ...[
            const SizedBox(height: 12),
            _TicketSummary(ticket: outcome.ticket!),
          ],
        ],
      ),
    );
  }

  (Color, IconData) _toneForVariant(AccessScanUiVariant variant) {
    switch (variant) {
      case AccessScanUiVariant.valid:
        return (AppColors.success, Icons.check_circle);
      case AccessScanUiVariant.used:
        return (AppColors.warning, Icons.history_toggle_off);
      case AccessScanUiVariant.invalid:
        return (AppColors.error, Icons.block);
      case AccessScanUiVariant.notFound:
        return (const Color(0xFF9CA3AF), Icons.search_off);
      case AccessScanUiVariant.networkError:
        return (AppColors.error, Icons.wifi_off);
    }
  }
}

class _TicketSummary extends StatelessWidget {
  const _TicketSummary({required this.ticket});

  final AccessTicketSnapshot ticket;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '${ticket.displayName} · ${ticket.ticketTypeLabel} · ${ticket.code}',
      style: textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceMuted),
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.failure});

  final AccessScanFailureInfo failure;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      borderColor: AppColors.error.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failure.code,
            style: textTheme.titleLarge?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            failure.message,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
