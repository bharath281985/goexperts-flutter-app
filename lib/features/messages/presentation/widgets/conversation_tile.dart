import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../domain/entities/conversation.dart';

/// Reusable conversation list row.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  });

  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 2),
      leading: AppAvatar(name: c.name, imageUrl: c.avatarUrl, size: 50, showOnline: true, isOnline: c.isOnline),
      title: Row(
        children: [
          Expanded(child: Text(c.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (c.isPinned) const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.mutedText),
          const SizedBox(width: 4),
          Text(Formatters.relative(c.lastMessageAt), style: context.text.labelSmall),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            if (c.isMuted) const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.volume_off_rounded, size: 13, color: AppColors.mutedText),
            ),
            Expanded(
              child: Text(
                c.isTyping ? 'typing…' : c.lastMessage,
                style: context.text.bodySmall?.copyWith(
                  color: c.isTyping ? AppColors.success : null,
                  fontStyle: c.isTyping ? FontStyle.italic : FontStyle.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (c.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text('${c.unreadCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}
