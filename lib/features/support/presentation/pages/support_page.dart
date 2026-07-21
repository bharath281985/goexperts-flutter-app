import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown.dart';
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
  static const _pageSize = 20;
  static const _categories = [
    'Account Verification',
    'Payment / Invoicing',
    'Technical Issue / Bug',
    'General Inquiry',
    'Feedback / Suggestions',
  ];
  static const _priorities = ['High', 'Medium', 'Low'];
  static const _faqs = [
    [
      'How do I withdraw my earnings?',
      'Go to Wallet -> Withdraw and choose your bank account. Payouts take 1-3 business days.',
    ],
    [
      'How does escrow work?',
      'Funds are held securely and released to freelancers when milestones are approved.',
    ],
    [
      'How do I verify my profile?',
      'Complete your profile and submit documents under Security Center -> Verification.',
    ],
    [
      'Can I switch roles?',
      'Yes, you can add more roles from Settings -> Account at any time.',
    ],
  ];

  bool _loading = true;
  List<_SupportTicket> _tickets = const [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await sl<ApiClientHelper>()
        .getEnvelope<_SupportTicketsResponse>(
          ApiEndpoints.supportTickets,
          query: const {'page': 1, 'limit': _pageSize},
          parser: (e) => _SupportTicketsResponse.fromEnvelope(e.data, e.meta),
        );
    if (!mounted) return;
    res.fold((f) => context.showTopSnack(f.message, isError: true), (page) {
      _tickets = page.items;
      _total = page.total;
    });
    setState(() => _loading = false);
  }

  Future<void> _createTicket() async {
    final payload = await _TicketCreateSheet.show(
      context,
      categories: _categories,
      priorities: _priorities,
    );
    if (payload == null || !mounted) return;

    final res = await _submitTicket(payload);
    if (!mounted) return;

    await res.fold(
      (f) async => context.showTopSnack(f.message, isError: true),
      (message) async {
        context.showTopSnack(message);
        await _load();
      },
    );
  }

  Future<Result<String>> _submitTicket(Map<String, dynamic> payload) {
    return sl<ApiClientHelper>().postEnvelope<String>(
      ApiEndpoints.supportTickets,
      body: {
        'subject': payload['subject']?.toString().trim(),
        'category': payload['category']?.toString().trim(),
        'priority': payload['priority']?.toString().trim(),
      },
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Ticket created',
    );
  }

  Future<void> _openTicket(_SupportTicket ticket) async {
    final res = await sl<ApiClientHelper>().get<_SupportTicket>(
      ApiEndpoints.supportTicket(ticket.id),
      parser: (raw) =>
          _SupportTicket.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
    if (!mounted) return;

    res.fold(
      (f) => context.showTopSnack(f.message, isError: true),
      (ticket) => _TicketDetailsSheet.show(context, ticket),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(context.tr('Help & Support'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTicket,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('Create Ticket')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: context.paddingWithBottomSafe(
            const EdgeInsets.all(AppSizes.screenPadding),
          ),
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
            AppSectionHeader(title: context.tr('Frequently Asked Questions')),
            AppSizes.vGapSm,
            for (final f in _faqs)
              AppCard(
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(context.tr(f[0]), style: context.text.titleSmall),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    0,
                    AppSizes.lg,
                    AppSizes.lg,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.tr(f[1]),
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            AppSizes.vGapLg,
            Row(
              children: [
                Expanded(
                  child: AppSectionHeader(title: context.tr('My Tickets')),
                ),
                if (_total > 0)
                  Text(
                    '$_total',
                    style: context.text.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            AppSizes.vGapSm,
            if (_loading)
              const AppCard(child: Center(child: CircularProgressIndicator()))
            else if (_tickets.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.subtleText,
                        size: 36,
                      ),
                      AppSizes.vGapSm,
                      Text(
                        context.tr('No support tickets yet'),
                        style: context.text.titleSmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final ticket in _tickets)
                _TicketCard(ticket: ticket, onTap: () => _openTicket(ticket)),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Widget _contact(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return AppCard(
      onTap: () => context.showSnack('$label...'),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLg),
          const SizedBox(height: 6),
          Text(
            context.tr(label),
            style: context.text.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onTap});

  final _SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final priorityColor = _priorityColor(ticket.priority);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: statusColor,
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSizes.vGapXs,
                    Text(
                      ticket.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          AppSizes.vGapMd,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              _TicketChip(label: ticket.status, color: statusColor),
              _TicketChip(label: ticket.priority, color: priorityColor),
              _TicketChip(
                label: Formatters.relative(ticket.createdAt),
                color: AppColors.mutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
      case 'resolved':
        return AppColors.success;
      case 'pending':
      case 'in progress':
        return AppColors.warning;
      case 'open':
      default:
        return AppColors.info;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.success;
    }
  }
}

class _TicketChip extends StatelessWidget {
  const _TicketChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.tr(label),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TicketCreateSheet extends StatefulWidget {
  const _TicketCreateSheet({
    required this.categories,
    required this.priorities,
  });

  final List<String> categories;
  final List<String> priorities;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<String> categories,
    required List<String> priorities,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.88,
          child: _TicketCreateSheet(
            categories: categories,
            priorities: priorities,
          ),
        ),
      ),
    );
  }

  @override
  State<_TicketCreateSheet> createState() => _TicketCreateSheetState();
}

class _TicketCreateSheetState extends State<_TicketCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  String? _category;
  String? _priority;

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    final category = _category;
    final priority = _priority;
    if (category == null || priority == null) return;
    Navigator.pop(context, {
      'subject': _subject.text.trim(),
      'category': category,
      'priority': priority,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.lg,
              AppSizes.screenPadding,
              AppSizes.xxl + context.bottomSafeInset + 96,
            ),
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.subtleText.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              AppSizes.vGapLg,
              Row(
                children: [
                  Text(
                    context.tr('Create Support Ticket'),
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: context.tr('Close'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
              AppSizes.vGapLg,
              AppTextField(
                controller: _subject,
                label: 'Subject',
                hint: 'Describe your issue',
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('Subject is required')
                    : null,
              ),
              AppSizes.vGapXxl,
              AppDropdown<String>(
                value: _category,
                label: 'Category',
                hint: 'Select category',
                prefixIcon: Icons.category_outlined,
                items: widget.categories,
                itemLabel: (category) => category,
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('Category is required')
                    : null,
              ),
              AppSizes.vGapXxl,
              AppDropdown<String>(
                value: _priority,
                label: 'Priority',
                hint: 'Select priority',
                prefixIcon: Icons.priority_high_rounded,
                items: widget.priorities,
                itemLabel: (priority) => priority,
                onChanged: (value) => setState(() => _priority = value),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('Priority is required')
                    : null,
              ),
              AppSizes.vGapXxxl,
              AppPrimaryButton(
                label: 'Submit',
                icon: Icons.send_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketDetailsSheet {
  const _TicketDetailsSheet._();

  static Future<void> show(BuildContext context, _SupportTicket ticket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.lg,
              AppSizes.screenPadding,
              AppSizes.xxl + context.bottomSafeInset,
            ),
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.subtleText.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    context.tr('Support Ticket'),
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: context.tr('Close'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
              AppSizes.vGapLg,
              Text(
                ticket.subject,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
              ),
              AppSizes.vGapMd,
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  _TicketChip(label: ticket.status, color: AppColors.info),
                  _TicketChip(
                    label: ticket.priority,
                    color: ticket.priority.toLowerCase() == 'high'
                        ? AppColors.danger
                        : ticket.priority.toLowerCase() == 'medium'
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ],
              ),
              AppSizes.vGapLg,
              _DetailRow(label: 'Category', value: ticket.category),
              _DetailRow(
                label: 'Created',
                value: Formatters.dateTime(ticket.createdAt),
              ),
              _DetailRow(
                label: 'Updated',
                value: Formatters.dateTime(ticket.updatedAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              context.tr(label),
              style: context.text.bodySmall?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}

class _SupportTicketsResponse {
  const _SupportTicketsResponse({required this.items, required this.total});

  final List<_SupportTicket> items;
  final int total;

  factory _SupportTicketsResponse.fromEnvelope(
    dynamic raw,
    Map<String, dynamic>? meta,
  ) {
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (item) =>
                    _SupportTicket.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <_SupportTicket>[];
    return _SupportTicketsResponse(
      items: items,
      total: (meta?['total'] as num?)?.toInt() ?? items.length,
    );
  }
}

class _SupportTicket {
  const _SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory _SupportTicket.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    return _SupportTicket(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'Ticket',
      category: json['category']?.toString() ?? 'General Inquiry',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Open',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
    );
  }
}
