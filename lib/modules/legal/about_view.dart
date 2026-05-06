import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/image/app_image.dart';
import 'controller/app_details_controller.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppDetailsController());
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }
          final details = controller.appDetails.value;
          if (details == null) {
            return const Text("Failed to load About Us details");
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  MyAppImage.appLogo,
                  height: 100,
                ), // Assuming logo exists
                const SizedBox(height: 20),
                const Text(
                  "Chef Starz",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text("Version 1.0.0"),
                const SizedBox(height: 30),
                Text(
                  details.aboutUs,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Developed with ❤️ by the Chef Starz Team",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
