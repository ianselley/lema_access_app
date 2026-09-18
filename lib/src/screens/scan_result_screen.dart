import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import 'event_ui.dart';

class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({
    super.key,
    this.onContinueScanning,
    this.onManualEntry,
    this.onManualSearch,
  });

  final VoidCallback? onContinueScanning;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(accessScanControllerProvider);

    if (state case AccessScanSuccess(:final outcome)) {
      final variant = accessScanUiVariantForResultCode(outcome.resultCode);
      final accent = switch (variant) {
        AccessScanUiVariant.valid => AppColors.success,
        AccessScanUiVariant.used =>
          outcome.ticket?.addOns.any((extra) => extra.remainingQuantity > 0) ==
                  true
              ? AppColors.warning
              : AppColors.error,
        AccessScanUiVariant.invalid => AppColors.error,
        AccessScanUiVariant.notFound => AppColors.error,
        AccessScanUiVariant.networkError => AppColors.error,
      };

      return LemaScaffold(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultado de escaneo',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outcome.displayHeadline,
                          style: textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  LemaStatusPill(
                    label: historyResultLabel(outcome.resultCode),
                    color: accent,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LemaStatusStripCard(
                accent: accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.displayHeadline,
                      style: textTheme.displayMedium?.copyWith(color: accent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outcome.displayBody,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    if (outcome.displayReasonLabel != null) ...[
                      const SizedBox(height: 14),
                      LemaTag(
                        label: outcome.displayReasonLabel!,
                        color: AppColors.surfaceHigh,
                        textColor: accent,
                        icon: Icons.info_outline,
                      ),
                    ],
                  ],
                ),
              ),
              if (outcome.ticket != null) ...[
                const SizedBox(height: 16),
                _TicketCard(ticket: outcome.ticket!, accent: accent),
              ],
              const SizedBox(height: 16),
              LemaPanel(
                color: AppColors.surfaceLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lectura registrada', style: textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Entrada', value: outcome.rawInput),
                    if (outcome.scanLog?.createdAt != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Momento',
                        value: _formatDateTime(outcome.scanLog!.createdAt!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LemaPrimaryButton(
                label: 'Volver al escáner',
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  ref.read(accessScanControllerProvider.notifier).reset();
                  onContinueScanning?.call();
                },
              ),
              if (outcome.resultCode == 'not_found') ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onManualSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar manualmente'),
                ),
              ] else if (outcome.resultCode == 'temporary_error') ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onManualEntry,
                  icon: const Icon(Icons.keyboard_alt_outlined),
                  label: const Text('Probar entrada manual'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (state case AccessScanFailure(:final failure)) {
      return LemaScaffold(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        body: Center(
          child: LemaPanel(
            color: AppColors.surfaceLow,
            borderColor: AppColors.error.withValues(alpha: 0.24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No se pudo completar la operación',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  accessScanReasonLabel(failure.code) ?? 'Error de acceso',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  failure.displayMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 16),
                LemaPrimaryButton(
                  label: 'Volver al escáner',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    ref.read(accessScanControllerProvider.notifier).reset();
                    onContinueScanning?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: Center(
        child: LemaPanel(
          color: AppColors.surfaceLow,
          child: Text(
            'Aún no hay un resultado de escaneo disponible.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.accent});

  final AccessTicketSnapshot ticket;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceHighest,
      borderColor: accent.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalle del ticket', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          _InfoRow(label: 'Asistente', value: ticket.displayName),
          const SizedBox(height: 8),
          _InfoRow(label: 'Tipo', value: ticket.ticketTypeLabel),
          if (ticket.ticketTypeDescriptionLabel != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Descripción',
              value: ticket.ticketTypeDescriptionLabel!,
            ),
          ],
          const SizedBox(height: 8),
          _InfoRow(label: 'Código', value: ticket.code),
          const SizedBox(height: 8),
          _InfoRow(label: 'Estado', value: ticket.statusLabel),
          const SizedBox(height: 8),
          _InfoRow(label: 'Pedido', value: ticket.orderLabel),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: textTheme.bodyMedium)),
      ],
    );
  }
}
