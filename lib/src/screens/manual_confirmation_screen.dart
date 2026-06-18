import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket_models.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualConfirmationScreen extends ConsumerWidget {
  const ManualConfirmationScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final outcome = ref.watch(accessLatestCheckInOutcomeProvider);
    final ticket = outcome?.ticket;

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
            Text('Acceso confirmado', style: textTheme.displayMedium),
            const SizedBox(height: 20),
            if (outcome == null)
              LemaPanel(
                color: AppColors.surfaceLow,
                child: Text(
                  'No hay una confirmación manual reciente para mostrar.',
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
                      'Entrada registrada correctamente',
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket == null
                          ? 'La validación manual se completó correctamente.'
                          : 'La validación manual quedó registrada para ${_attendeeLabel(ticket)}.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${ticket == null ? 'Sin datos' : _attendeeLabel(ticket)} · ${ticket?.code ?? 'Sin código'}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (_ticketTypeDescription(ticket) != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_ticketTypeLabel(ticket!)} · ${_ticketTypeDescription(ticket)!}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                    if (outcome.scanLog?.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Registrado el ${_formatDateTime(outcome.scanLog!.createdAt!)}',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LemaPrimaryButton(
                label: 'Continuar escaneando',
                icon: Icons.arrow_forward,
                onPressed: onContinue,
              ),
            ],
          ],
        ),
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

String _attendeeLabel(AccessTicketSnapshot ticket) =>
    ticket.attendee.fullName?.trim().isNotEmpty == true
    ? ticket.attendee.fullName!.trim()
    : 'Sin asistente';

String _ticketTypeLabel(AccessTicketSnapshot ticket) =>
    ticket.ticketType.name?.trim().isNotEmpty == true
    ? ticket.ticketType.name!.trim()
    : 'Sin tipo';

String? _ticketTypeDescription(AccessTicketSnapshot? ticket) {
  final description = ticket?.ticketType.description?.trim();
  if (description == null || description.isEmpty) {
    return null;
  }
  return description;
}
