import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/user_avatar.dart';
import 'package:sycx_flutter_app/models/user.dart' as app_user;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackground;
  final String title;
  final app_user.User? user;

  const CustomAppBar({
    super.key,
    required this.showBackground,
    required this.title,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: showBackground
              ? Colors.white.withOpacity(0.8)
              : Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // This line removes the back arrow
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientStart.withOpacity(showBackground ? 0.2 : 0),
                  AppColors.gradientEnd.withOpacity(showBackground ? 0.2 : 0),
                ],
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo/icon.png',
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.headingStyleNoShadow.copyWith(
                    color: AppColors.primaryTextColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: UserAvatar(user: user!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
