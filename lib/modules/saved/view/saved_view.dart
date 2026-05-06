import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../controller/saved_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/custom_dialogs.dart';

class SavedView extends GetView<SavedController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Saved",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.redAccent),
            tooltip: "Clear All Saves",
            onPressed: () {
              CustomDialogs.showActionDialog(
                title: "Clear All Saves?",
                subtitle: "This will unsave all items from your account. Proceed?",
                confirmText: "Yes, Clear All",
                isDestructive: true,
                icon: Icons.cleaning_services,
                onConfirm: () {
                  Get.back();
                  controller.clearAllSaves();
                },
              );
            },
          ),
          Obx(() {
            if (controller.selectedCollections.isNotEmpty) {
              return IconButton(
                onPressed: controller.deleteSelectedCollections,
                icon: const Icon(Icons.delete, color: Colors.red),
              );
            }
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'clear') controller.clearSelection();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Text("Clear Selection"),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 25,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.customCollections.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.customCollections.length) {
              return _buildCreateCard(context);
            }
            final item = controller.customCollections[index];

            // Count and image directly from the custom collection
            int itemCount = item.itemIds.length;
            String? coverImage = item.coverImage;

            return Obx(() {
              final isSelected = controller.selectedCollections.contains(
                item.id,
              );
              return GestureDetector(
                onLongPress: () => controller.toggleSelection(item.id),
                onTap: () {
                  if (controller.selectedCollections.isNotEmpty) {
                    controller.toggleSelection(item.id);
                  } else {
                    Get.toNamed(
                      Routes.SAVED_DETAILS,
                      arguments: {'id': item.id, 'title': item.name},
                    );
                  }
                },
                child: Stack(
                  children: [
                    _buildCollectionCard(
                      context,
                      title: item.name,
                      subtitle: "$itemCount Items",
                      isDefault: false, // No longer default
                      image: coverImage,
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildCollectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool isDefault = false,
    String? image,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: isDefault && (image == null || image.isEmpty)
                ? Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: image != null && image.isNotEmpty
                        ? (image.toLowerCase().endsWith('.mp4') ||
                                  image.toLowerCase().endsWith('.avi') ||
                                  image.toLowerCase().endsWith('.mov'))
                              ? Container(
                                  color: Colors.black87,
                                  width: double.infinity,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : image.startsWith('assets/')
                              ? Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildErrorPlaceholder(),
                                )
                              : image.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildErrorPlaceholder(),
                                )
                              : Image.file(
                                  File(image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildErrorPlaceholder(),
                                )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  void _showCreateCollectionDialog(
    BuildContext context,
    SavedController controller,
  ) {
    final TextEditingController nameController = TextEditingController();
    final RxnString selectedImagePath = RxnString();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create New Collection",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Collection Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final path = await controller.pickImage();
                    if (path != null) selectedImagePath.value = path;
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImagePath.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(selectedImagePath.value!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Pick Cover Image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFF8A1F,
                    ), // App primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    controller.createCollection(
                      nameController.text,
                      selectedImagePath.value,
                    );
                  },
                  child: const Text(
                    "Create",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showCreateCollectionDialog(context, controller),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(Icons.add, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 10),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      "Create new\ncollection",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
