import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';

class MeetingDetailsPage extends StatefulWidget {
  const MeetingDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  late Future<Result<Meeting>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<MeetingRepository>().getMeeting(widget.id);
  }

  Future<void> _reschedule(Meeting meeting) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: meeting.startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(meeting.startTime),
    );
    if (pickedTime == null || !mounted) return;

    final newStartTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final res = await sl<MeetingRepository>().reschedule(
      widget.id,
      newStartTime,
    );
    if (!mounted) return;

    res.fold((fail) => context.showSnack(fail.message, isError: true), (_) {
      context.showSnack('Meeting rescheduled successfully!');
      setState(() {
        _load();
      });
    });
  }

  Future<void> _cancelMeeting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Meeting'),
        content: const Text('Are you sure you want to cancel this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final res = await sl<MeetingRepository>().cancel(widget.id);
    if (!mounted) return;

    res.fold((fail) => context.showSnack(fail.message, isError: true), (_) {
      context.showSnack('Meeting cancelled successfully!');
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Meeting>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meeting Details')),
            body: const AppLoadingShimmer(itemCount: 4, height: 110),
          );
        }
        final meeting = snapshot.data?.valueOrNull;
        if (meeting == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meeting Details')),
            body: const AppErrorState(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meeting Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => context.showSnack('Invite link copied'),
              ),
              IconButton(
                icon: const Icon(Icons.event_available_outlined),
                onPressed: () => context.showSnack('Added to calendar'),
              ),
              if (meeting.status != EntityStatus.cancelled)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: _cancelMeeting,
                ),
            ],
          ),
          body: _content(context, meeting),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  if (meeting.status != EntityStatus.cancelled) ...[
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Reschedule',
                        icon: Icons.schedule_rounded,
                        onPressed: () => _reschedule(meeting),
                      ),
                    ),
                    AppSizes.hGapMd,
                  ],
                  Expanded(
                    flex: 2,
                    child: AppPrimaryButton(
                      label: meeting.status == EntityStatus.cancelled
                          ? 'Cancelled'
                          : 'Join Meeting',
                      icon: Icons.videocam_rounded,
                      onPressed: meeting.status == EntityStatus.cancelled
                          ? null
                          : () => context.showSnack('Joining… (WebRTC ready)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, Meeting m) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                m.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                color: AppColors.primary,
              ),
            ),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title, style: context.text.titleMedium),
                  Text(
                    m.isVideo ? 'Video meeting' : 'Voice call',
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            AppStatusChip.status(m.status, dense: true),
          ],
        ),
        AppSizes.vGapLg,
        AppCard(
          child: Column(
            children: [
              _row(
                context,
                Icons.event_outlined,
                'Date',
                Formatters.date(m.startTime),
              ),
              const Divider(height: AppSizes.lg),
              _row(
                context,
                Icons.schedule_rounded,
                'Time',
                '${Formatters.time(m.startTime)} – ${Formatters.time(m.endTime)} (${m.durationMinutes} min)',
              ),
              const Divider(height: AppSizes.lg),
              _row(context, Icons.person_outline_rounded, 'With', m.withName),
            ],
          ),
        ),
        AppSizes.vGapLg,
        AppCard(
          onTap: () => context.showSnack('Opening meeting room…'),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.info),
              AppSizes.hGapMd,
              Expanded(
                child: Text(
                  m.meetingLink,
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => context.showSnack('Link copied'),
              ),
            ],
          ),
        ),
        if (m.agenda.isNotEmpty) ...[
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Agenda'),
          AppSizes.vGapSm,
          Text(m.agenda, style: context.text.bodyMedium),
        ],
        AppSizes.vGapLg,
        AppSectionHeader(title: 'Participants (${m.participants.length + 1})'),
        AppSizes.vGapSm,
        _participant(context, m.withName, 'Host'),
        for (final p in m.participants) _participant(context, p, 'Guest'),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.mutedText),
      AppSizes.hGapMd,
      Text(label, style: context.text.labelMedium),
      const Spacer(),
      Flexible(
        child: Text(
          value,
          style: context.text.bodyMedium,
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );

  Widget _participant(BuildContext context, String name, String role) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Row(
          children: [
            AppAvatar(name: name, size: 36),
            AppSizes.hGapMd,
            Expanded(child: Text(name, style: context.text.titleSmall)),
            Text(role, style: context.text.labelSmall),
          ],
        ),
      );
}
