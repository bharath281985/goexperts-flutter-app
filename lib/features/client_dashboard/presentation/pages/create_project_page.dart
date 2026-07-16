import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_file_upload.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_stepper.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_skills_picker.dart';
import '../../../master_data/domain/entities/skill_option.dart';
import '../../../projects/domain/repositories/project_repository.dart';

/// 5-step create / edit project wizard.
class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  int _step = 0;
  final _basicsFormKey = GlobalKey<FormState>();
  final _budgetFormKey = GlobalKey<FormState>();
  static const _steps = [
    'Basics',
    'Category',
    'Budget',
    'Attachments',
    'Review',
  ];

  final _title = TextEditingController();
  final _desc = TextEditingController();
  String? _categoryId;
  String _categoryName = '';
  String _budgetType = 'Fixed';
  String _workMode = 'Remote';
  String _experienceLevel = 'intermediate';
  final _budget = TextEditingController();
  final Set<String> _skillIds = {};
  final Map<String, String> _skillNamesById = {};
  DateTime? _deadline;
  final List<_ProjectAttachment> _attachments = [];
  final List<String> _existingAttachmentUrls = [];
  bool _publishing = false;
  bool _loadingExisting = false;
  String? _categoryError;
  String? _skillsError;
  String? _deadlineError;
  String? _attachmentsError;

  bool get _isEdit => (widget.projectId ?? '').isNotEmpty;

  static String _normalizeExperienceLevel(String? raw) {
    final value = (raw ?? 'intermediate').trim().toLowerCase();
    if (value == 'beginner' || value == 'entry' || value == 'junior') {
      return 'beginner';
    }
    if (value == 'expert' || value == 'senior' || value == 'advanced') {
      return 'expert';
    }
    return 'intermediate';
  }

  static String _experienceLevelLabel(String key) {
    switch (_normalizeExperienceLevel(key)) {
      case 'beginner':
        return 'Beginner';
      case 'expert':
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }

  static const _maxAttachments = 20;
  static const _allowedAttachmentExtensions = {
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'rtf',
    'odt',
    'ods',
    'odp',
    'zip',
    'rar',
    '7z',
  };
  static const _blockedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'heic',
    'heif',
    'svg',
    'ico',
    'tif',
    'tiff',
  };

  int get _attachmentCount =>
      _attachments.length + _existingAttachmentUrls.length;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);
    final res = await sl<ProjectRepository>().getProject(widget.projectId!);
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _loadingExisting = false);
        context.showSnack(f.message, isError: true);
      },
      (project) {
        _title.text = project.title;
        _desc.text = project.description;
        _categoryId = project.categoryId;
        _categoryName = project.category;
        _skillIds
          ..clear()
          ..addAll(project.skillIds);
        for (var i = 0; i < project.skillIds.length; i++) {
          final id = project.skillIds[i];
          final name = i < project.skills.length ? project.skills[i] : id;
          _skillNamesById[id] = name;
        }
        _budgetType = project.isHourly ? 'Hourly' : 'Fixed';
        _workMode = project.workMode;
        _experienceLevel = _normalizeExperienceLevel(project.experienceLevel);
        if (project.budgetMin == project.budgetMax) {
          _budget.text = project.budgetMax.toStringAsFixed(0);
        } else {
          _budget.text =
              '${project.budgetMin.toStringAsFixed(0)}-${project.budgetMax.toStringAsFixed(0)}';
        }
        _deadline = DateTime.tryParse(project.timeline);
        _existingAttachmentUrls
          ..clear()
          ..addAll(project.attachments);
        setState(() => _loadingExisting = false);
      },
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _budget.dispose();
    super.dispose();
  }

  void _onSkillOptionsLoaded(List<SkillOption> skills) {
    for (final skill in skills) {
      _skillNamesById[skill.id] = skill.name;
    }
  }

  String _skillLabels() {
    if (_skillIds.isEmpty) return '—';
    return _skillIds.map((id) => _skillNamesById[id] ?? id).join(', ');
  }

  bool _validateCategoryStep() {
    var valid = true;
    if (_categoryId == null) {
      _categoryError = 'Category is required';
      valid = false;
    } else {
      _categoryError = null;
    }
    _skillsError = null;
    setState(() {});
    return valid;
  }

  bool _validateBudgetStep() {
    final validForm = _budgetFormKey.currentState?.validate() ?? false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = _deadline == null
        ? null
        : DateTime(_deadline!.year, _deadline!.month, _deadline!.day);

    if (_deadline == null) {
      _deadlineError = 'Deadline is required';
    } else if (selected!.isBefore(today)) {
      _deadlineError = 'Deadline cannot be in the past';
    } else {
      _deadlineError = null;
    }

    setState(() {});
    return validForm && _deadlineError == null;
  }

  bool _validateAttachmentsStep() {
    if (_attachmentCount == 0) {
      setState(() {
        _attachmentsError = 'Upload at least 1 document.';
      });
      return false;
    }
    if (_attachmentCount > _maxAttachments) {
      setState(() {
        _attachmentsError = 'You can upload up to $_maxAttachments files.';
      });
      return false;
    }
    setState(() => _attachmentsError = null);
    return true;
  }

  String? _validateBudget(String? value) {
    final required = Validators.required(value, field: 'Budget');
    if (required != null) return required;

    final range = _parseBudgetRange(value!);
    if (range == null) return 'Enter a valid budget or range';
    if (range.max <= 0) return 'Budget must be greater than 0';
    if (range.min < 0) return 'Budget cannot be negative';
    if (range.min > range.max) return 'Minimum budget cannot exceed maximum';
    return null;
  }

  ({double min, double max})? _parseBudgetRange(String value) {
    final sanitized = value
        .trim()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .replaceAll(RegExp(r'\s+'), '');
    if (sanitized.isEmpty) return null;

    final parts = sanitized.split('-');
    if (parts.length == 1) {
      final max = double.tryParse(parts.first);
      if (max == null) return null;
      return (min: 0, max: max);
    }
    if (parts.length == 2) {
      final min = double.tryParse(parts.first);
      final max = double.tryParse(parts.last);
      if (min == null || max == null) return null;
      return (min: min, max: max);
    }
    return null;
  }

  String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  bool _isAllowedAttachment(String name) {
    final extension = _extensionOf(name);
    return _allowedAttachmentExtensions.contains(extension) &&
        !_blockedImageExtensions.contains(extension);
  }

  Future<void> _pickAttachments() async {
    final remaining = _maxAttachments - _attachmentCount;
    if (remaining <= 0) {
      context.showSnack(
        'Maximum $_maxAttachments files allowed.',
        isError: true,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _allowedAttachmentExtensions.toList(),
    );
    if (result == null) return;

    final rejected = <String>[];
    final selected = <_ProjectAttachment>[];

    for (final file in result.files) {
      if (file.path == null || !_isAllowedAttachment(file.name)) {
        rejected.add(file.name);
        continue;
      }

      selected.add(
        _ProjectAttachment(name: file.name, path: file.path!, size: file.size),
      );
    }

    final skippedForLimit = selected.length > remaining
        ? selected.length - remaining
        : 0;
    final toAdd = selected.take(remaining);

    if (!mounted) return;
    setState(() {
      for (final attachment in toAdd) {
        final alreadySelected = _attachments.any(
          (item) => item.path == attachment.path,
        );
        if (!alreadySelected) _attachments.add(attachment);
      }
      if (_attachments.isNotEmpty) _attachmentsError = null;
    });

    if (rejected.isNotEmpty) {
      context.showSnack(
        'Images are not allowed. Upload PDF, DOC, Excel, PPT, ZIP or text documents.',
        isError: true,
      );
    } else if (skippedForLimit > 0) {
      context.showSnack(
        'Only $_maxAttachments files allowed. $skippedForLimit file(s) were skipped.',
        isError: true,
      );
    }
  }

  Future<List<String>?> _uploadAttachments() async {
    final uploader = sl<FileUploadHelper>();
    final urls = <String>[];

    for (final attachment in _attachments) {
      final upload = await uploader.uploadUrl(
        path: attachment.path,
        endpoint: ApiEndpoints.filesUpload,
        fields: {'category': 'project_attachment'},
      );

      String? error;
      upload.fold((failure) => error = failure.message, (url) {
        urls.add(url.isNotEmpty ? url : attachment.name);
      });

      if (error != null) {
        if (mounted) context.showSnack(error!, isError: true);
        return null;
      }
    }

    return urls;
  }

  Future<void> _next() async {
    if (_step == 0 && !(_basicsFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_step == 1 && !_validateCategoryStep()) return;
    if (_step == 2 && !_validateBudgetStep()) return;
    if (_step == 3 && !_validateAttachmentsStep()) return;

    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }

    setState(() => _publishing = true);
    final attachmentUrls = await _uploadAttachments();
    if (!mounted) return;
    if (attachmentUrls == null) {
      setState(() => _publishing = false);
      return;
    }

    final budgetRange = _parseBudgetRange(_budget.text);
    if (budgetRange == null) {
      setState(() => _publishing = false);
      return;
    }

    final body = {
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'categoryId': _categoryId,
      'skillIds': _skillIds.toList(),
      'budget': budgetRange.max,
      'budgetMin': budgetRange.min,
      'budgetMax': budgetRange.max,
      'budgetType': _budgetType.toLowerCase(),
      'workMode': _workMode,
      'experienceLevel': _experienceLevel,
      if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
      'attachments': [..._existingAttachmentUrls, ...attachmentUrls],
    };

    if (_isEdit) {
      final res = await sl<ProjectRepository>().updateProject(
        widget.projectId!,
        body,
      );
      if (!mounted) return;
      setState(() => _publishing = false);
      res.fold((f) => context.showSnack(f.message, isError: true), (_) {
        context.showSnack('Project updated successfully!');
        Navigator.of(context).maybePop(true);
      });
      return;
    }

    final api = sl<ApiClientHelper>();
    final res = await api.post<Map<String, dynamic>>(
      ApiEndpoints.clientProjects,
      body: body,
      parser: (data) => Map<String, dynamic>.from(data as Map),
      allowNullData: false,
    );
    if (!mounted) return;
    setState(() => _publishing = false);
    res.fold((f) => context.showSnack(f.message), (_) {
      context.showSnack('Project published successfully!');
      Navigator.of(context).maybePop(true);
    });
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Project' : 'Post a Project')),
      body: _loadingExisting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: AppStepper(steps: _steps, currentStep: _step),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    child: _buildStep(),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: AppSecondaryButton(
                              label: 'Back',
                              onPressed: _back,
                            ),
                          ),
                        if (_step > 0) AppSizes.hGapMd,
                        Expanded(
                          flex: 2,
                          child: AppPrimaryButton(
                            label: _step == _steps.length - 1
                                ? (_isEdit ? 'Save Changes' : 'Publish Project')
                                : 'Continue',
                            isLoading: _publishing,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Form(
          key: _basicsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _title,
                label: 'Project Title',
                hint: 'Enter your project title',
                validator: (v) =>
                    Validators.minLength(v, 5, field: 'Project title'),
              ),
              AppSizes.vGapLg,
              AppTextField(
                controller: _desc,
                label: 'Description',
                hint: 'Describe your project…',
                maxLines: 6,
                validator: (v) =>
                    Validators.minLength(v, 20, field: 'Description'),
              ),
            ],
          ),
        );
      case 1:
        return CategorySkillsPicker(
          selectedCategoryId: _categoryId,
          selectedSkillIds: _skillIds,
          categorySubtitle: 'Choose a category for your project',
          skillsLabel: 'Skills',
          skillsSubtitle: 'Select skills needed for this project (optional)',
          categoryError: _categoryError,
          skillsError: _skillsError,
          onCategoryChanged: (id, name) {
            setState(() {
              _categoryId = id;
              _categoryName = name;
              _categoryError = null;
            });
          },
          onSkillsChanged: (ids) {
            setState(() {
              _skillIds
                ..clear()
                ..addAll(ids);
              _skillsError = null;
            });
          },
          onSkillOptionsLoaded: _onSkillOptionsLoaded,
        );
      case 2:
        return Form(
          key: _budgetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<String>(
                label: 'Budget Type',
                hint: 'Select budget type',
                value: _budgetType,
                items: const ['Fixed', 'Hourly'],
                itemLabel: (e) => e,
                onChanged: (v) => setState(() => _budgetType = v ?? 'Fixed'),
              ),
              AppSizes.vGapLg,
              AppTextField(
                controller: _budget,
                label: 'Budget (₹)',
                hint: '10000-50000',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9., -]')),
                ],
                prefixIcon: Icons.currency_rupee_rounded,
                validator: _validateBudget,
              ),
              AppSizes.vGapLg,
              AppDatePicker(
                label: 'Deadline',
                value: _deadline,
                firstDate: DateTime.now(),
                onChanged: (d) => setState(() {
                  _deadline = d;
                  _deadlineError = null;
                }),
              ),
              if (_deadlineError != null) ...[
                AppSizes.vGapXs,
                Text(
                  _deadlineError!,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
              AppSizes.vGapLg,
              AppDropdown<String>(
                label: 'Experience Level',
                hint: 'Select level',
                value: _experienceLevel,
                items: const ['beginner', 'intermediate', 'expert'],
                itemLabel: _experienceLevelLabel,
                onChanged: (v) =>
                    setState(() => _experienceLevel = v ?? 'intermediate'),
              ),
              AppSizes.vGapLg,
              AppDropdown<String>(
                label: 'Work Mode',
                hint: 'Select work mode',
                value: _workMode,
                items: const ['Remote', 'On-site', 'Hybrid'],
                itemLabel: (e) => e,
                onChanged: (v) => setState(() => _workMode = v ?? 'Remote'),
              ),
            ],
          ),
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFileUpload(
              label: 'Upload attachments',
              hint:
                  'At least 1 document required. Up to $_maxAttachments files: PDF, DOC, Excel, PPT, ZIP or text. Images not allowed.',
              onTap: _pickAttachments,
              fileName: _attachmentCount == 0
                  ? null
                  : '$_attachmentCount / $_maxAttachments document(s)',
            ),
            if (_attachmentsError != null) ...[
              AppSizes.vGapXs,
              Text(
                _attachmentsError!,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            if (_existingAttachmentUrls.isNotEmpty) ...[
              AppSizes.vGapMd,
              for (final url in _existingAttachmentUrls)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_file_rounded),
                  title: Text(
                    url.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        setState(() => _existingAttachmentUrls.remove(url)),
                  ),
                ),
            ],
            if (_attachments.isNotEmpty) ...[
              AppSizes.vGapMd,
              for (final attachment in _attachments)
                _attachmentTile(attachment),
            ],
          ],
        );
      default:
        return _review();
    }
  }

  Widget _review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Publish', style: context.text.titleMedium),
        AppSizes.vGapMd,
        _row('Title', _title.text.isEmpty ? '—' : _title.text),
        _row('Category', _categoryName.isEmpty ? '—' : _categoryName),
        _row('Skills', _skillLabels()),
        _row('Level', _experienceLevelLabel(_experienceLevel)),
        _row('Work Mode', _workMode),
        _row(
          'Budget',
          '${_budget.text.isEmpty ? '—' : '₹${_budget.text}'} ($_budgetType)',
        ),
        _row('Skills', _skillLabels()),
        _row(
          'Deadline',
          _deadline == null
              ? '—'
              : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
        ),
        _row(
          'Attachments',
          _attachmentCount == 0
              ? '—'
              : [
                  ..._existingAttachmentUrls.map((u) => u.split('/').last),
                  ..._attachments.map((file) => file.name),
                ].join(', '),
        ),
      ],
    );
  }

  Widget _attachmentTile(_ProjectAttachment attachment) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.sm),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.description_outlined),
        title: Text(
          attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatFileSize(attachment.size)),
        trailing: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: context.colors.error.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: context.colors.outline,
            tooltip: 'Remove attachment',
            iconSize: 18,
            icon: Icon(Icons.close_rounded, color: context.colors.error),
            onPressed: () => setState(() {
              _attachments.remove(attachment);
            }),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 26, height: 26),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'Document';
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: context.text.labelMedium),
        ),
        Expanded(child: Text(value, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _ProjectAttachment {
  const _ProjectAttachment({
    required this.name,
    required this.path,
    required this.size,
  });

  final String name;
  final String path;
  final int size;
}
