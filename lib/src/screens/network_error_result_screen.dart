import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class NetworkErrorResultScreen extends ConsumerWidget {
  const NetworkErrorResultScreen({
    super.key,
    this.onRetry,
    this.onManualSearch,
  });

  final VoidCallback? onRetry;
  final VoidCallback? onManualSearch;

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
    final facts = <LemaResultFact>[
      if (failure?.code != null)
        LemaResultFact(
          label: 'Error',
          value: failure!.code,
          icon: Icons.error_outline_rounded,
        ),
      if (outcome?.normalizedInput != null)
        LemaResultFact(
          label: 'Entrada',
          value: outcome!.normalizedInput!,
          icon: Icons.tag_rounded,
        ),
    ];

    return LemaScaffold(
      body: LemaResultScreenLayout(
        accent: AppColors.error,
        content: [
          LemaResultHero(
            kicker: 'Estado del sistema',
            status: 'Error de conexión',
            accent: AppColors.error,
            icon: Icons.cloud_off_rounded,
            subject: outcome?.headline ?? 'No hay conexión con el servidor',
            supporting: failure?.code,
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: AppColors.error,
            icon: Icons.wifi_find_rounded,
            title: 'Sin comunicación con el backend',
            meta: failure?.code,
            description:
                failure?.message ??
                outcome?.body ??
                'Reintenta o busca el ticket manualmente.',
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: AppColors.error),
          ],
        ],
        actions: [
          LemaPrimaryButton(
            label: 'Reintentar conexión',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onManualSearch,
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Buscar ticket'),
          ),
        ],
      ),
    );
  }
}
