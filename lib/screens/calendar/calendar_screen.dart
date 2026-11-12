// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_model.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/nav_scaffold.dart';
import 'calendar_day_view.dart';
import 'calendar_month_view.dart';
import 'calendar_multi_day_view.dart';
import 'calendar_schedule_view.dart';
import 'calendar_search_bar.dart';
import 'calendar_search_results_view.dart';
import 'calendar_year_view.dart';

// ── Main widget ───────────────────────────────────────────────────────────────

class CalendarWorkspaceView extends ConsumerStatefulWidget {
  const CalendarWorkspaceView({super.key});

  @override
  ConsumerState<CalendarWorkspaceView> createState() =>
      _CalendarWorkspaceViewState();
}

class _CalendarWorkspaceViewState extends ConsumerState<CalendarWorkspaceView> {
  late DateTime _focusedDay;
  late DateTime _focusedMonth;
  late final _searchController = TextEditingController(
    text: ref.read(calendarSearchQueryProvider),
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _focusedMonth = DateTime(now.year, now.month);
  }

  /// The schedule view ignores [_focusedDay]: "Today" scrolls it instead.
  final _scheduleController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedDay = now;
      _focusedMonth = DateTime(now.year, now.month);
    });
    if (_scheduleController.hasClients) {
      _scheduleController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  CalendarViewMode get _currentView => ref.read(calendarViewModeProvider);

  void _setView(CalendarViewMode mode) =>
      ref.read(calendarViewModeProvider.notifier).set(mode);

  void _navigateForward() {
    setState(() {
      switch (_currentView) {
        case CalendarViewMode.day:
          _focusedDay = _focusedDay.add(const Duration(days: 1));
        case CalendarViewMode.week:
        case CalendarViewMode.sevenDays:
          _focusedDay = _focusedDay.add(const Duration(days: 7));
        case CalendarViewMode.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        case CalendarViewMode.year:
          _focusedMonth = DateTime(_focusedMonth.year + 1, _focusedMonth.month);
        case CalendarViewMode.schedule:
          break;
      }
    });
  }

  void _navigateBackward() {
    setState(() {
      switch (_currentView) {
        case CalendarViewMode.day:
          _focusedDay = _focusedDay.subtract(const Duration(days: 1));
        case CalendarViewMode.week:
        case CalendarViewMode.sevenDays:
          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
        case CalendarViewMode.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        case CalendarViewMode.year:
          _focusedMonth = DateTime(_focusedMonth.year - 1, _focusedMonth.month);
        case CalendarViewMode.schedule:
          break;
      }
    });
  }

  /// Mouse wheel moves between periods in the month and year views; the day
  /// and week views use it to scroll their hour grid.
  void _handlePointerSignal(PointerSignalEvent event) {
    const gridViews = {
      CalendarViewMode.day,
      CalendarViewMode.week,
      CalendarViewMode.sevenDays,
    };
    if (gridViews.contains(_currentView)) return;
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy > 0) {
        _navigateForward();
      } else if (event.scrollDelta.dy < 0) {
        _navigateBackward();
      }
    }
  }

  String _viewLabel(CalendarViewMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case CalendarViewMode.day:
        return l10n.calendarViewDay;
      case CalendarViewMode.week:
        return l10n.calendarViewWeek;
      case CalendarViewMode.month:
        return l10n.calendarViewMonth;
      case CalendarViewMode.year:
        return l10n.calendarViewYear;
      case CalendarViewMode.schedule:
        return l10n.calendarViewSchedule;
      case CalendarViewMode.sevenDays:
        return l10n.calendarViewSevenDays;
    }
  }

  /// The hint on the right is the label's first letter.
  PopupMenuItem<CalendarViewMode> _viewMenuItem(CalendarViewMode mode) {
    final label = _viewLabel(mode);
    return PopupMenuItem<CalendarViewMode>(
      value: mode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const SizedBox(width: AppSpacing.xl),
          Text(
            label[0].toUpperCase(),
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calendarViewModeProvider);
    final allEvents = ref.watch(calendarItemsProvider);
    final showTasks = ref.watch(calendarShowTasksProvider);
    final searchQuery = ref.watch(calendarSearchQueryProvider);
    final isSearching = searchQuery.isNotEmpty;
    final filteredEvents = ref.watch(filteredCalendarEventsProvider);

    return NavScaffold(
      section: DrawerSection.calendar,
      titleWidget: CalendarSearchBar(
        controller: _searchController,
        provider: calendarSearchQueryProvider,
        hintText: context.l10n.calendarSearchHint,
      ),
      alignTitleEnd: true,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.task_alt),
          color:
              showTasks
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
          onPressed: ref.read(calendarShowTasksProvider.notifier).toggle,
          tooltip:
              showTasks
                  ? context.l10n.calendarHideTasks
                  : context.l10n.calendarShowTasks,
        ),
        if (!isSearching) ...[
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: _goToToday,
            tooltip: context.l10n.commonToday,
          ),
          PopupMenuButton<CalendarViewMode>(
            initialValue: _currentView,
            onSelected: _setView,
            tooltip: context.l10n.calendarChangeView,
            itemBuilder:
                (_) => [
                  for (final mode in CalendarViewMode.values)
                    _viewMenuItem(mode),
                ],
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _viewLabel(_currentView),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ],
      body: Listener(
        onPointerSignal: _handlePointerSignal,
        child:
            isSearching
                ? CalendarSearchResultsView(events: filteredEvents)
                : _buildCurrentView(allEvents),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final now = DateTime.now();
          final newEvent = CalendarEventModel(startTime: now, endTime: now);
          AppNav.openEvent(context, newEvent);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentView(List<CalendarEventModel> allEvents) {
    switch (_currentView) {
      case CalendarViewMode.day:
        return CalendarDayView(
          day: _focusedDay,
          allEvents: allEvents,
          onPreviousDay:
              () => setState(
                () =>
                    _focusedDay = _focusedDay.subtract(const Duration(days: 1)),
              ),
          onNextDay:
              () => setState(
                () => _focusedDay = _focusedDay.add(const Duration(days: 1)),
              ),
        );
      case CalendarViewMode.week:
        return CalendarMultiDayView(
          startDay: _focusedDay.subtract(
            Duration(days: _focusedDay.weekday - 1),
          ),
          dayCount: 7,
          allEvents: allEvents,
          onPrevious:
              () => setState(
                () =>
                    _focusedDay = _focusedDay.subtract(const Duration(days: 7)),
              ),
          onNext:
              () => setState(
                () => _focusedDay = _focusedDay.add(const Duration(days: 7)),
              ),
        );
      case CalendarViewMode.month:
        return CalendarMonthView(
          focusedMonth: _focusedMonth,
          allEvents: allEvents,
          onPreviousMonth:
              () => setState(
                () =>
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    ),
              ),
          onNextMonth:
              () => setState(
                () =>
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    ),
              ),
        );
      case CalendarViewMode.year:
        return CalendarYearView(
          focusedMonth: _focusedMonth,
          allEvents: allEvents,
          onPreviousYear:
              () => setState(
                () =>
                    _focusedMonth = DateTime(
                      _focusedMonth.year - 1,
                      _focusedMonth.month,
                    ),
              ),
          onNextYear:
              () => setState(
                () =>
                    _focusedMonth = DateTime(
                      _focusedMonth.year + 1,
                      _focusedMonth.month,
                    ),
              ),
          onMonthSelected: (month) {
            setState(() => _focusedMonth = month);
            _setView(CalendarViewMode.month);
          },
        );
      case CalendarViewMode.schedule:
        return CalendarScheduleView(
          allEvents: allEvents,
          controller: _scheduleController,
        );
      case CalendarViewMode.sevenDays:
        return CalendarMultiDayView(
          startDay: _focusedDay,
          dayCount: 7,
          allEvents: allEvents,
          onPrevious:
              () => setState(
                () =>
                    _focusedDay = _focusedDay.subtract(const Duration(days: 7)),
              ),
          onNext:
              () => setState(
                () => _focusedDay = _focusedDay.add(const Duration(days: 7)),
              ),
        );
    }
  }
}
