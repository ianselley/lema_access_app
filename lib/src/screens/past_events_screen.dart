import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/debug_log.dart';
import '../models/event_models.dart';
import '../providers/event_providers.dart';
import '../screens/event_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class PastEventsScreen extends ConsumerWidget {
  const PastEventsScreen({super.key, this.onOpenEvent});

  final ValueChanged<String>? onOpenEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final asyncEvents = ref.watch(accessEventsProvider);

    return asyncEvents.when(
      loading: () => const LemaScaffold(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stackTrace) {
        accessLog(
          'Past events error: $error',
          scope: 'events',
          error: error,
          stackTrace: stackTrace,
        );

        return LemaScaffold(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LemaPanel(
                color: AppColors.surfaceHighest,
                borderColor: AppColors.error.withValues(alpha: 0.28),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'No se pudieron cargar los eventos pasados',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      error.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => ref.invalidate(accessEventsProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      data: (events) {
        final finishedEvents = events
            .where((event) => event.isFinished)
            .toList(growable: false);

        accessLog(
          'Past events rendered with ${finishedEvents.length} finished events',
          scope: 'events',
        );

        return LemaScaffold(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(accessEventsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERFIL',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Eventos pasados', style: textTheme.displayMedium),
                      const SizedBox(height: 8),
                      Text(
                        finishedEvents.isEmpty
                            ? 'No hay eventos cerrados para mostrar.'
                            : '${finishedEvents.length} eventos cerrados o finalizados.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                if (finishedEvents.isEmpty)
                  SliverToBoxAdapter(
                    child: LemaPanel(
                      color: AppColors.surfaceLow,
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Cuando un evento termine o se archive aparecerá aquí.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = finishedEvents[index];
  
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == finishedEvents.length - 1 ? 0 : 10,
                        ),
                        child: _PastEventRow(
                          event: event,
                          onTap: () => onOpenEvent?.call(event.event.id),
                        ),
                      );
                    }, childCount: finishedEvents.length),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PastEventRow extends StatelessWidget {
  const _PastEventRow({required this.event, this.onTap});

  final AccessEventSummary event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.displayName,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.locationLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    LemaStatusPill(
                      label: event.statusLabel,
                      color: AppColors.surfaceHigh,
                    ),
                    LemaTag(
                      label: '${event.checkedInCount} accesos',
                      color: AppColors.surfaceHigh,
                      textColor: AppColors.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceMuted,
          ),
        ],
      ),
    );
  }
}
