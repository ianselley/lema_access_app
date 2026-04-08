import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/scan/access_scan_models.dart';
import '../access/scan/access_scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualConfirmationScreen extends ConsumerWidget {
  const ManualConfirmationScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    AccessScanOutcome outcome,
  ) async {
    final confirmed = await ref
        .read(accessScanControllerProvider.notifier)
        .confirmTicket(outcome.ticket!.id);

    if (!context.mounted || confirmed == null) {
      return;
    }

    onContinue?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(accessScanControllerProvider);
    final previewOutcome = switch (state) {
      AccessScanSuccess(:final outcome)
          when outcome.stage == AccessScanStage.preview =>
        outcome,
      _ => null,
    };

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CONFIRMACIÓN MANUAL',
              style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('Revisa antes de continuar', style: textTheme.displayMedium),
            const SizedBox(height: 20),
            if (previewOutcome == null)
              LemaPanel(
                color: AppColors.surfaceLow,
                child: Text(
                  'Primero resuelve un código manual para ver el detalle.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              )
            else ...[
              LemaPanel(
                color: AppColors.surfaceHighest,
                borderColor: AppColors.success.withValues(alpha: 0.28),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewOutcome.headline,
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      previewOutcome.body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${previewOutcome.ticket?.displayName ?? 'Sin datos'} · ${previewOutcome.ticket?.code ?? previewOutcome.rawInput}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LemaPrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                onPressed: previewOutcome.ticket == null
                    ? null
                    : () => _confirm(context, ref, previewOutcome),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
