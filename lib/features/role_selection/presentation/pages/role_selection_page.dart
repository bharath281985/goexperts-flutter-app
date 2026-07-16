import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key, this.fromSignup = false});

  final bool fromSignup;

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  UserRole? _selected;

  @override
  Widget build(BuildContext context) {
    final showBack = widget.fromSignup || context.canPop();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          context.showSnack(state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ResponsiveWrapper(
            maxWidth: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl,
                    AppSizes.xl,
                    AppSizes.xl,
                    AppSizes.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBack) ...[
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(Routes.signup);
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back',
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.primaryBlack,
                            backgroundColor: context.theme.cardColor,
                            side: BorderSide(color: context.theme.dividerColor),
                          ),
                        ),
                        AppSizes.vGapLg,
                      ],
                      Text(
                        'Choose your role',
                        style: context.text.displaySmall,
                      ),
                      AppSizes.vGapXs,
                      Text(
                        'Tell us how you want to use Go Experts. You can add more roles later.',
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    children: [
                      for (final role in UserRole.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: _RoleCard(
                            role: role,
                            selected: _selected == role,
                            onTap: () => setState(() => _selected = role),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppPrimaryButton(
                        label: 'Continue',
                        isLoading: state.isSubmitting,
                        onPressed: _selected == null
                            ? null
                            : () => context.read<AuthBloc>().add(
                                AuthRoleSelected(_selected!),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : context.theme.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected
                      ? null
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  role.icon,
                  color: selected ? Colors.white : AppColors.primary,
                  size: AppSizes.iconLg,
                ),
              ),
              AppSizes.hGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            role.label,
                            style: context.text.titleMedium,
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(role.description, style: context.text.bodySmall),
                    AppSizes.vGapMd,
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: [
                        for (final b in role.benefits)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusPill,
                              ),
                              border: Border.all(
                                color: context.theme.dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(b, style: context.text.labelSmall),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
