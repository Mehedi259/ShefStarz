import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class ParentalVerificationDialog extends StatefulWidget {
  const ParentalVerificationDialog({super.key});

  /// Helper to easily show the gate
  static Future<bool> present() async {
    final result = await Get.dialog<bool>(
      const ParentalVerificationDialog(),
      barrierDismissible: false, // Must either answer or cancel
    );
    return result ?? false;
  }

  @override
  State<ParentalVerificationDialog> createState() =>
      _ParentalVerificationDialogState();
}

class _ParentalVerificationDialogState
    extends State<ParentalVerificationDialog> {
  late TextEditingController _answerController;
  int _num1 = 0;
  int _num2 = 0;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _generateProblem();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _generateProblem() {
    final random = Random();
    setState(() {
      _num1 = random.nextInt(10) + 1; // 1 to 10
      _num2 = random.nextInt(10) + 1; // 1 to 10
    });
    _answerController.clear();
  }

  void _verifyAnswer() async {
    final input = int.tryParse(_answerController.text.trim());
    final correctAnswer = _num1 + _num2;

    if (input == correctAnswer) {
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(result: true);
    } else {
      Get.snackbar(
        'Incorrect',
        'Incorrect answer. Please ask a parent for help.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      _generateProblem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.family_restroom,
                size: 48,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Parental Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please solve this math problem to continue:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Text(
                'What is $_num1 + $_num2?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _verifyAnswer(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 100));
                      Get.back(result: false);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _verifyAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}