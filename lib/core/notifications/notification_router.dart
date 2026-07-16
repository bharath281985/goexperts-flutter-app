import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';

/// Routes notification tap payloads to in-app destinations.
class NotificationRouter {
  NotificationRouter(this._goRouter);

  final GoRouter _goRouter;

  void handle(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? data['screen']?.toString() ?? '';
    final id = data['id']?.toString() ?? data['entityId']?.toString();
    // final roleRaw = data['role']?.toString();

    switch (type) {
      case 'chat':
      case 'message':
        if (id != null) {
          _goRouter.push('${Routes.chat}/$id');
        } else {
          _goRouter.push(Routes.messages);
        }
        return;
      case 'notification':
      case 'notifications':
        _goRouter.push(Routes.notifications);
        return;
      case 'wallet':
      case 'transaction':
        _goRouter.push(Routes.wallet);
        return;
      case 'support':
      case 'ticket':
        _goRouter.push(Routes.support);
        return;
      case 'subscription':
        _goRouter.push(Routes.subscription);
        return;
      case 'project':
        if (id != null) _goRouter.push('${Routes.projectDetails}/$id');
        return;
      case 'proposal':
        if (id != null) _goRouter.push('${Routes.proposalDetails}/$id');
        return;
      default:
        _goRouter.push(Routes.notifications);
    }
  }
}
