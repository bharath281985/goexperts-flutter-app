import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../utils/formatters.dart';

/// Avatar that renders a network image or gracefully falls back to initials.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.imageBytes,
    this.size = AppSizes.avatarMd,
    this.showOnline = false,
    this.isOnline = false,
    this.badge,
  });

  final String name;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final bool showOnline;
  final bool isOnline;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final seedColor = AppColors.fromSeed(name);
    var displayUrl = imageUrl;
    if (displayUrl != null && displayUrl.contains('localhost:4000')) {
      displayUrl = displayUrl
          .replaceAll('http://localhost:4000', 'https://mobileapi.goexperts.in')
          .replaceAll('localhost:4000', 'mobileapi.goexperts.in');
    }

    final resolvedUrl = displayUrl != null && displayUrl.isNotEmpty
        ? ((displayUrl.startsWith('http://') ||
                  displayUrl.startsWith('https://') ||
                  displayUrl.startsWith('data:'))
              ? displayUrl
              : 'https://mobileapi.goexperts.in${displayUrl.startsWith('/') ? '' : '/'}$displayUrl')
        : null;

    final bool isSvg =
        resolvedUrl != null &&
        (resolvedUrl.split('?').first.toLowerCase().endsWith('.svg') ||
            resolvedUrl.toLowerCase().contains('/svg'));

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: seedColor.withValues(alpha: 0.15),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageBytes != null
          ? Image.memory(imageBytes!, fit: BoxFit.cover)
          : resolvedUrl != null
          ? isSvg
                ? SvgPicture.network(
                    resolvedUrl,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => _initials(seedColor),
                  )
                : CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _initials(seedColor),
                    errorWidget: (_, __, ___) => _initials(seedColor),
                  )
          : _initials(seedColor),
    );

    if (!showOnline && badge == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (showOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.subtleText,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
        if (badge != null) Positioned(right: 2, top: 2, child: badge!),
      ],
    );
  }

  Widget _initials(Color color) => Center(
    child: Text(
      Formatters.initials(name),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.36,
      ),
    ),
  );
}
