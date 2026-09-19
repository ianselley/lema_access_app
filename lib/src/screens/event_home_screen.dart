import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/failure.dart';
import '../models/event_models.dart';
import '../models/ticket_models.dart' as tm;
import '../providers/event_providers.dart';
import '../providers/ticket_providers.dart';
import '../screens/event_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import 'history_scan_result_screen.dart';
import 'recent_history_screen.dart';

class EventHomeScreen extends ConsumerWidget {
  const EventHomeScreen({
    super.key,
    required this.eventId,
    this.onOpenScanner,
    this.onOpenTicketDetail,
    this.bottomOverlay,
  });

  final String eventId;
  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenTicketDetail;
  final Widget? bottomOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventId.trim().isEmpty) {
      return LemaScaffold(
        body: _MissingEventState(onOpenScanner: onOpenScanner),
      );
    }

    final asyncHome = ref.watch(accessEventHomeProvider(eventId));

    return asyncHome.when(
      loading: () => const LemaScaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stackTrace) => LemaScaffold(
        body: _EventHomeErrorState(
          error: error,
          onRetry: () => ref.invalidate(accessEventHomeProvider(eventId)),
        ),
      ),
      data: (home) {
        final history = home.recentHistoryPreview.take(5).toList();

        return LemaScaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(accessEventHomeProvider(eventId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopHero(
                        eventName: home.displayName,
                        eventLocation: home.locationLabel,
                        membershipLabel: home.membershipLabel,
                        statusLabel: home.statusLabel,
                        progressLabel: home.progressLabel,
                        capacityLabel: home.capacityLabel,
                        checkedInCount: home.counters.checkedInCount,
                        pendingCount: home.counters.pendingCheckInCount,
                        progress: home.progress,
                        showCurrentOccupancy: home.canViewCurrentOccupancy,
                      ),
                      const SizedBox(height: 24),
                      LemaSectionHeading(
                        kicker: 'Actividad',
                        title: 'Últimos accesos',
                        trailing: TextButton(
                          onPressed: () => showRecentHistoryBottomSheet(
                            context,
                            eventId: eventId,
                            onOpenTicketDetail: onOpenTicketDetail,
                          ),
                          child: const Text('Ver todo >'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (history.isEmpty)
                        const _EmptyHistoryState()
                      else
                        Column(
                          children: [
                            for (var index = 0; index < history.length; index++)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == history.length - 1 ? 0 : 10,
                                ),
                                child: AccessHistoryListRow(
                                  titleLabel: history[index].titleLabel,
                                  subtitleLabel: history[index].subtitleLabel,
                                  detailLabels: history[index].detailLabels,
                                  resultLabel: history[index].resultLabel,
                                  resultColor: history[index].resultColor,
                                  relativeTimeLabel:
                                      history[index].relativeTimeLabel,
                                  onTap: () => _openHistoryEntry(
                                    context,
                                    ref,
                                    history[index],
                                    onOpenTicketDetail,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),
              ?bottomOverlay,
            ],
          ),
        );
      },
    );
  }
}

void _openHistoryEntry(
  BuildContext context,
  WidgetRef ref,
  AccessHistoryItem item,
  VoidCallback? onOpen,
) {
  if (historyResultNeedsExplanation(item.resultCode)) {
    openHistoryScanResultScreen(
      context,
      snapshot: HistoryScanResultSnapshot.fromEventHistoryItem(item),
    );
    return;
  }

  final ticket = item.ticket;
  if (ticket == null) return;

  ref
      .read(accessSelectedTicketProvider.notifier)
      .state = tm.AccessTicketSelection(
    eventId: ticket.eventId,
    ticketId: ticket.id,
    query: ticket.code ?? item.normalizedInput ?? item.rawInput ?? 'Sin código',
    matchReason: tm.TicketSearchMatchReason.other,
    ticket: _mapEventToDetailTicket(ticket),
    contextLabel: _sourceLabel(item.source),
  );
  ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
  onOpen?.call();
}

tm.AccessTicketSnapshot _mapEventToDetailTicket(AccessTicketSnapshot ticket) {
  return tm.AccessTicketSnapshot(
    id: ticket.id,
    eventId: ticket.eventId,
    code: ticket.code ?? '',
    status: ticket.status,
    canCheckIn: ticket.canCheckIn,
    ticketType: tm.AccessTicketType(
      id: ticket.ticketType.id,
      name: ticket.ticketType.name,
      description: ticket.ticketType.description,
    ),
    attendee: tm.AccessTicketAttendee(
      id: ticket.attendee.id,
      fullName: ticket.attendee.fullName,
      email: ticket.attendee.email,
      phone: ticket.attendee.phone,
      birthDate: ticket.attendee.birthDate,
      documentId: ticket.attendee.documentId,
      isOrderBuyer: ticket.attendee.isOrderBuyer ?? false,
    ),
    buyer: ticket.buyer == null
        ? null
        : tm.AccessTicketBuyer(
            id: ticket.buyer!.id,
            fullName: ticket.buyer!.fullName,
            email: ticket.buyer!.email,
            phone: ticket.buyer!.phone,
          ),
    order: tm.AccessTicketOrder(
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
      return 'Otra fuente';
  }
}

class _TopHero extends StatelessWidget {
  const _TopHero({
    required this.eventName,
    required this.eventLocation,
    required this.membershipLabel,
    required this.statusLabel,
    required this.progressLabel,
    required this.capacityLabel,
    required this.checkedInCount,
    required this.pendingCount,
    required this.progress,
    required this.showCurrentOccupancy,
  });

  final String eventName;
  final String eventLocation;
  final String membershipLabel;
  final String statusLabel;
  final String progressLabel;
  final String capacityLabel;
  final int checkedInCount;
  final int pendingCount;
  final double progress;
  final bool showCurrentOccupancy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: const EdgeInsets.all(18),
      color: AppColors.backgroundAlt,
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
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
                      'EVENTO ACTIVO',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      eventName,
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventLocation,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              LemaStatusPill(
                label: statusLabel,
                color: AppColors.primaryStrong,
              ),
              LemaTag(
                label: membershipLabel,
                color: AppColors.surfaceHigh,
                textColor: AppColors.onSurface,
              ),
            ],
          ),
          if (showCurrentOccupancy) ...[
            const SizedBox(height: 18),
            Text(
              progressLabel,
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            LemaProgressBar(
              value: progress,
              color: AppColors.primaryStrong,
              background: AppColors.backgroundAlt,
            ),
            const SizedBox(height: 12),
            Text(
              '$checkedInCount accesos validados · $pendingCount pendientes · $capacityLabel',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Text(
        'Todavía no hay actividad reciente para este evento.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
      ),
    );
  }
}

class _MissingEventState extends StatelessWidget {
  const _MissingEventState({this.onOpenScanner});

  final VoidCallback? onOpenScanner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: LemaPanel(
        color: AppColors.surfaceLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona un evento', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Necesitas un evento activo antes de abrir este panel.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            if (onOpenScanner != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (onOpenScanner != null)
                    OutlinedButton.icon(
                      onPressed: onOpenScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escáner'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventHomeErrorState extends StatelessWidget {
  const _EventHomeErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accessFailure = error is AccessFailure
        ? error as AccessFailure
        : null;
    final message =
        accessFailure?.displayMessage ??
        'No se pudo cargar el home del evento.';

    return Center(
      child: LemaPanel(
        color: AppColors.surfaceLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error de evento', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
