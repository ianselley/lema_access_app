import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class EventHomeScreen extends StatelessWidget {
  const EventHomeScreen({super.key, this.onOpenScanner, this.onOpenHistory});

  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final history = <HistoryEntry>[
      const HistoryEntry(
        name: 'Alejandro García',
        ticketType: 'VIP Access',
        timeAgo: '2 min',
        status: TicketState.valid,
      ),
      const HistoryEntry(
        name: 'Lucía Torres',
        ticketType: 'General Entry',
        timeAgo: '5 min',
        status: TicketState.valid,
      ),
      const HistoryEntry(
        name: 'Marco Beltrán',
        ticketType: 'VIP Access',
        timeAgo: '12 min',
        status: TicketState.valid,
      ),
      const HistoryEntry(
        name: 'Elena Rivas',
        ticketType: 'Guest List',
        timeAgo: '18 min',
        status: TicketState.valid,
      ),
    ];

    return LemaScaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopHero(eventName: 'Terminal Alpha', onOpenHistory: onOpenHistory),
            const SizedBox(height: 20),
            LemaPanel(
              padding: const EdgeInsets.all(18),
              color: AppColors.surfaceHighest,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.2),
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
                              'Progreso de acceso',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '68%',
                              style: textTheme.displayLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '342 entradas validadas de 500',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LemaProgressBar(
                    value: 0.68,
                    color: AppColors.primaryStrong,
                    background: AppColors.backgroundAlt,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Validados',
                          value: '342',
                          accent: AppColors.secondary,
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'Pendientes',
                          value: '158',
                          accent: AppColors.primary,
                          icon: Icons.hourglass_bottom_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            LemaSectionHeading(
              kicker: 'Operación',
              title: 'Historial reciente',
              trailing: onOpenHistory == null
                  ? null
                  : TextButton(
                      onPressed: onOpenHistory,
                      child: const Text('Ver todo'),
                    ),
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                for (final entry in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryRow(entry: entry),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LemaPanel(
              padding: const EdgeInsets.all(18),
              color: AppColors.surfaceLow,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acción principal',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Iniciar escaneo',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Abre el escáner activo y continúa con la validación de entradas en tiempo real.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LemaPrimaryButton(
                    label: 'Empezar a escanear',
                    icon: Icons.qr_code_scanner,
                    onPressed: onOpenScanner,
                  ),
                  if (onOpenHistory != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onOpenHistory,
                      icon: const Icon(Icons.history),
                      label: const Text('Revisar historial'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHero extends StatelessWidget {
  const _TopHero({required this.eventName, this.onOpenHistory});

  final String eventName;
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
                    LemaTag(
                      label: 'Gestión de flujo',
                      color: AppColors.surfaceHigh,
                      textColor: AppColors.secondary,
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      eventName,
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Pabellón 8 - IFEMA Madrid',
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
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              LemaTag(
                label: 'Activo',
                color: AppColors.primaryStrong,
                textColor: AppColors.black,
                icon: Icons.circle,
              ),
              LemaTag(
                label: '68% completo',
                color: AppColors.surfaceHigh,
                textColor: AppColors.onSurface,
                icon: Icons.trending_up,
              ),
              LemaTag(
                label: '342 validados',
                color: AppColors.surfaceHigh,
                textColor: AppColors.onSurface,
                icon: Icons.verified,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: const EdgeInsets.all(14),
      color: AppColors.background,
      borderColor: accent.withValues(alpha: 0.18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = toneForState(entry.status);

    return LemaPanel(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: tone.accent,
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.ticketType,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          entry.timeAgo,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
