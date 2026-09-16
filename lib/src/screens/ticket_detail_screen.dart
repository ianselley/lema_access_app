import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rpc_exception.dart';
import '../models/add_on_models.dart';
import '../models/ticket_models.dart';
import '../providers/ticket_providers.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accessSelectedTicketDetailProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                    onUndo: () async {
                      await ref
                          .read(accessTicketCheckInControllerProvider.notifier)
                          .undoSelectedTicketCheckIn();
                    },
                  ),
                ),
              ],
            ],
          ),
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
    required this.onUndo,
  });

  final AccessTicketDetail detail;
  final AccessTicketSelection selection;
  final AccessTicketCheckInState actionState;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onUndo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _ticketStatusPresentation(detail.ticket.status);
    final canCheckIn = detail.canCheckIn && actionState.isLoading == false;
    final canUndo =
        detail.ticket.status == 'checked_in' && actionState.isLoading == false;

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
                          _fallbackText(
                            detail.ticketType.name,
                            placeholder: 'Tipo de ticket',
                          ),
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if ((detail.ticketType.description ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            detail.ticketType.description!,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          _fallbackText(
                            detail.attendee.fullName,
                            placeholder: 'Sin nombre',
                          ),
                          style: textTheme.titleLarge?.copyWith(
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
                'Código ${_fallbackText(detail.ticket.code)}',
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
                    label: selection.detailContextLabel,
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
        if (detail.ticket.zoneOffer?.serviceStartsAt != null ||
            detail.ticket.zoneOffer?.serviceEndsAt != null ||
            detail.ticket.validityWindow != null) ...[
          _TicketSchedulePanel(ticket: detail.ticket),
          const SizedBox(height: 16),
        ],
        if (detail.ticket.addOns.isNotEmpty) ...[
          _AddOnsPanel(addOns: detail.ticket.addOns),
          const SizedBox(height: 16),
        ],
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
        if (canUndo)
          OutlinedButton.icon(
            onPressed: onUndo,
            icon: const Icon(Icons.undo_outlined),
            label: const Text('Desmarcar acceso'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        else
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

class _TicketSchedulePanel extends StatelessWidget {
  const _TicketSchedulePanel({required this.ticket});

  final AccessTicketSnapshot ticket;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final zoneOffer = ticket.zoneOffer;
    final validityWindow = ticket.validityWindow;

    return LemaPanel(
      color: AppColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horario de acceso', style: textTheme.titleLarge),
          if (zoneOffer?.serviceStartsAt != null ||
              zoneOffer?.serviceEndsAt != null) ...[
            const SizedBox(height: 12),
            _ScheduleRow(
              label: zoneOffer!.displayName,
              value: _formatInterval(
                zoneOffer.serviceStartsAt,
                zoneOffer.serviceEndsAt,
              ),
            ),
          ],
          if (validityWindow != null) ...[
            const SizedBox(height: 12),
            _ScheduleRow(
              label: 'Horario válido de escaneo',
              value: _formatInterval(
                validityWindow.startsAt,
                validityWindow.endsAt,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelLarge),
              const SizedBox(height: 3),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddOnsPanel extends StatelessWidget {
  const _AddOnsPanel({required this.addOns});

  final List<AccessTicketAddOn> addOns;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final operations = <String, _AddOnOperation>{};
    for (final addOn in addOns) {
      for (final redemption in addOn.redemptions) {
        final key =
            redemption.createdAt?.toUtc().toIso8601String() ?? redemption.id;
        operations
            .putIfAbsent(
              key,
              () => _AddOnOperation(createdAt: redemption.createdAt),
            )
            .items
            .add((addOn: addOn, redemption: redemption));
      }
    }
    final sortedOperations = operations.values.toList()
      ..sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

    return LemaPanel(
      color: AppColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extras', style: textTheme.titleLarge),
          const SizedBox(height: 14),
          for (final addOn in addOns) ...[
            Row(
              children: [
                Expanded(
                  child: Text(addOn.displayName, style: textTheme.bodyLarge),
                ),
                Text(
                  '${addOn.redeemedQuantity}/${addOn.quantity} consumidos',
                  style: textTheme.bodySmall?.copyWith(
                    color: addOn.remainingQuantity > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            if (addOn.description != null) ...[
              const SizedBox(height: 3),
              Text(
                addOn.description!,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
          if (sortedOperations.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 10),
            Text('Validaciones de extras', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (var i = 0; i < sortedOperations.length; i++) ...[
              LemaStatusStripCard(
                accent: AppColors.success,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trámite · ${_formatDateTime(sortedOperations[i].createdAt)}',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final item in sortedOperations[i].items)
                      Text(
                        '${item.redemption.quantity} × ${item.addOn.displayName}',
                        style: textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (i != sortedOperations.length - 1) const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _AddOnOperation {
  _AddOnOperation({required this.createdAt});

  final DateTime? createdAt;
  final List<({AccessTicketAddOn addOn, AccessAddOnRedemption redemption})>
  items = [];
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
            state.message ?? 'No se pudo actualizar el acceso.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
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
                  _validationLabel(event, result),
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_checkInMethodLabel(event.source)} · ${event.actor.displayLabel}',
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

String _validationLabel(
  AccessTicketScanLog event,
  TicketAccessResultCode result,
) {
  if (event.reasonCode == 'CHECK_IN_REVERSED') {
    return 'Acceso desmarcado';
  }
  return '${result.label} · ${_fallbackText(event.reasonCode)}';
}

String _checkInMethodLabel(String? source) {
  switch (source) {
    case 'scanner':
      return 'Escaneado con QR';
    case 'manual_code':
    case 'manual_search':
    case 'manual_detail':
      return 'Marcado manualmente';
    default:
      return 'Acceso registrado';
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

String _fallbackText(String? value, {String placeholder = 'Sin dato'}) {
  final text = value?.trim();
  if (text == null || text.isEmpty) {
    return placeholder;
  }
  return text;
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Sin fecha';
  }

  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

String _formatInterval(DateTime? startsAt, DateTime? endsAt) {
  if (startsAt != null && endsAt != null) {
    return '${_formatDateTime(startsAt)} – ${_formatDateTime(endsAt)}';
  }
  if (startsAt != null) return 'Desde ${_formatDateTime(startsAt)}';
  return 'Hasta ${_formatDateTime(endsAt)}';
}
