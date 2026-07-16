import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_chip.dart';

/// Invitation history with Sent / Received tabs and status filtering.
class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  static const _filters = ['All', 'Pending', 'Accepted', 'Rejected', 'Expired'];
  String _filter = 'All';

  bool _matches(AppInvitation i) => _filter == 'All' || i.status.label == _filter;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          bottom: const TabBar(tabs: [Tab(text: 'Sent'), Tab(text: 'Received')]),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
                children: [
                  for (final f in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _list(MockData.invitationsSent.where(_matches).toList(), sent: true),
                  _list(MockData.invitationsReceived.where(_matches).toList(), sent: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<AppInvitation> items, {required bool sent}) {
    if (items.isEmpty) {
      return const AppEmptyState(title: 'No invitations', icon: Icons.mail_outline_rounded);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      itemCount: items.length,
      separatorBuilder: (_, __) => AppSizes.vGapMd,
      itemBuilder: (context, i) => _tile(items[i], sent: sent),
    );
  }

  Widget _tile(AppInvitation inv, {required bool sent}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: inv.name, imageUrl: inv.avatarUrl, size: 44),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.name, style: context.text.titleSmall),
                    Text('${inv.type} · ${inv.context}', style: context.text.labelSmall),
                  ],
                ),
              ),
              AppStatusChip.status(inv.status, dense: true),
            ],
          ),
          AppSizes.vGapSm,
          Row(
            children: [
              Text(Formatters.relative(inv.createdAt), style: context.text.labelSmall),
              const Spacer(),
              if (inv.status == EntityStatus.pending) ...[
                if (sent)
                  TextButton(onPressed: () => context.showSnack('Invitation withdrawn'), child: const Text('Withdraw'))
                else ...[
                  TextButton(onPressed: () => context.showSnack('Declined'), child: const Text('Decline', style: TextStyle(color: AppColors.danger))),
                  TextButton(onPressed: () => context.showSnack('Accepted'), child: const Text('Accept')),
                ],
              ] else if (inv.status == EntityStatus.expired && sent)
                TextButton(onPressed: () => context.showSnack('Invitation resent'), child: const Text('Resend')),
            ],
          ),
        ],
      ),
    );
  }
}
