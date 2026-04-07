import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ValidResultScreen extends StatelessWidget {
  const ValidResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                mediaQuery.size.height - mediaQuery.padding.vertical - 42,
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
                      Icons.qr_code_scanner,
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
                          'NOMBRE DEL EVENTO',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Validación correcta',
                          style: textTheme.titleLarge?.copyWith(
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LemaStatusPill(
                    label: 'Activo',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LemaPanel(
                color: AppColors.surfaceHighest,
                borderColor: AppColors.success.withValues(alpha: 0.35),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TICKET VÁLIDO',
                                style: textTheme.displayMedium?.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'El acceso está autorizado y listo para continuar.',
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
                    const LemaProgressBar(
                      value: 1,
                      color: AppColors.success,
                      background: AppColors.backgroundAlt,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        LemaTag(
                          label: 'Validado',
                          color: AppColors.success,
                          textColor: AppColors.black,
                          icon: Icons.verified,
                        ),
                        LemaTag(
                          label: 'Sin incidencias',
                          color: AppColors.surfaceHigh,
                          textColor: AppColors.onSurface,
                          icon: Icons.shield_outlined,
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
                      'DETALLES DEL ASISTENTE',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Asistente',
                      value: 'Juan Pérez',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Categoría',
                      value: 'Entrada General - VIP',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Código de pedido',
                      value: '#LEMA-8932',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LemaPanel(
                color: AppColors.surfaceLow,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Puede continuar con el siguiente escaneo. Mantenga el flujo sin pausas.',
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
                label: 'Continuar escaneando',
                icon: Icons.qr_code_scanner,
                onPressed: onContinueScanning,
              ),
              const SizedBox(height: 10),
              Text(
                'Pulse para volver al flujo de escaneo inmediato.',
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
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
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
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
