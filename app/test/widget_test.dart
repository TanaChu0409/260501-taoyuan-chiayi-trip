import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner_app/features/trips/presentation/trips_list_screen.dart';

void main() {
  testWidgets('app renders trip landing content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TripsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('旅遊規劃APP'), findsOneWidget);
    expect(
      find.text('所有旅程、天數、停靠點與分享關係都會直接以 Supabase 作為唯一資料來源。'),
      findsOneWidget,
    );
    expect(find.text('新增旅程'), findsOneWidget);
  });
}
