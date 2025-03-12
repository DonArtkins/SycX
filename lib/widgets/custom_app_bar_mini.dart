import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';

class CustomAppBarMini extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBarMini({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientStart,
                AppColors.gradientMiddle,
                AppColors.gradientEnd,
              ],
            ),
          ),
          child: AppBar(
            title: Text(
              title,
              style: AppTextStyles.titleStyleX
                  .copyWith(color: AppColors.primaryTextColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0, // Remove shadow if needed
            iconTheme: const IconThemeData(
              color: AppColors.primaryTextColor,
            ),
            leading: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryTextColor),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.primaryTextColor,
                  weight: 700,
                  size: 25,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
