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
String _monthName(int month) {
  const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return months[month];
}

class _MonthSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void changeMonth(int offset) {
      final newMonth = DateTime(selectedMonth.year, selectedMonth.month + offset, 1);
      final now = DateTime.now();
      final minDate = DateTime(now.year, now.month - 3, 1);
      final maxDate = DateTime(now.year, now.month, 1);
      
      if (newMonth.isAfter(maxDate) || newMonth.isBefore(minDate)) return;
      ref.read(selectedMonthProvider.notifier).state = newMonth;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => changeMonth(-1),
          icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
        ),
        Text(
          '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => changeMonth(1),
          icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }
}

/// Daily view showing a calendar and selected day's summary.
class _DailyView extends ConsumerStatefulWidget {
  final String uid;
  const _DailyView({required this.uid});

  @override
  ConsumerState<_DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends ConsumerState<_DailyView> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cachedData = ref.watch(cachedHistoryProvider(widget.uid));

    return cachedData.when(
      loading: () => const DashboardShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allData) {
        final monthData = ref.watch(selectedMonthHistoryProvider(widget.uid));
        final selectedMonth = ref.watch(selectedMonthProvider);
        
        // Build Calendar Grid
        final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
        final firstDayWeekday = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday;
        
        final daysMap = {for (var d in monthData) d.date: d};
        
        final selectedDateStr = selectedDate != null ? Formatters.formatDateKey(selectedDate!) : Formatters.formatDateKey(DateTime.now());
        final selectedDayData = daysMap[selectedDateStr] ?? DailyStepsEntity(
            uid: widget.uid,
            date: selectedDateStr,
            steps: 0,
            distance: 0.0,
            calories: 0.0,
            starRating: 0.0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonthSelector(),
              const SizedBox(height: 16),
              ClayCard(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: 24,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => 
                        Text(d, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54))
                      ).toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: daysInMonth + firstDayWeekday - 1,
                      itemBuilder: (context, index) {
                        if (index < firstDayWeekday - 1) return const SizedBox();
                        final dayNumber = index - firstDayWeekday + 2;
                        final currentDate = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
                        final dateStr = Formatters.formatDateKey(currentDate);
                        final dayData = daysMap[dateStr];
                        final isSelected = selectedDateStr == dateStr;
                        final hasSteps = (dayData?.steps ?? 0) > 0;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = currentDate;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primaryBlue 
                                  : (hasSteps ? AppColors.primaryBlue.withValues(alpha: 0.2) : Colors.transparent),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : (isDark ? Colors.white12 : Colors.black12),
                              )
                            ),
                            child: Center(
                              child: Text(
                                dayNumber.toString(),
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 24),
              Text(
                "Day Summary",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                context, 'Steps', Formatters.formatNumber(selectedDayData.steps),
                Icons.directions_walk_rounded, AppColors.primaryBlue,
              ),
              _buildStatRow(
                context, 'Distance', Formatters.formatDistance(selectedDayData.distance),
                Icons.route_rounded, AppColors.secondaryTeal,
              ),
              _buildStatRow(
                context, 'Calories', Formatters.formatCalories(selectedDayData.calories),
                Icons.local_fire_department_rounded, AppColors.accentOrange,
              ),
              _buildStatRow(
                context, 'Star Rating', '${selectedDayData.starRating.toStringAsFixed(1)} ★',
                Icons.star_rounded, AppColors.goldBadge,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon, Color color) {
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
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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

class _WeekSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void changeWeek(int offset) {
      final newWeek = selectedWeek.add(Duration(days: offset * 7));
      final now = DateTime.now();
      final minDate = DateTime(now.year, now.month - 3, 1);
      if (newWeek.isAfter(now) || newWeek.isBefore(minDate)) return;
      ref.read(selectedWeekProvider.notifier).state = newWeek;
    }

    final endOfWeek = selectedWeek.add(const Duration(days: 6));
    final formatStart = '${_monthName(selectedWeek.month).substring(0,3)} ${selectedWeek.day}';
    final formatEnd = '${_monthName(endOfWeek.month).substring(0,3)} ${endOfWeek.day}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => changeWeek(-1),
          icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
        ),
        Text(
          '$formatStart - $formatEnd',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => changeWeek(1),
          icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }
}

/// Weekly view with bar chart showing 7 days.
class _WeeklyView extends ConsumerWidget {
  final String uid;
  const _WeeklyView({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cachedData = ref.watch(cachedHistoryProvider(uid));

    return cachedData.when(
      loading: () => const DashboardShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allData) {
        final weekData = ref.watch(selectedWeekHistoryProvider(uid));
        final selectedWeek = ref.watch(selectedWeekProvider);
        
        final daysMap = {for (var d in weekData) d.date: d};
        
        final dailySteps = <double>[];
        int totalSteps = 0;
        int maxStepDayIndex = 0;
        int maxStepVal = 0;
        
        for (var i = 0; i < 7; i++) {
          final d = selectedWeek.add(Duration(days: i));
          final dateStr = Formatters.formatDateKey(d);
          final steps = daysMap[dateStr]?.steps ?? 0;
          dailySteps.add(steps.toDouble());
          totalSteps += steps;
          if (steps > maxStepVal) {
            maxStepVal = steps;
            maxStepDayIndex = i;
          }
        }
        
        final weekAvg = totalSteps / 7;
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final bestDayName = maxStepVal > 0 ? dayNames[maxStepDayIndex] : 'N/A';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeekSelector(),
              const SizedBox(height: 20),
              ClayCard(
                height: AppDimensions.chartHeight + 40,
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: 24,
                child: _buildBarChart(dailySteps, isDark),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context, 'Total Steps',
                      Formatters.formatNumber(totalSteps), AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context, 'Daily Avg',
                      Formatters.formatNumber(weekAvg.round()), AppColors.secondaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context, 'Best Day',
                      bestDayName, AppColors.goldBadge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<double> dailySteps, bool isDark) {
    final maxSteps = dailySteps.isEmpty 
        ? 10000.0 
        : (dailySteps.reduce((a, b) => a > b ? a : b) + 1000).clamp(10000.0, double.infinity);

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSteps * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                Formatters.formatNumber(rod.toY.round()),
                GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
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
                if (index < 0 || index > 6) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dayNames[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) {
          final steps = dailySteps[i];
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
                  colors: [AppColors.primaryBlue, AppColors.primaryLight],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, Color color) {
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
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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

/// Monthly view with bar chart showing weeks of the month.
class _MonthlyView extends ConsumerWidget {
  final String uid;
  const _MonthlyView({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cachedData = ref.watch(cachedHistoryProvider(uid));

    return cachedData.when(
      loading: () => const DashboardShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allData) {
        final monthData = ref.watch(selectedMonthHistoryProvider(uid));
        
        // Group by week of month
        final weeksMap = <int, List<DailyStepsEntity>>{1: [], 2: [], 3: [], 4: [], 5: []};
        for (var d in monthData) {
          try {
            final parts = d.date.split('-');
            final day = int.parse(parts[2]);
            final weekNum = ((day - 1) / 7).floor() + 1;
            weeksMap[weekNum]?.add(d);
          } catch (_) {}
        }
        
        final weeklyTotals = <int, double>{};
        double grandTotal = 0;
        int activeDays = 0;
        
        for (var i = 1; i <= 5; i++) {
          final list = weeksMap[i]!;
          if (list.isEmpty) {
            weeklyTotals[i] = 0;
          } else {
            final sum = list.fold<int>(0, (p, c) => p + c.steps);
            grandTotal += sum;
            activeDays += list.where((x) => x.steps > 0).length;
            weeklyTotals[i] = sum.toDouble();
          }
        }
        
        final overallAvg = activeDays == 0 ? 0 : grandTotal / activeDays;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonthSelector(),
              const SizedBox(height: 20),
              ClayCard(
                height: AppDimensions.chartHeight + 40,
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: 24,
                child: _buildBarChart(weeklyTotals, isDark),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context, 'Total Steps',
                      Formatters.formatNumber(grandTotal.round()), AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context, 'Active Avg',
                      Formatters.formatNumber(overallAvg.round()), AppColors.secondaryTeal,
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

  Widget _buildBarChart(Map<int, double> weeklyTotals, bool isDark) {
    final maxSteps = weeklyTotals.values.isEmpty 
        ? 10000.0 
        : (weeklyTotals.values.reduce((a, b) => a > b ? a : b) + 1000).clamp(10000.0, double.infinity);
        
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSteps * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                Formatters.formatNumber(rod.toY.round()),
                GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
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
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Week ${value.toInt() + 1}",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(5, (i) {
          final steps = weeklyTotals[i + 1] ?? 0.0;
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
                  colors: [AppColors.secondaryTeal, AppColors.successGreen],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, Color color) {
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
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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
