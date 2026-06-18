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
    final headline = outcome?.displayHeadline ?? 'Ticket inválido';
    final description =
        outcome?.displayBody ?? 'No permitas el acceso con esta lectura.';
    final referenceLabel = _scanReferenceLabel(outcome);
    final invalidContext = outcome?.invalidContext;
    final ticketEvent = invalidContext?.ticketEvent;
    final currentEvent = invalidContext?.currentEvent;
    final ticketStatusLabel = accessTicketStatusLabel(
      invalidContext?.ticketStatus ??
          outcome?.ticketStatus ??
          outcome?.ticket?.status,
    );
    final facts = <LemaResultFact>[
      if (referenceLabel != null)
        LemaResultFact(
          label: 'Referencia',
          value: referenceLabel,
          icon: Icons.pin_outlined,
        ),
      if (outcome?.displayReasonLabel != null)
        LemaResultFact(
          label: 'Incidencia',
          value: outcome!.displayReasonLabel!,
          icon: Icons.rule_folder_outlined,
        ),
      if (ticketEvent?.displayName != null)
        LemaResultFact(
          label: 'Evento del ticket',
          value: ticketEvent!.displayName!,
          icon: Icons.event_note_rounded,
        ),
      if (ticketEvent?.brandName != null)
        LemaResultFact(
          label: 'Marca',
          value: ticketEvent!.brandName!,
          icon: Icons.storefront_outlined,
        ),
      if (ticketEvent?.startTime != null)
        LemaResultFact(
          label: 'Día',
          value: _formatEventDate(ticketEvent!.startTime!),
          icon: Icons.calendar_today_rounded,
        ),
      if (currentEvent?.displayName != null &&
          currentEvent!.id.isNotEmpty &&
          currentEvent.id != ticketEvent?.id)
        LemaResultFact(
          label: 'Escaneando para',
          value: currentEvent.displayName!,
          icon: Icons.event_available_rounded,
        ),
      if (ticketStatusLabel != 'Sin estado')
        LemaResultFact(
          label: 'Estado',
          value: ticketStatusLabel,
          icon: Icons.info_outline_rounded,
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
            subject: headline,
            supporting: ticketEvent?.displayName ?? referenceLabel,
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: AppColors.error,
            icon: Icons.do_not_disturb_on_rounded,
            title: headline,
            meta: lemaJoinText([referenceLabel, outcome?.displayReasonLabel]),
            description: _buildDescription(
              fallback: description,
              ticketTypeDescription:
                  outcome?.ticket?.ticketTypeDescriptionLabel,
              ticketEvent: ticketEvent,
            ),
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

String _formatEventDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month · $hour:$minute';
}

String _buildDescription({
  required String fallback,
  required String? ticketTypeDescription,
  required AccessScanEventContext? ticketEvent,
}) {
  final eventLabel = ticketEvent?.displayName;
  final typeLabel = ticketTypeDescription?.trim();
  if (eventLabel == null || eventLabel.isEmpty) {
    return fallback;
  }
  if (typeLabel == null || typeLabel.isEmpty) {
    return fallback;
  }

  return '$fallback Tipo detectado: $typeLabel.';
}
