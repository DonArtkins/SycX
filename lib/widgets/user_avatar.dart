import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/screens/auth/login.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/services/auth.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';
import 'package:sycx_flutter_app/models/user.dart' as app_user;

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
            backgroundImage: NetworkImage(user.userProfile),
          ),
        ),
      ),
    );
  }
}
