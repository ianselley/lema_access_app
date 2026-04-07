import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class InvalidResultScreen extends StatelessWidget {
  const InvalidResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: AppColors.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resultado de validación',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                const LemaTag(
                  label: 'Error',
                  color: AppColors.error,
                  textColor: Colors.white,
                  icon: Icons.report_gmailerrorred_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error.withValues(alpha: 0.24),
                    AppColors.surface,
                  ],
                ),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          color: AppColors.error,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket inválido',
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'La validación ha sido rechazada. No permitas el acceso hasta revisar el origen del código o repetir la lectura.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LemaStatusStripCard(
                    accent: AppColors.error,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estado',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.onSurfaceMuted,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Acceso denegado',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const LemaStatusPill(
                          label: 'Revisar',
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LemaSectionHeading(
              kicker: 'Posibles causas',
              title: 'Qué revisar antes de volver a escanear',
              trailing: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 14),
            const _CauseHint(
              icon: Icons.qr_code_2_rounded,
              title: 'Código corrupto o mal enfocado',
              description:
                  'El lector pudo captar un fragmento incompleto, un reflejo o un QR fuera de foco.',
            ),
            const SizedBox(height: 10),
            const _CauseHint(
              icon: Icons.assignment_late_rounded,
              title: 'Ticket fuera de estado válido',
              description:
                  'El código existe, pero su estado actual no permite entrada en este momento.',
            ),
            const SizedBox(height: 10),
            const _CauseHint(
              icon: Icons.sync_problem_rounded,
              title: 'Desajuste con el evento actual',
              description:
                  'El ticket podría pertenecer a otro evento, otra sesión o una tanda diferente.',
            ),
            const SizedBox(height: 20),
            LemaPanel(
              color: AppColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referencia técnica',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error `INV-4007`',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Si el problema se repite, registra el código y prueba con una nueva lectura.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LemaPrimaryButton(
              label: 'Continuar escaneando',
              icon: Icons.qr_code_scanner_rounded,
              onPressed: onContinueScanning,
            ),
            const SizedBox(height: 10),
            Text(
              'Mantén el flujo activo y vuelve a intentar con un código legible.',
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

class _CauseHint extends StatelessWidget {
  const _CauseHint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.error),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
