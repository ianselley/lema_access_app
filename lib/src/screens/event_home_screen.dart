import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/core/access_failure.dart';
import '../access/events/access_event_ui.dart';
import '../access/models/access_models.dart';
import '../access/providers/access_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class EventHomeScreen extends ConsumerWidget {
  const EventHomeScreen({
    super.key,
    required this.eventId,
    this.onOpenScanner,
    this.onOpenHistory,
  });

  final String eventId;
  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventId.trim().isEmpty) {
      return LemaScaffold(
        body: _MissingEventState(
          onOpenScanner: onOpenScanner,
          onOpenHistory: onOpenHistory,
        ),
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
        final history = home.recentHistoryPreview.take(3).toList();

        return LemaScaffold(
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                  onOpenScanner: onOpenScanner,
                  onOpenHistory: onOpenHistory,
                ),
                const SizedBox(height: 24),
                LemaSectionHeading(
                  kicker: 'Actividad',
                  title: 'Últimos accesos',
                  trailing: onOpenHistory == null
                      ? null
                      : TextButton(
                          onPressed: onOpenHistory,
                          child: const Text('Ver todo'),
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
                          child: _HistoryRow(entry: history[index]),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
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
    this.onOpenScanner,
    this.onOpenHistory,
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
  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenHistory;

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
              if (onOpenHistory != null)
                IconButton(
                  onPressed: onOpenHistory,
                  icon: const Icon(Icons.history),
                  tooltip: 'Historial',
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
          const SizedBox(height: 18),
          Text(
            progressLabel,
            style: textTheme.headlineLarge?.copyWith(color: AppColors.primary),
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
          if (onOpenScanner != null || onOpenHistory != null) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (onOpenScanner != null)
                  LemaPrimaryButton(
                    label: 'Empezar a escanear',
                    icon: Icons.qr_code_scanner,
                    onPressed: onOpenScanner,
                  ),
                if (onOpenHistory != null)
                  OutlinedButton.icon(
                    onPressed: onOpenHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('Ver historial'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final AccessHistoryItem entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: entry.resultColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.titleLabel,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.subtitleLabel,
                            style: textTheme.labelMedium?.copyWith(
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
                          entry.relativeTimeLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LemaStatusPill(
                          label: entry.resultLabel,
                          color: entry.resultColor,
                        ),
                      ],
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
  const _MissingEventState({this.onOpenScanner, this.onOpenHistory});

  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenHistory;

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
            if (onOpenScanner != null || onOpenHistory != null) ...[
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
                  if (onOpenHistory != null)
                    OutlinedButton.icon(
                      onPressed: onOpenHistory,
                      icon: const Icon(Icons.history),
                      label: const Text('Historial'),
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
        accessFailure?.message ?? 'No se pudo cargar el home del evento.';

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
