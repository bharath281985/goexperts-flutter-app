import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_file_upload.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../startup_ideas/domain/repositories/startup_repository.dart';
import '../../../proposals/domain/repositories/proposal_repository.dart';

/// A single reusable application form that adapts to the application [type].
///
/// Supports: Project, Startup opportunity, Investment opportunity,
/// Partnership, Co-founder request, Mentor request, Technical partner.
class ApplyFormPage extends StatefulWidget {
  const ApplyFormPage({
    super.key,
    this.type = 'Project',
    this.targetName,
    this.projectId,
    this.proposalId,
    this.initialBid,
    this.initialCover,
    this.initialDeliveryDays,
  });

  final String type;
  final String? targetName;
  final String? projectId;
  final String? proposalId;
  final String? initialBid;
  final String? initialCover;
  final String? initialDeliveryDays;

  @override
  State<ApplyFormPage> createState() => _ApplyFormPageState();
}

class _ApplyFormPageState extends State<ApplyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetter = TextEditingController();
  final _budget = TextEditingController();
  final _customTimeline = TextEditingController();
  String _timeline = '1-2 weeks';
  String? _resume;
  String? _resumePath;
  String? _portfolio;
  String? _portfolioPath;
  bool _submitting = false;

  static const _timelines = [
    'Less than a week',
    '1-2 weeks',
    '1 month',
    '2-3 months',
    '3-6 months',
    '6-12 months',
    'More than 1 year',
    'Custom',
  ];

  bool get _isInvestment => widget.type.toLowerCase().contains('invest');
  bool get _isProject => widget.type.toLowerCase() == 'project';
  bool get _isEdit => (widget.proposalId ?? '').isNotEmpty;
  bool get _isPartnership =>
      widget.type.toLowerCase().contains('partner') ||
      widget.type.toLowerCase().contains('founder') ||
      widget.type.toLowerCase().contains('mentor');

  @override
  void initState() {
    super.initState();
    if ((widget.initialCover ?? '').isNotEmpty) {
      _coverLetter.text = widget.initialCover!;
    }
    if ((widget.initialBid ?? '').isNotEmpty) {
      _budget.text = widget.initialBid!;
    }
    _setInitialTimeline();
  }

  @override
  void dispose() {
    _coverLetter.dispose();
    _budget.dispose();
    _customTimeline.dispose();
    super.dispose();
  }

  void _setInitialTimeline() {
    final days = int.tryParse(widget.initialDeliveryDays ?? '');
    if (days == null) return;
    if (days <= 6) {
      _timeline = 'Less than a week';
    } else if (days <= 14) {
      _timeline = '1-2 weeks';
    } else if (days <= 30) {
      _timeline = '1 month';
    } else if (days <= 90) {
      _timeline = '2-3 months';
    } else if (days <= 180) {
      _timeline = '3-6 months';
    } else if (days <= 365) {
      _timeline = '6-12 months';
    } else {
      _timeline = 'More than 1 year';
    }
  }

  Future<void> _pickFile({
    required bool portfolio,
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      context.showSnack('Could not read file', isError: true);
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      context.showSnack('File too large. Maximum size is 10MB.', isError: true);
      return;
    }
    setState(() {
      if (portfolio) {
        _portfolio = file.name;
        _portfolioPath = path;
      } else {
        _resume = file.name;
        _resumePath = path;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    if (_isProject && _isEdit) {
      final result = await sl<ProposalRepository>().updateProposal(
        proposalId: widget.proposalId!,
        coverLetter: _coverLetter.text.trim(),
        bidAmount: double.tryParse(_budget.text.trim()) ?? 0,
        deliveryDays: _deliveryDays,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) {
          context.showSnack('Proposal updated');
          Navigator.of(context).maybePop();
        },
      );
      return;
    }
    if (_isProject && widget.projectId != null) {
      final result = await sl<ProposalRepository>().submitProposal(
        projectId: widget.projectId!,
        coverLetter: _coverLetter.text.trim(),
        bidAmount: double.tryParse(_budget.text.trim()) ?? 0,
        deliveryDays: _deliveryDays,
        attachments: [
          if (_resumePath != null) _resumePath!,
          if (_portfolioPath != null) _portfolioPath!,
        ],
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) {
          context.showSnack('Proposal sent to client for review!');
          Navigator.of(context).maybePop();
        },
      );
      return;
    }

    if (_isInvestment && widget.projectId != null) {
      final api = sl<ApiClientHelper>();
      final result = await api.postAction(
        ApiEndpoints.investorExpressInterest,
        body: {
          'startupId': widget.projectId,
          'amount': double.tryParse(_budget.text.trim()) ?? 0.0,
          'message': _coverLetter.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) {
          context.showSnack('Investment application submitted successfully!');
          Navigator.of(context).maybePop();
        },
      );
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);
    context.showSnack('${widget.type} application submitted!');
    Navigator.of(context).maybePop();
  }

  int get _deliveryDays {
    switch (_timeline) {
      case 'Less than a week':
        return 6;
      case '1-2 weeks':
        return 14;
      case '1 month':
        return 30;
      case '2-3 months':
        return 75;
      case '3-6 months':
        return 120;
      case '6-12 months':
        return 270;
      case 'More than 1 year':
        return 366;
      case 'Custom':
        return _customDeliveryDays;
      default:
        return 14;
    }
  }

  bool get _hasCustomTimeline => _timeline == 'Custom';

  int get _customDeliveryDays {
    final text = _customTimeline.text.trim().toLowerCase();
    final value = int.tryParse(RegExp(r'\d+').firstMatch(text)?.group(0) ?? '');
    if (value == null || value <= 0) return 14;
    if (text.contains('year')) return value * 365;
    if (text.contains('month')) return value * 30;
    if (text.contains('week')) return value * 7;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final amountLabel = _isInvestment
        ? 'Investment amount (₹)'
        : 'Expected budget (₹)';
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Proposal' : 'Apply · ${widget.type}'),
        actions: [
          if (!_isEdit)
            TextButton(
              onPressed: () async {
                if (widget.projectId == null) {
                  context.showSnack('Draft saved');
                  Navigator.of(context).maybePop();
                  return;
                }

                final String targetId = widget.projectId!;
                if (_isProject) {
                  final res = await sl<ProjectRepository>().toggleSave(
                    targetId,
                  );
                  if (!context.mounted) return;
                  res.fold((f) => context.showSnack(f.message, isError: true), (
                    success,
                  ) {
                    context.showSnack('Project saved successfully!');
                    Navigator.of(context).maybePop();
                  });
                } else if (_isInvestment) {
                  final res = await sl<StartupRepository>().toggleSave(
                    targetId,
                  );
                  if (!context.mounted) return;
                  res.fold((f) => context.showSnack(f.message, isError: true), (
                    success,
                  ) {
                    context.showSnack('Startup saved successfully!');
                    Navigator.of(context).maybePop();
                  });
                } else {
                  context.showSnack('Draft saved');
                  Navigator.of(context).maybePop();
                }
              },
              child: Text(
                _isProject
                    ? 'Save Project'
                    : (_isInvestment ? 'Save Startup' : 'Save Draft'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              AppSizes.screenPadding + AppSizes.lg,
            ),
            children: [
              if (widget.targetName != null)
                AppCard(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: Text(
                          _isEdit
                              ? 'Updating proposal for ${widget.targetName}'
                              : 'Applying to ${widget.targetName}',
                          style: context.text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              AppSizes.vGapLg,
              AppTextField(
                controller: _coverLetter,
                label: _isPartnership ? 'Message / Pitch' : 'Cover letter',
                hint: 'Tell them why you\'re a great fit…',
                maxLines: 6,
                validator: (v) => (v == null || v.trim().length < 20)
                    ? 'Please write at least 20 characters'
                    : null,
              ),
              AppSizes.vGapLg,
              AppTextField(
                controller: _budget,
                label: amountLabel,
                hint: '250000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
              if (!_isInvestment) ...[
                AppSizes.vGapLg,
                AppDropdown<String>(
                  label: 'Expected timeline',
                  hint: 'Select expected timeline',
                  value: _timeline,
                  items: _timelines,
                  itemLabel: (e) => e,
                  onChanged: (v) => setState(() => _timeline = v ?? _timeline),
                ),
                if (_hasCustomTimeline) ...[
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _customTimeline,
                    label: 'Custom timeline',
                    hint: 'Enter expected timeline, e.g. 45 days',
                    keyboardType: TextInputType.text,
                    validator: (v) =>
                        _hasCustomTimeline && (v == null || v.trim().isEmpty)
                        ? 'Enter expected timeline'
                        : null,
                  ),
                ],
              ],
              if (!_isEdit) ...[
                AppSizes.vGapLg,
                AppFileUpload(
                  label: 'Attach resume / profile',
                  hint: 'PDF · up to 10MB',
                  fileName: _resume,
                  onTap: () => _pickFile(
                    portfolio: false,
                    allowedExtensions: const ['pdf', 'doc', 'docx'],
                  ),
                ),
                AppSizes.vGapLg,
                AppFileUpload(
                  label: 'Attach portfolio (optional)',
                  hint: 'PDF or ZIP · up to 10MB',
                  fileName: _portfolio,
                  onTap: () => _pickFile(
                    portfolio: true,
                    allowedExtensions: const ['pdf', 'zip'],
                  ),
                ),
              ],
              AppSizes.vGapXl,
              AppPrimaryButton(
                label: _isEdit ? 'Update Proposal' : 'Submit Application',
                isLoading: _submitting,
                onPressed: _submit,
              ),
              if (_isEdit) ...[
                AppSizes.vGapMd,
                AppSecondaryButton(
                  label: 'Withdraw Proposal',
                  color: AppColors.danger,
                  onPressed: () async {
                    final ok = await AppConfirmDialog.show(
                      context,
                      title: 'Withdraw proposal?',
                      message: 'The client will no longer see this proposal.',
                      confirmLabel: 'Withdraw',
                      isDestructive: true,
                    );
                    if (!ok || !context.mounted) return;
                    final res = await sl<ProposalRepository>().withdraw(
                      widget.proposalId!,
                    );
                    if (!context.mounted) return;
                    res.fold(
                      (f) => context.showSnack(f.message, isError: true),
                      (_) {
                        context.showSnack('Proposal withdrawn');
                        Navigator.of(context).maybePop();
                      },
                    );
                  },
                ),
              ] else ...[
                AppSizes.vGapMd,
                AppSecondaryButton(
                  label: 'Withdraw',
                  color: AppColors.danger,
                  onPressed: () async {
                    final ok = await AppConfirmDialog.show(
                      context,
                      title: 'Withdraw application?',
                      message: 'This will remove your application permanently.',
                      confirmLabel: 'Withdraw',
                      isDestructive: true,
                    );
                    if (ok && context.mounted) {
                      context.showSnack('Application withdrawn');
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
