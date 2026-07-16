import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../startup_ideas/domain/entities/startup.dart';
import '../../../startup_ideas/domain/repositories/startup_repository.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../widgets/meeting_card.dart';

/// Embeddable meetings catalog.
class MeetingsListView extends StatefulWidget {
  const MeetingsListView({super.key});

  @override
  State<MeetingsListView> createState() => _MeetingsListViewState();
}

class _MeetingsListViewState extends State<MeetingsListView> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<MeetingRepository>();
    return Scaffold(
      body: CatalogView<Meeting>(
        key: ValueKey(_refreshKey),
        fetcher: repo.getMeetings,
        searchHint: 'Search meetings…',
        emptyTitle: 'No meetings scheduled',
        emptyIcon: Icons.event_outlined,
        skeletonHeight: 96,
        itemBuilder: (context, m, _) => AppMeetingCard(
          meeting: m,
          onJoin: () => context.showSnack('Joining ${m.title}… (WebRTC ready)'),
          onTap: () => context.push('${Routes.meetingDetails}/${m.id}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleMeetingSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showScheduleMeetingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleMeetingSheet(onScheduled: _refresh),
    );
  }
}

class _ScheduleMeetingSheet extends StatefulWidget {
  const _ScheduleMeetingSheet({required this.onScheduled});
  final VoidCallback onScheduled;

  @override
  State<_ScheduleMeetingSheet> createState() => _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState extends State<_ScheduleMeetingSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isVideo = true;
  bool _loading = false;

  List<Startup> _startups = [];
  bool _loadingStartups = true;
  String? _selectedFounderId;

  @override
  void initState() {
    super.initState();
    _loadStartups();
  }

  Future<void> _loadStartups() async {
    try {
      final res = await sl<StartupRepository>().getStartups(
        const QueryParams(pageSize: 50),
      );
      if (mounted) {
        setState(() {
          _startups = res.valueOrNull?.items ?? [];
          _loadingStartups = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingStartups = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedFounderId == null) {
      context.showSnack('Please select a startup/founder', isError: true);
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      context.showSnack('Please select date and time', isError: true);
      return;
    }

    setState(() => _loading = true);

    final start = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final meeting = Meeting(
      id: '',
      title: 'Expert Consultation',
      withName: '',
      withAvatar: null,
      startTime: start,
      durationMinutes: 45,
      status: EntityStatus.pending,
      isVideo: _isVideo,
      meetingLink: '',
      agenda: 'Expert Consultation',
      participants: [_selectedFounderId!],
    );

    final res = await sl<MeetingRepository>().schedule(meeting);

    if (!mounted) return;
    setState(() => _loading = false);

    res.fold((fail) => context.showSnack(fail.message, isError: true), (_) {
      context.showSnack('Meeting scheduled successfully!');
      widget.onScheduled();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule Meeting',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loadingStartups)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_startups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No active startups found to schedule meeting with.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedFounderId,
                decoration: const InputDecoration(
                  labelText: 'Select Startup / Founder',
                  border: OutlineInputBorder(),
                ),
                items: _startups.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.founderId,
                    child: Text('${s.name} (${s.founderName})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedFounderId = val);
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                    ),
                    onPressed: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                    onPressed: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<bool>(
              value: _isVideo,
              decoration: const InputDecoration(
                labelText: 'Meeting Mode',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text('Online (Video Call)'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Offline (In-Person)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _isVideo = val);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Schedule Meeting',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
