import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:go_router/go_router.dart';
import 'package:step_sync/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:step_sync/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:step_sync/features/groups/data/models/group_model.dart';
import 'package:step_sync/core/widgets/clay_card.dart';

final leaderboardRemoteProvider = Provider((ref) => LeaderboardRemoteDataSource());

final topConsistentPerformerProvider = StreamProvider<LeaderboardEntryModel?>((ref) {
  final ds = ref.watch(leaderboardRemoteProvider);
  return ds.getConsistencyLeaderboardStream(limit: 1).map((list) => list.isNotEmpty ? list.first : null);
});

final topGroupProvider = FutureProvider<GroupModel?>((ref) async {
  final ds = ref.watch(leaderboardRemoteProvider);
  final list = await ds.getMonthlyTopGroups(limit: 1);
  return list.isNotEmpty ? list.first : null;
});

class DashboardHighlights extends ConsumerWidget {
  const DashboardHighlights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnerAsync = ref.watch(topConsistentPerformerProvider);
    final topGroupAsync = ref.watch(topGroupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Top Performers',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: winnerAsync.when(
                data: (winner) => _HighlightCard(
                  title: 'Most Consistent',
                  name: winner?.name ?? 'No data',
                  value: winner != null ? '${(winner.consistencyScore * 5.0).toStringAsFixed(1)}★ rating' : '-',
                  icon: Icons.star_rounded,
                  color: AppColors.primaryBlue,
                  onTap: () => context.push('/leaderboard'),
                ),
                loading: () => const _HighlightCardLoading(),
                error: (_, __) => const SizedBox(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: topGroupAsync.when(
                data: (group) => _HighlightCard(
                  title: 'Top Group',
                  name: group?.name ?? 'No data',
                  value: group != null ? '${Formatters.formatNumber(group.totalSteps ~/ (group.memberUids.isNotEmpty ? group.memberUids.length : 1))} avg steps' : '-',
                  icon: Icons.groups_rounded,
                  color: AppColors.secondaryTeal,
                  onTap: () => context.push('/groups'),
                ),
                loading: () => const _HighlightCardLoading(),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String name;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _HighlightCard({
    required this.title,
    required this.name,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClayCard(
      onTap: onTap,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutQuad);
  }
}

class _HighlightCardLoading extends StatelessWidget {
  const _HighlightCardLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      borderRadius: 16,
      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : AppColors.lightSurface.withValues(alpha: 0.5),
      child: const SizedBox(height: 100),
    );
  }
}
