import 'package:SycX/services/auth.dart';
import 'package:SycX/services/database.dart';
import 'package:SycX/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SycX/utils/constants.dart';
import 'package:SycX/widgets/custom_app_bar_mini.dart';
import 'package:SycX/widgets/custom_bottom_nav_bar.dart';
import 'package:SycX/widgets/animated_button.dart';
import 'package:SycX/widgets/custom_textfield.dart';

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
  bool _loading = false; // Add loading state
  final Auth _auth = Auth(); // Add Auth instance
  final Database _database = Database(); // Add Database instance

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Loading()
        : Scaffold(
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

  // Implement password change functionality
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        // Get current user
        final user = _auth.getCurrentUser();

        if (user != null && user.email != null) {
          // First, verify current password is correct
          final signInResult = await _auth.signInWithEmailAndPassword(
            user.email!,
            _currentPasswordController.text,
          );

          if (signInResult['success'] == true) {
            // Create EmailAuthCredential for reauthentication
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: _currentPasswordController.text,
            );

            // Reauthenticate user
            await user.reauthenticateWithCredential(credential);

            // Change password
            await user.updatePassword(_newPasswordController.text);

            // Reset form
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();

            setState(() {
              _loading = false;
            });

            if (mounted) {
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
          } else {
            throw Exception(
                signInResult['message'] ?? 'Current password is incorrect');
          }
        }
      } catch (e) {
        setState(() {
          _loading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString()}',
                style: AppTextStyles.bodyTextStyle
                    .copyWith(color: AppColors.primaryTextColor),
              ),
              backgroundColor: AppColors.gradientEnd,
            ),
          );
        }
      }
    }
  }

  // Implement account deletion
  Future<void> _deleteAccount() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = _auth.getCurrentUser();

      if (user != null) {
        final userId = user.uid;

        // Sign out first to prevent auth errors
        await _auth.signOut();

        // Navigate to login screen immediately after logout
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }

        // Delete user data from Firestore
        await _deleteUserData(userId);

        // Finally delete the Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      // We're already logged out and navigated away, so we don't need to show a snackbar
    }
  }

  // Helper method to delete all user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      // Delete user summaries
      final summariesSnapshot = await _database.firestore
          .collection('summaries')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in summariesSnapshot.docs) {
        await _database.firestore.collection('summaries').doc(doc.id).delete();
      }

      // Delete user feedback
      final feedbackSnapshot = await _database.firestore
          .collection('feedback')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in feedbackSnapshot.docs) {
        await _database.firestore.collection('feedback').doc(doc.id).delete();
      }

      // Delete user search history
      final searchesSnapshot = await _database.firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in searchesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Finally, delete the user document itself
      await _database.firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user data: $e');
    }
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
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }
}
