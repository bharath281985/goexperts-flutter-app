import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_location_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../master_data/domain/entities/skill_category.dart';
import '../../../master_data/domain/entities/skill_option.dart';
import '../../../master_data/domain/repositories/master_data_repository.dart';
import '../bloc/auth_bloc.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _headline = TextEditingController();
  final _location = TextEditingController();
  final _bio = TextEditingController();
  final _imagePicker = ImagePicker();

  final Set<String> _selectedSkillIds = {};
  final Map<String, List<SkillOption>> _skillsByCategoryId = {};

  bool _loadingCategories = true;
  bool _loadingSkills = false;
  bool _skillsExpanded = false;
  String? _loadError;
  String? _categoryError;
  String? _skillsSubmitError;
  String? _avatarError;
  Uint8List? _avatarBytes;

  List<SkillCategory> _categories = [];
  String? _selectedCategoryId;
  List<SkillOption> _visibleSkills = [];

  static const _initialSkillsVisible = 8;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _loadError = null;
    });

    // Profile "Category" is sourced from industries API.
    final result = await sl<MasterDataRepository>().getIndustries();
    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _loadingCategories = false;
        _loadError =
            result.failureOrNull?.message ?? 'Failed to load categories';
      });
      return;
    }

    final categories = result.valueOrNull ?? [];
    if (categories.isEmpty) {
      setState(() {
        _loadingCategories = false;
        _loadError = 'No categories available';
      });
      return;
    }

    setState(() {
      _categories = categories;
      _selectedCategoryId = null;
      _visibleSkills = [];
      _loadingCategories = false;
    });
  }

  Future<void> _loadSkillsForCategory(String categoryId) async {
    if (_skillsByCategoryId.containsKey(categoryId)) {
      setState(() {
        _selectedCategoryId = categoryId;
        _visibleSkills = _skillsByCategoryId[categoryId] ?? [];
        _skillsExpanded = false;
        _categoryError = null;
      });
      return;
    }

    setState(() {
      _selectedCategoryId = categoryId;
      _loadingSkills = true;
      _loadError = null;
      _skillsExpanded = false;
      _categoryError = null;
    });

    final repo = sl<MasterDataRepository>();
    final allSkills = <SkillOption>[];
    var page = 1;
    const pageSize = 100;
    var total = 0;

    while (true) {
      final result = await repo.getSkills(
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
      if (!mounted) return;

      if (result.isFailure) {
        setState(() {
          _loadingSkills = false;
          _loadError = result.failureOrNull?.message ?? 'Failed to load skills';
        });
        return;
      }

      final batch = result.valueOrNull ?? [];
      if (batch.isEmpty) break;

      allSkills.addAll(batch.where((skill) => skill.id.isNotEmpty));

      if (page == 1) {
        final totalResult = await repo.getSkillsTotal(categoryId: categoryId);
        total = totalResult.valueOrNull ?? batch.length;
      }

      if (allSkills.length >= total || batch.length < pageSize) break;
      page++;
    }

    setState(() {
      _skillsByCategoryId[categoryId] = allSkills;
      _visibleSkills = allSkills;
      _loadingSkills = false;
    });
  }

  void _toggleSkill(String skillId) {
    setState(() {
      _skillsSubmitError = null;
      if (_selectedSkillIds.contains(skillId)) {
        _selectedSkillIds.remove(skillId);
      } else {
        _selectedSkillIds.add(skillId);
      }
    });
  }

  void _onCategorySelected(String categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() {
      _selectedSkillIds.clear();
      _visibleSkills = [];
    });
    _loadSkillsForCategory(categoryId);
  }

  SkillCategory? get _selectedCategory {
    for (final category in _categories) {
      if (category.id == _selectedCategoryId) return category;
    }
    return null;
  }

  @override
  void dispose() {
    _headline.dispose();
    _location.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final existingAvatar = context.read<AuthBloc>().state.user?.avatarUrl;
    final hasAvatar =
        _avatarBytes != null ||
        (existingAvatar != null && existingAvatar.isNotEmpty);
    if (!hasAvatar) {
      const message = 'Profile photo is required';
      setState(() => _avatarError = message);
      _showTopValidationMessage(message);
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _categoryError = 'Category is required');
      return;
    }

    setState(() {
      _skillsSubmitError = null;
      _avatarError = null;
      _categoryError = null;
    });

    context.read<AuthBloc>().add(
      AuthProfileCompleted({
        'headline': _headline.text.trim(),
        'location': _location.text.trim(),
        'city': _location.text.trim(),
        'bio': _bio.text.trim(),
        'categoryId': _selectedCategoryId,
        // Skills are optional.
        if (_selectedSkillIds.isNotEmpty)
          'skillIds': _selectedSkillIds.toList(),
      }, avatarBytes: _avatarBytes?.toList()),
    );
  }

  void _showTopValidationMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: context.colors.error,
        content: Text(
          message,
          style: context.text.bodyMedium?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Dismiss',
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: messenger.hideCurrentMaterialBanner,
          ),
        ],
      ),
    );

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      messenger.hideCurrentMaterialBanner();
    });
  }

  Future<void> _openAvatarPicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            if (_avatarBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _avatarBytes = null);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickAvatar(source);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _avatarBytes = bytes;
        _avatarError = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isCamera = source == ImageSource.camera;
      final denied = e.code.contains('denied') || e.code.contains('restricted');
      context.showSnack(
        denied
            ? '${isCamera ? 'Camera' : 'Gallery'} permission is required to select a profile photo.'
            : 'Could not select profile photo. Please try again.',
        isError: true,
      );
    }
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleSmall),
        if (subtitle != null) ...[
          AppSizes.vGapXs,
          Text(subtitle, style: context.text.bodySmall),
        ],
      ],
    );
  }

  Widget _buildCategorySection() {
    if (_loadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && _categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Category'),
          AppSizes.vGapSm,
          Text(
            _loadError!,
            style: context.text.bodyMedium?.copyWith(color: AppColors.danger),
          ),
          TextButton(onPressed: _loadCategories, child: const Text('Retry')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Category',
          subtitle: 'Choose your industry / category',
        ),
        AppSizes.vGapMd,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in _categories)
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: category.id == _selectedCategoryId,
                    showCheckmark: false,
                    onSelected: (_) => _onCategorySelected(category.id),
                  ),
                ),
            ],
          ),
        ),
        if (_categoryError != null) ...[
          AppSizes.vGapXs,
          Text(
            _categoryError!,
            style: context.text.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }

  Widget _buildSkillChip(SkillOption skill) {
    final isSelected = _selectedSkillIds.contains(skill.id);
    return FilterChip(
      label: Text(skill.name),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => _toggleSkill(skill.id),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      side: BorderSide(
        color: isSelected ? AppColors.primary : context.theme.dividerColor,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : context.text.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildSkillsSection() {
    if (_loadingCategories) return const SizedBox.shrink();

    if (_selectedCategoryId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSizes.vGapLg,
          _buildSectionTitle(
            'Skills (optional)',
            subtitle: 'Choose a category first, then select skills if you want',
          ),
        ],
      );
    }

    final categoryName = _selectedCategory?.name ?? 'this category';
    final shouldLimit =
        _visibleSkills.length > _initialSkillsVisible && !_skillsExpanded;
    final skillsToShow = shouldLimit
        ? _visibleSkills.take(_initialSkillsVisible).toList()
        : _visibleSkills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSizes.vGapLg,
        _buildSectionTitle(
          'Skills (optional)',
          subtitle: 'Select skills that apply to you (you can skip this)',
        ),
        if (_selectedSkillIds.isNotEmpty) ...[
          AppSizes.vGapSm,
          Text(
            '${_selectedSkillIds.length} selected',
            style: context.text.bodySmall?.copyWith(color: AppColors.primary),
          ),
        ],
        if (_skillsSubmitError != null) ...[
          AppSizes.vGapSm,
          Text(
            _skillsSubmitError!,
            style: context.text.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
        AppSizes.vGapMd,
        if (_loadingSkills)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (_loadError != null && _visibleSkills.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loadError!,
                style: context.text.bodyMedium?.copyWith(
                  color: AppColors.danger,
                ),
              ),
              if (_selectedCategoryId != null)
                TextButton(
                  onPressed: () => _loadSkillsForCategory(_selectedCategoryId!),
                  child: const Text('Retry'),
                ),
            ],
          )
        else if (_visibleSkills.isEmpty)
          Text(
            'No skills found for $categoryName',
            style: context.text.bodyMedium,
          )
        else ...[
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final skill in skillsToShow) _buildSkillChip(skill),
            ],
          ),
          if (_visibleSkills.length > _initialSkillsVisible) ...[
            AppSizes.vGapSm,
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    setState(() => _skillsExpanded = !_skillsExpanded),
                child: Text(_skillsExpanded ? 'Show less' : 'Show more'),
              ),
            ),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final role =
        context.select((AuthBloc b) => b.state.user?.role) ??
        UserRole.freelancer;
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: ResponsiveWrapper(
        maxWidth: 560,
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              (previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null) ||
              (previous.successMessage != current.successMessage &&
                  current.successMessage != null),
          listener: (context, state) {
            if (state.errorMessage != null) {
              context.showSnack(state.errorMessage!, isError: true);
            }
            if (state.successMessage != null) {
              // Message comes from API envelope (e.g. "Profile updated successfully")
              context.showSnack(state.successMessage!);
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: context.paddingWithBottomSafe(
                const EdgeInsets.all(AppSizes.xl),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              AppAvatar(
                                name: state.user?.fullName ?? 'User',
                                imageUrl: state.user?.avatarUrl,
                                imageBytes: _avatarBytes,
                                size: 88,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Material(
                                    color: AppColors.primary,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      tooltip: 'Add profile photo',
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 25,
                                            height: 25,
                                          ),
                                      padding: EdgeInsets.zero,
                                      onPressed: _openAvatarPicker,
                                      icon: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSizes.vGapSm,
                          Text(
                            'Profile photo *',
                            style: context.text.bodySmall,
                          ),
                          if (_avatarError != null) ...[
                            AppSizes.vGapXs,
                            Text(
                              _avatarError!,
                              style: context.text.bodySmall?.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSizes.vGapLg,
                    Text(
                      'Setting up your ${role.shortLabel} profile',
                      style: context.text.titleMedium,
                    ),
                    AppSizes.vGapLg,
                    AppTextField(
                      controller: _headline,
                      label: 'Headline',
                      hint: role == UserRole.founder
                          ? 'Enter your title'
                          : 'Enter your job title',
                      validator: (v) =>
                          Validators.minLength(v, 3, field: 'Headline'),
                    ),
                    AppSizes.vGapLg,
                    AppLocationField(
                      controller: _location,
                      label: 'Location',
                      hint: 'Search and select your location',
                      validator: (v) =>
                          Validators.required(v, field: 'Location'),
                    ),
                    AppSizes.vGapLg,
                    AppTextField(
                      controller: _bio,
                      label: 'About',
                      hint: 'Tell us about yourself…',
                      maxLines: 4,
                      validator: (v) =>
                          Validators.minLength(v, 10, field: 'About'),
                    ),
                    AppSizes.vGapLg,
                    _buildCategorySection(),
                    _buildSkillsSection(),
                    AppSizes.vGapXl,
                    AppPrimaryButton(
                      label: 'Continue',
                      isLoading: state.isSubmitting,
                      onPressed: _submit,
                    ),
                    AppSizes.vGapLg,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
