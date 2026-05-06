import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';

class CustomHeaderAuth extends StatelessWidget {
  final String titleFirstLine;
  final String titleSecondLine;
  final Color backgroundColor;
  final bool isSubTextFSiz;
  final double height;
  final double mainFSiz;
  final double subFSize;
  // final bool isArro;

  const CustomHeaderAuth({
    super.key,
    required this.titleFirstLine,
    required this.titleSecondLine,
    this.backgroundColor = const Color(0xFFFFF9C4),
    this.isSubTextFSiz = false,
    required this.height,
    this.mainFSiz = 32,
    this.subFSize = 17, // Default pale yellow
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20, // Accounts for status bar
        bottom: 40,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titleFirstLine,
            style: TextStyle(
              fontSize: mainFSiz,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            titleSecondLine,
            style: TextStyle(
              fontSize: subFSize,
              fontWeight: isSubTextFSiz ? FontWeight.w400 : FontWeight.bold,
              color: isSubTextFSiz ? AppColors.textSecondary : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
