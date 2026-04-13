import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner_app/features/notifications/services/notification_service.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';

void main() {
  final store = TripStore.instance;
  final notifications = NotificationService.instance;

  setUp(() {
    store.resetForTests();
  });

  test('owner delete removes trip and clears reminders', () {
    expect(store.findById('taoyuan-chiayi-2026'), isNotNull);
    expect(notifications.hasTripReminders('taoyuan-chiayi-2026'), isTrue);

    final deleted = store.deleteTrip('taoyuan-chiayi-2026');

    expect(deleted, isTrue);
    expect(store.findById('taoyuan-chiayi-2026'), isNull);
    expect(notifications.hasTripReminders('taoyuan-chiayi-2026'), isFalse);
  });

  test('guest leave removes shared trip and clears reminders', () {
    expect(store.findById('shared-family-trip'), isNotNull);
    expect(notifications.hasTripReminders('shared-family-trip'), isTrue);

    final left = store.leaveSharedTrip('shared-family-trip');

    expect(left, isTrue);
    expect(store.findById('shared-family-trip'), isNull);
    expect(notifications.hasTripReminders('shared-family-trip'), isFalse);
  });

  test('guest cannot use owner delete path', () {
    final deleted = store.deleteTrip('shared-family-trip');

    expect(deleted, isFalse);
    expect(store.findById('shared-family-trip'), isNotNull);
  });
}