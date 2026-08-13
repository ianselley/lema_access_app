import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
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
    final facts = <LemaResultFact>[
      if (outcome?.normalizedInput != null)
        LemaResultFact(
          label: 'Entrada',
          value: outcome!.normalizedInput!,
          icon: Icons.tag_rounded,
        ),
      if (outcome?.scanLog?.createdAt != null)
        LemaResultFact(
          label: 'Intento',
          value: _formatDateTime(outcome!.scanLog!.createdAt!),
          icon: Icons.schedule_rounded,
        ),
    ];

    return LemaScaffold(
      body: LemaResultScreenLayout(
        accent: AppColors.primary,
        content: [
          LemaResultHero(
            kicker: 'Resultado del escaneo',
            status: 'No encontrado',
            accent: AppColors.primary,
            icon: Icons.search_off_rounded,
            subject: outcome?.headline ?? 'No encontramos ese ticket',
            supporting: outcome?.normalizedInput,
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: AppColors.primary,
            icon: Icons.manage_search_rounded,
            title: 'Buscar ticket',
            meta: outcome?.normalizedInput ?? 'Sin referencia disponible',
            description:
                'No existe una coincidencia directa para esta lectura. Busca por nombre, email, teléfono, código o pedido.',
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: AppColors.primary),
          ],
        ],
        actions: [
          LemaPrimaryButton(
            label: 'Buscar ticket',
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

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month · $hour:$minute';
}
