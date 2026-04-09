import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/history_controller.dart';
import '../core/scan_input_normalizer.dart';
import '../core/rpc_exception.dart';
import '../models/history_models.dart';
import '../models/ticket_models.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';

/// Shows the recent-history bottom sheet.
///
/// [eventId] scopes the history to a single event.
/// [onOpenTicketDetail] is called after selecting a ticket so the parent can
/// navigate to the ticket detail page.
void showRecentHistoryBottomSheet(
  BuildContext context, {
  String? eventId,
  VoidCallback? onOpenTicketDetail,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RecentHistorySheet(
      eventId: eventId,
      onOpenTicketDetail: onOpenTicketDetail,
    ),
  );
}

// ---------------------------------------------------------------------------
// Bottom-sheet wrapper
// ---------------------------------------------------------------------------

class _RecentHistorySheet extends ConsumerStatefulWidget {
  const _RecentHistorySheet({this.eventId, this.onOpenTicketDetail});

  final String? eventId;
  final VoidCallback? onOpenTicketDetail;

  @override
  ConsumerState<_RecentHistorySheet> createState() =>
      _RecentHistorySheetState();
}

class _RecentHistorySheetState extends ConsumerState<_RecentHistorySheet> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter > 280) {
      return;
    }

    ref
        .read(accessHistoryControllerProvider(widget.eventId).notifier)
        .loadMore();
  }

  Future<void> _refresh() async {
    try {
      final _ = await ref.refresh(
        accessHistoryControllerProvider(widget.eventId).future,
      );
    } catch (_) {
      // The provider already surfaces the error state.
    }
  }

  void _openTicketDetail(AccessHistoryEntry item) {
    final ticket = item.ticket;
    if (ticket == null) {
      return;
    }

    ref
        .read(accessSelectedTicketProvider.notifier)
        .state = AccessTicketSelection(
      eventId: ticket.eventId,
      ticketId: ticket.id,
      query: _ticketReferenceLabel(item),
      matchReason: TicketSearchMatchReason.other,
      ticket: _mapHistoryTicket(ticket),
      contextLabel: _sourceLabel(item.source),
    );
    ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;

    // Close bottom sheet first, then navigate.
    Navigator.of(context).pop();
    widget.onOpenTicketDetail?.call();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      accessHistoryControllerProvider(widget.eventId),
    );
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, sheetScrollController) {
        // We wire the sheet's scroll controller to our own internal one
        // for the pagination logic. The DraggableScrollableSheet provides
        // its own controller, but we need to drive both the sheet drag
        // AND the list scroll with it, so we use NotificationListener.
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: Color(0xFF2A2325),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              _DragHandle(),

              // Content
              Expanded(
                child: historyAsync.when(
                  loading: () => const _LoadingState(),
                  error: (error, _) =>
                      _ErrorState(error: error, onRetry: _refresh),
                  data: (state) => _HistoryList(
                    state: state,
                    eventId: widget.eventId,
                    scrollController: sheetScrollController,
                    onRefresh: _refresh,
                    onOpenTicketDetail: _openTicketDetail,
                    onLoadMore: () => ref
                        .read(
                          accessHistoryControllerProvider(
                            widget.eventId,
                          ).notifier,
                        )
                        .loadMore(),
                    bottomPadding: bottomPadding,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.onSurfaceMuted.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// History list (scrollable with pagination)
// ---------------------------------------------------------------------------

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.state,
    required this.eventId,
    required this.scrollController,
    required this.onRefresh,
    required this.onOpenTicketDetail,
    required this.onLoadMore,
    required this.bottomPadding,
  });

  final AccessHistoryState state;
  final String? eventId;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(AccessHistoryEntry) onOpenTicketDetail;
  final VoidCallback onLoadMore;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          if (metrics.extentAfter < 280 &&
              state.hasMore &&
              !state.isLoadingMore) {
            onLoadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: _Header(
                  eventId: eventId,
                  totalCount: state.totalCount,
                  summary: state.summary,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // Items
            if (state.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyHistoryState(
                    eventId: eventId,
                    onRefresh: onRefresh,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = state.items[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == state.items.length - 1 ? 0 : 10,
                        ),
                        child: _HistoryCard(
                          item: item,
                          onTap: item.ticket != null
                              ? () => onOpenTicketDetail(item)
                              : null,
                        ),
                      );
                    },
                    childCount: state.items.length,
                  ),
                ),
              ),

            // Inline loading indicator (for pagination)
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),

            // Bottom safe area spacer
            SliverToBoxAdapter(
              child: SizedBox(height: 24 + bottomPadding),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: map ticket for detail navigation
// ---------------------------------------------------------------------------

AccessTicketSnapshot _mapHistoryTicket(AccessHistoryTicketSnapshot ticket) {
  return AccessTicketSnapshot(
    id: ticket.id,
    eventId: ticket.eventId,
    code: ticket.code,
    status: ticket.status,
    canCheckIn: ticket.canCheckIn,
    ticketType: AccessTicketType(
      id: ticket.ticketType.id,
      name: ticket.ticketType.name,
      description: ticket.ticketType.description,
    ),
    attendee: AccessTicketAttendee(
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
        : AccessTicketBuyer(
            id: ticket.buyer!.id,
            fullName: ticket.buyer!.fullName,
            email: ticket.buyer!.email,
            phone: ticket.buyer!.phone,
          ),
    order: AccessTicketOrder(
      id: ticket.order.id,
      status: ticket.order.status,
      currency: ticket.order.currency,
      paidAt: ticket.order.paidAt,
    ),
    issuedAt: ticket.issuedAt,
    checkedInAt: ticket.checkedInAt,
    updatedAt: ticket.updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.eventId,
    required this.totalCount,
    required this.summary,
  });

  final String? eventId;
  final int totalCount;
  final AccessHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HISTORIAL',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          eventId == null ? 'Sin evento activo' : 'Actividad reciente',
          style: textTheme.displayMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          eventId == null
              ? 'Conecta un evento para ver registros.'
              : '$totalCount registros · ${summary.validCount} válidos · ${summary.incidentCount} incidencias',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// History card
// ---------------------------------------------------------------------------

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, this.onTap});

  final AccessHistoryEntry item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = _toneForResultCode(item.resultCode);
    final textTheme = Theme.of(context).textTheme;
    final ticket = item.ticket;
    final attendeeName =
        ticket?.attendee.fullName ?? item.actor.displayName ?? 'Sin asistente';
    final ticketType = ticket?.ticketType.name ?? 'Sin tipo de entrada';
    final code = _ticketReferenceLabel(item);

    return LemaStatusStripCard(
      accent: tone.accent,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendeeName,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticketType,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _sourceLabel(item.source),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatRelativeTime(item.createdAt),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              LemaStatusPill(label: tone.label, color: tone.accent),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ticket reference label
// ---------------------------------------------------------------------------

String _ticketReferenceLabel(AccessHistoryEntry item) {
  final ticketCode = item.ticket?.code.trim();
  if (ticketCode != null && ticketCode.isNotEmpty) {
    return ticketCode;
  }

  final relatedCode = item.relatedTicketCode?.trim();
  if (relatedCode != null && relatedCode.isNotEmpty) {
    return 'CODE: $relatedCode';
  }

  final token =
      item.extractedScanToken?.trim() ??
      extractLemaTicketToken(item.rawInput ?? '')?.trim();
  if (token != null && token.isNotEmpty) {
    return 'TOKEN: $token';
  }

  final normalizedInput = item.normalizedInput?.trim();
  if (normalizedInput != null && normalizedInput.isNotEmpty) {
    return normalizedInput;
  }

  final rawInput = item.rawInput?.trim();
  if (rawInput != null && rawInput.isNotEmpty) {
    return rawInput;
  }

  return 'Sin código';
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({required this.eventId, required this.onRefresh});

  final String? eventId;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventId == null ? 'Sin evento activo' : 'Sin actividad reciente',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            eventId == null
                ? 'Selecciona un evento antes de abrir el historial.'
                : 'Todavía no hay accesos registrados para este evento.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading state
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando historial...',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final message = error is AccessRpcException
        ? (error as AccessRpcException).message
        : 'No se pudo cargar el historial.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: LemaPanel(
          color: AppColors.surfaceLow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Error al leer el historial', style: textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tone / styling helpers
// ---------------------------------------------------------------------------

_HistoryTone _toneForResultCode(String resultCode) {
  switch (resultCode) {
    case 'valid':
      return const _HistoryTone(
        label: 'Válido',
        accent: AppColors.success,
        icon: Icons.check_circle_rounded,
      );
    case 'already_used':
      return const _HistoryTone(
        label: 'Ya usado',
        accent: AppColors.warning,
        icon: Icons.history_toggle_off_rounded,
      );
    case 'wrong_event':
      return const _HistoryTone(
        label: 'Evento incorrecto',
        accent: AppColors.error,
        icon: Icons.swap_horiz_rounded,
      );
    case 'cancelled_or_invalid':
      return const _HistoryTone(
        label: 'Inválido',
        accent: AppColors.error,
        icon: Icons.block_rounded,
      );
    case 'not_found':
      return const _HistoryTone(
        label: 'No encontrado',
        accent: Color(0xFF9CA3AF),
        icon: Icons.search_off_rounded,
      );
    case 'forbidden':
      return const _HistoryTone(
        label: 'Sin permiso',
        accent: AppColors.primaryStrong,
        icon: Icons.lock_outline,
      );
    case 'temporary_error':
      return const _HistoryTone(
        label: 'Error temporal',
        accent: AppColors.warning,
        icon: Icons.cloud_off_rounded,
      );
    default:
      return const _HistoryTone(
        label: 'Desconocido',
        accent: AppColors.onSurfaceMuted,
        icon: Icons.help_outline_rounded,
      );
  }
}

String _sourceLabel(String source) {
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
      return source;
  }
}

String _formatRelativeTime(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt.toLocal());
  if (difference.inMinutes < 1) {
    return 'Ahora';
  }
  if (difference.inHours < 1) {
    return 'Hace ${difference.inMinutes} min';
  }
  if (difference.inDays < 1) {
    return 'Hace ${difference.inHours} h';
  }
  return 'Hace ${difference.inDays} d';
}

class _HistoryTone {
  const _HistoryTone({
    required this.label,
    required this.accent,
    required this.icon,
  });

  final String label;
  final Color accent;
  final IconData icon;
}
