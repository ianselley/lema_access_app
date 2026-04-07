import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class NotFoundResultScreen extends StatelessWidget {
  const NotFoundResultScreen({
    super.key,
    this.onManualSearch,
    this.onContinueScanning,
  });

  final VoidCallback? onManualSearch;
  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(textTheme: textTheme),
            const SizedBox(height: 24),
            LemaPanel(
              color: AppColors.surfaceHigh,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No encontramos ese ticket',
                          style: textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Revisa el código y prueba de nuevo. Si fue dictado o escrito manualmente, usa la búsqueda para localizar el registro correcto.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LemaTag(
                    label: 'Referencia: ZX-2408-LEMA',
                    icon: Icons.confirmation_number_rounded,
                    color: AppColors.backgroundAlt,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sugerencias rápidas', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _HintRow(
                    icon: Icons.qr_code_2_rounded,
                    label:
                        'Escanea otra vez si el código está doblado, recortado o con poco contraste.',
                  ),
                  const SizedBox(height: 10),
                  _HintRow(
                    icon: Icons.keyboard_alt_rounded,
                    label:
                        'Si el ticket fue ingresado a mano, abre la búsqueda manual y valida el nombre.',
                  ),
                  const SizedBox(height: 10),
                  _HintRow(
                    icon: Icons.receipt_long_rounded,
                    label:
                        'Comprueba el evento activo antes de buscar en otra sesión o jornada.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LemaPrimaryButton(
              label: 'Búsqueda manual',
              icon: Icons.search_rounded,
              onPressed: onManualSearch,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onContinueScanning,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Continuar escaneando'),
            ),
            const SizedBox(height: 24),
            LemaPanel(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si el problema se repite, registra el código y continúa con el siguiente intento.',
                      style: textTheme.bodySmall?.copyWith(
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
  const _Header({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.badge_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEMA Scanner',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Ticket no localizado', style: textTheme.headlineLarge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Recuperación de acceso',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
