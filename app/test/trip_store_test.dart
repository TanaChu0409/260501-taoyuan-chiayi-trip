import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';
import 'package:trip_planner_app/features/trips/data/trip_service.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';

void main() {
  test('stop item json roundtrip preserves fields', () {
    const stop = StopItem(
      id: 'stop-1',
      title: '嘉義站',
      timeLabel: '9:5',
      note: '測試備註',
      badge: '午餐',
      mapUrl: 'https://example.com',
      isHighlight: true,
      sortOrder: 2,
    );

    final restored = StopItem.fromJson(stop.toJson());

    expect(restored.id, 'stop-1');
    expect(restored.title, '嘉義站');
    expect(restored.timeLabel, '09:05');
    expect(restored.note, '測試備註');
    expect(restored.badge, '午餐');
    expect(restored.mapUrl, 'https://example.com');
    expect(restored.isHighlight, isTrue);
    expect(restored.sortOrder, 2);
  });

  test('trip summary stop count aggregates nested stops', () {
    const trip = TripSummary(
      id: 'trip-1',
      title: '測試旅程',
      dateRange: '2026/05/01 - 2026/05/02',
      role: TripRole.owner,
      days: [
        TripDay(
          id: 'day-1',
          label: '第一天',
          dateLabel: '5/1',
          subtitle: '說明',
          stops: [
            StopItem(title: 'A'),
            StopItem(title: 'B'),
          ],
        ),
        TripDay(
          id: 'day-2',
          label: '第二天',
          dateLabel: '5/2',
          subtitle: '說明',
          stops: [StopItem(title: 'C')],
        ),
      ],
    );

    expect(trip.stopCount, 3);
  });

  test('sort stops chronologically with untimed stops last', () {
    const stops = [
      StopItem(title: '午餐', timeLabel: '12:00', sortOrder: 1),
      StopItem(title: '未排定', sortOrder: 0),
      StopItem(title: '早餐', timeLabel: '08:30', sortOrder: 2),
    ];

    final sorted = sortStopsChronologically(stops);

    expect(sorted.map((stop) => stop.title).toList(), ['早餐', '午餐', '未排定']);
  });

  test('sort stops keeps sort order for matching times', () {
    const stops = [
      StopItem(title: 'B 點', timeLabel: '09:00', sortOrder: 1),
      StopItem(title: 'A 點', timeLabel: '09:00', sortOrder: 0),
      StopItem(title: 'C 點', timeLabel: '09:00', sortOrder: 2),
    ];

    final sorted = sortStopsChronologically(stops);

    expect(sorted.map((stop) => stop.title).toList(), ['A 點', 'B 點', 'C 點']);
  });

  test('trip summary copyWith can keep and replace color', () {
    const trip = TripSummary(
      id: 'trip-1',
      title: '測試旅程',
      dateRange: '2026/05/01 - 2026/05/02',
      role: TripRole.owner,
      days: [],
      color: '#003D79',
    );

    final updated = trip.copyWith(color: '#F97316');

    expect(trip.color, '#003D79');
    expect(updated.color, '#F97316');
    expect(updated.title, trip.title);
  });

  test('trip store updates local trip color after service update', () async {
    final service = _FakeTripService(
      trips: const [
        TripSummary(
          id: 'trip-1',
          title: '測試旅程',
          dateRange: '2026/05/01 - 2026/05/02',
          role: TripRole.owner,
          days: [],
        ),
      ],
    );
    final store = TripStore(tripService: service);

    await store.ensureLoaded();
    await store.updateTripColor(tripId: 'trip-1', color: '#15803D');

    expect(service.updatedTripId, 'trip-1');
    expect(service.updatedColor, '#15803D');
    expect(store.trips.single.color, '#15803D');
  });
}

class _FakeTripService extends TripService {
  _FakeTripService({required this.trips});

  final List<TripSummary> trips;
  String? updatedTripId;
  String? updatedColor;

  @override
  Future<List<TripSummary>> fetchTripsForCurrentUser() async {
    return trips;
  }

  @override
  Future<void> updateTripColor({
    required String tripId,
    required String color,
  }) async {
    updatedTripId = tripId;
    updatedColor = color;
  }
}
