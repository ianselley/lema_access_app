import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, this.onConfirmManualAccess});

  final VoidCallback? onConfirmManualAccess;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final validationHistory = <_ValidationEvent>[
      const _ValidationEvent(
        title: 'Escaneo inicial',
        detail: 'Validado por el puesto de acceso principal',
        timestamp: '19:42',
        state: TicketState.valid,
      ),
      const _ValidationEvent(
        title: 'Revisión manual anterior',
        detail: 'Sin incidencias detectadas en puerta secundaria',
        timestamp: '19:18',
        state: TicketState.valid,
      ),
      const _ValidationEvent(
        title: 'Último intento',
        detail: 'Marcado como usado en la sesión actual',
        timestamp: '18:57',
        state: TicketState.used,
      ),
    ];

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalle del ticket',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Revisión manual', style: textTheme.titleLarge),
                    ],
                  ),
                ),
                LemaTag(
                  label: 'Operativo',
                  color: AppColors.surfaceHigh,
                  textColor: AppColors.primary,
                  icon: Icons.bolt,
                ),
              ],
            ),
            const SizedBox(height: 22),
            LemaPanel(
              color: AppColors.surfaceHighest,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'María Fernández',
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entrada general - VIP',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LemaStatusPill(
                        label: 'Requiere confirmación',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      LemaTag(
                        label: 'Código #LEMA-4831',
                        color: AppColors.surfaceHigh,
                        textColor: AppColors.primary,
                        icon: Icons.receipt_long_outlined,
                      ),
                      LemaTag(
                        label: 'Pedido #8932',
                        color: AppColors.surfaceHigh,
                        textColor: AppColors.onSurface,
                        icon: Icons.shopping_bag_outlined,
                      ),
                      LemaTag(
                        label: 'Puerta 2',
                        color: AppColors.surfaceHigh,
                        textColor: AppColors.secondary,
                        icon: Icons.meeting_room_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LemaProgressBar(
                    value: 0.82,
                    color: AppColors.primaryStrong,
                    background: AppColors.backgroundAlt,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Datos consolidados a partir de la búsqueda manual y del último historial de validación.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del acceso',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.65,
                    children: const [
                      _DetailCard(
                        label: 'Estado',
                        value: 'Pendiente de confirmación',
                        icon: Icons.pending_actions_outlined,
                        accent: AppColors.warning,
                      ),
                      _DetailCard(
                        label: 'Validaciones',
                        value: '2 correctas',
                        icon: Icons.verified_outlined,
                        accent: AppColors.secondary,
                      ),
                      _DetailCard(
                        label: 'Canal',
                        value: 'Búsqueda manual',
                        icon: Icons.search_outlined,
                        accent: AppColors.primary,
                      ),
                      _DetailCard(
                        label: 'Última puerta',
                        value: 'Acceso principal',
                        icon: Icons.storefront_outlined,
                        accent: AppColors.onSurfaceMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surface,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Historial de validación',
                        style: textTheme.titleLarge,
                      ),
                      const Spacer(),
                      const LemaTag(
                        label: '3 eventos',
                        color: AppColors.surfaceHigh,
                        textColor: AppColors.onSurface,
                        icon: Icons.history,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < validationHistory.length; i++) ...[
                    _ValidationRow(event: validationHistory[i]),
                    if (i != validationHistory.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirma el acceso manual solo si el nombre y el pedido coinciden con el listado del evento.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LemaPrimaryButton(
              label: 'Confirmar acceso manual',
              icon: Icons.verified_user_outlined,
              onPressed: onConfirmManualAccess,
            ),
            const SizedBox(height: 10),
            Text(
              'La confirmación queda registrada para el flujo operativo actual.',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationEvent {
  const _ValidationEvent({
    required this.title,
    required this.detail,
    required this.timestamp,
    required this.state,
  });

  final String title;
  final String detail;
  final String timestamp;
  final TicketState state;
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({required this.event});

  final _ValidationEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = toneForState(event.state);

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
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(tone.icon, color: tone.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.detail,
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
                          event.timestamp,
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
