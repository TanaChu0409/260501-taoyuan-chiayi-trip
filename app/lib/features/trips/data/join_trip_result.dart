import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';

enum JoinTripByCodeStatus { success, tripNotFound, alreadyJoined }

JoinTripByCodeStatus joinTripByCodeStatusFromBackend(String? value) {
  switch (value) {
    case 'success':
      return JoinTripByCodeStatus.success;
    case 'already_joined':
      return JoinTripByCodeStatus.alreadyJoined;
    case 'trip_not_found':
    default:
      return JoinTripByCodeStatus.tripNotFound;
  }
}

class JoinTripByCodeResult {
  const JoinTripByCodeResult({required this.status, this.trip});

  final JoinTripByCodeStatus status;
  final TripSummary? trip;

  bool get isSuccess => status == JoinTripByCodeStatus.success && trip != null;
}
