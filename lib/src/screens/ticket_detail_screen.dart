import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/core/access_rpc_exception.dart';
import '../access/tickets/access_ticket_models.dart';
import '../access/tickets/access_ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class TicketDetailScreen extends ConsumerWidget {
  const TicketDetailScreen({super.key, this.onConfirmManualAccess});

  final VoidCallback? onConfirmManualAccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final selection = ref.watch(accessSelectedTicketProvider);
    final detailAsync = ref.watch(accessSelectedTicketDetailProvider);
    final actionState = ref.watch(accessTicketCheckInControllerProvider);

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'DETALLE DEL TICKET',
              style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('Revisión manual', style: textTheme.displayMedium),
            const SizedBox(height: 20),
            if (selection == null) ...[
              const _EmptySelectionPanel(),
            ] else ...[
              detailAsync.when(
                loading: () => const _LoadingPanel(),
                error: (error, stackTrace) => _ErrorPanel(error: error),
                data: (detail) => _DetailContent(
                  detail: detail,
                  selection: selection,
                  actionState: actionState,
                  onConfirm: () async {
                    await ref
                        .read(accessTicketCheckInControllerProvider.notifier)
                        .confirmSelectedTicket();
                    if (ref
                            .read(accessTicketCheckInControllerProvider)
                            .status ==
                        AccessActionStatus.success) {
                      onConfirmManualAccess?.call();
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.selection,
    required this.actionState,
    required this.onConfirm,
  });

  final AccessTicketDetail detail;
  final AccessTicketSelection selection;
  final AccessTicketCheckInState actionState;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _ticketStatusPresentation(detail.ticket.status);
    final canCheckIn =
        detail.canCheckIn &&
        actionState.isLoading == false &&
        actionState.status != AccessActionStatus.success;
    final lastScanResult = detail.lastScanResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LemaPanel(
          color: AppColors.surfaceHighest,
          borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.attendee.fullName ?? 'Sin nombre',
                          style: textTheme.displayMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.ticketType.name ?? 'Tipo de ticket',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  LemaStatusPill(label: status.label, color: status.accent),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Código ${detail.ticket.code} · Pedido ${detail.order.id}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  LemaTag(
                    label: selection.matchReason.label,
                    color: AppColors.surfaceHigh,
                    textColor: AppColors.primary,
                    icon: Icons.search_outlined,
                  ),
                  LemaTag(
                    label: detail.ticket.canCheckIn
                        ? 'Confirmable'
                        : 'Bloqueado',
                    color: AppColors.surfaceHigh,
                    textColor: detail.ticket.canCheckIn
                        ? AppColors.secondary
                        : AppColors.warning,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Canal', value: selection.matchReason.label),
              const SizedBox(height: 12),
              _DetailRow(label: 'Último estado', value: status.label),
              if (lastScanResult != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Último resultado',
                  value:
                      '${lastScanResult.result.label} · ${lastScanResult.reasonCode}',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (detail.validationHistory.isNotEmpty)
          LemaPanel(
            color: AppColors.surface,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial', style: textTheme.titleLarge),
                const SizedBox(height: 14),
                for (var i = 0; i < detail.validationHistory.length; i++) ...[
                  _ValidationRow(event: detail.validationHistory[i]),
                  if (i != detail.validationHistory.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        if (detail.validationHistory.isNotEmpty) const SizedBox(height: 16),
        LemaPrimaryButton(
          label: actionState.isLoading
              ? 'Confirmando...'
              : 'Confirmar acceso manual',
          icon: actionState.isLoading
              ? Icons.hourglass_top
              : Icons.verified_user_outlined,
          onPressed: canCheckIn ? onConfirm : null,
        ),
        if (actionState.status == AccessActionStatus.failure) ...[
          const SizedBox(height: 14),
          _ActionErrorBanner(state: actionState),
        ],
      ],
    );
  }
}

class _EmptySelectionPanel extends StatelessWidget {
  const _EmptySelectionPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sin ticket seleccionado', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Abre un resultado de búsqueda para cargar su detalle.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const LemaPanel(
      color: AppColors.surfaceLow,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AccessRpcException? rpcError = error is AccessRpcException
        ? error as AccessRpcException
        : null;
    final message = rpcError?.message ?? error.toString();
    final code = rpcError?.code ?? 'UNKNOWN_ERROR';

    return LemaPanel(
      color: AppColors.error.withValues(alpha: 0.08),
      borderColor: AppColors.error.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No se pudo cargar el detalle', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            code,
            style: textTheme.labelSmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionErrorBanner extends StatelessWidget {
  const _ActionErrorBanner({required this.state});

  final AccessTicketCheckInState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.error.withValues(alpha: 0.08),
      borderColor: AppColors.error.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.code ?? 'ERROR',
            style: textTheme.labelSmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 6),
          Text(
            state.message ?? 'No se pudo confirmar el acceso.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({required this.event});

  final AccessTicketScanLog event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final result = event.result;
    final accent = _resultAccent(result);

    return LemaStatusStripCard(
      accent: accent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.label} · ${event.reasonCode}',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.source} · ${event.actor.displayLabel}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDateTime(event.createdAt),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketStatusPresentation {
  const _TicketStatusPresentation({required this.label, required this.accent});

  final String label;
  final Color accent;
}

_TicketStatusPresentation _ticketStatusPresentation(String status) {
  switch (status) {
    case 'issued':
      return const _TicketStatusPresentation(
        label: 'Pendiente',
        accent: AppColors.warning,
      );
    case 'checked_in':
      return const _TicketStatusPresentation(
        label: 'Usado',
        accent: AppColors.success,
      );
    case 'cancelled':
    case 'voided':
      return const _TicketStatusPresentation(
        label: 'Cancelado',
        accent: AppColors.error,
      );
    default:
      return const _TicketStatusPresentation(
        label: 'Desconocido',
        accent: AppColors.onSurfaceMuted,
      );
  }
}

Color _resultAccent(TicketAccessResultCode result) {
  switch (result) {
    case TicketAccessResultCode.valid:
      return AppColors.success;
    case TicketAccessResultCode.alreadyUsed:
      return AppColors.warning;
    case TicketAccessResultCode.cancelledOrInvalid:
      return AppColors.error;
    case TicketAccessResultCode.notFound:
      return AppColors.onSurfaceMuted;
    case TicketAccessResultCode.wrongEvent:
      return AppColors.secondary;
    case TicketAccessResultCode.forbidden:
      return AppColors.error;
    case TicketAccessResultCode.temporaryError:
      return AppColors.warning;
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
