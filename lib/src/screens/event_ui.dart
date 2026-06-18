import 'package:flutter/material.dart';

import '../models/event_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';

extension AccessEventSummaryUi on AccessEventSummary {
  String get displayName => party.name ?? 'Evento sin nombre';

  String get brandLabel => brand.name ?? 'Marca sin nombre';

  String get placeLabel => place.name ?? place.city ?? 'Ubicación sin nombre';

  String get locationLabel =>
      _joinNonEmpty([placeLabel, brandLabel], 'Sin ubicación');

  bool get isLive => operationalState == 'live';

  bool get isScheduled => operationalState == 'scheduled';

  bool get isEnded => operationalState == 'ended';

  bool get isCancelled => operationalState == 'cancelled';

  bool get isDraft => operationalState == 'draft';

  bool get isArchived => operationalState == 'archived';

  bool get isFinished => isEnded || isCancelled || isArchived || isDraft;

  double get progress =>
      capacityTotal <= 0 ? 0 : checkedInCount / capacityTotal;

  String get progressLabel => '${(progress * 100).round()}%';

  String get capacityLabel => '$checkedInCount / $capacityTotal';

  String get statusLabel {
    switch (operationalState) {
      case 'live':
        return 'En vivo';
      case 'scheduled':
        return 'Programado';
      case 'ended':
        return 'Finalizado';
      case 'draft':
        return 'Borrador';
      case 'cancelled':
        return 'Cancelado';
      case 'archived':
        return 'Archivado';
      default:
        return operationalState;
    }
  }

  String get membershipLabel {
    switch (membershipRole) {
      case 'event_member':
        return 'Miembro del evento';
      case 'brand_member':
        return 'Miembro de marca';
      case 'brand_owner':
        return 'Propietario de marca';
      default:
        return membershipRole ?? 'Sin rol';
    }
  }
}

extension AccessEventHomeUi on AccessEventHome {
  String get displayName => party.name ?? 'Evento sin nombre';

  String get brandLabel => brand.name ?? 'Marca sin nombre';

  String get placeLabel => place.name ?? place.city ?? 'Ubicación sin nombre';

  String get locationLabel =>
      _joinNonEmpty([placeLabel, brandLabel], 'Sin ubicación');

  bool get isLive => operationalState == 'live';

  bool get isScheduled => operationalState == 'scheduled';

  bool get isEnded => operationalState == 'ended';

  bool get isCancelled => operationalState == 'cancelled';

  bool get isDraft => operationalState == 'draft';

  bool get isArchived => operationalState == 'archived' || party.isArchived;

  bool get isFinished => isEnded || isCancelled || isArchived || isDraft;

  double get progress => counters.capacityTotal <= 0
      ? 0
      : counters.checkedInCount / counters.capacityTotal;

  String get progressLabel => '${(progress * 100).round()}%';

  String get capacityLabel =>
      '${counters.checkedInCount} / ${counters.capacityTotal}';

  String get statusLabel {
    switch (operationalState) {
      case 'live':
        return 'En vivo';
      case 'scheduled':
        return 'Programado';
      case 'ended':
        return 'Finalizado';
      case 'draft':
        return 'Borrador';
      case 'cancelled':
        return 'Cancelado';
      case 'archived':
        return 'Archivado';
      default:
        return operationalState;
    }
  }

  String get membershipLabel {
    switch (membershipRole) {
      case 'event_member':
        return 'Miembro del evento';
      case 'brand_member':
        return 'Miembro de marca';
      case 'brand_owner':
        return 'Propietario de marca';
      default:
        return membershipRole ?? 'Sin rol';
    }
  }
}

extension AccessHistoryItemUi on AccessHistoryItem {
  String get titleLabel => ticket?.attendee.fullName ?? actor.label;

  String get subtitleLabel {
    final parts = <String>[
      if (ticket?.code != null && ticket!.code!.trim().isNotEmpty)
        ticket!.code!,
      if (normalizedInput != null && normalizedInput!.trim().isNotEmpty)
        normalizedInput!,
      if (source != null && source!.trim().isNotEmpty) source!,
    ];

    if (parts.isEmpty) {
      return 'Validación registrada';
    }

    return parts.join(' · ');
  }

  String get resultLabel => historyResultLabel(resultCode);

  Color get resultColor => historyResultColor(resultCode);

  String get relativeTimeLabel => formatRelativeTime(createdAt);
}

String historyResultLabel(String? resultCode) {
  switch (resultCode) {
    case 'valid':
      return 'Válido';
    case 'already_used':
      return 'Ya usado';
    case 'wrong_event':
      return 'Evento incorrecto';
    case 'forbidden':
      return 'Sin acceso';
    case 'not_found':
      return 'No encontrado';
    case 'temporary_error':
      return 'Error temporal';
    case 'cancelled_or_invalid':
      return 'Inválido';
    default:
      return 'Revisar';
  }
}

Color historyResultColor(String? resultCode) {
  switch (resultCode) {
    case 'valid':
      return AppColors.success;
    case 'already_used':
      return AppColors.warning;
    case 'wrong_event':
    case 'forbidden':
    case 'cancelled_or_invalid':
      return AppColors.error;
    case 'not_found':
      return const Color(0xFF9CA3AF);
    case 'temporary_error':
      return AppColors.primaryStrong;
    default:
      return AppColors.primary;
  }
}

bool historyResultNeedsExplanation(String? resultCode) {
  switch (resultCode) {
    case 'valid':
    case 'already_used':
      return false;
    default:
      return true;
  }
}

class AccessHistoryListRow extends StatelessWidget {
  const AccessHistoryListRow({
    super.key,
    required this.titleLabel,
    required this.subtitleLabel,
    required this.resultLabel,
    required this.resultColor,
    required this.relativeTimeLabel,
    this.onTap,
  });

  final String titleLabel;
  final String subtitleLabel;
  final String resultLabel;
  final Color resultColor;
  final String relativeTimeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaStatusStripCard(
      accent: resultColor,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleLabel,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                relativeTimeLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              LemaStatusPill(label: resultLabel, color: resultColor),
            ],
          ),
        ],
      ),
    );
  }
}

String formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Hace un momento';
  }

  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) {
    return 'Hace unos segundos';
  }
  if (diff.inMinutes < 60) {
    return 'Hace ${diff.inMinutes} min';
  }
  if (diff.inHours < 24) {
    return 'Hace ${diff.inHours} h';
  }
  return 'Hace ${diff.inDays} d';
}

String _joinNonEmpty(List<String> values, String fallback) {
  final filtered = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (filtered.isEmpty) {
    return fallback;
  }

  return filtered.join(' · ');
}
