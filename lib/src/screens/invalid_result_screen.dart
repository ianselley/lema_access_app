import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/scan_input_normalizer.dart';
import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
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
    final referenceLabel = _scanReferenceLabel(outcome);
    final facts = <LemaResultFact>[
      if (referenceLabel != null)
        LemaResultFact(
          label: 'Referencia',
          value: referenceLabel,
          icon: Icons.pin_outlined,
        ),
      if (outcome?.reasonCode != null)
        LemaResultFact(
          label: 'Motivo',
          value: outcome!.reasonCode!,
          icon: Icons.rule_folder_outlined,
        ),
      if (outcome?.ticket?.ticketTypeLabel != null)
        LemaResultFact(
          label: 'Tipo',
          value: outcome!.ticket!.ticketTypeLabel,
          icon: Icons.confirmation_number_outlined,
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
        accent: AppColors.error,
        content: [
          LemaResultHero(
            kicker: 'Validación rechazada',
            status: 'Acceso denegado',
            accent: AppColors.error,
            icon: Icons.block_rounded,
            subject: outcome?.headline ?? 'Ticket inválido',
            supporting: referenceLabel,
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: AppColors.error,
            icon: Icons.do_not_disturb_on_rounded,
            title: outcome?.headline ?? 'Ticket inválido',
            meta: lemaJoinText([referenceLabel, outcome?.reasonCode]),
            description:
                outcome?.ticket?.ticketTypeDescriptionLabel ??
                outcome?.body ??
                'No permitas el acceso con esta lectura.',
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: AppColors.error),
          ],
        ],
        actions: [
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

String? _scanReferenceLabel(AccessScanOutcome? outcome) {
  if (outcome == null) {
    return null;
  }

  final ticketCode = outcome.ticket?.code.trim();
  if (ticketCode != null && ticketCode.isNotEmpty) {
    return 'CODE: $ticketCode';
  }

  final token =
      extractLemaTicketToken(outcome.rawInput)?.trim() ??
      outcome.normalizedInput?.trim();
  if (token != null && token.isNotEmpty) {
    return 'TOKEN: $token';
  }

  return null;
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month · $hour:$minute';
}
