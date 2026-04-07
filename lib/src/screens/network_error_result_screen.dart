import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class NetworkErrorResultScreen extends StatelessWidget {
  const NetworkErrorResultScreen({super.key, this.onRetry, this.onManualEntry});

  final VoidCallback? onRetry;
  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.sizeOf(context).height -
                MediaQuery.paddingOf(context).vertical -
                40,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      'Error de conexión',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LemaPanel(
                  color: AppColors.surfaceHigh,
                  borderColor: AppColors.error.withValues(alpha: 0.38),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LemaTag(
                        label: 'Modo offline',
                        color: AppColors.error.withValues(alpha: 0.14),
                        textColor: AppColors.error,
                        icon: Icons.signal_wifi_connected_no_internet_4_rounded,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No hay conexión con el servidor',
                        style: textTheme.displayMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No pudimos validar el ticket porque la red no responde. Puedes reintentar o continuar con entrada manual mientras se restablece la conexión.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const LemaProgressBar(
                        value: 0.15,
                        color: AppColors.error,
                        background: AppColors.backgroundAlt,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Intentando mantener el flujo operativo.',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LemaPanel(
                  padding: const EdgeInsets.all(18),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acciones recomendadas',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _RecoveryStep(
                        icon: Icons.refresh_rounded,
                        title: 'Reintenta la validación',
                        description:
                            'Vuelve a comprobar la conexión y lanza de nuevo la lectura.',
                      ),
                      const SizedBox(height: 10),
                      _RecoveryStep(
                        icon: Icons.badge_outlined,
                        title: 'Pasa a entrada manual',
                        description:
                            'Si el fallo persiste, valida el ticket con código o búsqueda manual.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Spacer(),
                LemaPrimaryButton(
                  label: 'Reintentar conexión',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onManualEntry,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Entrada manual'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Si la red vuelve, el sistema seguirá validando sin perder el contexto actual.',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryStep extends StatelessWidget {
  const _RecoveryStep({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
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
    );
  }
}
