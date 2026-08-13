import 'package:flutter/material.dart';

import '../models/event_models.dart' as event_models;
import '../models/history_models.dart' as history_models;
import '../models/scan_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import 'event_ui.dart';

class HistoryScanResultSnapshot {
  const HistoryScanResultSnapshot({
    required this.resultCode,
    required this.sourceLabel,
    this.reasonCode,
    this.referenceLabel,
    this.subject,
    this.ticketTypeLabel,
    this.ticketTypeDescription,
    this.attemptedAt,
  });

  factory HistoryScanResultSnapshot.fromEventHistoryItem(
    event_models.AccessHistoryItem item,
  ) {
    final ticket = item.ticket;
    return HistoryScanResultSnapshot(
      resultCode: item.resultCode ?? '',
      reasonCode: _cleanText(item.reasonCode),
      sourceLabel: _sourceLabel(item.source),
      referenceLabel: _eventHistoryReferenceLabel(item),
      subject: _cleanText(ticket?.attendee.fullName),
      ticketTypeLabel: _cleanText(ticket?.ticketType.name),
      ticketTypeDescription: _cleanText(ticket?.ticketType.description),
      attemptedAt: item.createdAt,
    );
  }

  factory HistoryScanResultSnapshot.fromHistoryEntry(
    history_models.AccessHistoryEntry item,
  ) {
    final ticket = item.ticket;
    return HistoryScanResultSnapshot(
      resultCode: item.resultCode,
      reasonCode: _cleanText(item.reasonCode),
      sourceLabel: _sourceLabel(item.source),
      referenceLabel: _historyEntryReferenceLabel(item),
      subject: _cleanText(ticket?.attendee.fullName),
      ticketTypeLabel: _cleanText(ticket?.ticketType.name),
      ticketTypeDescription: _cleanText(ticket?.ticketType.description),
      attemptedAt: item.createdAt,
    );
  }

  final String resultCode;
  final String sourceLabel;
  final String? reasonCode;
  final String? referenceLabel;
  final String? subject;
  final String? ticketTypeLabel;
  final String? ticketTypeDescription;
  final DateTime? attemptedAt;

  Color get accent => historyResultColor(resultCode);
  String get statusLabel => historyResultLabel(resultCode);
  String get headline => accessScanHeadlineForResultCode(resultCode);
  String get body => accessScanBodyForResultCode(resultCode);
}

class HistoryScanResultScreen extends StatelessWidget {
  const HistoryScanResultScreen({super.key, required this.snapshot});

  final HistoryScanResultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final detailText = snapshot.ticketTypeDescription ?? snapshot.body;
    final facts = <LemaResultFact>[
      if (snapshot.referenceLabel != null)
        LemaResultFact(
          label: 'Referencia',
          value: snapshot.referenceLabel!,
          icon: Icons.pin_outlined,
        ),
      if (snapshot.reasonCode != null)
        LemaResultFact(
          label: 'Motivo',
          value: snapshot.reasonCode!,
          icon: Icons.info_outline_rounded,
        ),
      if (snapshot.ticketTypeLabel != null)
        LemaResultFact(
          label: 'Tipo',
          value: snapshot.ticketTypeLabel!,
          icon: Icons.confirmation_number_outlined,
        ),
      if (snapshot.attemptedAt != null)
        LemaResultFact(
          label: 'Intento',
          value: _formatDateTime(snapshot.attemptedAt!),
          icon: Icons.schedule_rounded,
        ),
    ];

    return LemaScaffold(
      body: LemaResultScreenLayout(
        accent: snapshot.accent,
        content: [
          LemaResultHero(
            kicker: 'Resultado del escaneo',
            status: snapshot.statusLabel,
            accent: snapshot.accent,
            icon: _iconForResultCode(snapshot.resultCode),
            subject: snapshot.subject,
            supporting: lemaJoinText([
              snapshot.ticketTypeLabel,
              snapshot.referenceLabel,
            ]),
          ),
          if (detailText.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              detailText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ],
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 16),
            LemaResultFacts(facts: facts, accent: snapshot.accent),
          ],
        ],
        actions: [
          LemaPrimaryButton(
            label: 'Cerrar',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

void openHistoryScanResultScreen(
  BuildContext context, {
  required HistoryScanResultSnapshot snapshot,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => HistoryScanResultScreen(snapshot: snapshot),
    ),
  );
}

String? _eventHistoryReferenceLabel(event_models.AccessHistoryItem item) {
  final ticketCode = _cleanText(item.ticket?.code);
  if (ticketCode != null) {
    return ticketCode;
  }

  final normalizedInput = _cleanText(item.normalizedInput);
  if (normalizedInput != null) {
    return normalizedInput;
  }

  return _cleanText(item.rawInput);
}

String? _historyEntryReferenceLabel(history_models.AccessHistoryEntry item) {
  final ticketCode = _cleanText(item.ticket?.code);
  if (ticketCode != null) {
    return ticketCode;
  }

  final relatedCode = _cleanText(item.relatedTicketCode);
  if (relatedCode != null) {
    return 'CODE: $relatedCode';
  }

  final token = _cleanText(item.extractedScanToken);
  if (token != null) {
    return 'TOKEN: $token';
  }

  final normalizedInput = _cleanText(item.normalizedInput);
  if (normalizedInput != null) {
    return normalizedInput;
  }

  return _cleanText(item.rawInput);
}

String _sourceLabel(String? source) {
  switch (source) {
    case 'scanner':
      return 'Escáner';
    case 'manual_code':
      return 'Código manual';
    case 'manual_search':
      return 'Búsqueda manual';
    case 'manual_detail':
      return 'Detalle manual';
    default:
      return _cleanText(source) ?? 'Otro origen';
  }
}

String? _cleanText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month · $hour:$minute';
}

IconData _iconForResultCode(String resultCode) {
  switch (resultCode) {
    case 'valid':
      return Icons.check_circle_rounded;
    case 'already_used':
      return Icons.history_toggle_off_rounded;
    case 'wrong_event':
      return Icons.swap_horiz_rounded;
    case 'cancelled_or_invalid':
      return Icons.block_rounded;
    case 'not_found':
      return Icons.search_off_rounded;
    case 'forbidden':
      return Icons.lock_outline_rounded;
    case 'temporary_error':
      return Icons.cloud_off_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}
