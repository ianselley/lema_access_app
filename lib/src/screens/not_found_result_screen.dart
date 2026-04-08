import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class NotFoundResultScreen extends ConsumerWidget {
  const NotFoundResultScreen({
    super.key,
    this.onManualSearch,
    this.onContinueScanning,
  });

  final VoidCallback? onManualSearch;
  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessScanControllerProvider);
    final outcome = switch (state) {
      AccessScanSuccess(:final outcome)
          when outcome.resultCode == 'not_found' =>
        outcome,
      _ => null,
    };
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NO ENCONTRADO',
            style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            outcome?.headline ?? 'No encontramos ese ticket',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          LemaPanel(
            color: AppColors.surfaceLow,
            child: Text(
              outcome?.normalizedInput ?? 'Sin referencia disponible',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
            ),
          ),
          const Spacer(),
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
        ],
      ),
    );
  }
}
