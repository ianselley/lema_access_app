import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_models.dart';
import '../services/event_service.dart';
import 'activity_refresh_providers.dart';
import 'auth_providers.dart';

final accessCurrentEventIdProvider = StateProvider<String?>((ref) => null);

final accessEventsServiceProvider = Provider<AccessEventsService>((ref) {
  return AccessEventsService(ref.watch(accessRpcClientProvider));
});

final accessEventsProvider = FutureProvider<List<AccessEventSummary>>((
  ref,
) async {
  ref.watch(accessActivityRefreshTickProvider);
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) {
    return const <AccessEventSummary>[];
  }

  return ref.watch(accessEventsServiceProvider).getEvents();
});

final accessEventHomeProvider = FutureProvider.family<AccessEventHome, String>((
  ref,
  eventId,
) async {
  ref.watch(accessActivityRefreshTickProvider);
  await ref.watch(authSessionProvider.future);
  return ref.watch(accessEventsServiceProvider).getEventHome(eventId);
});
