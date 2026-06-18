import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/scan_models.dart';

void main() {
  group('AccessScanOutcome', () {
    test('parses wrong-event invalid context for cross-brand tickets', () {
      final outcome = AccessScanOutcome.fromJson(
        stage: AccessScanStage.checkIn,
        source: AccessScanSource.scanner,
        rawInput: 'ABC123',
        json: <String, dynamic>{
          'result_code': 'wrong_event',
          'reason_code': 'TICKET_EVENT_MISMATCH',
          'can_check_in': false,
          'event_match': false,
          'input_kind': 'code',
          'normalized_input': 'ABC123',
          'ticket_status': 'issued',
          'ticket': <String, dynamic>{
            'id': 'ticket-1',
            'event_id': 'event-b',
            'status': 'issued',
            'code': 'ABC123',
          },
          'invalid_context': <String, dynamic>{
            'category': 'different_brand',
            'ticket_status': 'issued',
            'same_brand': false,
            'same_day': true,
            'current_event': <String, dynamic>{
              'id': 'event-a',
              'name': 'Fiesta Viernes',
              'brand_name': 'Lema Nights',
              'start_time': '2026-04-16T22:00:00Z',
            },
            'ticket_event': <String, dynamic>{
              'id': 'event-b',
              'name': 'Sábado Deluxe',
              'brand_name': 'Otra Marca',
              'start_time': '2026-04-16T23:00:00Z',
            },
          },
        },
      );

      expect(outcome.invalidContext?.category, 'different_brand');
      expect(outcome.invalidContext?.ticketEvent?.displayName, 'Sábado Deluxe');
      expect(outcome.displayHeadline, 'Ticket de otra marca');
      expect(outcome.displayReasonLabel, 'Otra marca');
      expect(
        outcome.displayBody,
        'Este ticket corresponde a Sábado Deluxe. No es válido para Fiesta Viernes.',
      );
    });

    test('parses invalid status context for voided tickets', () {
      final outcome = AccessScanOutcome.fromJson(
        stage: AccessScanStage.checkIn,
        source: AccessScanSource.manualDetail,
        rawInput: 'ticket-2',
        json: <String, dynamic>{
          'result_code': 'cancelled_or_invalid',
          'reason_code': 'TICKET_STATUS_INVALID',
          'can_check_in': false,
          'event_match': true,
          'input_kind': 'ticket_id',
          'normalized_input': 'ticket-2',
          'ticket_status': 'voided',
          'ticket': <String, dynamic>{
            'id': 'ticket-2',
            'event_id': 'event-a',
            'ticket_type': <String, dynamic>{'name': 'General'},
            'attendee': <String, dynamic>{},
            'order': <String, dynamic>{'id': 'order-1', 'status': 'paid'},
            'code': 'XYZ789',
            'status': 'voided',
            'can_check_in': false,
          },
          'invalid_context': <String, dynamic>{
            'category': 'ticket_voided',
            'ticket_status': 'voided',
          },
        },
      );

      expect(outcome.invalidContext?.category, 'ticket_voided');
      expect(outcome.displayHeadline, 'Ticket anulado');
      expect(
        outcome.displayBody,
        'Este ticket fue anulado y no permite el acceso.',
      );
      expect(accessTicketStatusLabel(outcome.ticketStatus), 'Anulado');
    });
  });
}
