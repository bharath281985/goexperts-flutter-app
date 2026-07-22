import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_action_sheet.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/message_repository.dart';
import '../bloc/chat_cubit.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.conversationId, this.conversation});
  final String conversationId;
  final Conversation? conversation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(sl<MessageRepository>(), conversationId)..load(),
      child: _ChatView(conversation: conversation),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({this.conversation});
  final Conversation? conversation;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().send(text);
    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _attach() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'csv',
        'zip',
        'mp4',
        'mov',
        'webm',
        'avi',
      ],
      withData: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      context.showSnack('Could not read file', isError: true);
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      context.showSnack('File too large. Maximum size is 10MB.', isError: true);
      return;
    }
    final err = await context.read<ChatCubit>().sendAttachment(path);
    if (!mounted) return;
    if (err != null) {
      context.showSnack(err, isError: true);
    } else {
      _scrollToBottom();
    }
  }

  List<_ChatRow> _buildRows(List<ChatMessage> messages) {
    final rows = <_ChatRow>[];
    DateTime? lastDay;
    for (final msg in messages) {
      final day = DateTime(msg.sentAt.year, msg.sentAt.month, msg.sentAt.day);
      if (lastDay == null || lastDay != day) {
        rows.add(_ChatRow.date(Formatters.chatDayLabel(msg.sentAt)));
        lastDay = day;
      }
      rows.add(_ChatRow.message(msg));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.conversation?.name ?? 'Chat';
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(
              name: name,
              imageUrl: widget.conversation?.avatarUrl,
              size: 38,
              showOnline: true,
              isOnline: widget.conversation?.isOnline ?? true,
            ),
            AppSizes.hGapSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    (widget.conversation?.isOnline ?? true)
                        ? 'Online'
                        : 'Offline',
                    style: context.text.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => context.showSnack('Voice call (WebRTC ready)'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => context.showSnack('Video call (WebRTC ready)'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => AppActionSheet.show(
              context,
              title: name,
              actions: [
                AppAction(
                  label: 'Mark as Unread',
                  icon: Icons.mark_email_unread_outlined,
                  onTap: () async {
                    await sl<MessageRepository>()
                        .markConversationUnread(
                      context.read<ChatCubit>().conversationId,
                    );
                    if (context.mounted) {
                      context.showSnack('Marked as unread');
                    }
                  },
                ),
                AppAction(
                  label: 'Mark as Read',
                  icon: Icons.mark_email_read_outlined,
                  onTap: () async {
                    await sl<MessageRepository>().markConversationRead(
                      context.read<ChatCubit>().conversationId,
                    );
                    if (context.mounted) {
                      context.showSnack('Marked as read');
                    }
                  },
                ),
                AppAction(
                  label: 'View Profile',
                  icon: Icons.person_outline_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.status == ViewStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = _buildRows(state.messages);
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    if (row.isDate) {
                      return _DateChip(label: row.dateLabel!);
                    }
                    return _Bubble(
                      message: row.message!,
                      onLongPress: () => _messageActions(context, row.message!),
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (p, c) => p.uploading != c.uploading,
            builder: (context, state) {
              if (!state.uploading) return const SizedBox.shrink();
              return const LinearProgressIndicator(minHeight: 2);
            },
          ),
          _InputBar(controller: _controller, onSend: _send, onAttach: _attach),
        ],
      ),
    );
  }

  void _messageActions(BuildContext context, ChatMessage message) {
    final cubit = context.read<ChatCubit>();
    AppActionSheet.show(
      context,
      title: 'Message',
      actions: [
        if (!message.isMine)
          AppAction(
            label: 'Mark as Read',
            icon: Icons.done_all_rounded,
            onTap: () => cubit.markMessageRead(message.id),
          ),
        if (message.isMine)
          AppAction(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () => cubit.deleteMessage(message.id),
          ),
      ],
    );
  }
}

class _ChatRow {
  _ChatRow.date(this.dateLabel)
      : message = null,
        isDate = true;
  _ChatRow.message(this.message)
      : dateLabel = null,
        isDate = false;

  final bool isDate;
  final String? dateLabel;
  final ChatMessage? message;
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: context.text.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onLongPress});
  final ChatMessage message;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          constraints: BoxConstraints(maxWidth: context.width * 0.72),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : context.theme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSizes.radiusLg),
              topRight: const Radius.circular(AppSizes.radiusLg),
              bottomLeft: Radius.circular(mine ? AppSizes.radiusLg : 4),
              bottomRight: Radius.circular(mine ? 4 : AppSizes.radiusLg),
            ),
            border: mine ? null : Border.all(color: context.theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.attachmentUrl != null &&
                  message.attachmentUrl!.isNotEmpty)
                _AttachmentPreview(
                  url: message.attachmentUrl!,
                  type: message.type,
                  mine: mine,
                ),
              if (message.text.isNotEmpty &&
                  message.text != '[Attachment]') ...[
                if (message.attachmentUrl != null) const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: mine ? Colors.white : context.text.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.time(message.sentAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: mine ? Colors.white70 : AppColors.subtleText,
                    ),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 3),
                    Icon(
                      message.status == MessageStatus.seen
                          ? Icons.done_all_rounded
                          : Icons.check_rounded,
                      size: 13,
                      color: message.status == MessageStatus.seen
                          ? const Color(0xFF90CAF9)
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.url,
    required this.type,
    required this.mine,
  });
  final String url;
  final MessageType type;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final label = url.split('/').last;
    if (type == MessageType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 180,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fileChip(context, label),
        ),
      );
    }
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: _fileChip(context, label),
    );
  }

  Widget _fileChip(BuildContext context, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          type == MessageType.video
              ? Icons.videocam_outlined
              : Icons.insert_drive_file_outlined,
          size: 18,
          color: mine ? Colors.white : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mine ? Colors.white : context.text.bodyMedium?.color,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border(top: BorderSide(color: context.theme.dividerColor)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => AppActionSheet.show(
                context,
                title: 'Attach (max 10MB)',
                actions: [
                  AppAction(
                    label: 'Photo / Video / Document',
                    icon: Icons.attach_file_rounded,
                    onTap: onAttach,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            AppSizes.hGapSm,
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
