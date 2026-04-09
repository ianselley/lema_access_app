import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rpc_exception.dart';
import '../models/ticket_models.dart';
import '../providers/event_providers.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key, this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final eventId = ref.watch(accessCurrentEventIdProvider);
    final query = ref.watch(accessManualSearchQueryProvider).trim();
    final hasEventContext = eventId != null && eventId.trim().isNotEmpty;
    final hasQuery = query.isNotEmpty;

    return LemaScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accessTicketSearchResultsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESULTADOS',
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text('Búsqueda manual', style: textTheme.displayMedium),
              const SizedBox(height: 8),
              if (!hasEventContext || !hasQuery)
                _ContextNotice(
                  title: !hasEventContext
                      ? 'Falta evento activo'
                      : 'Falta consulta',
                  message: !hasEventContext
                      ? 'Selecciona un evento antes de abrir resultados.'
                      : 'Introduce una consulta para continuar.',
                  accent: AppColors.warning,
                )
              else
                _ResultsContent(
                  query: query,
                  onOpenTicketDetail: onOpenTicketDetail,
                ),
              const OperatorShellBottomSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsContent extends ConsumerWidget {
  const _ResultsContent({
    required this.query,
    required this.onOpenTicketDetail,
  });

  final String query;
  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(accessTicketSearchResultsProvider);

    return resultsAsync.when(
      loading: () => const _LoadingPanel(),
      error: (error, stackTrace) => _ErrorPanel(error: error),
      data: (page) {
        if (page.items.isEmpty) {
          return _EmptyResultsPanel(query: query);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LemaPanel(
              color: AppColors.backgroundAlt,
              padding: const EdgeInsets.all(18),
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              child: Text(
                '$query · ${page.totalCount} coincidencias',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                for (var index = 0; index < page.items.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == page.items.length - 1 ? 0 : 10,
                    ),
                    child: _ResultCard(
                      item: page.items[index],
                      onTap: () {
                        final selection = AccessTicketSelection(
                          eventId: ref.read(accessCurrentEventIdProvider)!,
                          ticketId: page.items[index].ticket.id,
                          query: query,
                          matchReason: page.items[index].matchReason,
                          ticket: page.items[index].ticket,
                        );
                        ref.read(accessSelectedTicketProvider.notifier).state =
                            selection;
                        ref
                                .read(
                                  accessLatestCheckInOutcomeProvider.notifier,
                                )
                                .state =
                            null;
                        onOpenTicketDetail?.call();
                      },
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ContextNotice extends StatelessWidget {
  const _ContextNotice({
    required this.title,
    required this.message,
    required this.accent,
  });

  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: accent.withValues(alpha: 0.08),
      borderColor: accent.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const LemaPanel(
      color: AppColors.surfaceLow,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AccessRpcException? rpcError = error is AccessRpcException
        ? error as AccessRpcException
        : null;
    final message = rpcError?.message ?? error.toString();

    return LemaPanel(
      color: AppColors.error.withValues(alpha: 0.08),
      borderColor: AppColors.error.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No se pudo cargar la búsqueda', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultsPanel extends StatelessWidget {
  const _EmptyResultsPanel({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sin coincidencias', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'No hay tickets que coincidan con "$query".',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item, required this.onTap});

  final AccessTicketSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _ticketStatusPresentation(item.ticket.status);

    return LemaStatusStripCard(
      accent: status.accent,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ticket.attendee.fullName ?? 'Sin nombre',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.ticket.ticketType.name ?? 'Tipo de ticket'} · ${item.ticket.code}',
                  style: textTheme.bodyMedium?.copyWith(
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
              LemaStatusPill(label: status.label, color: status.accent),
              const SizedBox(height: 8),
              Text(
                item.matchReason.label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketStatusPresentation {
  const _TicketStatusPresentation({required this.label, required this.accent});

  final String label;
  final Color accent;
}

_TicketStatusPresentation _ticketStatusPresentation(String status) {
  switch (status) {
    case 'issued':
      return const _TicketStatusPresentation(
        label: 'Pendiente',
        accent: AppColors.warning,
      );
    case 'checked_in':
      return const _TicketStatusPresentation(
        label: 'Usado',
        accent: AppColors.success,
      );
    case 'cancelled':
    case 'voided':
      return const _TicketStatusPresentation(
        label: 'Cancelado',
        accent: AppColors.error,
      );
    default:
      return const _TicketStatusPresentation(
        label: 'Desconocido',
        accent: AppColors.onSurfaceMuted,
      );
  }
}
