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

    test('preserves custom invitation details from the scan snapshot', () {
      final outcome = AccessScanOutcome.fromJson(
        stage: AccessScanStage.checkIn,
        source: AccessScanSource.scanner,
        rawInput: 'INVITACION',
        json: <String, dynamic>{
          'result_code': 'valid',
          'can_check_in': true,
          'event_match': true,
          'ticket': <String, dynamic>{
            'id': 'ticket-3',
            'event_id': 'event-a',
            'ticket_type': <String, dynamic>{
              'name': 'Acceso backstage',
              'description': 'Equipo de producción',
            },
            'attendee': <String, dynamic>{},
            'order': <String, dynamic>{'id': 'order-3', 'status': 'paid'},
            'code': 'INVITACION',
            'status': 'issued',
            'can_check_in': true,
          },
        },
      );

      expect(outcome.ticket?.ticketTypeLabel, 'Acceso backstage');
      expect(
        outcome.ticket?.ticketTypeDescriptionLabel,
        'Equipo de producción',
      );
    });

    test('parses remaining and consumed ticket add-ons', () {
      final outcome = AccessScanOutcome.fromJson(
        stage: AccessScanStage.checkIn,
        source: AccessScanSource.scanner,
        rawInput: 'EXTRAS',
        json: <String, dynamic>{
          'result_code': 'already_used',
          'can_check_in': false,
          'event_match': true,
          'ticket': <String, dynamic>{
            'id': 'ticket-4',
            'event_id': 'event-a',
            'ticket_type': <String, dynamic>{'name': 'General'},
            'attendee': <String, dynamic>{},
            'order': <String, dynamic>{'id': 'order-4', 'status': 'paid'},
            'code': 'EXTRAS',
            'status': 'checked_in',
            'can_check_in': false,
            'zone_offer': <String, dynamic>{
              'zone_name': 'VIP Terraza',
              'service_starts_at': '2026-09-15T20:00:00Z',
              'service_ends_at': '2026-09-15T23:30:00Z',
            },
            'validity_window': <String, dynamic>{
              'starts_at': '2026-09-15T19:00:00Z',
              'ends_at': '2026-09-16T01:00:00Z',
            },
            'add_ons': <Map<String, dynamic>>[
              <String, dynamic>{
                'assignment_id': 'assignment-1',
                'name': 'Consumición',
                'quantity': 3,
                'refunded_quantity': 0,
                'redeemed_quantity': 1,
                'pending_refund_quantity': 0,
                'remaining_quantity': 2,
                'active_redemptions': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'redemption-1',
                    'quantity': 1,
                    'created_at': '2026-09-15T20:00:00Z',
                    'source': 'scanner',
                  },
                ],
              },
            ],
          },
        },
      );

      final addOn = outcome.ticket!.addOns.single;
      expect(addOn.displayName, 'Consumición');
      expect(addOn.redeemedQuantity, 1);
      expect(addOn.remainingQuantity, 2);
      expect(addOn.redemptions.single.quantity, 1);
      expect(outcome.ticket!.zoneOffer?.name, 'VIP Terraza');
      expect(outcome.ticket!.zoneOffer?.displayName, 'Reservado · VIP Terraza');
      expect(
        outcome.ticket!.zoneOffer?.serviceEndsAt,
        DateTime.parse('2026-09-15T23:30:00Z'),
      );
      expect(
        outcome.ticket!.validityWindow?.startsAt,
        DateTime.parse('2026-09-15T19:00:00Z'),
      );
    });

    test('requires an operator decision outside the scan validity window', () {
      final outcome = AccessScanOutcome.fromJson(
        stage: AccessScanStage.checkIn,
        source: AccessScanSource.scanner,
        rawInput: 'EARLY',
        json: <String, dynamic>{
          'result_code': 'cancelled_or_invalid',
          'reason_code': 'TICKET_VALIDITY_NOT_STARTED',
          'can_check_in': false,
          'event_match': true,
          'ticket': <String, dynamic>{
            'id': 'ticket-5',
            'event_id': 'event-a',
            'status': 'issued',
            'validity_window': <String, dynamic>{
              'starts_at': '2026-09-15T20:00:00Z',
              'ends_at': '2026-09-15T23:00:00Z',
            },
          },
        },
      );

      expect(outcome.requiresValidityDecision, isTrue);
      expect(outcome.displayHeadline, 'Fuera del horario válido');
      expect(
        outcome.displayReasonLabel,
        'Aún no está dentro del horario válido',
      );
    });
  });
}
