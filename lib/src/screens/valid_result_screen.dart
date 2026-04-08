import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ValidResultScreen extends ConsumerWidget {
  const ValidResultScreen({super.key, this.onContinueScanning});

  final VoidCallback? onContinueScanning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessScanControllerProvider);
    final outcome = switch (state) {
      AccessScanSuccess(:final outcome) when outcome.resultCode == 'valid' =>
        outcome,
      _ => null,
    };
    final ticket = outcome?.ticket;
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'VALIDACIÓN CORRECTA',
            style: textTheme.labelSmall?.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: 8),
          Text(
            ticket?.displayName ?? 'Acceso registrado',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          LemaStatusStripCard(
            accent: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acceso autorizado',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ticket?.ticketTypeLabel ?? 'Ticket'} · ${ticket?.orderLabel ?? 'Sin pedido'}',
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
