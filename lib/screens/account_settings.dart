import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'package:sycx_flutter_app/widgets/custom_textfield.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  AccountSettingsState createState() => AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Account Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChangePasswordSection(),
                const SizedBox(height: defaultMargin * 2),
                _buildDangerZone(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/account_settings',
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: AppTextStyles.titleStyle
                    .copyWith(color: AppColors.primaryTextColorDark),
              ),
              const SizedBox(height: defaultMargin),
              CustomTextField(
                hintText: 'Current Password',
                obscureText: _obscureCurrentPassword,
                onChanged: (value) => {},
                validator: (value) =>
                    value!.isEmpty ? 'Enter current password' : null,
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.secondaryTextColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                controller: _currentPasswordController,
              ),
              const SizedBox(height: defaultMargin),
              CustomTextField(
                hintText: 'New Password',
                obscureText: _obscureNewPassword,
                onChanged: (value) => {},
                validator: (value) =>
                    value!.isEmpty ? 'Enter new password' : null,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.secondaryTextColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                controller: _newPasswordController,
              ),
              const SizedBox(height: defaultMargin),
              CustomTextField(
                hintText: 'Confirm New Password',
                obscureText: _obscureConfirmPassword,
                onChanged: (value) => {},
                validator: (value) {
                  if (value!.isEmpty) return 'Confirm new password';
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.secondaryTextColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: defaultMargin * 1.5),
              AnimatedButton(
                text: 'Change Password',
                onPressed: _changePassword,
                backgroundColor: AppColors.primaryButtonColor,
                textColor: AppColors.primaryButtonTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement password change logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password changed successfully',
            style: AppTextStyles.bodyTextStyle
                .copyWith(color: AppColors.primaryTextColor),
          ),
          backgroundColor: AppColors.gradientMiddle,
        ),
      );
    }
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger Zone',
              style: AppTextStyles.titleStyle
                  .copyWith(color: AppColors.gradientEnd),
            ),
            const SizedBox(height: defaultMargin),
            Text(
              'Deleting your account is permanent and cannot be undone. All your data will be lost.',
              style: AppTextStyles.bodyTextStyle
                  .copyWith(color: AppColors.secondaryTextColorDark),
            ),
            const SizedBox(height: defaultMargin * 1.5),
            AnimatedButton(
              text: 'Delete Account',
              onPressed: _showDeleteAccountDialog,
              backgroundColor: AppColors.gradientEnd,
              textColor: AppColors.primaryButtonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.textFieldFillColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Delete Account',
            style: AppTextStyles.titleStyle
                .copyWith(color: AppColors.primaryTextColor),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: AppTextStyles.bodyTextStyle
                .copyWith(color: AppColors.primaryTextColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyTextStyle
                    .copyWith(color: AppColors.secondaryTextColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Delete',
                style: AppTextStyles.bodyTextStyle
                    .copyWith(color: AppColors.gradientEnd),
              ),
              onPressed: () {
                // TODO: Implement account deletion logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Account deleted successfully',
                      style: AppTextStyles.bodyTextStyle
                          .copyWith(color: AppColors.primaryTextColor),
                    ),
                    backgroundColor: AppColors.gradientEnd,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
