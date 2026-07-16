import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import 'qr_code_view.dart';

/// Reusable share bottom sheet used across profiles, projects, startups, etc.
class ShareSheet extends StatelessWidget {
  const ShareSheet({
    super.key,
    required this.title,
    required this.link,
    this.subtitle,
    this.onShared,
  });

  final String title;
  final String? subtitle;
  final String link;
  final void Function(String platform)? onShared;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String link,
    String? subtitle,
    void Function(String platform)? onShared,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ShareSheet(
        title: title,
        link: link,
        subtitle: subtitle,
        onShared: onShared,
      ),
    );
  }

  Future<void> _share(
    BuildContext context, {
    required String platform,
    required Uri uri,
  }) async {
    onShared?.call(platform);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    context.showSnack(
      ok ? 'Opening $platform…' : 'Could not open $platform',
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final encoded = Uri.encodeComponent(link);
    final text = Uri.encodeComponent('Check this out on GoExperts: $link');
    final targets = <_ShareTarget>[
      _ShareTarget(
        'WhatsApp',
        Icons.chat_rounded,
        const Color(0xFF25D366),
        Uri.parse('https://wa.me/?text=$text'),
      ),
      _ShareTarget(
        'Email',
        Icons.email_outlined,
        AppColors.info,
        Uri.parse('mailto:?subject=${Uri.encodeComponent(title)}&body=$text'),
      ),
      _ShareTarget(
        'SMS',
        Icons.sms_outlined,
        AppColors.primary,
        Uri.parse('sms:?body=$text'),
      ),
      _ShareTarget(
        'LinkedIn',
        Icons.business_center_outlined,
        const Color(0xFF0A66C2),
        Uri.parse(
          'https://www.linkedin.com/sharing/share-offsite/?url=$encoded',
        ),
      ),
      _ShareTarget(
        'Twitter/X',
        Icons.alternate_email_rounded,
        AppColors.primaryBlack,
        Uri.parse('https://twitter.com/intent/tweet?url=$encoded&text=$text'),
      ),
      _ShareTarget(
        'Telegram',
        Icons.send_rounded,
        const Color(0xFF229ED9),
        Uri.parse('https://t.me/share/url?url=$encoded&text=$text'),
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          0,
          AppSizes.lg,
          AppSizes.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share $title', style: context.text.titleLarge),
            if (subtitle != null) ...[
              AppSizes.vGapXs,
              Text(subtitle!, style: context.text.bodySmall),
            ],
            AppSizes.vGapLg,
            Center(child: QrCodeView(data: link, size: 180)),
            AppSizes.vGapMd,
            Center(
              child: Text(
                'Scan to open · deep link ready',
                style: context.text.labelSmall,
              ),
            ),
            AppSizes.vGapLg,
            Container(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 4, 4, 4),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: context.theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      onShared?.call('copy');
                      Navigator.of(context).pop();
                      context.showSnack('Link copied to clipboard');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ),
            AppSizes.vGapLg,
            Wrap(
              spacing: AppSizes.lg,
              runSpacing: AppSizes.md,
              children: [
                for (final t in targets)
                  _TargetButton(
                    target: t,
                    onTap: () => _share(
                      context,
                      platform: t.label.toLowerCase().replaceAll('/', '_'),
                      uri: t.uri,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareTarget {
  const _ShareTarget(this.label, this.icon, this.color, this.uri);
  final String label;
  final IconData icon;
  final Color color;
  final Uri uri;
}

class _TargetButton extends StatelessWidget {
  const _TargetButton({required this.target, required this.onTap});
  final _ShareTarget target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: target.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(target.icon, color: target.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              target.label,
              style: context.text.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
