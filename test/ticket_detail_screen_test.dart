import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/ticket_models.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';
import 'package:lema_access_app/src/screens/ticket_detail_screen.dart';

class _CheckInController extends AccessTicketCheckInController {
  int undoCount = 0;
  @override
  Future<void> undoSelectedTicketCheckIn() async {
    undoCount++;
  }
}

void main() {
  testWidgets('undo access requires confirmation and can be cancelled', (
    tester,
  ) async {
    final detail = AccessTicketDetail.fromJson({
      'ticket': {
        'id': 'ticket',
        'event_id': 'event',
        'status': 'checked_in',
        'attendee': <String, dynamic>{},
        'order': <String, dynamic>{},
        'ticket_type': {'name': 'Mesa 1'},
        'zone_offer': {'people_count_current': 7},
      },
      'attendee': <String, dynamic>{},
      'order': <String, dynamic>{},
      'ticket_type': {'name': 'Mesa 1'},
    });
    final controller = _CheckInController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessSelectedTicketProvider.overrideWith(
            (ref) => AccessTicketSelection(
              eventId: 'event',
              ticketId: 'ticket',
              query: '',
              matchReason: TicketSearchMatchReason.code,
              ticket: detail.ticket,
            ),
          ),
          accessSelectedTicketDetailProvider.overrideWith(
            (ref) async => detail,
          ),
          accessTicketCheckInControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: TicketDetailScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reservado · Mesa 1'), findsOneWidget);
    expect(find.text('7 personas'), findsOneWidget);
    await tester.ensureVisible(find.text('Desmarcar acceso'));
    await tester.tap(find.text('Desmarcar acceso'));
    await tester.pumpAndSettle();
    expect(controller.undoCount, 0);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(controller.undoCount, 0);
    await tester.tap(find.text('Desmarcar acceso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desmarcar'));
    await tester.pumpAndSettle();
    expect(controller.undoCount, 1);
  });
}
