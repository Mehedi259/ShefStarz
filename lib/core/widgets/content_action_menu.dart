import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/trust_and_safety/controller/trust_and_safety_controller.dart';
import '../../modules/auth/data/auth_service.dart';
import 'custom_dialogs.dart';

class ContentActionMenu extends StatelessWidget {
  final String contentId;
  final String targetUserId;
  final String targetUserName;

  const ContentActionMenu({
    super.key,
    required this.contentId,
    required this.targetUserId,
    this.targetUserName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    // Ensure TrustAndSafetyController is registered
    final tsController = Get.put(TrustAndSafetyController());

    return Obx(() {
      final currentUserId = AuthService.to.currentUser.value?.id.toString();
      
      // HIDE the menu completely if it's the user's own content
      if (targetUserId == currentUserId) {
        return const SizedBox.shrink();
      }

      final parsedTargetUserId = int.tryParse(targetUserId) ?? -1;
      final isBlocked = tsController.blockedUserIds.contains(parsedTargetUserId);

      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (String value) {
          if (value == 'report') {
            _showReportBottomSheet(context, tsController);
          } else if (value == 'block_toggle') {
            if (isBlocked) {
              _showUnblockDialog(context, tsController);
            } else {
              _showBlockDialog(context, tsController);
            }
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'report',
            child: ListTile(
              leading: Icon(Icons.flag_outlined, color: Colors.orange),
              title: Text('Report'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          PopupMenuItem<String>(
            value: 'block_toggle',
            child: ListTile(
              leading: Icon(
                isBlocked ? Icons.check_circle_outline : Icons.block_outlined,
                color: isBlocked ? Colors.green : Colors.red,
              ),
              title: Text(isBlocked ? 'Unblock $targetUserName' : 'Block $targetUserName'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      );
    });
  }

  void _showReportBottomSheet(BuildContext context, TrustAndSafetyController controller) {
    final List<String> reportReasons = [
      'Inappropriate content',
      'Spam',
      'Bullying or Harassment',
      'False Information',
      'Hate Speech',
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please select a reason for reporting this content. Your report will be kept anonymous.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reportReasons.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(reportReasons[index]),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Get.back(); // Close bottom sheet
                      CustomDialogs.showActionDialog(
                        title: 'Report this content?',
                        subtitle: 'Are you sure you want to proceed? This action cannot be undone.',
                        confirmText: 'Report',
                        isDestructive: true,
                        icon: Icons.flag_rounded,
                        onConfirm: () {
                          Get.back(); // close dialog
                          final parsedContentId = int.tryParse(contentId) ?? -1;
                          if (parsedContentId == -1) {
                             Get.snackbar('Error', 'Invalid content ID for reporting', snackPosition: SnackPosition.BOTTOM);
                             return;
                          }
                          // Using targetType "post" or "recipe", assuming contentId refers to a post here
                          controller.report(
                            targetId: parsedContentId,
                            targetType: 'post', // Adjust this based on your API structure if needed
                            reason: reportReasons[index]
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showBlockDialog(BuildContext context, TrustAndSafetyController controller) {
    CustomDialogs.showActionDialog(
      title: 'Block $targetUserName?',
      subtitle: 'Are you sure? Their recipes and comments will be hidden from your feed.',
      confirmText: 'Block',
      isDestructive: true,
      icon: Icons.block,
      onConfirm: () {
        Get.back(); // close the dialog
        final parsedUserId = int.tryParse(targetUserId) ?? -1;
        if (parsedUserId != -1) {
           controller.blockUser(parsedUserId);
        } else {
           Get.snackbar('Error', 'Invalid user ID');
        }
      },
    );
  }

  void _showUnblockDialog(BuildContext context, TrustAndSafetyController controller) {
    CustomDialogs.showActionDialog(
      title: 'Unblock $targetUserName?',
      subtitle: 'They will be able to see your recipes and comments again.',
      confirmText: 'Unblock',
      isDestructive: false,
      icon: Icons.check_circle_outline,
      onConfirm: () {
        Get.back(); // close the dialog
        final parsedUserId = int.tryParse(targetUserId) ?? -1;
        if (parsedUserId != -1) {
           controller.unblockUser(parsedUserId);
        } else {
           Get.snackbar('Error', 'Invalid user ID');
        }
      },
    );
  }
}
