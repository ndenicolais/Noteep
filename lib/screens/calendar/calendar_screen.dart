// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_model.dart';
import '../../providers/calendar_provider.dart';
import '../../widgets/nav_scaffold.dart';
import 'calendar_day_view.dart';
import 'calendar_month_view.dart';
import 'calendar_multi_day_view.dart';
import 'calendar_schedule_view.dart';
import 'calendar_search_bar.dart';
import 'calendar_search_results_view.dart';
import 'calendar_year_view.dart';

// ── View modes ────────────────────────────────────────────────────────────────

enum _CalendarViewMode { day, week, month, year, schedule, sevenDays }

// ── Main widget ───────────────────────────────────────────────────────────────

class CalendarWorkspaceView extends ConsumerStatefulWidget {
  const CalendarWorkspaceView({super.key});

  @override
  ConsumerState<CalendarWorkspaceView> createState() =>
      _CalendarWorkspaceViewState();
}

class _CalendarWorkspaceViewState extends ConsumerState<CalendarWorkspaceView> {
  _CalendarViewMode _currentView = _CalendarViewMode.month;
  late DateTime _focusedDay;
  late DateTime _focusedMonth;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _focusedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedDay = now;
      _focusedMonth = DateTime(now.year, now.month);
    });
  }

  void _navigateForward() {
    setState(() {
      switch (_currentView) {
        case _CalendarViewMode.day:
          _focusedDay = _focusedDay.add(const Duration(days: 1));
        case _CalendarViewMode.week:
        case _CalendarViewMode.sevenDays:
          _focusedDay = _focusedDay.add(const Duration(days: 7));
        case _CalendarViewMode.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        case _CalendarViewMode.year:
          _focusedMonth = DateTime(_focusedMonth.year + 1, _focusedMonth.month);
        case _CalendarViewMode.schedule:
          break;
      }
    });
  }

  void _navigateBackward() {
    setState(() {
      switch (_currentView) {
        case _CalendarViewMode.day:
          _focusedDay = _focusedDay.subtract(const Duration(days: 1));
        case _CalendarViewMode.week:
        case _CalendarViewMode.sevenDays:
          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
        case _CalendarViewMode.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        case _CalendarViewMode.year:
          _focusedMonth = DateTime(_focusedMonth.year - 1, _focusedMonth.month);
        case _CalendarViewMode.schedule:
          break;
      }
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy > 0) {
        _navigateForward();
      } else if (event.scrollDelta.dy < 0) {
        _navigateBackward();
      }
    }
  }

  String get _currentViewLabel {
    switch (_currentView) {
      case _CalendarViewMode.day:
        return 'Giorno';
      case _CalendarViewMode.week:
        return 'Settimana';
      case _CalendarViewMode.month:
        return 'Mese';
      case _CalendarViewMode.year:
        return 'Anno';
      case _CalendarViewMode.schedule:
        return 'Programma';
      case _CalendarViewMode.sevenDays:
        return '7 giorni';
    }
  }

  PopupMenuItem<_CalendarViewMode> _viewMenuItem(
    _CalendarViewMode mode,
    String label,
    String shortcut,
  ) {
    return PopupMenuItem<_CalendarViewMode>(
      value: mode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const SizedBox(width: 24),
          Text(
            shortcut,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(activeEventsProvider);
    final searchQuery = ref.watch(calendarSearchQueryProvider);
    final isSearching = searchQuery.isNotEmpty;
    final filteredEvents = ref.watch(filteredCalendarEventsProvider);

    return NavScaffold(
      section: DrawerSection.calendar,
      titleWidget: CalendarSearchBar(
        controller: _searchController,
        provider: calendarSearchQueryProvider,
        hintText: 'Cerca eventi...',
      ),
      appBarActions: [
        if (!isSearching) ...[
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: _goToToday,
            tooltip: 'Oggi',
          ),
          PopupMenuButton<_CalendarViewMode>(
            initialValue: _currentView,
            onSelected: (mode) => setState(() => _currentView = mode),
            tooltip: 'Cambia visualizzazione',
            itemBuilder:
                (_) => [
                  _viewMenuItem(_CalendarViewMode.day, 'Giorno', 'G'),
                  _viewMenuItem(_CalendarViewMode.week, 'Settimana', 'W'),
                  _viewMenuItem(_CalendarViewMode.month, 'Mese', 'M'),
                  _viewMenuItem(_CalendarViewMode.year, 'Anno', 'A'),
                  _viewMenuItem(_CalendarViewMode.schedule, 'Programma', 'P'),
                  _viewMenuItem(_CalendarViewMode.sevenDays, '7 giorni', '7'),
                ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentViewLabel,
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
          final newEvent = CalendarEventModel(
            startTime: now,
            endTime: now.add(const Duration(hours: 1)),
          );
          AppNav.openEvent(context, newEvent);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentView(List<CalendarEventModel> allEvents) {
    switch (_currentView) {
      case _CalendarViewMode.day:
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
      case _CalendarViewMode.week:
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
      case _CalendarViewMode.month:
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
      case _CalendarViewMode.year:
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
          onMonthSelected:
              (month) => setState(() {
                _focusedMonth = month;
                _currentView = _CalendarViewMode.month;
              }),
        );
      case _CalendarViewMode.schedule:
        return CalendarScheduleView(allEvents: allEvents);
      case _CalendarViewMode.sevenDays:
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
