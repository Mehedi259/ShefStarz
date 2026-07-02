import 'package:chef_starz/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../controller/upload_controller.dart';

class UploadPostView extends GetView<UploadController> {
  const UploadPostView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Upload Photo/Videos",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.orange,
            size: 25,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.grey, size: 30),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildField(
              context,
              label: "Write Post/Video Title",
              controller: controller.postTitle,
              hint: "eg. rainbow cake",
              hasError: controller.postTitleError.value,
              onChanged: (_) {
                if (controller.postTitleError.value) {
                  controller.postTitleError.value = false;
                }
              },
            )),
            const SizedBox(height: 24),
            Obx(() => _buildField(
              context,
              label: "Description",
              controller: controller.postDescription,
              hint: "A rainbow cake is a vibrant...",
              maxLines: 4,
              hasError: controller.postDescriptionError.value,
              onChanged: (_) {
                if (controller.postDescriptionError.value) {
                  controller.postDescriptionError.value = false;
                }
              },
            )),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomLoadingButton(
                onTap: () {
                  controller.publishPost();
                },
                isLoading: controller.isLoading,
                text: 'Publish',
                gradient: AppColors.primaryGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool hasError = false,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : theme.dividerColor,
                width: hasError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : theme.dividerColor,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.orange,
                width: 2,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "This field is required",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
