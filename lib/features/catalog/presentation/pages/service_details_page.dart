import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<ServiceItem>(
      title: 'Service Details',
      fetcher: () => sl<CatalogRepository>().getService(id),
      actions: detailActions(context, shareTitle: 'this service', shareLink: '${Routes.serviceDetails}/$id', reportType: 'service'),
      bottomBar: (context, s) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Expanded(child: AppSecondaryButton(label: 'Message', icon: Icons.chat_bubble_outline_rounded, onPressed: () => context.showSnack('Opening chat…'))),
            AppSizes.hGapMd,
            Expanded(flex: 2, child: AppPrimaryButton(label: 'Order · ${Formatters.compactCurrency(s.priceFrom)}', icon: Icons.shopping_cart_checkout_rounded, onPressed: () => context.showSnack('Order started'))),
          ],
        ),
      ),
      builder: (context, s) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.design_services_outlined,
            title: s.name,
            subtitle: s.category,
            chips: [DetailStatChip(icon: Icons.star_rounded, label: '${s.rating}'), DetailStatChip(icon: Icons.shopping_bag_outlined, label: '${s.ordersCount} orders')],
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(child: DetailMetric(icon: Icons.payments_outlined, label: 'Starting at', value: Formatters.currency(s.priceFrom))),
              Expanded(child: DetailMetric(icon: Icons.schedule_rounded, label: 'Delivery', value: '${s.deliveryDays} days')),
            ],
          ),
          AppSizes.vGapLg,
          DetailSection(title: 'Overview', child: Text(s.description, style: context.text.bodyMedium)),
          AppSizes.vGapLg,
          if (s.deliverables.isNotEmpty) ...[
            DetailSection(
              title: 'What you get',
              child: Column(
                children: [
                  for (final d in s.deliverables)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                        AppSizes.hGapSm,
                        Expanded(child: Text(d, style: context.text.bodyMedium)),
                      ]),
                    ),
                ],
              ),
            ),
            AppSizes.vGapLg,
          ],
          if (s.tags.isNotEmpty) ...[
            DetailSection(title: 'Tags', child: DetailChips(items: s.tags)),
            AppSizes.vGapLg,
          ],
          DetailSection(
            title: 'Provider',
            child: AppCard(
              onTap: () => context.showSnack('Opening provider profile'),
              child: Row(
                children: [
                  AppAvatar(name: s.providerName, imageUrl: s.providerAvatar, size: 44),
                  AppSizes.hGapMd,
                  Expanded(child: Text(s.providerName, style: context.text.titleSmall)),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
