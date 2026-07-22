import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../domain/entities/startup.dart';

/// Reusable startup card for investor discovery.
class AppStartupCard extends StatelessWidget {
  const AppStartupCard({
    super.key,
    required this.startup,
    this.onTap,
    this.onSave,
    this.onInterest,
    this.onEdit,
    this.onDelete,
  });

  final Startup startup;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onInterest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 12,
      shadowColor: AppColors.black.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(startup: startup),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xl,
                AppSizes.md,
                AppSizes.xl,
                AppSizes.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleBlock(startup: startup),
                 
                  _CategoryChips(startup: startup),
                  AppSizes.vGapXl,
                  _FundingProgress(startup: startup),
                  AppSizes.vGapLg,
                  const Divider(height: 1, color: AppColors.projectPanelBorder),
                  AppSizes.vGapLg,
                  _Stats(startup: startup),
                  AppSizes.vGapXl,
                  if (onSave != null ||
                      onInterest != null ||
                      onEdit != null ||
                      onDelete != null) ...[
                    AppSizes.vGapXl,
                    _Actions(
                      isSaved: startup.isSaved,
                      onSave: onSave,
                      onInterest: onInterest,
                      hasInvested: startup.hasInvested,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.startupHeaderRed,
                    AppColors.startupHeaderDarkRed,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: -80,
            child: Container(
              width: 310,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.startupHeaderHighlight,
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          Positioned(
            right: AppSizes.xl,
            top: AppSizes.xl,
            child: Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _HeaderTag(label: startup.industry),
                if (startup.tags.isNotEmpty)
                  _HeaderTag(label: startup.tags.first),
              ],
            ),
          ),
          Positioned(
            left: AppSizes.xl,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AppAvatar(
                name: startup.name,
                imageUrl: startup.logoUrl,
                size: 96,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.startupTagSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.text.titleSmall?.copyWith(
          color: AppColors.startupTagText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startup.name,
                style: context.text.headlineMedium?.copyWith(
                  color: AppColors.projectText,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSizes.vGapMd,
              Text(
                startup.tagline,
                style: context.text.titleLarge?.copyWith(
                  color: AppColors.projectBodyText,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (startup.isVerified) ...[
          AppSizes.hGapMd,
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: VerifiedBadge(size: 38, color: AppColors.projectVerified),
          ),
        ],
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.md,
      runSpacing: AppSizes.sm,
      children: [
        _CategoryChip(label: startup.industry),
        _CategoryChip(label: startup.stage),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.startupChipSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.text.titleSmall?.copyWith(
          color: AppColors.startupChipText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FundingProgress extends StatelessWidget {
  const _FundingProgress({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: LinearProgressIndicator(
            value: startup.fundingProgress,
            minHeight: 8,
            backgroundColor: AppColors.projectPanelBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
        AppSizes.vGapMd,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: Formatters.compactCurrency(startup.fundingRaised),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: ' raised of '),
              TextSpan(
                text: Formatters.compactCurrency(startup.fundingRequired),
                style: const TextStyle(
                  color: AppColors.projectText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          style: context.text.titleLarge?.copyWith(
            color: AppColors.projectBodyText,
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.currency_rupee_rounded,
            color: AppColors.success,
            surface: AppColors.startupIconGreenSurface,
            value: Formatters.compactCurrency(startup.fundingRequired),
            label: 'Ask',
          ),
        ),
        _VerticalDivider(),
        Expanded(
          child: _StatItem(
            icon: Icons.pie_chart_rounded,
            color: AppColors.projectVerified,
            surface: AppColors.startupIconBlueSurface,
            value: '${startup.equityOffered.toStringAsFixed(0)}%',
            label: 'Equity',
          ),
        ),
        _VerticalDivider(),
        Expanded(
          child: _StatItem(
            icon: Icons.groups_2_rounded,
            color: AppColors.projectPurple,
            surface: AppColors.startupIconPurpleSurface,
            value: '${startup.investorInterests}',
            label: 'Interest',
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 86, color: AppColors.projectPanelBorder);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.surface,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color surface;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: color, size: AppSizes.iconLg),
        ),
        AppSizes.vGapMd,
        Text(
          value,
          style: context.text.headlineSmall?.copyWith(
            color: AppColors.projectText,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.text.titleMedium?.copyWith(
            color: AppColors.projectBodyText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isSaved,
    required this.onSave,
    required this.onInterest,
    this.hasInvested = false,
    this.onEdit,
    this.onDelete,
  });

  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onInterest;
  final bool hasInvested;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onEdit != null || onDelete != null) {
      return Row(
        children: [
          if (onDelete != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: AppSizes.iconLg,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          if (onDelete != null && onEdit != null) AppSizes.hGapMd,
          if (onEdit != null)
            Expanded(
              child: AppPrimaryButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
                gradient: false,
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                height: 56,
              ),
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSave,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: AppColors.startupChipText,
              size: AppSizes.iconLg,
            ),
            label: Text(
              isSaved ? 'Saved' : 'Save',
              style: context.text.titleMedium?.copyWith(
                color: AppColors.projectText,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.projectPanelBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
        ),
        AppSizes.hGapMd,
        Expanded(
          child: AppPrimaryButton(
            label: hasInvested ? 'Withdraw' : 'Invest',
            icon: hasInvested
                ? Icons.cancel_outlined
                : Icons.trending_up_rounded,
            onPressed: onInterest,
            gradient: false,
            backgroundColor: hasInvested ? AppColors.danger : AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            height: 56,
          ),
        ),
      ],
    );
  }
}
