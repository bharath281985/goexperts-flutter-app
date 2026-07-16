import 'package:flutter/material.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// In-app legal document (Privacy / Terms). Content is store-compliance oriented.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<({String heading, String body})> sections;

  factory LegalDocumentPage.privacy() => const LegalDocumentPage(
        title: 'Privacy Policy',
        sections: [
          (
            heading: '1. Information We Collect',
            body:
                'Go Experts collects account details (name, email, phone), profile information, project and proposal data, messages, device tokens for notifications, and payment metadata required to process transactions through our payment partners.',
          ),
          (
            heading: '2. How We Use Information',
            body:
                'We use your information to operate the marketplace, authenticate users, facilitate messaging and contracts, process payments and subscriptions, improve product quality, and send service-related notifications.',
          ),
          (
            heading: '3. Sharing',
            body:
                'We share data with the other party in a transaction when required (for example, client and freelancer on a project), with payment gateways for checkout, and with infrastructure providers. We do not sell personal data.',
          ),
          (
            heading: '4. Security',
            body:
                'Access tokens are stored using platform secure storage. API traffic uses HTTPS. You are responsible for keeping your credentials confidential.',
          ),
          (
            heading: '5. Your Choices',
            body:
                'You may update profile information, change notification preferences, request account deletion, or contact support for privacy requests.',
          ),
          (
            heading: '6. Contact',
            body:
                'For privacy questions, contact support through the in-app Help Center or email the address published on goexperts.in.',
          ),
        ],
      );

  factory LegalDocumentPage.terms() => const LegalDocumentPage(
        title: 'Terms of Service',
        sections: [
          (
            heading: '1. Acceptance',
            body:
                'By creating an account or using Go Experts, you agree to these Terms and our Privacy Policy. If you do not agree, do not use the service.',
          ),
          (
            heading: '2. Roles & Accounts',
            body:
                'Users may register as Freelancer, Client, Investor, or Founder. You must provide accurate information and are responsible for activity under your account.',
          ),
          (
            heading: '3. Marketplace Conduct',
            body:
                'You agree not to misuse messaging, submit fraudulent proposals, attempt payment circumvention, scrape the platform, or violate applicable law. We may suspend accounts that breach these Terms.',
          ),
          (
            heading: '4. Payments & Subscriptions',
            body:
                'Paid features and wallet transactions are processed by third-party gateways (including Easebuzz). Fees, refunds, and payout timelines follow the applicable plan and gateway rules.',
          ),
          (
            heading: '5. Content',
            body:
                'You retain rights to content you upload, and grant Go Experts a license to host and display it as needed to provide the service. Do not upload unlawful or infringing material.',
          ),
          (
            heading: '6. Limitation of Liability',
            body:
                'Go Experts is a marketplace facilitator. We are not a party to freelance or investment contracts between users except where expressly stated. Liability is limited to the maximum extent permitted by law.',
          ),
          (
            heading: '7. Changes',
            body:
                'We may update these Terms. Continued use after updates constitutes acceptance of the revised Terms.',
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Text(
            'Last updated: 14 July 2026',
            style: context.text.labelMedium,
          ),
          AppSizes.vGapLg,
          for (final section in sections) ...[
            Text(section.heading, style: context.text.titleMedium),
            AppSizes.vGapSm,
            Text(section.body, style: context.text.bodyMedium),
            AppSizes.vGapLg,
          ],
        ],
      ),
    );
  }
}
