import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/share_sheet.dart';

/// A reusable document viewer shell that opens files in native handlers list/browser
/// and provides download + sharing actions.
class DocumentViewerPage extends StatefulWidget {
  const DocumentViewerPage({
    super.key,
    required this.type,
    this.name,
    this.url,
  });

  final String type;
  final String? name;
  final String? url;

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _isAutoAttempted = false;

  String? get _resolvedUrl {
    if (widget.url == null || widget.url!.isEmpty) return null;
    var displayUrl = widget.url!;
    if (displayUrl.contains('localhost:4000')) {
      displayUrl = displayUrl
          .replaceAll('http://localhost:4000', 'https://mobileapi.goexperts.in')
          .replaceAll('localhost:4000', 'mobileapi.goexperts.in');
    }
    return (displayUrl.startsWith('http://') ||
            displayUrl.startsWith('https://') ||
            displayUrl.startsWith('data:'))
        ? displayUrl
        : 'https://mobileapi.goexperts.in${displayUrl.startsWith('/') ? '' : '/'}$displayUrl';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoOpen();
    });
  }

  Future<void> _autoOpen() async {
    if (_isAutoAttempted) return;
    _isAutoAttempted = true;

    // Give context transitions a brief moment to settle down
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final target = _resolvedUrl;
    if (target != null && target.isNotEmpty) {
      context.showSnack('Opening document...');
      await _openDocument();
    }
  }

  Future<void> _openDocument() async {
    final targetUrl = _resolvedUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      context.showSnack('Invalid document URL', isError: true);
      return;
    }
    try {
      final uri = Uri.parse(targetUrl);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        if (mounted) {
          context.showSnack(
            'Could not open document externally. Please try downloading or opening in browser.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnack('Error opening document: $e', isError: true);
      }
    }
  }

  Future<void> _shareDocument() async {
    final targetUrl = _resolvedUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      context.showSnack('No document to share', isError: true);
      return;
    }
    ShareSheet.show(
      context,
      title: widget.name ?? 'Document',
      link: targetUrl,
      subtitle: '${widget.type} file details',
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(widget.type);
    final targetUrl = _resolvedUrl;

    return AppScaffold(
      appBar: AppBar(
        title: Text(widget.name ?? '${widget.type} Viewer'),
        actions: [
          IconButton(
            onPressed: () {
              if (targetUrl != null) {
                _openDocument();
              } else {
                context.showSnack('Download unavailable', isError: true);
              }
            },
            icon: const Icon(Icons.download_rounded),
          ),
          IconButton(
            onPressed: _shareDocument,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.theme.scaffoldBackgroundColor,
              context.theme.cardColor,
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xxl),
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: meta.color.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: Icon(meta.icon, size: 72, color: meta.color),
              ),
              AppSizes.vGapLg,
              Text(
                widget.name ?? 'Document File',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSizes.vGapXs,
              Text(
                'Type: ${widget.type.toUpperCase()}',
                style: context.text.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSizes.vGapXxl,
              if (targetUrl == null || targetUrl.isEmpty) ...[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
                AppSizes.vGapSm,
                Text(
                  'No link/URL was provided for this document.',
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                AppPrimaryButton(
                  label: 'View Document',
                  icon: Icons.open_in_new_rounded,
                  onPressed: _openDocument,
                ),
                AppSizes.vGapLg,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Text(
                    'The document will open in your device\'s default viewer or web browser. You can also download or share it using the top right actions.',
                    style: context.text.labelMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _DocMeta _metaFor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const _DocMeta(Icons.picture_as_pdf_outlined, AppColors.danger);
      case 'docx':
      case 'doc':
        return const _DocMeta(Icons.description_outlined, AppColors.info);
      case 'excel':
      case 'xlsx':
        return const _DocMeta(Icons.table_chart_outlined, AppColors.success);
      case 'powerpoint':
      case 'ppt':
      case 'pptx':
        return const _DocMeta(Icons.slideshow_outlined, AppColors.warning);
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const _DocMeta(Icons.image_outlined, AppColors.info);
      case 'video':
      case 'mp4':
        return const _DocMeta(Icons.movie_outlined, AppColors.primary);
      case 'audio':
      case 'mp3':
        return const _DocMeta(Icons.audiotrack_outlined, AppColors.primary);
      case 'zip':
      case 'archive':
        return const _DocMeta(Icons.folder_zip_outlined, AppColors.mutedText);
      default:
        return const _DocMeta(
          Icons.insert_drive_file_outlined,
          AppColors.mutedText,
        );
    }
  }
}

class _DocMeta {
  const _DocMeta(this.icon, this.color);
  final IconData icon;
  final Color color;
}
