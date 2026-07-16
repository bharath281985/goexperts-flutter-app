import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../../core/widgets/category_skills_picker.dart';
import '../../../master_data/domain/entities/skill_option.dart';
import '../../domain/entities/freelancer_task.dart';
import '../../domain/entities/portfolio_item.dart';
import '../../domain/repositories/freelancer_profile_repository.dart';
import '../../domain/repositories/freelancer_task_repository.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../../documents/domain/entities/app_document.dart';
import '../../../documents/domain/repositories/document_repository.dart';
import '../../../profile/domain/entities/review.dart';
import '../../../profile/domain/repositories/review_repository.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class _ListScaffold extends StatelessWidget {
  const _ListScaffold({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

class FreelancerContractsPage extends StatelessWidget {
  const FreelancerContractsPage({super.key});
  @override
  Widget build(BuildContext context) => _ListScaffold(
    title: 'Contracts',
    child: CatalogView<Contract>(
      fetcher: (q) => sl<ProjectRepository>().getContracts(q),
      searchHint: 'Search contracts…',
      emptyTitle: 'No contracts yet',
      itemBuilder: (context, c, __) => AppCard(
        onTap: () => context.push('${Routes.contractDetails}/${c.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(c.projectTitle, style: context.text.titleSmall),
                ),
                AppStatusChip.status(c.status, dense: true),
              ],
            ),
            AppSizes.vGapSm,
            Text(
              '${c.counterpartyName} · ${Formatters.compactCurrency(c.amount)}',
              style: context.text.bodySmall,
            ),
            AppSizes.vGapSm,
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: c.progress,
                minHeight: 6,
                backgroundColor: context.theme.dividerColor,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class FreelancerReviewsPage extends StatelessWidget {
  const FreelancerReviewsPage({super.key});
  @override
  Widget build(BuildContext context) => _ListScaffold(
    title: 'Reviews',
    child: CatalogView<Review>(
      fetcher: (q) => sl<ReviewRepository>().getReviews(q),
      searchHint: 'Search reviews…',
      itemBuilder: (context, r, __) => AppCard(
        onTap: () => context.push('${Routes.reviewDetails}/${r.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.authorName, style: context.text.titleSmall),
                ),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 16,
                ),
                Text(' ${r.rating}', style: context.text.labelMedium),
              ],
            ),
            AppSizes.vGapXs,
            Text(
              r.comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class FreelancerCertificatesPage extends StatefulWidget {
  const FreelancerCertificatesPage({super.key});
  @override
  State<FreelancerCertificatesPage> createState() =>
      _FreelancerCertificatesPageState();
}

class _FreelancerCertificatesPageState
    extends State<FreelancerCertificatesPage> {
  String _category = 'certificate';
  bool _uploading = false;

  @override
  Widget build(BuildContext context) => _ListScaffold(
    title: 'Documents',
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            AppSizes.md,
            AppSizes.screenPadding,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: const [
                    DropdownMenuItem(
                      value: 'certificate',
                      child: Text('Certificates'),
                    ),
                    DropdownMenuItem(value: 'resume', child: Text('Resume')),
                    DropdownMenuItem(
                      value: 'portfolio',
                      child: Text('Portfolio Files'),
                    ),
                    DropdownMenuItem(value: 'invoice', child: Text('Invoices')),
                    DropdownMenuItem(
                      value: 'contract',
                      child: Text('Contracts'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) =>
                      setState(() => _category = v ?? 'certificate'),
                ),
              ),
              AppSizes.hGapMd,
              AppPrimaryButton(
                label: 'Upload',
                isLoading: _uploading,
                onPressed: _uploading ? null : _pickAndUpload,
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogView<AppDocument>(
            fetcher: (q) =>
                sl<DocumentRepository>().getDocuments(q, category: _category),
            searchHint: 'Search files…',
            itemBuilder: (context, d, __) => AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    color: AppColors.primary,
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: context.text.titleSmall),
                        Text(
                          '${d.category} · ${Formatters.date(d.createdAt)}',
                          style: context.text.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(
                      '${Routes.documentViewer}?type=${_typeFor(d.name)}&name=${Uri.encodeComponent(d.name)}&url=${Uri.encodeComponent(d.url ?? '')}',
                    ),
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      final urlRes = await sl<DocumentRepository>().downloadUrl(
                        d.id,
                      );
                      if (!mounted) return;
                      urlRes.fold(
                        (f) => context.showSnack(f.message),
                        (_) => context.showSnack('Download link fetched'),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                  ),
                  IconButton(
                    onPressed: () async {
                      final del = await sl<DocumentRepository>().deleteDocument(
                        d.id,
                      );
                      if (!mounted) return;
                      del.fold(
                        (f) => context.showSnack(f.message),
                        (_) => context.showSnack('Document deleted'),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'zip',
        'mp4',
        'mp3',
      ],
    );
    if (res == null || res.files.single.path == null) {
      if (mounted) setState(() => _uploading = false);
      return;
    }
    final path = res.files.single.path!;
    final upload = await sl<DocumentRepository>().uploadDocument(
      filePath: path,
      category: _category,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    upload.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Upload completed'),
    );
  }

  String _typeFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.pdf')) return 'pdf';
    if (n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg')) {
      return 'image';
    }
    if (n.endsWith('.mp4')) return 'video';
    if (n.endsWith('.mp3')) return 'audio';
    if (n.endsWith('.zip')) return 'zip';
    if (n.endsWith('.doc') || n.endsWith('.docx')) return 'docx';
    if (n.endsWith('.xls') || n.endsWith('.xlsx')) return 'excel';
    return 'pdf';
  }
}

class FreelancerInvoicesPage extends StatelessWidget {
  const FreelancerInvoicesPage({super.key});
  @override
  Widget build(BuildContext context) => _ListScaffold(
    title: 'Invoices',
    child: CatalogView<Invoice>(
      fetcher: (q) => sl<WalletRepository>().getInvoices(q),
      searchHint: 'Search invoices…',
      itemBuilder: (context, inv, __) => AppCard(
        onTap: () => context.push('${Routes.invoiceDetails}/${inv.id}'),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inv.number, style: context.text.titleSmall),
                  Text(
                    '${inv.party} · ${Formatters.date(inv.issuedAt)}',
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.compactCurrency(inv.amount),
                  style: context.text.titleSmall,
                ),
                AppStatusChip(
                  label: inv.status,
                  dense: true,
                  color: inv.status == 'Paid'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class FreelancerWithdrawalsPage extends StatefulWidget {
  const FreelancerWithdrawalsPage({super.key});
  @override
  State<FreelancerWithdrawalsPage> createState() =>
      _FreelancerWithdrawalsPageState();
}

class _FreelancerWithdrawalsPageState extends State<FreelancerWithdrawalsPage> {
  bool _loading = true;
  WalletSummary _summary = const WalletSummary(
    available: 0,
    pending: 0,
    lifetime: 0,
  );
  List<WalletTransaction> _withdrawals = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final walletRepo = sl<WalletRepository>();
    final summaryRes = await walletRepo.getSummary();
    final txRes = await walletRepo.getTransactions(
      const QueryParams(page: 1, pageSize: 50),
    );
    if (!mounted) return;
    summaryRes.fold((_) {}, (s) => _summary = s);
    txRes.fold(
      (_) {},
      (page) => _withdrawals = page.items
          .where((t) => t.type == TransactionType.withdrawal)
          .toList(),
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Withdrawals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                AppCard(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available to withdraw',
                        style: context.text.labelMedium,
                      ),
                      AppSizes.vGapXs,
                      Text(
                        Formatters.currency(_summary.available),
                        style: context.text.headlineSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppSizes.vGapMd,
                      AppPrimaryButton(
                        label: 'Request Withdrawal',
                        icon: Icons.account_balance_outlined,
                        onPressed: () => _openWithdrawalSheet(context),
                      ),
                    ],
                  ),
                ),
                AppSizes.vGapLg,
                Text('History', style: context.text.titleMedium),
                AppSizes.vGapMd,
                if (_withdrawals.isEmpty)
                  const AppCard(child: Text('No withdrawal history yet'))
                else
                  for (final t in _withdrawals)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      onTap: () =>
                          context.push('${Routes.transactionDetails}/${t.id}'),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.north_east_rounded,
                            color: AppColors.danger,
                          ),
                          AppSizes.hGapMd,
                          Expanded(
                            child: Text(
                              t.title,
                              style: context.text.bodyMedium,
                            ),
                          ),
                          Text(
                            Formatters.compactCurrency(t.amount),
                            style: context.text.titleSmall,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
    );
  }

  Future<void> _openWithdrawalSheet(BuildContext context) async {
    final amount = TextEditingController();
    final accountHolderName = TextEditingController();
    final accountNumber = TextEditingController();
    final ifscCode = TextEditingController();
    final bankName = TextEditingController();
    final upiId = TextEditingController();
    var method = 'bank';
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        final safeBottom = MediaQuery.of(sheetContext).padding.bottom;
        final maxSheetHeight = MediaQuery.of(sheetContext).size.height * 0.95;
        var saving = false;
        String? errorMessage;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.sm,
                    AppSizes.lg,
                    bottomInset + safeBottom + AppSizes.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Request Withdrawal',
                                style: Theme.of(
                                  sheetContext,
                                ).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: saving
                                  ? null
                                  : () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Navigator.of(sheetContext).pop();
                                    },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        if (errorMessage != null) ...[
                          AppSizes.vGapMd,
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.md),
                              child: Text(
                                errorMessage!,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                        AppSizes.vGapMd,
                        Text(
                          'Available: ${Formatters.currency(_summary.available)}',
                          style: context.text.labelMedium,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: amount,
                          label: 'Amount',
                          hint: 'Enter amount',
                          prefixIcon: Icons.currency_rupee_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'bank',
                              label: Text('Bank'),
                              icon: Icon(Icons.account_balance_outlined),
                            ),
                            ButtonSegment(
                              value: 'upi',
                              label: Text('UPI'),
                              icon: Icon(Icons.qr_code_2_rounded),
                            ),
                          ],
                          selected: {method},
                          onSelectionChanged: saving
                              ? null
                              : (values) {
                                  setSheetState(() {
                                    method = values.first;
                                    errorMessage = null;
                                  });
                                },
                        ),
                        if (method == 'bank') ...[
                          AppSizes.vGapMd,
                          AppTextField(
                            controller: accountHolderName,
                            label: 'Account holder name',
                            hint: 'Enter name',
                            textInputAction: TextInputAction.next,
                          ),
                          AppSizes.vGapMd,
                          AppTextField(
                            controller: accountNumber,
                            label: 'Account number',
                            hint: 'Enter account number',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                          AppSizes.vGapMd,
                          AppTextField(
                            controller: ifscCode,
                            label: 'IFSC code',
                            hint: 'Enter Ifsc Code',
                            textInputAction: TextInputAction.next,
                          ),
                          AppSizes.vGapMd,
                          AppTextField(
                            controller: bankName,
                            label: 'Bank name',
                            hint: 'Enter bank name',
                            textInputAction: TextInputAction.done,
                          ),
                        ] else ...[
                          AppSizes.vGapMd,
                          AppTextField(
                            controller: upiId,
                            label: 'UPI ID',
                            hint: 'Enter UPI ID',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                        AppSizes.vGapXl,
                        AppPrimaryButton(
                          label: 'Submit Request',
                          isLoading: saving,
                          onPressed: () async {
                            final value = double.tryParse(amount.text.trim());
                            if (value == null || value <= 0) {
                              setSheetState(() {
                                errorMessage = 'Enter a valid amount';
                              });
                              return;
                            }
                            if (value > _summary.available) {
                              setSheetState(() {
                                errorMessage =
                                    'Amount cannot exceed available balance';
                              });
                              return;
                            }
                            final bankPayload = {
                              'accountHolderName': accountHolderName.text
                                  .trim(),
                              'accountNumber': accountNumber.text.trim(),
                              'ifscCode': ifscCode.text.trim(),
                              'bankName': bankName.text.trim(),
                            };
                            final upiPayload = {'upiId': upiId.text.trim()};
                            if (method == 'bank' &&
                                bankPayload.values.any((v) => v.isEmpty)) {
                              setSheetState(() {
                                errorMessage = 'Enter all bank details';
                              });
                              return;
                            }
                            if (method == 'upi' &&
                                upiPayload['upiId']!.isEmpty) {
                              setSheetState(() {
                                errorMessage = 'Enter UPI ID';
                              });
                              return;
                            }
                            setSheetState(() {
                              saving = true;
                              errorMessage = null;
                            });
                            final res = await sl<WalletRepository>()
                                .requestWithdrawal(
                                  amount: value,
                                  method: method,
                                  bankDetails: method == 'bank'
                                      ? bankPayload
                                      : null,
                                  upiDetails: method == 'upi'
                                      ? upiPayload
                                      : null,
                                );
                            if (!sheetContext.mounted) return;
                            res.fold(
                              (failure) {
                                setSheetState(() {
                                  saving = false;
                                  errorMessage = failure.message;
                                });
                              },
                              (successMessage) {
                                Navigator.of(sheetContext).pop(successMessage);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    amount.dispose();
    accountHolderName.dispose();
    accountNumber.dispose();
    ifscCode.dispose();
    bankName.dispose();
    upiId.dispose();
    if (!context.mounted || message == null) return;
    context.showSnack(message);
    setState(() => _loading = true);
    await _load();
  }
}

class FreelancerTasksPage extends StatefulWidget {
  const FreelancerTasksPage({super.key});
  @override
  State<FreelancerTasksPage> createState() => _FreelancerTasksPageState();
}

class _FreelancerTasksPageState extends State<FreelancerTasksPage> {
  final _saving = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: CatalogView<FreelancerTask>(
        fetcher: (q) => sl<FreelancerTaskRepository>().getTasks(q),
        searchHint: 'Search tasks…',
        emptyTitle: 'No tasks assigned',
        itemBuilder: (context, task, __) => AppCard(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: CheckboxListTile(
            value: task.isCompleted,
            onChanged: _saving[task.id] == true
                ? null
                : (v) => _updateTaskStatus(task, v ?? false),
            secondary: IconButton(
              onPressed: () => _openTaskDetail(task.id),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? AppColors.mutedText : null,
              ),
            ),
            subtitle: Row(
              children: [
                AppStatusChip(
                  label: task.status,
                  dense: true,
                  color: task.isCompleted ? AppColors.success : AppColors.info,
                ),
                if (_saving[task.id] == true) ...[
                  AppSizes.hGapSm,
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(FreelancerTask task, bool completed) async {
    setState(() => _saving[task.id] = true);
    final status = completed ? 'completed' : 'in_progress';
    final res = await sl<FreelancerTaskRepository>().updateTaskStatus(
      task.id,
      status,
    );
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Task status updated'),
    );
    setState(() => _saving[task.id] = false);
  }

  Future<void> _openTaskDetail(String id) async {
    final res = await sl<FreelancerTaskRepository>().getTask(id);
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message), (task) async {
      final repo = sl<FreelancerTaskRepository>();
      final commentsRes = await repo.getComments(id);
      final attachmentsRes = await repo.getAttachments(id);
      final timeLogsRes = await repo.getTimeLogs(id);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: context.text.titleLarge),
                AppSizes.vGapSm,
                AppStatusChip(
                  label: task.status,
                  dense: true,
                  color: task.isCompleted ? AppColors.success : AppColors.info,
                ),
                AppSizes.vGapMd,
                Text('Progress: ${task.progress}%'),
                AppSizes.vGapMd,
                Text('Comments'),
                AppSizes.vGapXs,
                commentsRes.fold(
                  (_) => const Text('Comments unavailable'),
                  (items) => items.isEmpty
                      ? const Text('No comments')
                      : Column(
                          children: items
                              .map(
                                (c) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(c.text),
                                  subtitle: Text(c.author),
                                ),
                              )
                              .toList(),
                        ),
                ),
                AppSizes.vGapSm,
                AppPrimaryButton(
                  label: 'Add comment',
                  onPressed: () async {
                    final ctrl = TextEditingController();
                    await showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Add Comment'),
                        content: AppTextField(controller: ctrl),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final r = await repo.addComment(
                                id,
                                ctrl.text.trim(),
                              );
                              if (!context.mounted) return;
                              r.fold(
                                (f) => context.showSnack(f.message),
                                (_) => context.showSnack('Comment added'),
                              );
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AppSizes.vGapMd,
                Text('Attachments'),
                AppSizes.vGapXs,
                attachmentsRes.fold(
                  (_) => const Text('Attachments unavailable'),
                  (items) => items.isEmpty
                      ? const Text('No attachments')
                      : Column(
                          children: items
                              .map(
                                (a) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(a.name),
                                  trailing: const Icon(Icons.download_rounded),
                                ),
                              )
                              .toList(),
                        ),
                ),
                AppSizes.vGapSm,
                AppPrimaryButton(
                  label: 'Add attachment',
                  onPressed: () async {
                    final pick = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                    );
                    if (pick == null || pick.files.single.path == null) return;
                    final r = await repo.addAttachment(
                      id,
                      pick.files.single.path!,
                    );
                    if (!context.mounted) return;
                    r.fold(
                      (f) => context.showSnack(f.message),
                      (_) => context.showSnack('Attachment uploaded'),
                    );
                  },
                ),
                AppSizes.vGapMd,
                Text('Time Logs'),
                AppSizes.vGapXs,
                timeLogsRes.fold(
                  (_) => const Text('Time logs unavailable'),
                  (items) => items.isEmpty
                      ? const Text('No time logs')
                      : Column(
                          children: items
                              .map(
                                (t) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('${t.hours}h · ${t.date}'),
                                  subtitle: Text(t.notes),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class FreelancerSkillsPage extends StatefulWidget {
  const FreelancerSkillsPage({super.key});
  @override
  State<FreelancerSkillsPage> createState() => _FreelancerSkillsPageState();
}

class _FreelancerSkillsPageState extends State<FreelancerSkillsPage> {
  String? _categoryId;
  final Set<String> _selectedSkillIds = {};
  final Map<String, String> _skillNamesById = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _onSkillOptionsLoaded(List<SkillOption> skills) {
    for (final skill in skills) {
      _skillNamesById[skill.id] = skill.name;
    }
  }

  Future<void> _load() async {
    final res = await sl<FreelancerProfileRepository>().getProfile();
    if (!mounted) return;
    res.fold((_) {}, (p) {
      if (p.skills.isNotEmpty) {
        _selectedSkillIds
          ..clear()
          ..addAll(p.skills);
      }
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_selectedSkillIds.isEmpty) {
      context.showSnack('Select at least one skill', isError: true);
      return;
    }

    setState(() => _saving = true);
    final res = await sl<FreelancerProfileRepository>().updateProfile({
      'skillIds': _selectedSkillIds.toList(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (_) => context.showSnack('Skills saved'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Text(
            'Select the skills that best represent you',
            style: context.text.bodyMedium,
          ),
          AppSizes.vGapLg,
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            CategorySkillsPicker(
              selectedCategoryId: _categoryId,
              selectedSkillIds: _selectedSkillIds,
              clearSkillsOnCategoryChange: false,
              categorySubtitle: 'Browse skills by category',
              skillsSubtitle: 'Select all skills that apply to you',
              onCategoryChanged: (id, _) => setState(() => _categoryId = id),
              onSkillsChanged: (ids) => setState(() {
                _selectedSkillIds
                  ..clear()
                  ..addAll(ids);
              }),
              onSkillOptionsLoaded: _onSkillOptionsLoaded,
            ),
        ],
      ),
    );
  }
}

class FreelancerExperiencePage extends StatefulWidget {
  const FreelancerExperiencePage({super.key});

  @override
  State<FreelancerExperiencePage> createState() =>
      _FreelancerExperiencePageState();
}

class _FreelancerExperiencePageState extends State<FreelancerExperiencePage> {
  bool _loading = true;
  final _items = <String>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<FreelancerProfileRepository>().getProfile();
    if (!mounted) return;
    res.fold(
      (_) {},
      (p) => _items
        ..clear()
        ..addAll(p.experience),
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Experience'),
        actions: [
          IconButton(
            onPressed: () => context.showSnack('Add experience'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (_items.isEmpty)
                  const AppCard(child: Text('No experience added yet.'))
                else
                  for (final role in _items)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            color: AppColors.primary,
                          ),
                          AppSizes.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(role, style: context.text.titleSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
    );
  }
}

class FreelancerEducationPage extends StatefulWidget {
  const FreelancerEducationPage({super.key});

  @override
  State<FreelancerEducationPage> createState() =>
      _FreelancerEducationPageState();
}

class _FreelancerEducationPageState extends State<FreelancerEducationPage> {
  bool _loading = true;
  final _items = <String>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<FreelancerProfileRepository>().getProfile();
    if (!mounted) return;
    res.fold(
      (_) {},
      (p) => _items
        ..clear()
        ..addAll(p.education),
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Education'),
        actions: [
          IconButton(
            onPressed: () => context.showSnack('Add education'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (_items.isEmpty)
                  const AppCard(child: Text('No education details added yet.'))
                else
                  for (final degree in _items)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: AppColors.primary,
                          ),
                          AppSizes.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(degree, style: context.text.titleSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
    );
  }
}

class FreelancerPortfolioPage extends StatefulWidget {
  const FreelancerPortfolioPage({super.key});

  @override
  State<FreelancerPortfolioPage> createState() =>
      _FreelancerPortfolioPageState();
}

class _FreelancerPortfolioPageState extends State<FreelancerPortfolioPage> {
  int _listKey = 0;

  void _reload() => setState(() => _listKey++);

  @override
  Widget build(BuildContext context) => _ListScaffold(
    title: 'Portfolio',
    child: CatalogView<PortfolioItem>(
      key: ValueKey(_listKey),
      fetcher: (q) => sl<PortfolioRepository>().getPortfolio(q),
      searchHint: 'Search portfolio…',
      emptyTitle: 'No portfolio items yet',
      emptyMessage: 'Add your best work so clients can see what you deliver.',
      itemBuilder: (context, item, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.title, style: context.text.titleSmall),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => _openEdit(context, item),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () async {
                      final del = await sl<PortfolioRepository>()
                          .deletePortfolio(item.id);
                      if (!context.mounted) return;
                      del.fold((f) => context.showSnack(f.message), (_) {
                        context.showSnack('Portfolio item deleted');
                        _reload();
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              if (item.description.isNotEmpty)
                Text(
                  item.description,
                  style: context.text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (item.projectUrl != null && item.projectUrl!.isNotEmpty) ...[
                AppSizes.vGapSm,
                Text(item.projectUrl!, style: context.text.labelSmall),
              ],
              if (item.technologies.isNotEmpty) ...[
                AppSizes.vGapSm,
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    for (final tech in item.technologies)
                      Chip(
                        label: Text(tech),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.md,
          AppSizes.screenPadding,
          AppSizes.sm,
        ),
        child: AppPrimaryButton(
          label: 'Add Portfolio Item',
          icon: Icons.add_rounded,
          onPressed: () => _openAdd(context),
        ),
      ),
    ),
  );

  Future<void> _openAdd(BuildContext context) async {
    final message = await _portfolioFormSheet(context);
    if (!context.mounted || message == null) return;
    context.showSnack(message);
    _reload();
  }

  Future<void> _openEdit(BuildContext context, PortfolioItem item) async {
    final message = await _portfolioFormSheet(context, item: item);
    if (!context.mounted || message == null) return;
    context.showSnack(message);
    _reload();
  }

  Future<String?> _portfolioFormSheet(
    BuildContext context, {
    PortfolioItem? item,
  }) async {
    final title = TextEditingController(text: item?.title ?? '');
    final desc = TextEditingController(text: item?.description ?? '');
    final url = TextEditingController(text: item?.projectUrl ?? '');
    final tech = TextEditingController(
      text: item?.technologies.join(', ') ?? '',
    );
    final role = TextEditingController(text: item?.role ?? '');
    final category = TextEditingController(text: item?.category ?? '');
    final completionDate = TextEditingController(
      text: _portfolioDateValue(item?.completionDate),
    );
    final savedMessage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        final safeBottom = MediaQuery.of(sheetContext).padding.bottom;
        final maxSheetHeight = MediaQuery.of(sheetContext).size.height * 0.95;
        var saving = false;
        String? errorMessage;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.sm,
                    AppSizes.lg,
                    bottomInset + safeBottom + AppSizes.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item == null
                                    ? 'Add Portfolio'
                                    : 'Edit Portfolio',
                                style: Theme.of(
                                  sheetContext,
                                ).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: saving
                                  ? null
                                  : () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Navigator.of(sheetContext).pop();
                                    },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        if (errorMessage != null) ...[
                          AppSizes.vGapMd,
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.md),
                              child: Text(
                                errorMessage!,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: title,
                          label: 'Title',
                          hint: 'Enter Title',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: desc,
                          label: 'Description',
                          hint: 'Enter Description',
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: url,
                          label: 'Project URL',
                          hint: 'Enter your url',
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: tech,
                          label: 'Technologies (comma separated)',
                          hint:
                              'Enter technologies used, e.g. Java, Swift, Firebase',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: role,
                          label: 'Role',
                          hint: 'Enter your role',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: category,
                          label: 'Category',
                          hint: 'Enter category',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: completionDate,
                          readOnly: true,
                          label: 'Completion date',
                          hint: 'Select date',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          onTap: saving
                              ? null
                              : () async {
                                  final current = DateTime.tryParse(
                                    completionDate.text,
                                  );
                                  final picked = await showDatePicker(
                                    context: sheetContext,
                                    initialDate: current ?? DateTime.now(),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked == null) return;
                                  completionDate.text = _portfolioDateValue(
                                    picked,
                                  );
                                },
                        ),
                        AppSizes.vGapXl,
                        AppPrimaryButton(
                          label: 'Save',
                          isLoading: saving,
                          onPressed: () async {
                            final payload = {
                              'title': title.text.trim(),
                              'description': desc.text.trim(),
                              'projectUrl': url.text.trim(),
                              'technologies': tech.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList(),
                              'role': role.text.trim(),
                              'category': category.text.trim(),
                              'completionDate': completionDate.text.trim(),
                            };
                            if ((payload['title'] as String).isEmpty) {
                              setSheetState(() {
                                errorMessage = 'Title is required';
                              });
                              return;
                            }
                            if ((payload['description'] as String).isEmpty) {
                              setSheetState(() {
                                errorMessage = 'Description is required';
                              });
                              return;
                            }
                            if ((payload['technologies'] as List).isEmpty) {
                              setSheetState(() {
                                errorMessage =
                                    'Enter at least one technology used.';
                              });
                              return;
                            }
                            setSheetState(() {
                              saving = true;
                              errorMessage = null;
                            });
                            final repo = sl<PortfolioRepository>();
                            final res = item == null
                                ? await repo.addPortfolio(payload)
                                : await repo.updatePortfolio(item.id, payload);
                            if (!sheetContext.mounted) return;
                            res.fold(
                              (f) {
                                setSheetState(() {
                                  saving = false;
                                  errorMessage = f.message;
                                });
                              },
                              (saved) {
                                final message =
                                    saved.responseMessage?.trim().isNotEmpty ==
                                        true
                                    ? saved.responseMessage!.trim()
                                    : item == null
                                    ? 'Portfolio added successfully'
                                    : 'Portfolio updated successfully';
                                Navigator.of(sheetContext).pop(message);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      title.dispose();
      desc.dispose();
      url.dispose();
      tech.dispose();
      role.dispose();
      category.dispose();
      completionDate.dispose();
    });
    return savedMessage;
  }

  String _portfolioDateValue(DateTime? date) {
    if (date == null) return '';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
