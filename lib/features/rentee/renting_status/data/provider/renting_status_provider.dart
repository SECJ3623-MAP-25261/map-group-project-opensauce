
import 'package:easyrent/features/rentee/renting_status/services/renting_status_notifier.dart';
import 'package:easyrent/features/rentee/renting_status/domain/renting_status_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final rentingStatusProvider = StateNotifierProvider<RentingStatusNotifier,RentingStatusState>(
  (ref) {
      return RentingStatusNotifier();
  }
);