import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_image.dart';
import '../controller/notifications_controller.dart';
import '../data/notification_model.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.orange,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
      body: Obx(() {
        final status = controller.status.value;

        if (status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_off_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Text(
                  status.errorMessage ?? "Error",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Text("No notifications yet", style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) =>
              Divider(color: theme.dividerColor),
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return _NotificationItem(
              avatar: item.avatar,
              name: item.name,
              action: item.action,
              target: item.target,
              time: item.time,
              type: item.type,
            );
          },
        );
      }),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String? avatar;
  final String? name;
  final String? action;
  final String? target;
  final String? time;
  final NotificationType type;

  const _NotificationItem({
    this.avatar,
    this.name,
    this.action,
    this.target,
    this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color targetColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    IconData? icon;
    Color? iconColor;

    if (type == NotificationType.following) {
      targetColor = Colors.orange;
    } else if (type == NotificationType.liked) {
      icon = Icons.favorite;
      iconColor = Colors.red;
    } else if (type == NotificationType.commented) {
      icon = Icons.chat_bubble_outline;
      iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppImage(
                url: avatar ?? '',
                width: 45,
                height: 45,
                isCircular: true,
              ),
              if (icon != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                    children: [
                      TextSpan(
                        text: "${name ?? 'User'} ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${action ?? ''} "),
                      TextSpan(
                        text: target ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: targetColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
