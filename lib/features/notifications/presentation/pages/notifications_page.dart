import 'package:flutter/material.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_notification_tile.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _unread = 0;
  int _listKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    final res = await sl<NotificationRepository>().unreadCount();
    if (!mounted) return;
    setState(() => _unread = res.valueOrNull ?? 0);
  }

  void _reloadList() {
    setState(() => _listKey++);
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<NotificationRepository>();
    return AppScaffold(
      appBar: AppBar(
        title: Text('Notifications ($_unread)'),
        actions: [
          TextButton(
            onPressed: () async {
              final res = await repo.markAllRead();
              if (!mounted) return;
              res.fold((f) => context.showSnack(f.message), (_) {
                context.showSnack('All notifications marked as read');
                _reloadList();
              });
              await _loadUnread();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: CatalogView<AppNotification>(
        key: ValueKey(_listKey),
        fetcher: repo.getNotifications,
        showSearch: false,
        emptyTitle: "You're all caught up",
        emptyIcon: Icons.notifications_none_rounded,
        skeletonHeight: 74,
        separator: const Divider(height: 1),
        itemBuilder: (context, n, _) => Dismissible(
          key: Key(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red.shade800,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) async {
            final res = await repo.delete(n.id);
            if (!context.mounted) return;
            res.fold((f) => context.showSnack(f.message), (_) {
              context.showSnack('Notification deleted');
            });
            await _loadUnread();
          },
          child: AppNotificationTile(
            title: n.title,
            body: n.body,
            time: Formatters.relative(n.createdAt),
            icon: n.category.icon,
            color: n.category.color,
            isRead: n.isRead,
            onTap: () async {
              if (!n.isRead) {
                final res = await repo.markRead(n.id);
                if (!context.mounted) return;
                res.fold((f) => context.showSnack(f.message), (_) {
                  _reloadList();
                });
                await _loadUnread();
              }
            },
          ),
        ),
      ),
    );
  }
}
