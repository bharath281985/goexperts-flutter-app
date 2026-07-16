import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../widgets/meeting_card.dart';

/// Embeddable meetings catalog.
class MeetingsListView extends StatelessWidget {
  const MeetingsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<MeetingRepository>();
    return CatalogView<Meeting>(
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
    );
  }
}
