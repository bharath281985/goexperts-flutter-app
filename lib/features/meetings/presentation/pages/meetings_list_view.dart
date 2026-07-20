import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../investor_dashboard/domain/entities/investor.dart';
import '../../../investor_dashboard/domain/repositories/investor_repository.dart';
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
    );
  }
}

class ScheduleMeetingSheet extends StatefulWidget {
  const ScheduleMeetingSheet({
    required this.onScheduled,
    this.preselectedParticipantId,
    super.key,
  });
  final VoidCallback onScheduled;
  final String? preselectedParticipantId;

  @override
  State<ScheduleMeetingSheet> createState() => _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState extends State<ScheduleMeetingSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isVideo = true;
  bool _loading = false;

  bool _isFounder = false;
  List<Startup> _startups = [];
  List<Investor> _investors = [];
  bool _loadingData = true;
  String? _selectedParticipantId;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _isFounder = user?.role == UserRole.founder;
    if (widget.preselectedParticipantId != null) {
      _selectedParticipantId = widget.preselectedParticipantId;
      _loadingData = false;
    } else {
      if (_isFounder) {
        _loadInvestors();
      } else {
        _loadStartups();
      }
    }
  }

  Future<void> _loadStartups() async {
    try {
      final res = await sl<StartupRepository>().getStartups(
        const QueryParams(pageSize: 50),
      );
      if (mounted) {
        setState(() {
          _startups = res.valueOrNull?.items ?? [];
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    }
  }

  Future<void> _loadInvestors() async {
    try {
      final res = await sl<InvestorRepository>().getInvestors(
        const QueryParams(pageSize: 50),
      );
      if (mounted) {
        setState(() {
          _investors = res.valueOrNull?.items ?? [];
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingData = false;
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
    if (_selectedParticipantId == null) {
      context.showSnack(
        _isFounder
            ? 'Please select an investor'
            : 'Please select a startup/founder',
        isError: true,
      );
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
      participants: [_selectedParticipantId!],
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
    return SafeArea(
      child: Padding(
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loadingData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (widget.preselectedParticipantId == null &&
                  (_isFounder ? _investors.isEmpty : _startups.isEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _isFounder
                        ? 'No active investors found to schedule meeting with.'
                        : 'No active startups found to schedule meeting with.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                )
              else if (widget.preselectedParticipantId == null)
                DropdownButtonFormField<String>(
                  value: _selectedParticipantId,
                  decoration: InputDecoration(
                    labelText: _isFounder
                        ? 'Select Investor'
                        : 'Select Startup / Founder',
                    border: const OutlineInputBorder(),
                  ),
                  items: _isFounder
                      ? _investors.map((i) {
                          final displayCompany = i.company.isNotEmpty
                              ? ' (${i.company})'
                              : '';
                          return DropdownMenuItem<String>(
                            value: i.id,
                            child: Text('${i.name}$displayCompany'),
                          );
                        }).toList()
                      : _startups.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.founderId,
                            child: Text('${s.name} (${s.founderName})'),
                          );
                        }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedParticipantId = val);
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
      ),
    );
  }
}
