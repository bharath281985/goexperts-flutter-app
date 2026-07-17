import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
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
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CreateIdeaDialog(),
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

    res.fold((f) => context.showSnack(f.message, isError: true), (idea) {
      context.showSnack('Startup idea created successfully!');
      context.read<ListBloc<Startup>>().add(const ListRefreshed());
    });
  }

  Future<void> _editIdea(
    BuildContext context,
    Startup startup,
    ListBloc<Startup> bloc,
  ) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _EditIdeaDialog(startup: startup),
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

    res.fold((f) => context.showSnack(f.message, isError: true), (updatedIdea) {
      context.showSnack('Startup idea updated successfully!');
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

    res.fold((f) => context.showSnack(f.message, isError: true), (success) {
      if (success) {
        context.showSnack('Startup idea deleted successfully');
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
                  res.fold((f) => context.showSnack(f.message), (success) {
                    if (success) {
                      final updated = s.copyWith(isSaved: !s.isSaved);
                      bloc.add(
                        ListItemUpdated(
                          updated,
                          (existing, newItem) => existing.id == newItem.id,
                        ),
                      );
                      context.showSnack(
                        updated.isSaved
                            ? 'Saved startup'
                            : 'Removed from saved',
                      );
                    }
                  });
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
                    res.fold((f) => context.showSnack(f.message), (success) {
                      if (success) {
                        final updated = s.copyWith(hasInvested: false);
                        bloc.add(
                          ListItemUpdated(
                            updated,
                            (existing, newItem) => existing.id == newItem.id,
                          ),
                        );
                        context.showSnack('Withdrew interest successfully');
                      }
                    });
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

class _CreateIdeaDialog extends StatefulWidget {
  @override
  State<_CreateIdeaDialog> createState() => _CreateIdeaDialogState();
}

class _CreateIdeaDialogState extends State<_CreateIdeaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _categoryController = TextEditingController();
  final _fundingController = TextEditingController();
  final _equityController = TextEditingController();

  String? _stage = 'MVP';
  String? _localLogoPath;
  String? _localCoverPath;
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
        context.showSnack('Failed to pick logo: $e', isError: true);
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
        context.showSnack('Failed to pick cover: $e', isError: true);
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
              child: Image.file(File(path)),
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
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    'Image Picked',
                    style: TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 20),
              onPressed: () => _viewLocalImage(localPath),
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onPick,
              tooltip: 'Change',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              onPressed: onRemove,
              tooltip: 'Remove',
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
      label: Text('Pick $label'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formContent = Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            AppTextField(
              controller: _nameController,
              label: 'Startup Name',
              hint: 'e.g. HealthBridge AI',
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _industryController,
              label: 'Industry',
              hint: 'e.g. Healthcare',
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'e.g. Artificial Intelligence',
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _stage,
              decoration: const InputDecoration(
                labelText: 'Stage',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Idea Stage',
                  child: Text('Idea Stage'),
                ),
                DropdownMenuItem(value: 'Prototype', child: Text('Prototype')),
                DropdownMenuItem(value: 'MVP', child: Text('MVP')),
                DropdownMenuItem(
                  value: 'Early Revenue',
                  child: Text('Early Revenue'),
                ),
                DropdownMenuItem(
                  value: 'Early Traction',
                  child: Text('Early Traction'),
                ),
                DropdownMenuItem(value: 'Growth', child: Text('Growth')),
                DropdownMenuItem(value: 'Expansion', child: Text('Expansion')),
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
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
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
                      if (eq == null || eq < 0 || eq > 100) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        AlertDialog(
          title: const Text('Create Startup Idea'),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 450),
            child: formContent,
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: _loading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _loading = true);

                      String? logoUrl;
                      String? coverUrl;

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

                      if (!mounted) return;
                      Navigator.pop(context, {
                        'logo': logoUrl ?? '',
                        'coverimage': coverUrl ?? '',
                        'startup': _nameController.text.trim(),
                        'industry': _industryController.text.trim(),
                        'category': _categoryController.text.trim(),
                        'stage': _stage,
                        'funding':
                            double.tryParse(_fundingController.text.trim()) ??
                            0.0,
                        'equity':
                            double.tryParse(_equityController.text.trim()) ??
                            0.0,
                      });
                    },
              child: const Text('Create'),
            ),
          ],
        ),
        if (_loading)
          const Positioned.fill(
            child: Material(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _EditIdeaDialog extends StatefulWidget {
  const _EditIdeaDialog({required this.startup});

  final Startup startup;

  @override
  State<_EditIdeaDialog> createState() => _EditIdeaDialogState();
}

class _EditIdeaDialogState extends State<_EditIdeaDialog> {
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
    return AlertDialog(
      title: const Text('Edit Startup Idea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              value: _stage,
              decoration: const InputDecoration(
                labelText: 'Stage',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Idea Stage',
                  child: Text('Idea Stage'),
                ),
                DropdownMenuItem(value: 'Prototype', child: Text('Prototype')),
                DropdownMenuItem(value: 'MVP', child: Text('MVP')),
                DropdownMenuItem(
                  value: 'Early Revenue',
                  child: Text('Early Revenue'),
                ),
                DropdownMenuItem(
                  value: 'Early Traction',
                  child: Text('Early Traction'),
                ),
                DropdownMenuItem(value: 'Growth', child: Text('Growth')),
                DropdownMenuItem(value: 'Expansion', child: Text('Expansion')),
              ],
              onChanged: (val) => setState(() => _stage = val),
              validator: (v) => v == null ? 'Stage is required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(80, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'funding': double.tryParse(_fundingController.text.trim()) ?? 0.0,
              'stage': _stage,
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
