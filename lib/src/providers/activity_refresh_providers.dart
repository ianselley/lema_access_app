import 'package:flutter_riverpod/flutter_riverpod.dart';

final accessActivityRefreshTickProvider = StateProvider<int>((ref) => 0);

void bumpAccessActivityRefreshTick(Ref ref) {
  ref.read(accessActivityRefreshTickProvider.notifier).state++;
}
