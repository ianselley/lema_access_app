import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key, this.onOpenEvent, this.onOpenProfile});

  final VoidCallback? onOpenEvent;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    const events = <EventSummary>[
      EventSummary(
        id: '992-K',
        name: 'TechSummit Madrid 2024',
        location: 'Pabellón 8 · IFEMA',
        capacityLabel: '4.120 / 5.000',
        progress: 0.82,
        progressLabel: '82%',
        statusLabel: 'En vivo',
        isActive: true,
      ),
      EventSummary(
        id: '741-X',
        name: 'Concierto Acústico Rock',
        location: 'Sala Riviera',
        capacityLabel: '150 / 500',
        progress: 0.30,
        progressLabel: '30%',
        statusLabel: 'Activa',
        isActive: true,
      ),
      EventSummary(
        id: '224-M',
        name: 'Congreso de Neurociencia',
        location: 'Palacio de Congresos',
        capacityLabel: '1.2k pre-reg',
        progress: 0.44,
        progressLabel: '44%',
        statusLabel: 'Próximo',
        isActive: false,
      ),
      EventSummary(
        id: '519-P',
        name: 'Gala Anual de Logística',
        location: 'Hotel Ritz Madrid',
        capacityLabel: '450 pre-reg',
        progress: 0.18,
        progressLabel: '18%',
        statusLabel: 'Próximo',
        isActive: false,
      ),
      EventSummary(
        id: '118-R',
        name: 'ExpoRetail Digital',
        location: 'Hall 3 · IFEMA',
        capacityLabel: '100%',
        progress: 1,
        progressLabel: '100%',
        statusLabel: 'Finalizado',
        isActive: false,
      ),
    ];

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onOpenProfile: onOpenProfile)),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: _OverviewRow(
              totalEvents: '05',
              liveEvents: '02',
              pendingCheckins: '1.9k',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'En curso',
              subtitle: 'Eventos que están activos ahora mismo',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 360;
                if (!isWide) {
                  return Column(
                    children: [
                      _ActiveEventCard(
                        event: events[0],
                        onTap: onOpenEvent,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),
                      _ActiveEventCard(
                        event: events[1],
                        onTap: null,
                        isPrimary: false,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _ActiveEventCard(
                        event: events[0],
                        onTap: onOpenEvent,
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActiveEventCard(
                        event: events[1],
                        onTap: onOpenEvent,
                        isPrimary: false,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Próximos',
              subtitle: 'Eventos listos para preparar el flujo',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final event = events[index + 2];
              return Padding(
                padding: EdgeInsets.only(bottom: index == 1 ? 0 : 12),
                child: _UpcomingEventCard(event: event),
              );
            }, childCount: 2),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Finalizados',
              subtitle: 'Eventos cerrados recientemente',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _FinishedRow(event: events[4])),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: LemaPanel(
              color: AppColors.surfaceLow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu acceso', style: textTheme.labelSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Operación continua',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  LemaStatusPill(label: 'Activa', color: AppColors.success),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOpenProfile});

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
              Row(
                children: [
                  const _BrandMark(),
                  const SizedBox(width: 10),
                  Text(
                    'OPERATIONS',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Tus eventos', style: textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Gestiona accesos activos, próximos cierres y eventos finalizados desde una sola vista.',
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.primaryStrong,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.totalEvents,
    required this.liveEvents,
    required this.pendingCheckins,
  });

  final String totalEvents;
  final String liveEvents;
  final String pendingCheckins;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;

        if (compact) {
          return Column(
            children: [
              LemaMetricPanel(
                label: 'Eventos',
                value: totalEvents,
                accent: AppColors.primary,
              ),
              const SizedBox(height: 12),
              LemaMetricPanel(
                label: 'En vivo',
                value: liveEvents,
                accent: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              LemaMetricPanel(
                label: 'Pendientes',
                value: pendingCheckins,
                accent: AppColors.primaryStrong,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: LemaMetricPanel(
                label: 'Eventos',
                value: totalEvents,
                accent: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LemaMetricPanel(
                label: 'En vivo',
                value: liveEvents,
                accent: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LemaMetricPanel(
                label: 'Pendientes',
                value: pendingCheckins,
                accent: AppColors.primaryStrong,
              ),
            ),
          ],
        );
      },
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
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

  final EventSummary event;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _StripPanel(
      accent: isPrimary ? AppColors.primaryStrong : AppColors.secondary,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LemaTag(
                label: 'ID ${event.id}',
                color: AppColors.surfaceBright,
                textColor: AppColors.primary,
              ),
              Icon(
                Icons.sensors,
                size: 18,
                color: isPrimary
                    ? AppColors.primaryStrong
                    : AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(event.name, style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            event.location.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de acceso',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              Text(
                event.progressLabel,
                style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LemaProgressBar(
            value: event.progress,
            color: isPrimary ? AppColors.primaryStrong : AppColors.primary,
            background: AppColors.surfaceLow,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.capacityLabel,
                style: textTheme.headlineMedium?.copyWith(fontSize: 26),
              ),
              LemaStatusPill(
                label: event.statusLabel,
                color: isPrimary
                    ? AppColors.primaryStrong
                    : AppColors.secondary,
              ),
            ],
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

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(Icons.event, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LemaTag(
                  label: event.id,
                  color: AppColors.surfaceBright,
                  textColor: AppColors.onSurfaceMuted,
                ),
                const SizedBox(height: 10),
                Text(event.name, style: textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(event.location, style: textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.capacityLabel,
                style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                event.statusLabel.toUpperCase(),
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

class _FinishedRow extends StatelessWidget {
  const _FinishedRow({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.name, style: textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '${event.location} · ${event.capacityLabel}',
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            event.statusLabel.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
