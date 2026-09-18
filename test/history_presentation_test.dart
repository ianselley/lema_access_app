import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lema_access_app/src/models/history_models.dart';
import 'package:lema_access_app/src/screens/event_ui.dart';
import 'package:lema_access_app/src/screens/history_scan_result_screen.dart';
import 'package:lema_access_app/src/theme/app_theme.dart';

void main() {
  test('only already-used tickets with pending extras use orange', () {
    for (final result in [
      'already_used',
      'wrong_event',
      'cancelled_or_invalid',
      'not_found',
      'forbidden',
      'temporary_error',
      'unknown',
    ]) {
      expect(historyResultColor(result), AppColors.error);
      expect(
        historyResultColor(result, hasPendingExtras: true),
        result == 'already_used' ? AppColors.warning : AppColors.error,
      );
    }
    expect(historyResultColor('valid'), AppColors.success);
  });

  testWidgets('history keeps VIP name and translates database reasons', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final entry = AccessHistoryEntry.fromJson({
      'id': 'scan-1',
      'created_at': '2026-09-17T12:00:00Z',
      'result_code': 'cancelled_or_invalid',
      'reason_code': 'TICKET_VALIDITY_EXPIRED',
      'source': 'scanner',
      'actor': <String, dynamic>{},
      'ticket': {
        'id': 'ticket-1',
        'event_id': 'event-1',
        'code': 'VIP123',
        'ticket_type': {'name': 'Mesa Terraza'},
        'zone_offer': {'zone_name': 'Terraza', 'people_count_current': 8},
      },
    });
    final snapshot = HistoryScanResultSnapshot.fromHistoryEntry(entry);
    expect(snapshot.ticketTypeLabel, 'Reservado · Mesa Terraza');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: HistoryScanResultScreen(snapshot: snapshot),
      ),
    );
    expect(find.text('TICKET_VALIDITY_EXPIRED'), findsNothing);
    expect(find.text('El horario válido ya ha terminado'), findsOneWidget);
    expect(find.textContaining('Reservado · Mesa Terraza'), findsWidgets);
  });
}
