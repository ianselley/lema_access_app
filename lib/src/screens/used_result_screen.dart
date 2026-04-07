import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class UsedResultScreen extends StatelessWidget {
  const UsedResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context) {
    final usedTone = toneForState(TicketState.used);
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LemaTag(
                label: 'Evento activo',
                color: AppColors.surfaceHigh,
                textColor: AppColors.primary,
                icon: Icons.bolt,
              ),
              LemaStatusPill(
                label: 'Revisar manualmente',
                color: usedTone.accent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'TICKET YA UTILIZADO',
            style: textTheme.labelSmall?.copyWith(color: usedTone.accent),
          ),
          const SizedBox(height: 8),
          Text(
            'Este acceso ya fue validado antes.',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'Comprueba con calma los datos del asistente y continúa con el siguiente ticket.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 24),
          LemaStatusStripCard(
            accent: usedTone.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: usedTone.accent.withValues(alpha: 0.14),
                      child: Icon(usedTone.icon, color: usedTone.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'María Fernández',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Entrada general',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LemaTag(
                      label: usedTone.label,
                      color: usedTone.accent.withValues(alpha: 0.14),
                      textColor: usedTone.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Código del pedido',
                        value: '#LEMA-4831',
                        accent: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        label: 'Última validación',
                        value: '19:42',
                        accent: usedTone.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  label: 'Puesto de control',
                  value: 'Acceso principal · Puerta 2',
                  accent: AppColors.onSurfaceMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LemaPanel(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Qué hacer ahora', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                _HintRow(
                  icon: Icons.qr_code_scanner,
                  label:
                      'Vuelve a escanear el siguiente ticket sin salir del flujo.',
                ),
                const SizedBox(height: 10),
                _HintRow(
                  icon: Icons.front_hand,
                  label: 'Si hay dudas, valida el nombre antes de continuar.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LemaPrimaryButton(
            label: 'Continuar escaneando',
            icon: Icons.qr_code_scanner,
            onPressed: onContinueScanning,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'El ticket queda marcado como usado en esta sesión.',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
      ],
    );
  }
}
