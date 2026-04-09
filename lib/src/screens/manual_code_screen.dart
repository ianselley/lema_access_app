import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualCodeScreen extends ConsumerStatefulWidget {
  const ManualCodeScreen({super.key, this.onSubmitCode, this.onOpenSearch});

  final VoidCallback? onSubmitCode;
  final VoidCallback? onOpenSearch;

  @override
  ConsumerState<ManualCodeScreen> createState() => _ManualCodeScreenState();
}

class _ManualCodeScreenState extends ConsumerState<ManualCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _previewCode() async {
    final rawCode = _codeController.text.trim();
    if (rawCode.isEmpty) {
      return;
    }

    final outcome = await ref
        .read(accessScanControllerProvider.notifier)
        .previewManualInput(rawCode);

    if (!mounted || outcome == null) {
      return;
    }

    if (outcome.canCheckIn && widget.onSubmitCode != null) {
      widget.onSubmitCode?.call();
    }
  }

  void _append(String value) {
    final nextValue = '${_codeController.text}$value';
    _codeController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
    setState(() {});
  }

  void _clear() {
    _codeController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessScanControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final hasCode = _codeController.text.trim().isNotEmpty;
    final isProcessing = state is AccessScanProcessing;
    final AccessScanOutcome? previewOutcome = switch (state) {
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
              'ENTRADA MANUAL',
              style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('Código del ticket', style: textTheme.displayMedium),
            const SizedBox(height: 20),
            LemaPanel(
              color: AppColors.surfaceHighest,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _codeController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9\-]'),
                      ),
                      LengthLimitingTextInputFormatter(48),
                    ],
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.6,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      hintText: 'LEMA-4831',
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _previewCode(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QuickActionChip(
                        label: 'Limpiar',
                        icon: Icons.clear_all,
                        onTap: _clear,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(18),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final digit in const [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '0',
                    '-',
                  ])
                    _DigitChip(label: digit, onTap: () => _append(digit)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LemaPrimaryButton(
              label: isProcessing ? 'Resolviendo...' : 'Revisar ticket',
              icon: isProcessing ? Icons.timelapse : Icons.check_circle_outline,
              onPressed: hasCode && !isProcessing ? _previewCode : null,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onOpenSearch,
              icon: const Icon(Icons.search),
              label: const Text('Buscar manualmente'),
            ),
            const SizedBox(height: 12),
            _ManualPreviewCard(state: state, outcome: previewOutcome),
            const OperatorShellBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

class _ManualPreviewCard extends StatelessWidget {
  const _ManualPreviewCard({required this.state, required this.outcome});

  final AccessScanState state;
  final AccessScanOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (state is AccessScanIdle) {
      return Text(
        'Introduce un código o usa la búsqueda manual.',
        textAlign: TextAlign.center,
        style: textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceMuted),
      );
    }

    if (state is AccessScanProcessing) {
      return LemaPanel(
        color: AppColors.surfaceLow,
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Resolviendo ticket...',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is AccessScanFailure) {
      final failure = state as AccessScanFailure;
      return LemaPanel(
        color: AppColors.surfaceLow,
        borderColor: AppColors.error.withValues(alpha: 0.24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              failure.failure.code,
              style: textTheme.titleLarge?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              failure.failure.message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (outcome == null) {
      return const SizedBox.shrink();
    }

    final resolvedOutcome = outcome!;
    final variant = accessScanUiVariantForResultCode(
      resolvedOutcome.resultCode,
    );
    final accent = switch (variant) {
      AccessScanUiVariant.valid => AppColors.success,
      AccessScanUiVariant.used => AppColors.warning,
      AccessScanUiVariant.invalid => AppColors.error,
      AccessScanUiVariant.notFound => const Color(0xFF9CA3AF),
      AccessScanUiVariant.networkError => AppColors.error,
    };

    return LemaStatusStripCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accessScanHeadlineForResultCode(resolvedOutcome.resultCode),
            style: textTheme.titleLarge?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(
            accessScanBodyForResultCode(resolvedOutcome.resultCode),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          if (resolvedOutcome.ticket != null) ...[
            const SizedBox(height: 10),
            Text(
              '${resolvedOutcome.ticket!.displayName} · ${resolvedOutcome.ticket!.code}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            if (resolvedOutcome.ticket!.ticketTypeDescriptionLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                '${resolvedOutcome.ticket!.ticketTypeLabel} · ${resolvedOutcome.ticket!.ticketTypeDescriptionLabel!}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      backgroundColor: AppColors.surfaceHigh,
      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _DigitChip extends StatelessWidget {
  const _DigitChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: AppColors.surfaceHighest,
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
