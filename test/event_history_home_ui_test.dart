import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/screens/event_ui.dart';

void main() {
  test('home history falls back to the scanned reference', () {
    const item = AccessHistoryItem(
      id: 'history-1',
      createdAt: null,
      resultCode: 'not_found',
      reasonCode: 'TICKET_NOT_FOUND',
      source: 'scanner',
      inputKind: 'manual',
      rawInput: '  GUEST-42  ',
      normalizedInput: null,
      ticket: null,
      actor: AccessActor(
        userId: null,
        profileId: null,
        displayName: null,
        username: null,
      ),
    );

    expect(item.detailLabels, ['Sin tipo de entrada', 'GUEST-42']);
  });
}
