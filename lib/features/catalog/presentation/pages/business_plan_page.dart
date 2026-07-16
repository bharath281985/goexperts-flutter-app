import 'package:flutter/material.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class BusinessPlanPage extends StatelessWidget {
  const BusinessPlanPage({super.key, required this.startupId});
  final String startupId;

  @override
  Widget build(BuildContext context) {
    return DetailView<BusinessPlan>(
      title: 'Business Plan',
      fetcher: () => sl<CatalogRepository>().getBusinessPlan(startupId),
      actions: detailActions(context, shareTitle: 'this business plan', shareLink: '${Routes.businessPlanDetails}/$startupId', reportType: 'startup'),
      bottomBar: (context, b) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppPrimaryButton(label: 'Download PDF', icon: Icons.download_rounded, onPressed: () => context.showSnack('Downloading business plan')),
      ),
      builder: (context, b) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.description_outlined,
            title: '${b.startupName} Business Plan',
            subtitle: 'Updated ${Formatters.relative(b.updatedAt)}',
          ),
          if (b.summary.isNotEmpty) ...[
            AppSizes.vGapLg,
            Text(b.summary, style: context.text.bodyMedium),
          ],
          AppSizes.vGapLg,
          for (final s in b.sections)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: context.text.titleSmall),
                  AppSizes.vGapSm,
                  Text(s.content, style: context.text.bodyMedium),
                ],
              ),
            ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
