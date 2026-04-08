import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/core/access_rpc_exception.dart';
import '../access/history/access_history_controller.dart';
import '../access/history/access_history_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class RecentHistoryScreen extends ConsumerStatefulWidget {
  const RecentHistoryScreen({super.key, this.eventId, this.onOpenTicketDetail});

  final String? eventId;
  final VoidCallback? onOpenTicketDetail;

  @override
  ConsumerState<RecentHistoryScreen> createState() =>
      _RecentHistoryScreenState();
}

class _RecentHistoryScreenState extends ConsumerState<RecentHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      accessHistoryControllerProvider(widget.eventId),
    );
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: historyAsync.when(
        loading: () => _LoadingState(textTheme: textTheme),
        error: (error, stackTrace) =>
            _ErrorState(error: error, onRetry: _refresh),
        data: (state) => RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  eventId: widget.eventId,
                  totalCount: state.totalCount,
                  summary: state.summary,
                  onRefresh: _refresh,
                ),
                const SizedBox(height: 22),
                if (state.items.isEmpty)
                  _EmptyHistoryState(
                    eventId: widget.eventId,
                    onRefresh: _refresh,
                  )
                else
                  Column(
                    children: [
                      for (var index = 0; index < state.items.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == state.items.length - 1 ? 0 : 10,
                          ),
                          child: _HistoryCard(
                            item: state.items[index],
                            onTap: state.items[index].ticket != null
                                ? widget.onOpenTicketDetail
                                : null,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (state.hasMore)
                  _LoadMoreButton(
                    isLoadingMore: state.isLoadingMore,
                    onPressed: ref
                        .read(
                          accessHistoryControllerProvider(
                            widget.eventId,
                          ).notifier,
                        )
                        .loadMore,
                  ),
                if (state.isLoadingMore) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
                const OperatorShellBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.eventId,
    required this.totalCount,
    required this.summary,
    required this.onRefresh,
  });

  final String? eventId;
  final int totalCount;
  final AccessHistorySummary summary;
  final Future<void> Function() onRefresh;

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
                      'HISTORIAL',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventId == null
                          ? 'Sin evento activo'
                          : 'Actividad reciente',
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventId == null
                          ? 'Conecta un evento para ver registros.'
                          : '$totalCount registros · ${summary.validCount} válidos · ${summary.incidentCount} incidencias',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar historial',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    final code =
        ticket?.code ?? item.normalizedInput ?? item.rawInput ?? 'Sin código';

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
                  '$ticketType · $code',
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

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.isLoadingMore, required this.onPressed});

  final bool isLoadingMore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoadingMore ? null : onPressed,
      icon: const Icon(Icons.expand_more_rounded),
      label: Text(isLoadingMore ? 'Cargando...' : 'Cargar más'),
    );
  }
}

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

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
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
        padding: const EdgeInsets.only(top: 72),
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
