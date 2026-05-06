import 'package:chef_starz/core/image/app_image.dart';
import 'package:flutter/material.dart';

import 'camera_button.dart';
import 'curved_nav_background.dart';
import 'nav_item.dart';

class AppBottomBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onPressed;

  const AppBottomBar({
    super.key,
    required this.tabIndex,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // List definition with proper typing
    final List<Map<String, dynamic>?> navItems = [
      {'icon': MyAppImage.home, 'label': 'Home'},
      {'icon': MyAppImage.searchsvg, 'label': 'Search'},
      null, // Index 2: Placeholder for the center Camera Button
      {'icon': MyAppImage.chef, 'label': 'Recipes'},
      {'icon': MyAppImage.profile, 'label': 'Profile'},
    ];

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The background shape/shadow
          const CurvedNavBackground(),

          // Navigation Items Row
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ), // Adjust based on design
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];

                  // Handle the center gap
                  if (item == null) {
                    return const SizedBox(width: 60);
                  }

                  // Logic to map list index to tabIndex:
                  // List Index: [0, 1, 2 (null), 3, 4]
                  // Tab Index:  [0, 1,  N/A   , 2, 3]
                  int actualTabIndex = index > 2 ? index - 1 : index;

                  return NavItem(
                    icon: item['icon'],
                    label: item['label'] as String,
                    active: tabIndex == actualTabIndex,
                    onTap: () => onPressed(actualTabIndex),
                  );
                }),
              ),
            ),
          ),

          // Floating Camera Button
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(child: CameraButton()),
          ),
        ],
      ),
    );
  }
}
