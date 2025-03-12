import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/services/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_textfield.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Map<String, dynamic> result =
            await Auth().sendPasswordResetEmail(_emailController.text);

        if (result['success']) {
          _showResetInstructionsDialog(context, result['expiration']);
        } else {
          Fluttertoast.showToast(
            msg: result['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.gradientMiddle,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'An unexpected error occurred: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.gradientMiddle,
          textColor: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showResetInstructionsDialog(BuildContext context, String expiration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textFieldFillColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Check Your Email',
                  style: AppTextStyles.titleStyle
                      .copyWith(color: AppColors.primaryTextColor),
                ),
                const SizedBox(height: defaultPadding),
                Text(
                  'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions to reset your password. '
                  'The link will expire on $expiration UTC. If you don\'t see the email, please check your spam or junk folder as it might have been filtered there.',
                  style: AppTextStyles.bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 12),
                  ),
                  child: Text('OK', style: AppTextStyles.buttonTextStyle),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _formKey.currentState?.reset();
      _emailController.clear();
    });
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        body: _isLoading
            ? const Loading()
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Center(
                                child: Text(
                                  'Forgot Password',
                                  style: AppTextStyles.headingStyleWithShadow,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Enter your email to reset your password.',
                                  style: AppTextStyles.subheadingStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 60),
                              CustomTextField(
                                hintText: 'Email',
                                onChanged: (value) => {},
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter email' : null,
                                focusNode: _emailFocusNode,
                                onFieldSubmitted: (_) => _resetPassword(),
                                prefixIcon: Icons.email,
                                controller: _emailController,
                              ),
                              const SizedBox(height: 24),
                              AnimatedButton(
                                text: 'Send Reset Link',
                                onPressed: _resetPassword,
                                backgroundColor: AppColors.primaryButtonColor,
                                textColor: AppColors.primaryButtonTextColor,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                                  child: Text(
                                    'Back to Login',
                                    style: AppTextStyles.bodyTextStyle.copyWith(
                                      color: AppColors.primaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
}
