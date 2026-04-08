import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class UsedResultScreen extends ConsumerWidget {
  const UsedResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessScanControllerProvider);
    final outcome = switch (state) {
      AccessScanSuccess(:final outcome)
          when outcome.resultCode == 'already_used' =>
        outcome,
      _ => null,
    };
    final ticket = outcome?.ticket;
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YA UTILIZADO',
            style: textTheme.labelSmall?.copyWith(color: AppColors.warning),
          ),
          const SizedBox(height: 8),
          Text(
            ticket?.displayName ?? 'Este acceso ya fue validado.',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          LemaStatusStripCard(
            accent: AppColors.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisión manual recomendada',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ticket?.ticketTypeLabel ?? 'Ticket'} · ${ticket?.code ?? 'Sin código'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          LemaPrimaryButton(
            label: 'Continuar escaneando',
            icon: Icons.qr_code_scanner,
            onPressed: onContinueScanning,
          ),
        ],
      ),
    );
  }
}
