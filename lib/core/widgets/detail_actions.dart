import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import 'app_action_sheet.dart';
import 'report_dialog.dart';
import 'share_sheet.dart';

/// Standard app-bar actions for detail pages: bookmark, share and an overflow
/// menu (copy link, report). Keeps every detail screen consistent.
List<Widget> detailActions(
  BuildContext context, {
  required String shareTitle,
  required String shareLink,
  String reportType = 'item',
  String? reportName,
  bool bookmarkable = true,
}) {
  return [
    if (bookmarkable)
      IconButton(
        tooltip: 'Bookmark',
        icon: const Icon(Icons.bookmark_outline_rounded),
        onPressed: () => context.showSnack('Bookmarked'),
      ),
    IconButton(
      tooltip: 'Share',
      icon: const Icon(Icons.share_outlined),
      onPressed: () => ShareSheet.show(context, title: shareTitle, link: shareLink),
    ),
    IconButton(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert_rounded),
      onPressed: () => AppActionSheet.show(
        context,
        actions: [
          AppAction(
            label: 'Copy link',
            icon: Icons.link_rounded,
            onTap: () => context.showSnack('Link copied'),
          ),
          AppAction(
            label: 'Share',
            icon: Icons.share_outlined,
            onTap: () => ShareSheet.show(context, title: shareTitle, link: shareLink),
          ),
          AppAction(
            label: 'Report',
            icon: Icons.flag_outlined,
            isDestructive: true,
            onTap: () => ReportSheet.show(context, targetType: reportType, targetName: reportName),
          ),
        ],
      ),
    ),
  ];
}
