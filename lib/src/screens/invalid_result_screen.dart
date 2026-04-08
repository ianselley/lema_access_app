import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class InvalidResultScreen extends ConsumerWidget {
  const InvalidResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessScanControllerProvider);
    final outcome = switch (state) {
      AccessScanSuccess(:final outcome)
          when outcome.resultCode == 'wrong_event' ||
              outcome.resultCode == 'cancelled_or_invalid' ||
              outcome.resultCode == 'forbidden' =>
        outcome,
      _ => null,
    };
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'VALIDACIÓN RECHAZADA',
            style: textTheme.labelSmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            outcome?.headline ?? 'Ticket inválido',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          LemaStatusStripCard(
            accent: AppColors.error,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outcome?.body ?? 'No permitas el acceso con esta lectura.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                if (outcome?.reasonCode != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    outcome!.reasonCode ?? '',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          LemaPrimaryButton(
            label: 'Continuar escaneando',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: onContinueScanning,
          ),
        ],
      ),
    );
  }
}
