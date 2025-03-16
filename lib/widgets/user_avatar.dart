import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:SycX/screens/auth/login.dart';
import 'package:SycX/utils/constants.dart';
import 'package:SycX/services/auth.dart';
import 'package:SycX/widgets/loading.dart';
import 'package:SycX/models/user.dart' as app_user;

class UserAvatar extends StatelessWidget {
  final app_user.User user;
  final Auth _auth = Auth();

  UserAvatar({super.key, required this.user});

  void _handleLogout(BuildContext context) async {
    // Show loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Loading(),
    );

    try {
      // Perform logout
      await _auth.signOut();

      // Close loading screen and navigate to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Dismiss loading screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.textFieldFillColor,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: AppTextStyles.subheadingStyle
                    .copyWith(color: AppColors.primaryTextColor),
              ),
              Text(
                'Logged in as ${user.email}',
                style: AppTextStyles.bodyTextStyle.copyWith(
                  fontSize: 12,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              const Divider(color: AppColors.textFieldBorderColor),
            ],
          ),
        ),
        PopupMenuItem(
          child: TextButton.icon(
            icon: const Icon(Icons.person, color: AppColors.primaryButtonColor),
            label: Text(
              'Profile',
              style: AppTextStyles.bodyTextStyle
                  .copyWith(color: AppColors.primaryButtonColor),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ),
        PopupMenuItem(
          child: TextButton.icon(
            icon: const Icon(Icons.logout, color: AppColors.gradientEnd),
            label: Text(
              'Logout',
              style: AppTextStyles.bodyTextStyle
                  .copyWith(color: AppColors.gradientEnd),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the popup menu
              _handleLogout(context);
            },
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryButtonColor,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            backgroundImage: _getProfileImage(),
            backgroundColor: Colors.grey[200],
            child: _buildPlaceholderIfNeeded(),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (user.userProfile.isNotEmpty) {
      // Check if the profile image is a URL or base64 string
      if (user.userProfile.startsWith('http')) {
        return NetworkImage(user.userProfile);
      } else {
        try {
          // Try to decode as base64
          return MemoryImage(base64Decode(user.userProfile));
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      }
    }
    return null;
  }

  Widget? _buildPlaceholderIfNeeded() {
    if (user.userProfile.isEmpty) {
      // Return a placeholder icon if no image is available
      return const Icon(
        Icons.person,
        size: 24,
        color: AppColors.secondaryTextColor,
      );
    }
    // Return null to allow CircleAvatar to display the backgroundImage
    return null;
  }
}
