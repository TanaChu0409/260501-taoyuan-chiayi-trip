import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';
import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';
import 'package:trip_planner_app/features/trip_detail/presentation/widgets/day_tab.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key, required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = trip.role == TripRole.guest;

    return DefaultTabController(
      length: trip.days.length,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F9FE), Color(0xFFDDE8F3)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          trip.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isReadOnly)
                        PopupMenuButton<_TripDetailAction>(
                          tooltip: '旅程操作',
                          onSelected: (action) => _handleAction(context, action),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _TripDetailAction.leaveTrip,
                              child: Text('退出旅程'),
                            ),
                          ],
                          child: const Chip(label: Text('唯讀')),
                        )
                      else
                        PopupMenuButton<_TripDetailAction>(
                          tooltip: '旅程操作',
                          onSelected: (action) => _handleAction(context, action),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _TripDetailAction.deleteTrip,
                              child: Text('刪除旅程'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFAFDFF), Color(0xFFE2EDF8)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            trip.dateRange,
                            style: const TextStyle(
                              color: AppColors.accentStrong,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('旅程摘要', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Text(isReadOnly ? '受邀唯讀模式，可接收時程提醒與地點提醒。' : 'Owner 模式，可在後續版本直接新增 stop、管理分享與提醒設定。'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _MiniStat(value: '${trip.days.length}', label: '天數'),
                            const SizedBox(width: 12),
                            _MiniStat(value: '${trip.stopCount}', label: '停靠點'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.go('/trips/${trip.id}/navigation'),
                          icon: const Icon(Icons.navigation_outlined),
                          label: const Text('開啟導航模式'),
                        ),
                      ],
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  tabs: [
                    for (final day in trip.days)
                      Tab(text: '${day.label} · ${day.dateLabel}'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final day in trip.days)
                        DayTab(day: day, isReadOnly: isReadOnly),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, _TripDetailAction action) async {
    switch (action) {
      case _TripDetailAction.deleteTrip:
        await _deleteTrip(context);
      case _TripDetailAction.leaveTrip:
        await _leaveTrip(context);
    }
  }

  Future<void> _deleteTrip(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('刪除旅程？'),
            content: Text('此動作無法復原，${trip.title} 的所有行程與提醒都會刪除。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                child: const Text('確認刪除'),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted || !shouldDelete) {
      return;
    }

    final deleted = TripStore.instance.deleteTrip(trip.id);
    if (!context.mounted) {
      return;
    }

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已刪除旅程：${trip.title}')));
      context.go('/trips');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刪除旅程失敗')));
  }

  Future<void> _leaveTrip(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退出分享旅程？'),
            content: Text('退出後，${trip.title} 將從分享列表移除，相關提醒也會清掉。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('確認退出'),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted || !shouldLeave) {
      return;
    }

    final left = TripStore.instance.leaveSharedTrip(trip.id);
    if (!context.mounted) {
      return;
    }

    if (left) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已退出旅程：${trip.title}')));
      context.go('/trips');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('退出旅程失敗')));
  }
}

enum _TripDetailAction { deleteTrip, leaveTrip }

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
