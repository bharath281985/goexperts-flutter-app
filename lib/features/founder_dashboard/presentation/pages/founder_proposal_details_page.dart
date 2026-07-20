import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../messages/domain/repositories/message_repository.dart';
import '../../../meetings/presentation/pages/meetings_list_view.dart';

/// Detailed view of investor bids/proposals for founders.
class FounderProposalDetailsPage extends StatefulWidget {
  const FounderProposalDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<FounderProposalDetailsPage> createState() =>
      _FounderProposalDetailsPageState();
}

class _FounderProposalDetailsPageState
    extends State<FounderProposalDetailsPage> {
  bool _loading = true;
  bool _busy = false;
  Map<String, dynamic>? _proposal;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final client = sl<ApiClientHelper>();
    final res = await client.get<Map<String, dynamic>>(
      ApiEndpoints.founderProposal(widget.id),
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );

    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (data) => setState(() {
        _loading = false;
        _proposal = data;
      }),
    );
  }

  Future<void> _respond(String action) async {
    setState(() => _busy = true);

    final client = sl<ApiClientHelper>();
    final path = action == 'accept'
        ? ApiEndpoints.founderProposalAccept(widget.id)
        : ApiEndpoints.founderProposalReject(widget.id);

    final res = await client.patchAction(path);

    if (!mounted) return;
    setState(() => _busy = false);

    res.fold((f) => context.showSnack(f.message, isError: true), (_) {
      context.showSnack(
        action == 'accept'
            ? 'Proposal accepted successfully!'
            : 'Proposal rejected.',
      );
      _load();
    });
  }

  Future<void> _startChat(String investorId) async {
    if (_proposal == null) return;

    final investorName =
        _proposal!['investorName']?.toString() ??
        _proposal!['investorProfile']?['fullName']?.toString() ??
        'Investor';
    final investorAvatar =
        _proposal!['investorAvatar']?.toString() ??
        _proposal!['investorProfile']?['avatarUrl']?.toString() ??
        '';

    setState(() => _busy = true);
    final res = await sl<MessageRepository>().startChat(
      recipientId: investorId,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    res.fold((f) => context.showSnack(f.message, isError: true), (msg) {
      final convId = msg.conversationId;
      if (convId.isEmpty) {
        context.push(Routes.messages);
        return;
      }

      final nameParam = Uri.encodeComponent(investorName);
      final avatarParam = Uri.encodeComponent(investorAvatar);
      context.push(
        '${Routes.chat}/$convId?name=$nameParam&avatarUrl=$avatarParam',
      );
    });
  }

  void _scheduleMeeting(String investorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleMeetingSheet(
        preselectedParticipantId: investorId,
        onScheduled: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bid Details')),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_loading || _busy) {
      return const AppLoadingShimmer(itemCount: 4, height: 110);
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _load);
    }

    if (_proposal == null) {
      return const AppErrorState(message: 'Bid not found.');
    }

    final investorName =
        _proposal!['investorName']?.toString() ??
        _proposal!['investorProfile']?['fullName']?.toString() ??
        'Investor';
    final investorAvatar =
        _proposal!['investorAvatar']?.toString() ??
        _proposal!['investorProfile']?['avatarUrl']?.toString();
    final investorBio = _proposal!['investorProfile']?['bio']?.toString() ?? '';

    final offer =
        (num.tryParse(_proposal!['offer']?.toString() ?? '')?.toDouble()) ??
        (num.tryParse(_proposal!['amount']?.toString() ?? '')?.toDouble()) ??
        0.0;
    final equity =
        (num.tryParse(_proposal!['equity']?.toString() ?? '')?.toDouble()) ??
        0.0;
    final message =
        _proposal!['message']?.toString() ??
        _proposal!['coverLetter']?.toString() ??
        'No message provided.';
    final statusString = _proposal!['status']?.toString() ?? 'pending';
    final status = EntityStatus.fromString(statusString);

    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Investment Proposal',
                  style: context.text.headlineSmall,
                ),
              ),
              AppStatusChip.status(status, dense: true),
            ],
          ),
          AppSizes.vGapLg,
          AppCard(
            child: Row(
              children: [
                AppAvatar(
                  name: investorName,
                  imageUrl: investorAvatar,
                  size: 48,
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(investorName, style: context.text.titleMedium),
                      if (investorBio.isNotEmpty) ...[
                        AppSizes.vGapXs,
                        Text(
                          investorBio,
                          style: context.text.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.payments_outlined,
                  'Funding Bid',
                  Formatters.compactCurrency(offer),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildStatCard(
                  Icons.pie_chart_outline_rounded,
                  'Equity Asked',
                  '${equity.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          AppSizes.vGapLg,
          const Text(
            'Investor Note',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          AppSizes.vGapSm,
          AppCard(child: Text(message, style: context.text.bodyMedium)),
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (_loading || _busy || _proposal == null) return null;

    final statusString = _proposal!['status']?.toString() ?? 'pending';
    final status = EntityStatus.fromString(statusString);

    // Resolve the investor's user identity ID which is required by the chat and meeting participant APIs
    final investorId =
        _proposal!['investorProfile']?['userId']?.toString() ??
        _proposal!['userId']?.toString() ??
        _proposal!['investorId']?.toString() ??
        _proposal!['investorProfile']?['id']?.toString() ??
        '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: investorId.isEmpty
                        ? null
                        : () => _startChat(investorId),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Schedule Meeting',
                    icon: Icons.event_outlined,
                    onPressed: investorId.isEmpty
                        ? null
                        : () => _scheduleMeeting(investorId),
                  ),
                ),
              ],
            ),
            if (status == EntityStatus.pending) ...[
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Reject',
                      icon: Icons.cancel_outlined,
                      onPressed: () => _respond('reject'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Accept',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () => _respond('accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          AppSizes.vGapSm,
          Text(
            value,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: context.text.labelSmall),
        ],
      ),
    );
  }
}
