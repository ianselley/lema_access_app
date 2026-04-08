import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class NetworkErrorResultScreen extends ConsumerWidget {
  const NetworkErrorResultScreen({super.key, this.onRetry, this.onManualEntry});

  final VoidCallback? onRetry;
  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessScanControllerProvider);
    final outcome = switch (state) {
      AccessScanSuccess(:final outcome)
          when outcome.resultCode == 'temporary_error' =>
        outcome,
      _ => null,
    };
    final failure = switch (state) {
      AccessScanFailure(:final failure) => failure,
      _ => null,
    };
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ERROR DE CONEXIÓN',
            style: textTheme.labelSmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            outcome?.headline ?? 'No hay conexión con el servidor',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          LemaPanel(
            color: AppColors.surfaceLow,
            borderColor: AppColors.error.withValues(alpha: 0.24),
            child: Text(
              failure?.message ??
                  outcome?.body ??
                  'Reintenta o pasa a entrada manual.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
