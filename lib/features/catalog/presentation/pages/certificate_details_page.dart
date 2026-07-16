import 'package:flutter/material.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class CertificateDetailsPage extends StatelessWidget {
  const CertificateDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<Certificate>(
      title: 'Certificate',
      fetcher: () => sl<CatalogRepository>().getCertificate(id),
      actions: detailActions(context, shareTitle: 'this certificate', shareLink: '${Routes.certificateDetails}/$id', reportType: 'certificate'),
      bottomBar: (context, c) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Expanded(child: AppSecondaryButton(label: 'Verify', icon: Icons.verified_outlined, onPressed: () => context.showSnack('Opening verification…'))),
            AppSizes.hGapMd,
            Expanded(child: AppPrimaryButton(label: 'Download', icon: Icons.download_rounded, onPressed: () => context.showSnack('Downloading certificate'))),
          ],
        ),
      ),
      builder: (context, c) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.workspace_premium_outlined,
            title: c.title,
            subtitle: 'Issued by ${c.issuer}',
            chips: [DetailStatChip(icon: Icons.event_outlined, label: Formatters.date(c.issuedAt))],
          ),
          AppSizes.vGapLg,
          DetailSection(
            title: 'Details',
            child: AppCard(
              child: Column(
                children: [
                  _row(context, 'Issuer', c.issuer),
                  const Divider(height: AppSizes.lg),
                  _row(context, 'Issued', Formatters.date(c.issuedAt)),
                  if (c.expiresAt != null) ...[
                    const Divider(height: AppSizes.lg),
                    _row(context, 'Expires', Formatters.date(c.expiresAt!)),
                  ],
                  if (c.credentialId.isNotEmpty) ...[
                    const Divider(height: AppSizes.lg),
                    _row(context, 'Credential ID', c.credentialId),
                  ],
                ],
              ),
            ),
          ),
          if (c.skills.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(title: 'Skills', child: DetailChips(items: c.skills)),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
        children: [
          Text(label, style: context.text.labelMedium),
          const Spacer(),
          Flexible(child: Text(value, style: context.text.bodyMedium, textAlign: TextAlign.right)),
        ],
      );
}
