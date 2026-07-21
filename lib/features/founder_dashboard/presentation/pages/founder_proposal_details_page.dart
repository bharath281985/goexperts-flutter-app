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
    final investorBio =
        _proposal!['investorProfile']?['bio']?.toString() ?? 'Angel Investor';

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
        _proposal!['docs']?.toString() ??
        _proposal!['description']?.toString() ??
        'No message provided.';
    final statusString = _proposal!['status']?.toString() ?? 'pending';
    final status = EntityStatus.fromString(statusString);
    final dateString = _proposal!['createdAt']?.toString() ?? '';
    final formattedDate = dateString.isNotEmpty
        ? Formatters.date(DateTime.tryParse(dateString) ?? DateTime.now())
        : 'Recently';

    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: AppSizes.lg,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Proposal',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Received $formattedDate',
                    style: context.text.labelMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
              AppStatusChip.status(status, dense: false),
            ],
          ),
          AppSizes.vGapLg,
          Text(
            'Investor Profile',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.vGapSm,
          AppCard(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      width: 3,
                    ),
                  ),
                  child: AppAvatar(
                    name: investorName,
                    imageUrl: investorAvatar,
                    size: 58,
                  ),
                ),
                AppSizes.hGapLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              investorName,
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSizes.hGapXs,
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investorBio,
                        style: context.text.labelMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          Text(
            'Financial Terms',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.vGapSm,
          Row(
            children: [
              Expanded(
                child: _buildTermCard(
                  Icons.payments_outlined,
                  'Offered Funding',
                  Formatters.compactCurrency(offer),
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildTermCard(
                  Icons.pie_chart_outline_rounded,
                  'Requested Equity',
                  '${equity.toStringAsFixed(1)}%',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          AppSizes.vGapLg,
          Text(
            'Investor Cover Note',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.vGapSm,
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: context.theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 36,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 28.0),
                  child: Text(
                    message,
                    style: context.text.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: context.theme.textTheme.bodyLarge?.color
                          ?.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
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

  Widget _buildTermCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          AppSizes.vGapSm,
          Text(
            value,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
