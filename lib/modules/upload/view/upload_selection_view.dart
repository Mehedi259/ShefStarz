import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/custom_btn.dart';
import '../../../core/widgets/gradient_border_painter/gradient_border_painter.dart';
import '../controller/upload_controller.dart';

class UploadSelectionView extends GetView<UploadController> {
  const UploadSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Captured Image
          Obx(() {
            if (controller.mediaCaptured.value) {
              if (controller.capturedVideoPath.value.isNotEmpty) {
                return _VideoPreviewWidget(
                  videoPath: controller.capturedVideoPath.value,
                );
              }
              return AppImage(
                url: controller.capturedImagePath.value,
                fit: BoxFit.cover,
              );
            }

            if (controller.isCameraInitialized.value &&
                controller.cameraController != null) {
              return CameraPreview(controller.cameraController!);
            }

            // No background image - just show black background
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            );
          }),

          // Top Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      await controller.stopActiveResources();
                      Get.back();
                    },
                    icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  ),
                  const Text(
                    "Start Cooking!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => controller.mediaCaptured.value
                      ? _buildPreviewControls()
                      : _buildCameraControls(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode Selector Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gallery Button
            _buildSmallCircleButton(
              Icons.photo_library,
              controller.pickFromGallery,
            ),
            const SizedBox(width: 12),

            // Video Toggle Button
            Obx(
              () => _buildSmallCircleButton(
                controller.isVideoMode.value
                    ? Icons.videocam
                    : Icons.videocam_outlined,
                controller.toggleVideoMode,
                isActive: controller.isVideoMode.value,
              ),
            ),
            const SizedBox(width: 12),

            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTab("Post", controller.isPostTab.value),
                    _buildTab("Recipe", !controller.isPostTab.value),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Shutter Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              IconData flashIcon;
              switch (controller.currentFlashMode.value) {
                case FlashMode.torch:
                case FlashMode.always:
                  flashIcon = Icons.flash_on;
                  break;
                case FlashMode.auto:
                  flashIcon = Icons.flash_auto;
                  break;
                case FlashMode.off:
                  flashIcon = Icons.flash_off;
                  break;
              }
              return IconButton(
                onPressed: controller.toggleFlash,
                icon: Icon(flashIcon, color: Colors.white, size: 28),
              );
            }),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: controller.captureMedia,
              child: Obx(
                () => Container(
                  height: 80,
                  width: 80,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(
                      controller.isRecording.value ? 18 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isRecording.value
                          ? Colors.red
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                        controller.isRecording.value ? 8 : 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: controller.switchCamera,
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionIconButton(
            Icons.refresh,
            controller.resetCapture,
            "Retake",
          ),
          // Next Button
          SizedBox(
            width: 197,
            child: CustomGradientButton(
              text: 'Next',
              onTap: () async {
                await controller.stopActiveResources();
                final args = {
                  'type': controller.isVideoMode.value ? 'video' : 'image',
                  'path': controller.isVideoMode.value
                      ? controller.capturedVideoPath.value
                      : controller.capturedImagePath.value,
                };
                controller.isPostTab.value
                    ? Get.toNamed(Routes.UPLOAD_POST, arguments: args)
                    : Get.toNamed(Routes.UPLOAD_RECIPE, arguments: args);
              },
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.toggleTab(text == "Post"),
      child: AnimatedContainer(
        height: 43,
        width: 95,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          // No background color/gradient here
        ),
        child: CustomPaint(
          painter: isSelected
              ? GradientBorderPainter(
                  gradient: AppColors.primaryGradient,
                  radius: 20,
                  strokeWidth: 2,
                )
              : null,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                // Change text color to gradient or primary color when selected
                color: AppColors.background,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCircleButton(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        width: 69,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.orange.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.4),
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.orange
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.orange : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildActionIconButton(
    IconData icon,
    VoidCallback onTap,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 30),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _VideoPreviewWidget extends StatefulWidget {
  final String videoPath;
  const _VideoPreviewWidget({required this.videoPath});

  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          Get.find<UploadController>().activeVideoController = _controller;
        });
        _controller.play(); // Auto-play by default
        _controller.setLooping(true);
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller.value.isPlaying) {
        _controller.pause();
        setState(() {}); // Trigger rebuild to show play button
      }
    }
  }

  @override
  void dispose() {
    try {
      final uploadCtrl = Get.find<UploadController>();
      if (uploadCtrl.activeVideoController == _controller) {
        uploadCtrl.activeVideoController = null;
      }
    } catch (_) {}

    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
