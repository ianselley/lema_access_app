import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
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
    final accent =
        ticket?.addOns.any((extra) => extra.remainingQuantity > 0) == true
        ? AppColors.warning
        : AppColors.error;
    final facts = <LemaResultFact>[
      if (ticket != null)
        LemaResultFact(
          label: 'Tipo',
          value: ticket.ticketTypeLabel,
          icon: Icons.confirmation_number_outlined,
        ),
      if (ticket != null && ticket.code.isNotEmpty)
        LemaResultFact(
          label: 'Código',
          value: ticket.code,
          icon: Icons.qr_code_2_rounded,
        ),
      if (outcome?.scanLog?.createdAt != null)
        LemaResultFact(
          label: 'Último registro',
          value: _formatDateTime(outcome!.scanLog!.createdAt!),
          icon: Icons.history_toggle_off_rounded,
        ),
      if (ticket != null)
        LemaResultFact(
          label: 'Estado',
          value: ticket.statusLabel,
          icon: Icons.info_outline_rounded,
        ),
    ];

    return LemaScaffold(
      body: LemaResultScreenLayout(
        accent: accent,
        content: [
          LemaResultHero(
            kicker: 'Acceso previamente validado',
            status: 'Ya utilizado',
            accent: accent,
            icon: Icons.history_toggle_off_rounded,
            subject: ticket?.displayName ?? 'Revisión requerida',
            supporting: lemaJoinText([
              ticket?.ticketTypeLabel,
              outcome?.scanLog?.createdAt == null
                  ? null
                  : 'Registrado ${_formatDateTime(outcome!.scanLog!.createdAt!)}',
            ]),
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: accent,
            icon: Icons.warning_amber_rounded,
            title: 'Revisión manual recomendada',
            meta: lemaJoinText([
              ticket?.ticketTypeLabel,
              ticket?.code.isEmpty == true ? null : 'Código ${ticket?.code}',
            ]),
            description:
                ticket?.ticketTypeDescriptionLabel ??
                'Este ticket ya registra un acceso previo. Verifica el caso antes de permitir la entrada.',
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: accent),
          ],
        ],
        actions: [
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

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month · $hour:$minute';
}
