import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/user_model.dart';
import '../../../core/colors/app_colors.dart';

class FollowNetworkView extends StatelessWidget {
  const FollowNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String title = args['type'] ?? 'Network';
    final List<UserModel> userList = args['list'] ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.paleYellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.orange,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: userList.isEmpty
          ? Center(child: Text("No $title yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                final displayName = user.name.isNotEmpty
                    ? user.name
                    : user.username;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profilePicture?.isNotEmpty == true
                        ? (user.profilePicture!.startsWith('assets/')
                                  ? AssetImage(user.profilePicture!)
                                  : CachedNetworkImageProvider(
                                      user.profilePicture!,
                                    ))
                              as ImageProvider
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: user.profilePicture?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("@${user.username}"),
                  onTap: () {
                    // Navigate to Another User Profile logic if required,
                    // skipping it for now to avoid rapid unhandled loops loop.
                  },
                );
              },
            ),
    );
  }
}
