import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// A reusable avatar editor widget for profile edit pages.
/// Shows a 100×100 circle with the current avatar (local or network),
/// an edit button, and handles image picking internally.
/// The [onPathPicked] callback is called when the user picks a new image.
class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({
    super.key,
    this.localPath,
    this.networkUrl,
    required this.onPathPicked,
    this.size = 100,
  });

  final String? localPath;
  final String? networkUrl;
  final ValueChanged<String> onPathPicked;
  final double size;

  /// Normalizes any URL: localhost → production, bare paths → full URL
  static String? resolveUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    var u = url.trim();
    // replace emulator/dev localhost with production domain
    if (u.contains('localhost:4000')) {
      u = u
          .replaceAll('http://localhost:4000', 'https://mobileapi.goexperts.in')
          .replaceAll('localhost:4000', 'mobileapi.goexperts.in');
    }
    if (u.startsWith('http://') ||
        u.startsWith('https://') ||
        u.startsWith('data:')) {
      return u;
    }
    const base = 'https://mobileapi.goexperts.in';
    return u.startsWith('/') ? '$base$u' : '$base/$u';
  }

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    final path = picked?.path;
    if (path == null) return;
    onPathPicked(path);
    if (context.mounted) {
      context.showSnack('Photo selected. Tap Save to upload.');
    }
  }

  Widget _placeholder() =>
      Icon(Icons.person, size: size * 0.5, color: Colors.grey);

  Widget _networkImage(String url) {
    final isSvg =
        url.split('?').first.toLowerCase().endsWith('.svg') ||
        url.toLowerCase().contains('/svg');
    if (isSvg) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _placeholder(),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedNet = resolveUrl(networkUrl);

    Widget child;
    if (localPath != null) {
      child = Image.file(File(localPath!), fit: BoxFit.cover);
    } else if (resolvedNet != null) {
      child = _networkImage(resolvedNet);
    } else {
      child = _placeholder();
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
              width: size,
              height: size,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              child: child,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppSizes.sm),
                minimumSize: const Size(36, 36),
              ),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              onPressed: () => _pick(context),
            ),
          ),
        ],
      ),
    );
  }
}
