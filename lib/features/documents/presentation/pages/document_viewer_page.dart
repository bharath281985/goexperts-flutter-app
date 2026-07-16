import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// A reusable document viewer shell with type-aware preview placeholders.
///
/// Supports PDF, DOCX, Excel, PowerPoint, Image, Video, Audio and ZIP.
/// Swap the preview area for real renderers (e.g. `syncfusion_flutter_pdfviewer`,
/// `video_player`, `just_audio`) when wiring live files.
class DocumentViewerPage extends StatelessWidget {
  const DocumentViewerPage({super.key, required this.type, this.name, this.url});

  final String type;
  final String? name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(type);
    return AppScaffold(
      appBar: AppBar(
        title: Text(name ?? '$type Viewer'),
        actions: [
          IconButton(onPressed: () => context.showSnack('Downloading…'), icon: const Icon(Icons.download_rounded)),
          IconButton(onPressed: () => context.showSnack('Sharing…'), icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _preview(context, meta)),
          _toolbar(context, meta),
        ],
      ),
    );
  }

  Widget _preview(BuildContext context, _DocMeta meta) {
    switch (meta.kind) {
      case _DocKind.image:
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 96, color: Colors.white54),
        );
      case _DocKind.video:
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.play_circle_outline_rounded, size: 88, color: Colors.white),
              SizedBox(height: 8),
              Text('Tap to play', style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      case _DocKind.audio:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xxl),
                decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.graphic_eq_rounded, size: 64, color: meta.color),
              ),
              AppSizes.vGapLg,
              Text(name ?? 'audio.mp3', style: context.text.titleMedium),
            ],
          ),
        );
      case _DocKind.pages:
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.lg),
          itemCount: 4,
          separatorBuilder: (_, __) => AppSizes.vGapLg,
          itemBuilder: (_, i) => AspectRatio(
            aspectRatio: 1 / 1.3,
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: context.theme.dividerColor),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(meta.icon, size: 48, color: meta.color),
                  AppSizes.vGapSm,
                  Text('Page ${i + 1}', style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        );
      case _DocKind.archive:
        return ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text('Archive contents', style: context.text.titleMedium),
            AppSizes.vGapMd,
            for (final f in ['README.md', 'assets/logo.png', 'src/main.dart', 'docs/spec.pdf'])
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(f),
                trailing: const Icon(Icons.download_rounded, size: 18),
                onTap: () => context.showSnack('Extracting $f'),
              ),
          ],
        );
    }
  }

  Widget _toolbar(BuildContext context, _DocMeta meta) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border(top: BorderSide(color: context.theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(meta.icon, color: meta.color),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? '$type document', style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('$type · preview', style: context.text.labelSmall),
                ],
              ),
            ),
            IconButton(onPressed: () => context.showSnack('Zoom'), icon: const Icon(Icons.zoom_in_rounded)),
            IconButton(onPressed: () => context.showSnack('Open externally'), icon: const Icon(Icons.open_in_new_rounded)),
          ],
        ),
      ),
    );
  }

  _DocMeta _metaFor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const _DocMeta(_DocKind.pages, Icons.picture_as_pdf_outlined, AppColors.danger);
      case 'docx':
      case 'doc':
        return const _DocMeta(_DocKind.pages, Icons.description_outlined, AppColors.info);
      case 'excel':
      case 'xlsx':
        return const _DocMeta(_DocKind.pages, Icons.table_chart_outlined, AppColors.success);
      case 'powerpoint':
      case 'ppt':
      case 'pptx':
        return const _DocMeta(_DocKind.pages, Icons.slideshow_outlined, AppColors.warning);
      case 'image':
      case 'png':
      case 'jpg':
        return const _DocMeta(_DocKind.image, Icons.image_outlined, AppColors.info);
      case 'video':
      case 'mp4':
        return const _DocMeta(_DocKind.video, Icons.movie_outlined, AppColors.primary);
      case 'audio':
      case 'mp3':
        return const _DocMeta(_DocKind.audio, Icons.audiotrack_outlined, AppColors.primary);
      case 'zip':
      case 'archive':
        return const _DocMeta(_DocKind.archive, Icons.folder_zip_outlined, AppColors.mutedText);
      default:
        return const _DocMeta(_DocKind.pages, Icons.insert_drive_file_outlined, AppColors.mutedText);
    }
  }
}

enum _DocKind { pages, image, video, audio, archive }

class _DocMeta {
  const _DocMeta(this.kind, this.icon, this.color);
  final _DocKind kind;
  final IconData icon;
  final Color color;
}
