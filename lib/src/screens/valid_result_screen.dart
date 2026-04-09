import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_models.dart';
import '../providers/scan_providers.dart';
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
      if (ticket != null)
        LemaResultFact(
          label: 'Pedido',
          value: ticket.orderLabel,
          icon: Icons.receipt_long_outlined,
        ),
      if (ticket?.checkedInAt != null)
        LemaResultFact(
          label: 'Registrado',
          value: _formatDateTime(ticket!.checkedInAt!),
          icon: Icons.schedule_rounded,
        ),
    ];

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: LemaResultScreenLayout(
        accent: AppColors.success,
        content: [
          LemaResultHero(
            kicker: 'Validación correcta',
            status: 'Acceso autorizado',
            accent: AppColors.success,
            icon: Icons.check_circle_rounded,
            subject: ticket?.displayName ?? 'Acceso registrado',
            supporting: lemaJoinText([
              ticket?.ticketTypeLabel,
              ticket?.orderLabel,
            ]),
          ),
          const SizedBox(height: 16),
          LemaResultFocusCard(
            accent: AppColors.success,
            icon: Icons.verified_rounded,
            title: 'Registro completado',
            meta: lemaJoinText([
              ticket?.code.isEmpty == true ? null : 'Código ${ticket?.code}',
              ticket?.orderLabel,
            ]),
            description:
                ticket?.ticketTypeDescriptionLabel ??
                'El acceso quedó autorizado y registrado correctamente.',
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: AppColors.success),
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
