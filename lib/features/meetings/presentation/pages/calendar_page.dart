import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_scaffold.dart';

enum _CalKind { meeting, task, deadline, payment, interview }

class _CalEvent {
  const _CalEvent(this.title, this.time, this.kind, {this.subtitle});
  final String title;
  final DateTime time;
  final _CalKind kind;
  final String? subtitle;

  Color get color => switch (kind) {
        _CalKind.meeting => AppColors.primary,
        _CalKind.task => AppColors.info,
        _CalKind.deadline => AppColors.danger,
        _CalKind.payment => AppColors.success,
        _CalKind.interview => AppColors.warning,
      };

  IconData get icon => switch (kind) {
        _CalKind.meeting => Icons.videocam_outlined,
        _CalKind.task => Icons.check_circle_outline_rounded,
        _CalKind.deadline => Icons.flag_outlined,
        _CalKind.payment => Icons.payments_outlined,
        _CalKind.interview => Icons.record_voice_over_outlined,
      };
}

/// Full calendar with Day / Week / Month views aggregating meetings, tasks,
/// project deadlines, payment dates and interview schedules.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _view = 2; // 0 day, 1 week, 2 month
  late DateTime _focused;
  late DateTime _selected;
  late final List<_CalEvent> _events;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focused = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
    _events = _seedEvents();
  }

  List<_CalEvent> _seedEvents() {
    final now = DateTime.now();
    return [
      for (final m in MockData.meetings) _CalEvent(m.title, m.startTime, _CalKind.meeting, subtitle: 'with ${m.withName}'),
      _CalEvent('Submit fintech milestone', now.add(const Duration(days: 1, hours: 3)), _CalKind.deadline, subtitle: 'PayNova'),
      _CalEvent('Design QA task', now.add(const Duration(hours: 5)), _CalKind.task),
      _CalEvent('Payment due · INV-2045', now.add(const Duration(days: 2)), _CalKind.payment, subtitle: '₹1,90,000'),
      _CalEvent('Interview · Backend Engineer', now.add(const Duration(days: 3, hours: 2)), _CalKind.interview),
      _CalEvent('Weekly standup', now.add(const Duration(days: 5, hours: 1)), _CalKind.meeting),
    ];
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<_CalEvent> get _visibleEvents {
    switch (_view) {
      case 0:
        return _events.where((e) => _sameDay(e.time, _selected)).toList()..sort((a, b) => a.time.compareTo(b.time));
      case 1:
        final start = _selected.subtract(Duration(days: _selected.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return _events.where((e) => e.time.isAfter(start) && e.time.isBefore(end)).toList()..sort((a, b) => a.time.compareTo(b.time));
      default:
        return _events.where((e) => e.time.year == _focused.year && e.time.month == _focused.month).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [IconButton(onPressed: () => context.showSnack('Sync with Google / Outlook / Apple'), icon: const Icon(Icons.sync_rounded))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.showSnack('New event'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Event'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Day')),
              ButtonSegment(value: 1, label: Text('Week')),
              ButtonSegment(value: 2, label: Text('Month')),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
          AppSizes.vGapLg,
          if (_view == 2) _monthGrid(context),
          AppSizes.vGapMd,
          Text(
            _view == 0
                ? Formatters.date(_selected)
                : _view == 1
                    ? 'This week'
                    : Formatters.monthYear(_focused),
            style: context.text.titleMedium,
          ),
          AppSizes.vGapMd,
          if (_visibleEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSizes.xxl),
              child: AppEmptyState(title: 'No events', message: 'Nothing scheduled for this period.', icon: Icons.event_available_outlined),
            )
          else
            for (final e in _visibleEvents) _eventTile(context, e),
        ],
      ),
    );
  }

  Widget _monthGrid(BuildContext context) {
    final first = DateTime(_focused.year, _focused.month, 1);
    final daysInMonth = DateTime(_focused.year, _focused.month + 1, 0).day;
    final leading = first.weekday - 1; // Mon=1
    final cells = <Widget>[];

    for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      cells.add(Center(child: Text(d, style: context.text.labelSmall)));
    }
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focused.year, _focused.month, day);
      final isSelected = _sameDay(date, _selected);
      final hasEvents = _events.any((e) => _sameDay(e.time, date));
      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          onTap: () => setState(() => _selected = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : null,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$day', style: TextStyle(color: isSelected ? Colors.white : context.text.bodyMedium?.color, fontWeight: FontWeight.w600)),
                if (hasEvents)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(color: isSelected ? Colors.white : AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () => setState(() => _focused = DateTime(_focused.year, _focused.month - 1)), icon: const Icon(Icons.chevron_left_rounded)),
              Expanded(child: Center(child: Text(Formatters.monthYear(_focused), style: context.text.titleSmall))),
              IconButton(onPressed: () => setState(() => _focused = DateTime(_focused.year, _focused.month + 1)), icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: cells,
          ),
        ],
      ),
    );
  }

  Widget _eventTile(BuildContext context, _CalEvent e) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      onTap: () => context.showSnack(e.title),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(color: e.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
            child: Icon(e.icon, color: e.color, size: 18),
          ),
          AppSizes.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(e.subtitle ?? e.kind.name, style: context.text.labelSmall),
              ],
            ),
          ),
          Text(Formatters.time(e.time), style: context.text.labelMedium),
        ],
      ),
    );
  }
}
