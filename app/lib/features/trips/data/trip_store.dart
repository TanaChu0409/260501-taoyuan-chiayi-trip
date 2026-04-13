import 'package:flutter/foundation.dart';
import 'package:trip_planner_app/features/notifications/services/notification_service.dart';
import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';

class TripStore extends ChangeNotifier {
  TripStore._() {
    _seedNotifications();
  }

  static final TripStore instance = TripStore._();

  final List<TripSummary> _trips = List<TripSummary>.from(demoTrips);

  List<TripSummary> get trips => List<TripSummary>.unmodifiable(_trips);

  TripSummary? findById(String id) {
    for (final trip in _trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }

  TripSummary createTrip({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final tripId = _slugify(title, DateTime.now().millisecondsSinceEpoch);
    final days = <TripDay>[];
    var date = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDate = DateTime(endDate.year, endDate.month, endDate.day);
    var index = 0;

    while (!date.isAfter(lastDate)) {
      index += 1;
      days.add(
        TripDay(
          id: '$tripId-day$index',
          label: '第${_toChineseNumber(index)}天',
          dateLabel: '${date.month}/${date.day}',
          subtitle: index == 1 ? '從這一天開始安排行程。' : '這一天的詳細行程尚未建立。',
          stops: const [],
        ),
      );
      date = date.add(const Duration(days: 1));
    }

    final trip = TripSummary(
      id: tripId,
      title: title,
      dateRange: _formatRange(startDate, endDate),
      role: TripRole.owner,
      days: days,
    );

    _trips.insert(0, trip);
    NotificationService.instance.scheduleTripReminders(trip);
    notifyListeners();
    return trip;
  }

  bool deleteTrip(String tripId) {
    final index = _trips.indexWhere((trip) => trip.id == tripId && trip.role == TripRole.owner);
    if (index == -1) {
      return false;
    }

    _trips.removeAt(index);
    NotificationService.instance.cancelTripReminders(tripId);
    notifyListeners();
    return true;
  }

  bool leaveSharedTrip(String tripId) {
    final index = _trips.indexWhere((trip) => trip.id == tripId && trip.role == TripRole.guest);
    if (index == -1) {
      return false;
    }

    _trips.removeAt(index);
    NotificationService.instance.cancelTripReminders(tripId);
    notifyListeners();
    return true;
  }

  void resetForTests() {
    _trips
      ..clear()
      ..addAll(demoTrips);
    NotificationService.instance.resetForTests();
    _seedNotifications();
    notifyListeners();
  }

  void _seedNotifications() {
    for (final trip in _trips) {
      NotificationService.instance.scheduleTripReminders(trip);
    }
  }

  String _formatRange(DateTime startDate, DateTime endDate) {
    String format(DateTime value) {
      final month = value.month.toString().padLeft(2, '0');
      final day = value.day.toString().padLeft(2, '0');
      return '${value.year}/$month/$day';
    }

    return '${format(startDate)} - ${format(endDate)}';
  }

  String _slugify(String input, int timestamp) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), '-');
    final ascii = normalized.replaceAll(RegExp(r'[^\w\-\u4e00-\u9fff]'), '');
    return '${ascii.isEmpty ? 'trip' : ascii}-$timestamp';
  }

  String _toChineseNumber(int value) {
    const labels = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (value >= 0 && value < labels.length) {
      return labels[value];
    }
    return value.toString();
  }
}
