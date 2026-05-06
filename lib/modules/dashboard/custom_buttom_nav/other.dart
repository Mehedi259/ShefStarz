// BottomAppBar(
// shape: const CircularNotchedRectangle(),
// notchMargin: 8.0,
// color: theme.cardColor,
// elevation: 10,
// child: SizedBox(
// height: 60,
// child: Obx(
// () => Row(
// mainAxisAlignment: MainAxisAlignment.spaceAround,
// children: [
// // Fixed: Added the activeIcon argument to match function signature
// _buildNavItem(context, MyAppImage.home, MyAppImage.home, 0),
// _buildNavItem(context, MyAppImage.searchsbg1, MyAppImage.searchsbg1, 1),
// const SizedBox(width: 40), // Space for FAB
// _buildNavItem(context, MyAppImage.chef, MyAppImage.chef, 2),
// _buildNavItem(context, MyAppImage.profile, MyAppImage.profile, 3),
// ],
// ),
// ),
// ),
// ),
//
//
//
//
// Widget _buildNavItem(
// BuildContext context,
// String icon,
// String activeIcon, // This was missing in your calls above
// int index,
// ) {
// final theme = Theme.of(context);
// final isSelected = controller.tabIndex.value == index;
//
// return IconButton(
// onPressed: () => controller.changeTabIndex(index),
// icon: Container(
// width: 55,
// height: 55,
// padding: EdgeInsets.all(8),
// decoration: BoxDecoration(shape: BoxShape.circle, color:isSelected?AppColors.paleYellow:(theme.iconTheme.color?.withValues(alpha: 0.1) ?? Colors.white) ,),
//
// child: SvgPicture.asset(
// isSelected ? activeIcon : icon,
// // Fixed: Use colorFilter instead of deprecated color property
// colorFilter: ColorFilter.mode(
// isSelected
// ? theme.primaryColor
//     : (theme.iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey),
// BlendMode.srcIn,
// ),
// height: 29,
// width: 29,
// ),
// ),
// );
// }