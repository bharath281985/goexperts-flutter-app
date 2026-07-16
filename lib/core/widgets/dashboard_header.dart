import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/router/route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'app_avatar.dart';
import 'app_gradient_header.dart';

/// Gradient greeting header shared by all role home screens.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.subtitle, this.onMenu, this.unread = 0});

  final String subtitle;
  final VoidCallback? onMenu;
  final int unread;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final firstName = (user?.fullName ?? 'there').split(' ').first;
    return AppGradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onMenu != null)
                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (onMenu != null) AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting,',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    Text(firstName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _iconButton(context, Icons.search_rounded, () => context.push(Routes.search)),
              AppSizes.hGapSm,
              Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: _iconButton(context, Icons.notifications_none_rounded,
                    () => context.push(Routes.notifications)),
              ),
              AppSizes.hGapSm,
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: AppAvatar(name: user?.fullName ?? 'User', imageUrl: user?.avatarUrl, size: 40),
              ),
            ],
          ),
          AppSizes.vGapMd,
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
