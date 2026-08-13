import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/ticket_models.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';

void main() {
  test('reset clears a failed ticket check-in', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      accessTicketCheckInControllerProvider.notifier,
    );

    await controller.confirmSelectedTicket();
    controller.reset();

    expect(
      container.read(accessTicketCheckInControllerProvider).status,
      AccessActionStatus.idle,
    );
  });

  test('reads the compact check-in log returned by manual validation', () {
    final outcome = AccessTicketCheckInOutcome.fromJson({
      'result_code': 'valid',
      'reason_code': 'CHECKED_IN',
      'can_check_in': false,
      'ticket': null,
      'scan_log': {
        'id': 'log-id',
        'created_at': '2026-08-08T12:00:00Z',
        'result_code': 'valid',
        'reason_code': 'CHECKED_IN',
        'source': 'manual_detail',
      },
    });

    expect(outcome.scanLog?.source, 'manual_detail');
    expect(outcome.scanLog?.actor.displayLabel, 'Operador');
  });
}
