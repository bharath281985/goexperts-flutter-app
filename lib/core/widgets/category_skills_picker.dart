import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/dependency_injection/service_locator.dart';
import '../../features/master_data/domain/entities/skill_category.dart';
import '../../features/master_data/domain/entities/skill_option.dart';
import '../../features/master_data/domain/repositories/master_data_repository.dart';
import '../extensions/context_extensions.dart';

/// Loads categories/skills from the catalog API.
/// Selection values are always IDs; chips display human-readable names.
class CategorySkillsPicker extends StatefulWidget {
  const CategorySkillsPicker({
    super.key,
    required this.selectedCategoryId,
    required this.selectedSkillIds,
    required this.onCategoryChanged,
    required this.onSkillsChanged,
    this.onSkillOptionsLoaded,
    this.categoryLabel = 'Category',
    this.categorySubtitle,
    this.skillsLabel = 'Skills',
    this.skillsSubtitle,
    this.initialSkillsVisible = 8,
    this.clearSkillsOnCategoryChange = true,
    this.categoryError,
    this.skillsError,
  });

  final String? selectedCategoryId;
  final Set<String> selectedSkillIds;
  final void Function(String? categoryId, String categoryName)
  onCategoryChanged;
  final ValueChanged<Set<String>> onSkillsChanged;
  final void Function(List<SkillOption> skills)? onSkillOptionsLoaded;
  final String categoryLabel;
  final String? categorySubtitle;
  final String skillsLabel;
  final String? skillsSubtitle;
  final int initialSkillsVisible;
  final bool clearSkillsOnCategoryChange;
  final String? categoryError;
  final String? skillsError;

  @override
  State<CategorySkillsPicker> createState() => _CategorySkillsPickerState();
}

class _CategorySkillsPickerState extends State<CategorySkillsPicker> {
  final Map<String, List<SkillOption>> _skillsByCategoryId = {};

  bool _loadingCategories = true;
  bool _loadingSkills = false;
  bool _skillsExpanded = false;
  String? _loadError;

  List<SkillCategory> _categories = [];
  List<SkillOption> _visibleSkills = [];

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

    final result = await sl<MasterDataRepository>().getSkillCategories(
      page: 1,
      pageSize: 200,
      search: '',
    );
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
    setState(() {
      _categories = categories;
      _loadingCategories = false;
      if (categories.isEmpty) {
        _loadError = 'No categories available';
      }
    });

    final selectedId = widget.selectedCategoryId;
    if (selectedId != null && categories.any((c) => c.id == selectedId)) {
      await _loadSkillsForCategory(selectedId, notifyCategory: false);
    }
  }

  Future<void> _loadSkillsForCategory(
    String categoryId, {
    bool notifyCategory = true,
  }) async {
    if (_skillsByCategoryId.containsKey(categoryId)) {
      setState(() {
        _visibleSkills = _skillsByCategoryId[categoryId] ?? [];
        _skillsExpanded = false;
      });
      if (notifyCategory) {
        final name = _categoryName(categoryId);
        widget.onCategoryChanged(categoryId, name);
      }
      return;
    }

    setState(() {
      _loadingSkills = true;
      _loadError = null;
      _skillsExpanded = false;
    });
    if (notifyCategory) {
      widget.onCategoryChanged(categoryId, _categoryName(categoryId));
    }

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

    widget.onSkillOptionsLoaded?.call(allSkills);

    setState(() {
      _skillsByCategoryId[categoryId] = allSkills;
      _visibleSkills = allSkills;
      _loadingSkills = false;
    });
  }

  String _categoryName(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category.name;
    }
    return '';
  }

  void _onCategorySelected(String categoryId) {
    if (categoryId == widget.selectedCategoryId) return;

    if (widget.clearSkillsOnCategoryChange) {
      widget.onSkillsChanged({});
    }

    _loadSkillsForCategory(categoryId);
  }

  void _toggleSkill(String skillId) {
    final next = Set<String>.from(widget.selectedSkillIds);
    if (next.contains(skillId)) {
      next.remove(skillId);
    } else {
      next.add(skillId);
    }
    widget.onSkillsChanged(next);
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(title), style: context.text.titleSmall),
        if (subtitle != null) ...[
          AppSizes.vGapXs,
          Text(context.tr(subtitle), style: context.text.bodySmall),
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
          _buildSectionTitle(widget.categoryLabel),
          AppSizes.vGapSm,
          Text(
            _loadError!,
            style: context.text.bodyMedium?.copyWith(color: AppColors.danger),
          ),
          TextButton(
            onPressed: _loadCategories,
            child: Text(context.tr('Retry')),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          widget.categoryLabel,
          subtitle: widget.categorySubtitle,
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
                    selected: category.id == widget.selectedCategoryId,
                    showCheckmark: false,
                    onSelected: (_) => _onCategorySelected(category.id),
                  ),
                ),
            ],
          ),
        ),
        if (widget.categoryError != null) ...[
          AppSizes.vGapXs,
          Text(
            widget.categoryError!,
            style: context.text.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }

  Widget _buildSkillChip(SkillOption skill) {
    final isSelected = widget.selectedSkillIds.contains(skill.id);
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

    if (widget.selectedCategoryId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSizes.vGapLg,
          _buildSectionTitle(
            widget.skillsLabel,
            subtitle: widget.skillsSubtitle ?? 'Choose a category first',
          ),
        ],
      );
    }

    final categoryName = _categoryName(widget.selectedCategoryId!) == ''
        ? 'this category'
        : _categoryName(widget.selectedCategoryId!);
    final shouldLimit =
        _visibleSkills.length > widget.initialSkillsVisible && !_skillsExpanded;
    final skillsToShow = shouldLimit
        ? _visibleSkills.take(widget.initialSkillsVisible).toList()
        : _visibleSkills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSizes.vGapLg,
        _buildSectionTitle(widget.skillsLabel, subtitle: widget.skillsSubtitle),
        if (widget.selectedSkillIds.isNotEmpty) ...[
          AppSizes.vGapSm,
          Text(
            context
                .tr('{count} selected')
                .replaceFirst('{count}', '${widget.selectedSkillIds.length}'),
            style: context.text.bodySmall?.copyWith(color: AppColors.primary),
          ),
        ],
        if (widget.skillsError != null) ...[
          AppSizes.vGapSm,
          Text(
            widget.skillsError!,
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
              TextButton(
                onPressed: () =>
                    _loadSkillsForCategory(widget.selectedCategoryId!),
                child: Text(context.tr('Retry')),
              ),
            ],
          )
        else if (_visibleSkills.isEmpty)
          Text(
            context
                .tr('No skills found for {category}')
                .replaceFirst('{category}', categoryName),
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
          if (_visibleSkills.length > widget.initialSkillsVisible) ...[
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCategorySection(), _buildSkillsSection()],
    );
  }
}
