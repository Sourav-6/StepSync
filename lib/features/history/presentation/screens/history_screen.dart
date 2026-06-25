import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/loading_shimmer.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/history/presentation/providers/history_provider.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';
import 'package:step_sync/core/widgets/clay_card.dart';

/// History screen with Daily / Weekly / Monthly tabs and charts.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tab = ref.watch(historyTabProvider);
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.history,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: HistoryTab.values.map((t) {
                final isSelected = t == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(historyTabProvider.notifier).state = t,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(
                        _tabLabel(t),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textLightSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tab content
          Expanded(
            child: userState.when(
              loading: () => const DashboardShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Not logged in'));
                }
                switch (tab) {
                  case HistoryTab.daily:
                    return _DailyView(uid: user.uid);
                  case HistoryTab.weekly:
                    return _WeeklyView(uid: user.uid);
                  case HistoryTab.monthly:
                    return _MonthlyView(uid: user.uid);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabel(HistoryTab tab) {
    switch (tab) {
      case HistoryTab.daily:
        return AppStrings.daily;
      case HistoryTab.weekly:
        return AppStrings.weekly;
      case HistoryTab.monthly:
        return AppStrings.monthly;
    }
  }
}

/// Daily view showing today's summary.
class _DailyView extends ConsumerWidget {
  final String uid;
  const _DailyView({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stepData = ref.watch(todayStepsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Summary",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            context, 'Steps', Formatters.formatNumber(stepData.steps),
            Icons.directions_walk_rounded, AppColors.primaryBlue,
          ),
          _buildStatRow(
            context, 'Distance',
            Formatters.formatDistance(stepData.distance),
            Icons.route_rounded, AppColors.secondaryTeal,
          ),
          _buildStatRow(
            context, 'Calories',
            Formatters.formatCalories(stepData.calories),
            Icons.local_fire_department_rounded, AppColors.accentOrange,
          ),
          _buildStatRow(
            context, 'Goal Progress', '${stepData.progressPercent}%',
            Icons.flag_rounded, AppColors.successGreen,
          ),
        ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.05),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekly view with bar chart.
class _WeeklyView extends ConsumerWidget {
  final String uid;
  const _WeeklyView({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyData = ref.watch(weeklyHistoryProvider(uid));

    return weeklyData.when(
      loading: () => const DashboardShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (days) {
        final stats = WeeklyStats.fromDays(days);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.last7Days,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Bar chart
              ClayCard(
                height: AppDimensions.chartHeight + 40,
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: 24,
                child: _buildBarChart(days, isDark),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 20),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Steps',
                      Formatters.formatNumber(stats.totalSteps),
                      AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Avg/Day',
                      Formatters.formatNumber(stats.avgSteps.round()),
                      AppColors.secondaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Distance',
                      Formatters.formatDistance(stats.totalDistance),
                      AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Calories',
                      Formatters.formatCalories(stats.totalCalories),
                      AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<DailyStepsEntity> days, bool isDark) {
    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return Formatters.formatDateKey(date);
    });

    final dayNames = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return Formatters.formatDayNameShort(date);
    });

    final stepsMap = <String, int>{};
    for (final d in days) {
      stepsMap[d.date] = d.steps;
    }

    final maxSteps = stepsMap.values.isEmpty
        ? 10000.0
        : stepsMap.values.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSteps * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                Formatters.formatNumber(rod.toY.round()),
                GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dayNames.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dayNames[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) {
          final steps = (stepsMap[last7[i]] ?? 0).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: steps,
                width: AppDimensions.barChartBarWidth,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Monthly view with line chart and calendar summary.
class _MonthlyView extends ConsumerWidget {
  final String uid;
  const _MonthlyView({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyData = ref.watch(monthlyHistoryProvider(uid));

    return monthlyData.when(
      loading: () => const DashboardShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (days) {
        final stats = MonthlyStats.fromDays(days);
        final now = DateTime.now();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatters.formatDateMinimal(now).split(' ').first.isEmpty
                    ? 'This Month'
                    : '${_monthName(now.month)} ${now.year}',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Line chart
              ClayCard(
                height: AppDimensions.chartHeight + 40,
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: 24,
                child: _buildLineChart(days, isDark),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 20),

              // Monthly summary
              Row(
                children: [
                  Expanded(
                    child: _buildStat(context, AppStrings.totalMonthlySteps,
                        Formatters.formatNumber(stats.totalSteps), AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStat(context, AppStrings.averageDailySteps,
                        Formatters.formatNumber(stats.avgDailySteps.round()),
                        AppColors.secondaryTeal),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStat(context, 'Active Days',
                        '${stats.activeDays}', AppColors.successGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStat(context, 'Total Calories',
                        Formatters.formatCalories(stats.totalCalories),
                        AppColors.accentOrange),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart(List<DailyStepsEntity> days, bool isDark) {
    if (days.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: GoogleFonts.inter(
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textLightSecondary,
          ),
        ),
      );
    }

    // Sort by date
    final sorted = List<DailyStepsEntity>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxSteps = sorted
        .reduce((a, b) => a.steps > b.steps ? a : b)
        .steps
        .toDouble();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  Formatters.formatNumber(spot.y.round()),
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxSteps / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.15)
                : AppColors.lightBorder.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (sorted.length / 5).ceilToDouble().clamp(1, 10),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    sorted[index].date.split('-').last,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sorted.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.steps.toDouble());
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.secondaryTeal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.secondaryTeal,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.darkBg : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondaryTeal.withValues(alpha: 0.3),
                  AppColors.secondaryTeal.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }
}
