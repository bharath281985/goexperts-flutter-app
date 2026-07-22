import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/widgets/app_action_sheet.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/message_repository.dart';
import '../widgets/conversation_tile.dart';

/// Messages list backed by the live conversations API.
class ConversationsListView extends StatefulWidget {
  const ConversationsListView({super.key});

  @override
  State<ConversationsListView> createState() => _ConversationsListViewState();
}

class _ConversationsListViewState extends State<ConversationsListView> {
  final _search = TextEditingController();
  final _repo = sl<MessageRepository>();

  List<Conversation> _items = const [];
  ViewStatus _status = ViewStatus.initial;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _refresh(showLoading: true);
  }

  Future<void> _refresh({bool showLoading = false}) async {
    if (showLoading) {
      setState(() => _status = ViewStatus.loading);
    } else {
      setState(() => _status = ViewStatus.refreshing);
    }
    final result = await _repo.getConversations(const QueryParams(page: 1));
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() {
          _error = f.message;
          _status = _items.isEmpty ? ViewStatus.failure : ViewStatus.success;
        });
        if (_items.isNotEmpty) {
          context.showSnack(f.message, isError: true);
        }
      },
      (page) {
        setState(() {
          _items = page.items;
          _status = page.items.isEmpty ? ViewStatus.empty : ViewStatus.success;
          _error = null;
        });
      },
    );
  }

  List<Conversation> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _onLongPress(Conversation c) async {
    await AppActionSheet.show(
      context,
      title: c.name,
      actions: [
        AppAction(
          label: c.unreadCount > 0 ? 'Mark as Read' : 'Mark as Unread',
          icon: c.unreadCount > 0
              ? Icons.mark_email_read_outlined
              : Icons.mark_email_unread_outlined,
          onTap: () async {
            if (c.unreadCount > 0) {
              await _repo.markConversationRead(c.id);
            } else {
              await _repo.markConversationUnread(c.id);
            }
            await _refresh();
          },
        ),
        AppAction(
          label: 'Delete Chat',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: () async {
            final res = await _repo.deleteConversation(c.id);
            res.fold(
              (f) => context.showSnack(f.message, isError: true),
              (_) {
                setState(() {
                  _items = _items.where((e) => e.id != c.id).toList();
                  _status =
                      _items.isEmpty ? ViewStatus.empty : ViewStatus.success;
                });
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            AppSizes.sm,
            AppSizes.screenPadding,
            AppSizes.sm,
          ),
          child: AppSearchBar(
            controller: _search,
            hint: 'Search chats…',
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(child: _body(items)),
      ],
    );
  }

  Widget _body(List<Conversation> items) {
    if (_status == ViewStatus.loading && items.isEmpty) {
      return const AppLoadingShimmer(itemCount: 8, height: 72);
    }
    if (_status == ViewStatus.failure && items.isEmpty) {
      return AppErrorState(message: _error, onRetry: () => _refresh(showLoading: true));
    }
    if (_status == ViewStatus.empty || items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            AppEmptyState(
              title: 'No conversations yet',
              icon: Icons.chat_bubble_outline_rounded,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, i) {
          final c = items[i];
          return ConversationTile(
            conversation: c,
            onTap: () => context.push('${Routes.chat}/${c.id}', extra: c),
            onLongPress: () => _onLongPress(c),
          );
        },
      ),
    );
  }
}
