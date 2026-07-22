import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../app/constants/app_colors.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/bloc/list_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_filter_bottom_sheet.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/startup.dart';
import '../../domain/repositories/startup_repository.dart';
import '../widgets/startup_card.dart';

/// Embeddable startup discovery catalog. Implements creation, edition, and deletion of startup ideas for founder role.
class StartupsListView extends StatelessWidget {
  const StartupsListView({super.key, this.isFounderOverride});

  final bool? isFounderOverride;

  Future<void> _createIdea(BuildContext context) async {
    final data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateIdeaBottomSheet(),
    );

    if (data == null) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = sl<StartupRepository>();
    final res = await repo.createIdea(data);

    if (!context.mounted) return;
    Navigator.pop(context); // Dismiss loading spinner

    res.fold((f) => context.showTopSnack(f.message, isError: true), (idea) {
      context.showTopSnack('Startup idea created successfully!');
      context.read<ListBloc<Startup>>().add(const ListRefreshed());
    });
  }

  Future<void> _editIdea(
    BuildContext context,
    Startup startup,
    ListBloc<Startup> bloc,
  ) async {
    final data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditIdeaBottomSheet(startup: startup),
    );

    if (data == null) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = sl<StartupRepository>();
    final res = await repo.updateIdea(startup.id, data);

    if (!context.mounted) return;
    Navigator.pop(context); // Dismiss loading spinner

    res.fold((f) => context.showTopSnack(f.message, isError: true), (
      updatedIdea,
    ) {
      context.showTopSnack('Startup idea updated successfully!');
      bloc.add(const ListRefreshed());
    });
  }

  Future<void> _deleteIdea(
    BuildContext context,
    Startup startup,
    ListBloc<Startup> bloc,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Idea'),
        content: const Text(
          'Are you sure you want to delete this startup idea? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = sl<StartupRepository>();
    final res = await repo.deleteIdea(startup.id);

    if (!context.mounted) return;
    Navigator.pop(context); // Dismiss loading spinner

    res.fold((f) => context.showTopSnack(f.message, isError: true), (success) {
      if (success) {
        context.showTopSnack('Startup idea deleted successfully');
        bloc.add(const ListRefreshed());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<StartupRepository>();
    final authState = context.read<AuthBloc>().state;
    final isFounder =
        isFounderOverride ?? (authState.user?.role == UserRole.founder);

    return CatalogView<Startup>(
      fetcher: repo.getStartups,
      searchHint: isFounder
          ? 'Search startup ideas…'
          : 'Search startups, industries…',
      emptyTitle: isFounder ? 'No startup ideas found' : 'No startups found',
      emptyIcon: Icons.rocket_launch_outlined,
      sortOptions: const ['Most interest', 'Funding: High to Low', 'Newest'],
      filterSections: () => [
        FilterSection(
          key: 'industry',
          title: 'Industry',
          options: const [
            'AgriTech',
            'HealthTech',
            'EdTech',
            'CleanTech',
            'FinTech',
            'SaaS',
          ],
        ),
        FilterSection(
          key: 'stage',
          title: 'Stage',
          options: const [
            'Idea Stage',
            'Prototype',
            'MVP',
            'Early Revenue',
            'Early Traction',
            'Growth',
            'Expansion',
          ],
        ),
      ],
      floatingActionButton: isFounder
          ? Builder(
              builder: (catCtx) => FloatingActionButton.extended(
                key: const ValueKey('add_idea_fab'),
                onPressed: () => _createIdea(catCtx),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Idea'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            )
          : null,
      itemBuilder: (context, s, _) {
        final bloc = context.read<ListBloc<Startup>>();
        return AppStartupCard(
          startup: s,
          onTap: isFounder
              ? () => context.push(Routes.founderStartup)
              : () => context.push('${Routes.startupDetails}/${s.id}'),
          onSave: isFounder
              ? null
              : () async {
                  final res = await repo.toggleSave(s.founderId!);
                  res.fold(
                    (f) => context.showTopSnack(f.message, isError: true),
                    (success) {
                      if (success) {
                        final updated = s.copyWith(isSaved: !s.isSaved);
                        bloc.add(
                          ListItemUpdated(
                            updated,
                            (existing, newItem) => existing.id == newItem.id,
                          ),
                        );
                        context.showTopSnack(
                          updated.isSaved
                              ? 'Saved startup'
                              : 'Removed from saved',
                        );
                      }
                    },
                  );
                },
          onInterest: isFounder
              ? null
              : () async {
                  if (s.hasInvested) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Withdraw Interest'),
                        content: const Text(
                          'Are you sure you want to withdraw your interest in this startup?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Withdraw',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;

                    final res = await repo.withdrawInterest(s.id);
                    res.fold(
                      (f) => context.showTopSnack(f.message, isError: true),
                      (success) {
                        if (success) {
                          final updated = s.copyWith(hasInvested: false);
                          bloc.add(
                            ListItemUpdated(
                              updated,
                              (existing, newItem) => existing.id == newItem.id,
                            ),
                          );
                          context.showTopSnack(
                            'Withdrew interest successfully',
                          );
                        }
                      },
                    );
                  } else {
                    context.push(
                      '${Routes.apply}?type=Investment&name=${Uri.encodeComponent(s.name)}&projectId=${s.id}',
                    );
                  }
                },
          onEdit: isFounder ? () => _editIdea(context, s, bloc) : null,
          onDelete: isFounder ? () => _deleteIdea(context, s, bloc) : null,
        );
      },
    );
  }
}

class _CreateIdeaBottomSheet extends StatefulWidget {
  const _CreateIdeaBottomSheet();

  @override
  State<_CreateIdeaBottomSheet> createState() => _CreateIdeaBottomSheetState();
}

class _CreateIdeaBottomSheetState extends State<_CreateIdeaBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _categoryController = TextEditingController();
  final _fundingController = TextEditingController();
  final _equityController = TextEditingController();

  String? _stage = 'MVP';
  String? _localLogoPath;
  String? _localCoverPath;
  String? _localPitchDiskPath;
  String? _localBusinessPlanPath;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _categoryController.dispose();
    _fundingController.dispose();
    _equityController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      if (picked != null && picked.files.single.path != null) {
        setState(() {
          _localLogoPath = picked.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showTopSnack('Failed to pick logo: $e', isError: true);
      }
    }
  }

  Future<void> _pickCover() async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      if (picked != null && picked.files.single.path != null) {
        setState(() {
          _localCoverPath = picked.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showTopSnack('Failed to pick cover: $e', isError: true);
      }
    }
  }

  Future<void> _pickPitchDisk() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );
      if (picked != null && picked.files.single.path != null) {
        setState(() {
          _localPitchDiskPath = picked.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showTopSnack('Failed to pick Pitch Deck: $e', isError: true);
      }
    }
  }

  Future<void> _pickBusinessPlan() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );
      if (picked != null && picked.files.single.path != null) {
        setState(() {
          _localBusinessPlanPath = picked.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showTopSnack('Failed to pick Business Plan: $e', isError: true);
      }
    }
  }

  void _viewLocalImage(String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(path),
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerItem({
    required String label,
    required String? localPath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    if (localPath != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(localPath),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(label),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    context.tr('Image Picked'),
                    style: const TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 20),
              onPressed: () => _viewLocalImage(localPath),
              tooltip: context.tr('View'),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onPick,
              tooltip: context.tr('Change'),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              onPressed: onRemove,
              tooltip: context.tr('Remove'),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 38),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPick,
      icon: const Icon(Icons.image_outlined, size: 18),
      label: Text('${context.tr('Pick')} ${context.tr(label)}'),
    );
  }

  Widget _buildDocPickerItem({
    required String label,
    required String? localPath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    if (localPath != null) {
      final fileName = p.basename(localPath);
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(label),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    fileName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onPick,
              tooltip: context.tr('Change'),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              onPressed: onRemove,
              tooltip: context.tr('Remove'),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 38),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPick,
      icon: const Icon(Icons.upload_file_outlined, size: 18),
      label: Text('${context.tr('Upload')} ${context.tr(label)}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.viewPaddingOf(context).bottom +
            24,
      ),
      child: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20, top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Text(
                    context.tr('Create Startup Idea'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildImagePickerItem(
                    label: 'Logo',
                    localPath: _localLogoPath,
                    onPick: _pickLogo,
                    onRemove: () => setState(() => _localLogoPath = null),
                  ),
                  const SizedBox(height: 12),
                  _buildImagePickerItem(
                    label: 'Cover Image',
                    localPath: _localCoverPath,
                    onPick: _pickCover,
                    onRemove: () => setState(() => _localCoverPath = null),
                  ),
                  const SizedBox(height: 12),
                  _buildDocPickerItem(
                    label: 'Pitch Deck (pitch Disk)',
                    localPath: _localPitchDiskPath,
                    onPick: _pickPitchDisk,
                    onRemove: () => setState(() => _localPitchDiskPath = null),
                  ),
                  const SizedBox(height: 12),
                  _buildDocPickerItem(
                    label: 'Business Plan (Businessplan)',
                    localPath: _localBusinessPlanPath,
                    onPick: _pickBusinessPlan,
                    onRemove: () =>
                        setState(() => _localBusinessPlanPath = null),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _nameController,
                    label: 'Startup Name',
                    hint: 'e.g. HealthBridge AI',
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _industryController,
                    label: 'Industry',
                    hint: 'e.g. Healthcare',
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'e.g. Artificial Intelligence',
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _stage,
                    decoration: InputDecoration(
                      labelText: context.tr('Stage'),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Idea Stage',
                        child: Text(context.tr('Idea Stage')),
                      ),
                      DropdownMenuItem(
                        value: 'Prototype',
                        child: Text(context.tr('Prototype')),
                      ),
                      const DropdownMenuItem(value: 'MVP', child: Text('MVP')),
                      DropdownMenuItem(
                        value: 'Early Revenue',
                        child: Text(context.tr('Early Revenue')),
                      ),
                      DropdownMenuItem(
                        value: 'Early Traction',
                        child: Text(context.tr('Early Traction')),
                      ),
                      DropdownMenuItem(
                        value: 'Growth',
                        child: Text(context.tr('Growth')),
                      ),
                      DropdownMenuItem(
                        value: 'Expansion',
                        child: Text(context.tr('Expansion')),
                      ),
                    ],
                    onChanged: (val) => setState(() => _stage = val),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _fundingController,
                          label: 'Funding Ask',
                          hint: 'e.g. 15000',
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Invalid'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _equityController,
                          label: 'Equity (%)',
                          hint: 'e.g. 5',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final eq = double.tryParse(v ?? '');
                            if (eq == null || eq < 0 || eq > 100) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(80, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.tr('Cancel')),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 44),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                setState(() => _loading = true);

                                String? logoUrl;
                                String? coverUrl;
                                String? pitchDiskUrl;
                                String? businessPlanUrl;

                                final uploadHelper = sl<FileUploadHelper>();
                                if (_localLogoPath != null) {
                                  final res = await uploadHelper.uploadUrl(
                                    path: _localLogoPath!,
                                    endpoint: ApiEndpoints.filesUpload,
                                    fields: {'category': 'startup_logo'},
                                  );
                                  res.fold((_) {}, (url) => logoUrl = url);
                                }

                                if (_localCoverPath != null) {
                                  final res = await uploadHelper.uploadUrl(
                                    path: _localCoverPath!,
                                    endpoint: ApiEndpoints.filesUpload,
                                    fields: {'category': 'startup_cover'},
                                  );
                                  res.fold((_) {}, (url) => coverUrl = url);
                                }

                                if (_localPitchDiskPath != null) {
                                  final res = await uploadHelper.uploadUrl(
                                    path: _localPitchDiskPath!,
                                    endpoint: ApiEndpoints.filesUpload,
                                    fields: {'category': 'startup_pitch_deck'},
                                  );
                                  res.fold((_) {}, (url) => pitchDiskUrl = url);
                                }

                                if (_localBusinessPlanPath != null) {
                                  final res = await uploadHelper.uploadUrl(
                                    path: _localBusinessPlanPath!,
                                    endpoint: ApiEndpoints.filesUpload,
                                    fields: {
                                      'category': 'startup_business_plan',
                                    },
                                  );
                                  res.fold(
                                    (_) {},
                                    (url) => businessPlanUrl = url,
                                  );
                                }

                                if (!context.mounted) return;
                                context.pop({
                                  'logo': logoUrl ?? '',
                                  'coverimage': coverUrl ?? '',
                                  'pitchDisk': pitchDiskUrl ?? '',
                                  'Businessplan': businessPlanUrl ?? '',
                                  'pitchDeckUrl': pitchDiskUrl ?? '',
                                  'businessPlanUrl': businessPlanUrl ?? '',
                                  'startup': _nameController.text.trim(),
                                  'industry': _industryController.text.trim(),
                                  'category': _categoryController.text.trim(),
                                  'stage': _stage,
                                  'funding':
                                      double.tryParse(
                                        _fundingController.text.trim(),
                                      ) ??
                                      0.0,
                                  'equity':
                                      double.tryParse(
                                        _equityController.text.trim(),
                                      ) ??
                                      0.0,
                                });
                              },
                        child: Text(context.tr('Create')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _EditIdeaBottomSheet extends StatefulWidget {
  const _EditIdeaBottomSheet({required this.startup});

  final Startup startup;

  @override
  State<_EditIdeaBottomSheet> createState() => _EditIdeaBottomSheetState();
}

class _EditIdeaBottomSheetState extends State<_EditIdeaBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fundingController;
  String? _stage;

  @override
  void initState() {
    super.initState();
    _fundingController = TextEditingController(
      text: widget.startup.fundingRequired.toStringAsFixed(0),
    );
    _stage = widget.startup.stage;
  }

  @override
  void dispose() {
    _fundingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.viewPaddingOf(context).bottom +
            24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Text(
                context.tr('Edit Startup Idea'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _fundingController,
                label: 'Funding Ask (USD)',
                hint: 'e.g. 25000',
                keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'Enter valid funding ask'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _stage,
                decoration: InputDecoration(
                  labelText: context.tr('Stage'),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Idea Stage',
                    child: Text(context.tr('Idea Stage')),
                  ),
                  DropdownMenuItem(
                    value: 'Prototype',
                    child: Text(context.tr('Prototype')),
                  ),
                  const DropdownMenuItem(value: 'MVP', child: Text('MVP')),
                  DropdownMenuItem(
                    value: 'Early Revenue',
                    child: Text(context.tr('Early Revenue')),
                  ),
                  DropdownMenuItem(
                    value: 'Early Traction',
                    child: Text(context.tr('Early Traction')),
                  ),
                  DropdownMenuItem(
                    value: 'Growth',
                    child: Text(context.tr('Growth')),
                  ),
                  DropdownMenuItem(
                    value: 'Expansion',
                    child: Text(context.tr('Expansion')),
                  ),
                ],
                onChanged: (val) => setState(() => _stage = val),
                validator: (v) => v == null ? 'Stage is required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(80, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('Cancel')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 44),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.pop(context, {
                        'funding':
                            double.tryParse(_fundingController.text.trim()) ??
                            0.0,
                        'stage': _stage,
                      });
                    },
                    child: Text(context.tr('Update')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
