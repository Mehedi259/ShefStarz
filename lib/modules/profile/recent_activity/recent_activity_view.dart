import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recent_activity_controller.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_image.dart';

class RecentActivityView extends GetView<RecentActivityController> {
  const RecentActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Recent Activity",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (controller.activities.isEmpty) {
          return Center(
            child: Text(
              "No recent activity found.",
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.activities.length,
          separatorBuilder: (context, index) =>
              Divider(color: theme.dividerColor),
          itemBuilder: (context, index) {
            final activity = controller.activities[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(activity.type),
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              title: Text(
                activity.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy HH:mm').format(activity.timestamp),
                style: theme.textTheme.bodySmall,
              ),
              trailing: activity.imageUrl != null
                  ? AppImage(
                      url: activity.imageUrl!,
                      width: 50,
                      height: 50,
                      borderRadius: 10,
                    )
                  : null,
            );
          },
        );
      }),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'post':
        return Icons.post_add;
      case 'upload':
        return Icons.upload_file;
      default:
        return Icons.notifications;
    }
  }
}
