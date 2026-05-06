import 'package:flutter/material.dart';

class SafetyBanner extends StatelessWidget {
  final VoidCallback? onClose;

  const SafetyBanner({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.gpp_good_rounded,
            color: Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Safe!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Never share your real name, address, or phone number with anyone online.',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            InkWell(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
