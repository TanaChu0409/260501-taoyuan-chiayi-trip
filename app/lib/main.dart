import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/app.dart';
import 'package:trip_planner_app/core/config/supabase_options.dart';
import 'package:trip_planner_app/features/notifications/services/notification_service.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseOptions.initialize();
  await NotificationService.instance.initialize();
  await TripStore.instance.initialize();
  runApp(const ProviderScope(child: TripPlannerApp()));
}
