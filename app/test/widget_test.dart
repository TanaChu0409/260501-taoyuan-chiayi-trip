import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner_app/app.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';

void main() {
  setUp(() {
    TripStore.instance.resetForTests();
  });

  testWidgets('app renders trip landing content', (WidgetTester tester) async {
    await tester.pumpWidget(const TripPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('桃園嘉義行動導覽'), findsOneWidget);
    expect(find.text('Owner 可編輯 · Guest 唯讀'), findsOneWidget);
    expect(find.text('新增旅程'), findsOneWidget);
  });
}
