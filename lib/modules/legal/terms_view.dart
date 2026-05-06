import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/app_details_controller.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppDetailsController());
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final details = controller.appDetails.value;
        if (details == null) {
          return const Center(child: Text("Failed to load Terms"));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chef Starz Terms of Service",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(details.termsAndConditions),
              const SizedBox(height: 200),
              const Center(
                child: Text(
                  "Last Updated: January 2026",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
