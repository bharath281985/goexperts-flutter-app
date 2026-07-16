import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_chip.dart';

class FounderPitchDeckEditorPage extends StatelessWidget {
  const FounderPitchDeckEditorPage({super.key});
  @override
  Widget build(BuildContext context) {
    final deck = MockData.pitchDecks['s1']!;
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Pitch Deck Editor'),
        actions: [TextButton(onPressed: () => context.push('${Routes.pitchDeckDetails}/s1'), child: const Text('Preview'))],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.showSnack('Add slide'), icon: const Icon(Icons.add_rounded), label: const Text('Slide')),
      body: ReorderableListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        onReorderItem: (a, b) => context.showSnack('Reordered slides'),
        children: [
          for (var i = 0; i < deck.slides.length; i++)
            AppCard(
              key: ValueKey('slide_$i'),
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(children: [
                CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                AppSizes.hGapMd,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(deck.slides[i].title, style: context.text.titleSmall),
                  Text(deck.slides[i].subtitle, style: context.text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                IconButton(onPressed: () => context.showSnack('Edit slide'), icon: const Icon(Icons.edit_outlined, size: 18)),
                const Icon(Icons.drag_handle_rounded, color: AppColors.mutedText),
              ]),
            ),
        ],
      ),
    );
  }
}

class FounderBusinessPlanEditorPage extends StatelessWidget {
  const FounderBusinessPlanEditorPage({super.key});
  @override
  Widget build(BuildContext context) {
    final plan = MockData.businessPlans['s1']!;
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Business Plan Editor'),
        actions: [TextButton(onPressed: () => context.push('${Routes.businessPlanDetails}/s1'), child: const Text('Preview'))],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.showSnack('Add section'), icon: const Icon(Icons.add_rounded), label: const Text('Section')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          for (final s in plan.sections)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              onTap: () => context.showSnack('Edit ${s.title}'),
              child: Row(children: [
                const Icon(Icons.subject_rounded, color: AppColors.primary),
                AppSizes.hGapMd,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, style: context.text.titleSmall),
                  Text(s.content, style: context.text.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                const Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedText),
              ]),
            ),
        ],
      ),
    );
  }
}

class FounderTeamPage extends StatelessWidget {
  const FounderTeamPage({super.key});
  @override
  Widget build(BuildContext context) {
    final team = [
      ('Ishaan Verma', 'Founder & CEO'),
      ('Ananya Rao', 'Co-Founder & COO'),
      ('Dev Patel', 'CTO'),
      ('Sara Khan', 'Head of Marketing'),
    ];
    return AppScaffold(
      appBar: AppBar(title: const Text('Team'), actions: [IconButton(onPressed: () => context.showSnack('Add member'), icon: const Icon(Icons.person_add_alt_1_outlined))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          for (final (name, role) in team)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(children: [
                AppAvatar(name: name, size: 44),
                AppSizes.hGapMd,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: context.text.titleSmall),
                  Text(role, style: context.text.labelSmall),
                ])),
              ]),
            ),
        ],
      ),
    );
  }
}

class FounderHiringPage extends StatelessWidget {
  const FounderHiringPage({super.key});
  @override
  Widget build(BuildContext context) {
    final roles = [
      ('Senior Backend Engineer', '12 applicants', 'Open'),
      ('Growth Marketer', '8 applicants', 'Open'),
      ('Product Designer', '21 applicants', 'Closed'),
    ];
    return AppScaffold(
      appBar: AppBar(title: const Text('Hiring')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.showSnack('Post a role'), icon: const Icon(Icons.add_rounded), label: const Text('Post Role')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          for (final (title, applicants, status) in roles)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: context.text.titleSmall),
                  Text(applicants, style: context.text.labelSmall),
                ])),
                AppStatusChip(label: status, dense: true, color: status == 'Open' ? AppColors.success : AppColors.mutedText),
              ]),
            ),
        ],
      ),
    );
  }
}

class FounderMediaGalleryPage extends StatelessWidget {
  const FounderMediaGalleryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Media Gallery')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.showSnack('Upload media'), icon: const Icon(Icons.upload_rounded), label: const Text('Upload')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isMobile ? 2 : 3,
          crossAxisSpacing: AppSizes.md,
          mainAxisSpacing: AppSizes.md,
        ),
        itemCount: 8,
        itemBuilder: (context, i) {
          final isVideo = i % 3 == 0;
          return InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: () => context.push('${Routes.documentViewer}?type=${isVideo ? 'Video' : 'Image'}&name=media_$i'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: context.theme.dividerColor),
              ),
              child: Center(child: Icon(isVideo ? Icons.play_circle_outline_rounded : Icons.image_outlined, size: 40, color: AppColors.primary)),
            ),
          );
        },
      ),
    );
  }
}