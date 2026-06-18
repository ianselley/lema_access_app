import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/debug_log.dart';
import '../core/failure.dart';
import '../models/event_models.dart';
import '../providers/event_providers.dart';
import '../screens/event_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/join_with_code_sheet.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key, this.onOpenEvent, this.onOpenProfile});

  final ValueChanged<String>? onOpenEvent;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(accessEventsProvider);

    return asyncEvents.when(
      loading: () {
        accessLog('Event list loading', scope: 'events');
        return const LemaScaffold(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
          showAutomaticBackButton: false,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      },
      error: (error, stackTrace) {
        accessLog(
          'Event list error: $error',
          scope: 'events',
          error: error,
          stackTrace: stackTrace,
        );
        return LemaScaffold(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          showAutomaticBackButton: false,
          body: _EventsErrorState(
            error: error,
            onRetry: () => ref.invalidate(accessEventsProvider),
            onOpenProfile: onOpenProfile,
          ),
        );
      },
      data: (events) {
        accessLog(
          'Event list rendered with ${events.length} events',
          scope: 'events',
        );
        final visibleEvents = events.where((event) => !event.isDraft).toList();
        final liveEvents = visibleEvents
            .where((event) => event.isLive)
            .toList();
        final primaryEvents = liveEvents.isNotEmpty
            ? liveEvents.take(2).toList()
            : visibleEvents.take(2).toList();
        final primaryEventIds = primaryEvents
            .map((event) => event.event.id)
            .toSet();
        final scheduledEvents = visibleEvents
            .where(
              (event) =>
                  event.isScheduled &&
                  !primaryEventIds.contains(event.event.id),
            )
            .take(3)
            .toList();
        final pendingCount = visibleEvents.fold<int>(
          0,
          (sum, event) => sum + event.pendingCheckInCount,
        );

        return LemaScaffold(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          showAutomaticBackButton: false,
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
                  child: _Header(
                    totalEvents: visibleEvents.length,
                    liveEvents: liveEvents.length,
                    pendingCount: pendingCount,
                    onOpenProfile: onOpenProfile,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: liveEvents.isEmpty
                        ? 'Disponibles ahora'
                        : 'En curso',
                    subtitle: liveEvents.isEmpty
                        ? 'No hay eventos en vivo; puedes entrar en el siguiente evento disponible.'
                        : 'Prioriza estos eventos para operar ahora.',
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: _EventSectionGrid(
                    events: primaryEvents,
                    emptyLabel: 'No hay eventos disponibles.',
                    onOpenEvent: onOpenEvent,
                    onJoinWithCode: () => showJoinWithCodeSheet(context),
                    highlightFirst: true,
                  ),
                ),
                if (scheduledEvents.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  const SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Próximos',
                      subtitle: 'Siguientes eventos preparados para abrir.',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = scheduledEvents[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == scheduledEvents.length - 1 ? 0 : 10,
                        ),
                        child: _CompactEventRow(
                          event: event,
                          icon: Icons.event_outlined,
                          onTap: () => onOpenEvent?.call(event.event.id),
                        ),
                      );
                    }, childCount: scheduledEvents.length),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalEvents,
    required this.liveEvents,
    required this.pendingCount,
    required this.onOpenProfile,
  });

  final int totalEvents;
  final int liveEvents;
  final int pendingCount;
  final VoidCallback? onOpenProfile;

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
              Text('Tus eventos', style: textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                '$liveEvents en curso · $pendingCount pendientes · $totalEvents totales',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onOpenProfile,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _EventSectionGrid extends StatelessWidget {
  const _EventSectionGrid({
    required this.events,
    required this.emptyLabel,
    required this.onOpenEvent,
    required this.onJoinWithCode,
    required this.highlightFirst,
  });

  final List<AccessEventSummary> events;
  final String emptyLabel;
  final ValueChanged<String>? onOpenEvent;
  final VoidCallback? onJoinWithCode;
  final bool highlightFirst;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EmptySectionCard(
        label: emptyLabel,
        detail: 'No hay nada que operar en este momento.',
        onJoinWithCode: onJoinWithCode,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < events.length; index++) ...[
          _ActiveEventCard(
            event: events[index],
            onTap: onOpenEvent == null
                ? null
                : () => onOpenEvent!.call(events[index].event.id),
            isPrimary: highlightFirst && index == 0,
          ),
          if (index != events.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ActiveEventCard extends StatelessWidget {
  const _ActiveEventCard({
    required this.event,
    required this.onTap,
    required this.isPrimary,
  });

  final AccessEventSummary event;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = isPrimary ? AppColors.primaryStrong : AppColors.secondary;

    return _StripPanel(
      accent: accent,
      onTap: onTap,
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
                    Text(event.displayName, style: textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      event.locationLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LemaStatusPill(label: event.statusLabel, color: accent),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.progressLabel,
            style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          LemaProgressBar(
            value: event.progress,
            color: accent,
            background: AppColors.surfaceLow,
          ),
          const SizedBox(height: 10),
          Text(
            event.capacityLabel,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEventRow extends StatelessWidget {
  const _CompactEventRow({required this.event, required this.icon, this.onTap});

  final AccessEventSummary event;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.locationLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            event.statusLabel,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StripPanel extends StatelessWidget {
  const _StripPanel({required this.accent, required this.child, this.onTap});

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.label,
    required this.detail,
    this.onJoinWithCode,
  });

  final String label;
  final String detail;
  final VoidCallback? onJoinWithCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            detail,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          if (onJoinWithCode != null) ...[
            const SizedBox(height: 14),
            LemaPrimaryButton(
              label: 'Unirse con código',
              icon: Icons.vpn_key_outlined,
              onPressed: onJoinWithCode,
            ),
          ],
        ],
      ),
    );
  }
}

class _EventsErrorState extends StatelessWidget {
  const _EventsErrorState({
    required this.error,
    required this.onRetry,
    this.onOpenProfile,
  });

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accessFailure = error is AccessFailure
        ? error as AccessFailure
        : null;
    final message =
        accessFailure?.message ?? 'No se pudieron cargar los eventos.';

    return Center(
      child: LemaPanel(
        color: AppColors.surfaceLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error de eventos', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                if (onOpenProfile != null)
                  OutlinedButton.icon(
                    onPressed: onOpenProfile,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Revisar sesión'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
