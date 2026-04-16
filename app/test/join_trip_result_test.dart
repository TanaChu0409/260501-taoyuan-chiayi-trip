import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner_app/features/trips/data/join_trip_result.dart';

void main() {
  test('maps backend success status', () {
    expect(
      joinTripByCodeStatusFromBackend('success'),
      JoinTripByCodeStatus.success,
    );
  });

  test('maps backend already joined status', () {
    expect(
      joinTripByCodeStatusFromBackend('already_joined'),
      JoinTripByCodeStatus.alreadyJoined,
    );
  });

  test('falls back to trip not found for unknown backend status', () {
    expect(
      joinTripByCodeStatusFromBackend('unexpected'),
      JoinTripByCodeStatus.tripNotFound,
    );
    expect(
      joinTripByCodeStatusFromBackend(null),
      JoinTripByCodeStatus.tripNotFound,
    );
  });
}
