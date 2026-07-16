import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_text_field.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  static const _faqs = [
    [
      'How do I withdraw my earnings?',
      'Go to Wallet → Withdraw and choose your bank account. Payouts take 1–3 business days.',
    ],
    [
      'How does escrow work?',
      'Funds are held securely and released to freelancers when milestones are approved.',
    ],
    [
      'How do I verify my profile?',
      'Complete your profile and submit documents under Security Center → Verification.',
    ],
    [
      'Can I switch roles?',
      'Yes, you can add more roles from Settings → Account at any time.',
    ],
  ];

  bool _loading = true;
  List<Map<String, dynamic>> _tickets = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>()
        .getEnvelope<List<Map<String, dynamic>>>(
          ApiEndpoints.supportTickets,
          parser: (e) {
            final list = e.data as List?;
            if (list == null) return const [];
            return list
                .whereType<Map>()
                .map((x) => Map<String, dynamic>.from(x))
                .toList();
          },
        );
    if (!mounted) return;
    _tickets = res.valueOrNull ?? const [];
    setState(() => _loading = false);
  }

  Future<void> _createTicket() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Create ticket'),
        content: AppTextField(
          controller: ctrl,
          hint: 'Describe your issue',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final res = await sl<ApiClientHelper>().postAction(
                ApiEndpoints.supportTickets,
                body: {
                  'subject': 'Support request',
                  'message': ctrl.text.trim(),
                },
              );
              if (!mounted) return;
              res.fold(
                (f) => context.showSnack(f.message),
                (_) => context.showSnack('Ticket created'),
              );
              if (dCtx.mounted) Navigator.pop(dCtx);
              await _load();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _reply(String id) async {
    final res = await sl<ApiClientHelper>().postAction(
      ApiEndpoints.supportTicketReply(id),
      body: {'message': 'Thanks, please check latest details.'},
    );
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Reply sent'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Row(
            children: [
              Expanded(
                child: _contact(
                  context,
                  Icons.chat_bubble_outline_rounded,
                  'Live Chat',
                  AppColors.primary,
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: _contact(
                  context,
                  Icons.email_outlined,
                  'Email Us',
                  AppColors.info,
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: _contact(
                  context,
                  Icons.call_outlined,
                  'Call',
                  AppColors.success,
                ),
              ),
            ],
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Frequently Asked Questions'),
          AppSizes.vGapSm,
          for (final f in _faqs)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                shape: const Border(),
                title: Text(f[0], style: context.text.titleSmall),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  0,
                  AppSizes.lg,
                  AppSizes.lg,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(f[1], style: context.text.bodySmall),
                  ),
                ],
              ),
            ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'My Tickets'),
          AppSizes.vGapSm,
          _loading
              ? const AppCard(child: Center(child: CircularProgressIndicator()))
              : AppCard(
                  child: Column(
                    children: [
                      if (_tickets.isEmpty)
                        Text('No open tickets', style: context.text.bodyMedium),
                      for (final t in _tickets.take(5))
                        ListTile(
                          dense: true,
                          title: Text(t['subject']?.toString() ?? 'Ticket'),
                          subtitle: Text('Status: ${t['status'] ?? 'open'}'),
                          trailing: IconButton(
                            onPressed: () => _reply(t['id']?.toString() ?? ''),
                            icon: const Icon(Icons.reply_outlined),
                          ),
                        ),
                      AppSizes.vGapMd,
                      AppPrimaryButton(
                        label: 'Create Support Ticket',
                        icon: Icons.add_rounded,
                        onPressed: _createTicket,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _contact(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) => AppCard(
    onTap: () => context.showSnack('$label…'),
    padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
    child: Column(
      children: [
        Icon(icon, color: color, size: AppSizes.iconLg),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.text.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
