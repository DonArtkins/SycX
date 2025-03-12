import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/services/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sycx_flutter_app/utils/pick_image.dart';
import 'package:sycx_flutter_app/utils/convert_to_base64.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_textfield.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'dart:io';
import 'package:sycx_flutter_app/widgets/loading.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _selectedImage;
  bool _obscurePassword = true;
  bool _isLoading = false;
  Timer? _debounceTimer;

  void _refreshForm() {
    setState(() {
      _formKey.currentState?.reset();
      _fullnameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _selectedImage = null;
    });
  }

  Future<void> _handleRefresh() async {
    _refreshForm();
    return Future.delayed(const Duration(seconds: 1));
  }

  void _register() {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);
        String base64Image = '';
        try {
          if (_selectedImage != null) {
            base64Image = await compute(convertFileToBase64, _selectedImage!);
          }

          // Trim whitespace from input
          String fullname = _fullnameController.text.trim();
          String username = _usernameController.text.trim();
          String email = _emailController.text.trim();
          String password = _passwordController.text.trim();

          if (fullname.isEmpty ||
              username.isEmpty ||
              email.isEmpty ||
              password.isEmpty) {
            throw Exception('All fields except profile picture are required');
          }

          Map<String, dynamic> result =
              await Auth().registerWithEmailAndPassword(
            fullname,
            username,
            email,
            password,
            base64Image,
          );

          setState(() => _isLoading = false);

          if (result['success']) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showErrorToast(
                result['message'] ?? 'Registration failed. Please try again.');
          }
        } catch (e) {
          setState(() => _isLoading = false);
          print('Error during registration: $e');
          _showErrorToast('Registration failed: ${e.toString()}');
        }
      } else {
        _showErrorToast('Please fill all required fields correctly');
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

  void _registerWithGoogle() async {
    setState(() => _isLoading = true);
    Map<String, dynamic> result = await Auth().signInWithGoogle();
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.gradientMiddle,
        textColor: Colors.white,
      );
    }
  }

  void _registerWithApple() async {
    setState(() => _isLoading = true);
    Map<String, dynamic> result = await Auth().signInWithApple();
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.gradientMiddle,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _fullnameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      },
      child: Scaffold(
        body: _isLoading
            ? const Loading()
            : Container(
                height: MediaQuery.of(context).size.height,
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
                child: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Center(
                                    child: Text(
                                      'Create Your Account, Unlock the Future',
                                      style:
                                          AppTextStyles.headingStyleWithShadow,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      'Join a community transforming how knowledge is consumed. Start summarizing the world’s information in seconds with SycX.',
                                      style: AppTextStyles.subheadingStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_selectedImage != null)
                                    Center(
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryButtonColor,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors
                                                  .primaryButtonColor
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  AnimatedButton(
                                    text: 'Select Profile Picture',
                                    onPressed: _selectProfilePicture,
                                    backgroundColor:
                                        AppColors.secondaryButtonColor,
                                    textColor:
                                        AppColors.secondaryButtonTextColor,
                                  ),
                                  const SizedBox(height: 24),
                                  CustomTextField(
                                    hintText: 'Fullname',
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Fullname is required';
                                      }
                                      return null;
                                    },
                                    focusNode: _fullnameFocusNode,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_usernameFocusNode);
                                    },
                                    prefixIcon: Icons.badge,
                                    controller: _fullnameController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    hintText: 'Username',
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Username is required';
                                      }
                                      return null;
                                    },
                                    focusNode: _usernameFocusNode,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_emailFocusNode);
                                    },
                                    prefixIcon: Icons.person,
                                    controller: _usernameController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    hintText: 'Email',
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    focusNode: _emailFocusNode,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocusNode);
                                    },
                                    prefixIcon: Icons.email,
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    hintText: 'Password',
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      if (!RegExp(
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                                          .hasMatch(value)) {
                                        return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                      }
                                      return null;
                                    },
                                    focusNode: _passwordFocusNode,
                                    onFieldSubmitted: (_) => _register(),
                                    prefixIcon: Icons.lock,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.secondaryTextColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    controller: _passwordController,
                                  ),
                                  const SizedBox(height: 24),
                                  AnimatedButton(
                                    text: 'Register',
                                    onPressed: _register,
                                    backgroundColor:
                                        AppColors.primaryButtonColor,
                                    textColor: AppColors.primaryButtonTextColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Or sign up with',
                                    style: AppTextStyles.bodyTextStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSocialButton(
                                        'assets/images/google.png',
                                        _registerWithGoogle,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSocialButton(
                                        'assets/images/apple.png',
                                        _registerWithApple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/login');
                                      },
                                      child: Text(
                                        'Already have an account? Log in',
                                        style: AppTextStyles.bodyTextStyle
                                            .copyWith(
                                          color: AppColors.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onPressed) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textFieldFillColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image.asset(
            imagePath,
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }
}
