import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F9FE), Color(0xFFDDE8F3)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '多裝置同步 + 唯讀分享',
                            style: TextStyle(
                              color: AppColors.accentStrong,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('桃園嘉義行', style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 12),
                        const Text(
                          '先用登入流程把旅程綁到單一帳號，之後再接上 Supabase Auth 與實際 session。',
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/trips'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.accent,
                          ),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('以 Google 登入（暫時示意）'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/trips'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          icon: const Icon(Icons.apple),
                          label: const Text('以 Apple 登入（暫時示意）'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
