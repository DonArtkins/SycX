import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/models/user.dart' as app_user;
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/custom_textfield.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'package:sycx_flutter_app/utils/pick_image.dart';
import 'package:sycx_flutter_app/utils/convert_to_base64.dart';
import 'package:sycx_flutter_app/services/database.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';

class EditProfile extends StatefulWidget {
  final app_user.User? userData;

  const EditProfile({super.key, this.userData});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  File? _selectedImage;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  bool _isLoading = false;
  Timer? _debounceTimer;
  final Database _database = Database();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?.name);
    _emailController = TextEditingController(text: widget.userData?.email);
    _usernameController = TextEditingController(text: widget.userData?.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _selectProfilePicture() async {
    final picker = PickImage();
    try {
      final File? selectedImage =
          (await picker.pickImageFromGallery()) as File?;
      if (selectedImage != null) {
        setState(() {
          _selectedImage = selectedImage;
        });
      }
    } catch (e) {
      print('Error selecting image: $e');
      _showErrorToast('Failed to select image. Please try again.');
    }
  }

  void _submitForm() {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);

      try {
        String? base64Image;
        if (_selectedImage != null) {
          base64Image =
              await compute(convertFileToBase64Compute, _selectedImage!);
        }

        // Create an updated user object
        final updatedUser = app_user.User(
          id: widget.userData!.id,
          fullName: _nameController.text,
          userName: _usernameController.text,
          email: _emailController.text,
          userProfile: base64Image ?? widget.userData?.profileImage ?? '',
          createdAt: widget.userData!.createdAt,
          updatedAt: DateTime.now(), // Update the updated at timestamp
        );

        // Update user in Firestore
        await _database.updateUser(updatedUser);

        setState(() => _isLoading = false);
        Navigator.pop(context, updatedUser);
      } catch (e) {
        setState(() => _isLoading = false);
        print('Error updating profile: $e');
        _showErrorToast('Failed to update profile. Please try again.');
      }
    });
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.gradientMiddle,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Loading()
        : Scaffold(
            appBar: const CustomAppBarMini(title: 'Edit Profile'),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildProfileImage(),
                      const SizedBox(height: 24),
                      AnimatedButton(
                        text: 'Change Profile Picture',
                        onPressed: _selectProfilePicture,
                        backgroundColor: AppColors.secondaryButtonColor,
                        textColor: AppColors.secondaryButtonTextColor,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hintText: 'Full Name',
                        onChanged: (value) {},
                        validator: (value) =>
                            value!.isEmpty ? 'Name cannot be empty' : null,
                        prefixIcon: Icons.person,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_usernameFocus);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        hintText: 'Username',
                        onChanged: (value) {},
                        validator: (value) =>
                            value!.isEmpty ? 'Username cannot be empty' : null,
                        prefixIcon: Icons.alternate_email,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocus);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hintText: 'Email',
                        onChanged: (value) {},
                        validator: (value) =>
                            value!.isEmpty ? 'Email cannot be empty' : null,
                        prefixIcon: Icons.email,
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 32),
                      AnimatedButton(
                        text: 'Save Changes',
                        onPressed: _submitForm,
                        backgroundColor: AppColors.primaryButtonColor,
                        textColor: AppColors.primaryButtonTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavBar(
              currentRoute: '/edit_profile',
            ),
          );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryButtonColor,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CircleAvatar(
            radius: 90,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!) as ImageProvider
                : NetworkImage(widget.userData?.profileImage ?? ''),
          ),
        ),
      ),
    );
  }
}
