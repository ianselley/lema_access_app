import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualConfirmationScreen extends StatelessWidget {
  const ManualConfirmationScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.sizeOf(context).height -
                MediaQuery.of(context).padding.vertical -
                42,
          ),
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
                      Icons.verified_outlined,
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
                          'Confirmación manual',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revisa antes de continuar',
                          style: textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const LemaStatusPill(
                    label: 'Listo',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LemaPanel(
                color: AppColors.surfaceHighest,
                borderColor: AppColors.success.withValues(alpha: 0.28),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.success,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acceso manual confirmado',
                                style: textTheme.displayMedium?.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Los datos están listos para registrar la entrada y seguir con el flujo.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LemaProgressBar(
                      value: 1,
                      color: AppColors.success,
                      background: AppColors.backgroundAlt,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        LemaTag(
                          label: 'Validación manual',
                          color: AppColors.success,
                          textColor: AppColors.black,
                          icon: Icons.fact_check,
                        ),
                        LemaTag(
                          label: 'Sin incidencias',
                          color: AppColors.surfaceHigh,
                          textColor: AppColors.onSurface,
                          icon: Icons.shield_outlined,
                        ),
                        LemaTag(
                          label: 'Listo para continuar',
                          color: AppColors.surfaceHigh,
                          textColor: AppColors.primary,
                          icon: Icons.arrow_forward,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LemaPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Resumen del acceso',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Asistente',
                      value: 'María Fernández',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Código manual',
                      value: 'LEMA-4831',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Evento',
                      value: 'TechSummit Madrid 2024',
                      icon: Icons.event_outlined,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Canal',
                      value: 'Validación manual asistida',
                      icon: Icons.engineering_outlined,
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
                    Text('Siguiente paso', style: textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pulsa continuar para registrar este acceso y volver al flujo operativo.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LemaPrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                onPressed: onContinue,
              ),
              const SizedBox(height: 10),
              Text(
                'El acceso se mantiene en esta sesión hasta confirmar la siguiente acción.',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
