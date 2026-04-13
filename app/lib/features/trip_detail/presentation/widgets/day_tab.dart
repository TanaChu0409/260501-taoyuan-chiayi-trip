import 'package:flutter/material.dart';
import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';
import 'package:trip_planner_app/features/trip_detail/presentation/widgets/stop_card.dart';

class DayTab extends StatelessWidget {
  const DayTab({
    super.key,
    required this.day,
    required this.isReadOnly,
  });

  final TripDay day;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      itemCount: day.stops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final stop = day.stops[index];
        return StopCard(stop: stop, isReadOnly: isReadOnly);
      },
    );
  }
}
