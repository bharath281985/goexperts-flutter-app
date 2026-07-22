import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
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
          onJoin: () async {
            final link = m.meetingLink.isNotEmpty
                ? m.meetingLink
                : 'https://meet.google.com';
            final uri = Uri.tryParse(link);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          onTap: () async {
            await context.push('${Routes.meetingDetails}/${m.id}');
            if (mounted) {
              setState(() {
                _refreshKey++;
              });
            }
          },
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
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _ScheduleMeetingSheet(onScheduled: _refresh),
      ),
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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
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
    if (_isFounder) {
      _loadInvestors();
    } else {
      _loadStartups();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  List<DropdownMenuItem<String>> _participantItems() {
    final seen = <String>{};
    if (_isFounder) {
      return _investors
          .where((i) => i.id.trim().isNotEmpty && seen.add(i.id))
          .map((i) {
            final displayCompany = i.company.isNotEmpty
                ? ' (${i.company})'
                : '';
            return DropdownMenuItem<String>(
              value: i.id,
              child: Text(
                '${i.name}$displayCompany',
                overflow: TextOverflow.ellipsis,
              ),
            );
          })
          .toList();
    }

    return _startups
        .map((s) {
          final founderId = s.founderId?.trim() ?? '';
          return (startup: s, founderId: founderId);
        })
        .where((entry) {
          return entry.founderId.isNotEmpty && seen.add(entry.founderId);
        })
        .map((entry) {
          final s = entry.startup;
          return DropdownMenuItem<String>(
            value: entry.founderId,
            child: Text(
              '${s.name} (${s.founderName})',
              overflow: TextOverflow.ellipsis,
            ),
          );
        })
        .toList();
  }

  String? _validSelectedParticipantId(List<DropdownMenuItem<String>> items) {
    final selected = _selectedParticipantId;
    if (selected == null) return null;
    final matches = items.where((item) => item.value == selected).length;
    return matches == 1 ? selected : null;
  }

  Future<void> _submit() async {
    final selectedParticipantId = _validSelectedParticipantId(
      _participantItems(),
    );
    if (selectedParticipantId == null) {
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
      participants: [selectedParticipantId],
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
    final participantItems = _participantItems();
    final selectedParticipantId = _validSelectedParticipantId(participantItems);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
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
                else if (_isFounder ? _investors.isEmpty : _startups.isEmpty)
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
                else if (participantItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      _isFounder
                          ? 'No valid investors found to schedule meeting with.'
                          : 'No valid startup founders found to schedule meeting with.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                else
                  AppDropdown<String>(
                    value: selectedParticipantId,
                    label: _isFounder
                        ? 'Select Investor'
                        : 'Select Startup / Founder',
                    hint: _isFounder
                        ? 'Select Investor'
                        : 'Select Startup / Founder',
                    prefixIcon: Icons.person_search_outlined,
                    items: participantItems
                        .map((item) => item.value)
                        .whereType<String>()
                        .toList(),
                    itemLabel: (id) {
                      final match = participantItems.firstWhere(
                        (item) => item.value == id,
                      );
                      final child = match.child;
                      return child is Text ? child.data ?? id : id;
                    },
                    onChanged: (val) =>
                        setState(() => _selectedParticipantId = val),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _dateController,
                        label: 'Date',
                        hint: 'Select Date',
                        prefixIcon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _timeController,
                        label: 'Time',
                        hint: 'Select Time',
                        prefixIcon: Icons.access_time_outlined,
                        readOnly: true,
                        onTap: _selectTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppDropdown<bool>(
                  value: _isVideo,
                  label: 'Meeting Mode',
                  hint: 'Meeting Mode',
                  prefixIcon: Icons.video_call_outlined,
                  items: const [true, false],
                  itemLabel: (value) =>
                      value ? 'Online (Video Call)' : 'Offline (In-Person)',
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
      ),
    );
  }
}
