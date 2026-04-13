import 'package:go_router/go_router.dart';
import 'package:trip_planner_app/features/auth/presentation/auth_screen.dart';
import 'package:trip_planner_app/features/notifications/presentation/navigation_mode_screen.dart';
import 'package:trip_planner_app/features/trip_detail/presentation/trip_detail_screen.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';
import 'package:trip_planner_app/features/trips/presentation/trips_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/trips',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripsListScreen(),
      routes: [
        GoRoute(
          path: ':tripId',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            final trip = TripStore.instance.findById(tripId);
            if (trip == null) {
              return const TripsListScreen();
            }
            return TripDetailScreen(trip: trip);
          },
          routes: [
            GoRoute(
              path: 'navigation',
              builder: (context, state) {
                final tripId = state.pathParameters['tripId']!;
                final trip = TripStore.instance.findById(tripId);
                if (trip == null) {
                  return const TripsListScreen();
                }
                return NavigationModeScreen(trip: trip);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
