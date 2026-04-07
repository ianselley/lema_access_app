import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class RecentHistoryScreen extends StatelessWidget {
  const RecentHistoryScreen({super.key, this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const recentValidations = <_HistoryItem>[
      _HistoryItem(
        name: 'Alejandro García',
        ticketType: 'VIP Access',
        code: '#LEMA-8932',
        timeAgo: '2 min',
        state: TicketState.valid,
      ),
      _HistoryItem(
        name: 'María Fernández',
        ticketType: 'Entrada general',
        code: '#LEMA-4831',
        timeAgo: '7 min',
        state: TicketState.used,
      ),
      _HistoryItem(
        name: 'Lucía Torres',
        ticketType: 'General Entry',
        code: '#LEMA-7719',
        timeAgo: '11 min',
        state: TicketState.invalid,
      ),
      _HistoryItem(
        name: 'Javier Ortiz',
        ticketType: 'Guest List',
        code: '#LEMA-5520',
        timeAgo: '19 min',
        state: TicketState.notFound,
      ),
      _HistoryItem(
        name: 'Elena Rivas',
        ticketType: 'General Entry',
        code: '#LEMA-2104',
        timeAgo: '27 min',
        state: TicketState.networkError,
      ),
      _HistoryItem(
        name: 'Marco Beltrán',
        ticketType: 'VIP Access',
        code: '#LEMA-6628',
        timeAgo: '33 min',
        state: TicketState.valid,
      ),
    ];

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onOpenTicketDetail: onOpenTicketDetail),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: LemaMetricPanel(
                    label: 'Validados hoy',
                    value: '342',
                    accent: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: LemaMetricPanel(
                    label: 'Usados',
                    value: '18',
                    accent: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const LemaMetricPanel(
              label: 'Incidencias registradas',
              value: '3',
              accent: AppColors.error,
            ),
            const SizedBox(height: 22),
            LemaSectionHeading(
              kicker: 'Operación',
              title: 'Historial reciente',
              trailing: LemaTag(
                label: 'Actualizado',
                color: AppColors.surfaceHigh,
                textColor: AppColors.onSurface,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(height: 14),
            LemaPanel(
              color: AppColors.surfaceLow,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La fila principal abre el detalle del ticket para revisión manual.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                for (var index = 0; index < recentValidations.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == recentValidations.length - 1 ? 0 : 12,
                    ),
                    child: _HistoryCard(
                      item: recentValidations[index],
                      onTap: index == 0 ? onOpenTicketDetail : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            LemaPanel(
              color: AppColors.backgroundAlt,
              child: Row(
                children: [
                  const Icon(Icons.insights_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mantén este historial como punto de control para validar picos de tráfico y revisar incidencias sin salir del flujo.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

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
                      'HISTORIAL RECIENTE',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revisión operativa en tiempo real',
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (onOpenTicketDetail != null)
                LemaStatusPill(
                  label: 'Detalle',
                  color: AppColors.primaryStrong,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Consulta las últimas validaciones, detecta patrones y abre el ticket más reciente con un solo toque.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, this.onTap});

  final _HistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = toneForState(item.state);
    final textTheme = Theme.of(context).textTheme;

    return LemaStatusStripCard(
      accent: tone.accent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: tone.accent.withValues(alpha: 0.14),
                child: Icon(tone.icon, color: tone.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.ticketType,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LemaTag(
                    label: tone.label,
                    color: tone.accent.withValues(alpha: 0.14),
                    textColor: tone.accent,
                    icon: tone.icon,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetaBlock(label: 'Código', value: item.code),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaBlock(label: 'Estado', value: tone.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.name,
    required this.ticketType,
    required this.code,
    required this.timeAgo,
    required this.state,
  });

  final String name;
  final String ticketType;
  final String code;
  final String timeAgo;
  final TicketState state;
}
