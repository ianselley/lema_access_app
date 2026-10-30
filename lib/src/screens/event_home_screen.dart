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
import 'search_results_screen.dart';

class EventHomeScreen extends ConsumerWidget {
  const EventHomeScreen({
    super.key,
    required this.eventId,
    this.onOpenScanner,
    this.onOpenSearch,
    this.onOpenTicketDetail,
    this.bottomOverlay,
  });

  final String eventId;
  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenSearch;
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
                  ref.invalidate(accessRecentEventTicketsProvider(eventId));
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
                        eventSchedule: home.scheduleLabel,
                        statusLabel: home.statusLabel,
                        checkedInCount: home.counters.checkedInCount,
                        soldCount: home.counters.soldCount,
                        capacityTotal: home.counters.capacityTotal,
                        showCurrentOccupancy: home.canViewCurrentOccupancy,
                      ),
                      const SizedBox(height: 24),
                      if (home.canViewCurrentOccupancy) ...[
                        _RecentTicketsSection(
                          eventId: eventId,
                          onOpenSearch: onOpenSearch,
                          onOpenTicketDetail: onOpenTicketDetail,
                        ),
                        const SizedBox(height: 24),
                      ],
                      LemaSectionHeading(
                        kicker: 'Actividad',
                        title: 'Últimos accesos',
                        trailing: TextButton(
                          onPressed: () => showRecentHistoryBottomSheet(
                            context,
                            eventId: eventId,
                            showOccupancy: home.canViewCurrentOccupancy,
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

class _RecentTicketsSection extends ConsumerWidget {
  const _RecentTicketsSection({
    required this.eventId,
    required this.onOpenSearch,
    required this.onOpenTicketDetail,
  });

  final String eventId;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(accessRecentEventTicketsProvider(eventId));
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LemaSectionHeading(
          kicker: 'Entradas',
          title: 'Últimos tickets',
          trailing: TextButton(
            onPressed: onOpenSearch == null
                ? null
                : () {
                    ref.read(accessManualSearchQueryProvider.notifier).state =
                        '';
                    onOpenSearch!();
                  },
            child: const Text('Ver más >'),
          ),
        ),
        const SizedBox(height: 14),
        recent.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
          error: (error, stackTrace) => TextButton(
            onPressed: () =>
                ref.invalidate(accessRecentEventTicketsProvider(eventId)),
            child: const Text('No se pudieron cargar los tickets. Reintentar'),
          ),
          data: (pages) {
            final vip = pages.vip.items;
            final normal = pages.normal.items;
            if (vip.isEmpty && normal.isEmpty) {
              return Text(
                'Todavía no hay tickets.',
                style: textTheme.bodyMedium,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vip.isNotEmpty) ...[
                  Text('VIP', style: textTheme.titleLarge),
                  const SizedBox(height: 10),
                  for (final item in vip.take(3)) ...[
                    AccessTicketResultCard(
                      item: item,
                      onTap: () => _openRecentTicket(
                        ref,
                        eventId,
                        item,
                        onOpenTicketDetail,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                if (normal.isNotEmpty) ...[
                  Text('Entradas', style: textTheme.titleLarge),
                  const SizedBox(height: 10),
                  for (final item in normal.take(3)) ...[
                    AccessTicketResultCard(
                      item: item,
                      onTap: () => _openRecentTicket(
                        ref,
                        eventId,
                        item,
                        onOpenTicketDetail,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

void _openRecentTicket(
  WidgetRef ref,
  String eventId,
  tm.AccessTicketSearchItem item,
  VoidCallback? onOpenTicketDetail,
) {
  ref
      .read(accessSelectedTicketProvider.notifier)
      .state = tm.AccessTicketSelection(
    eventId: eventId,
    ticketId: item.ticket.id,
    query: '',
    matchReason: item.matchReason,
    ticket: item.ticket,
    contextLabel: 'Últimos tickets',
  );
  ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
  onOpenTicketDetail?.call();
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
    required this.eventSchedule,
    required this.statusLabel,
    required this.checkedInCount,
    required this.soldCount,
    required this.capacityTotal,
    required this.showCurrentOccupancy,
  });

  final String eventName;
  final String eventLocation;
  final String? eventSchedule;
  final String statusLabel;
  final int checkedInCount;
  final int soldCount;
  final int capacityTotal;
  final bool showCurrentOccupancy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = soldCount > 0 ? checkedInCount / soldCount : 0.0;
    final unsoldCount = capacityTotal > soldCount
        ? capacityTotal - soldCount
        : 0;

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
                child: Text(
                  eventName,
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LemaStatusPill(
                label: statusLabel,
                color: AppColors.primaryStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            eventLocation,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          if (eventSchedule != null) ...[
            const SizedBox(height: 4),
            Text(
              eventSchedule!,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
            ),
          ],
          if (showCurrentOccupancy) ...[
            const SizedBox(height: 18),
            Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text('Entradas escaneadas', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$checkedInCount',
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: ' de $soldCount vendidas'),
                  TextSpan(
                    text: ' · ${(progress * 100).round()}%',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            LemaProgressBar(
              value: progress,
              color: AppColors.primaryStrong,
              background: AppColors.surfaceHigh,
            ),
            if (capacityTotal > 0) ...[
              const SizedBox(height: 10),
              Text(
                unsoldCount == 0
                    ? 'SOLD OUT!'
                    : '$unsoldCount ${unsoldCount == 1 ? 'entrada sin vender' : 'entradas sin vender'}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
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
