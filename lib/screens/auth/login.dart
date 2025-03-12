import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/services/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_textfield.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Map<String, dynamic> result = await Auth().signInWithEmailAndPassword(
        _usernameController.text,
        _passwordController.text,
      );
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
  }

  void _loginWithGoogle() async {
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

  void _loginWithApple() async {
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

  Future<void> _handleRefresh() async {
    setState(() {
      _formKey.currentState?.reset();
      _usernameController.clear();
      _passwordController.clear();
    });
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
                                  const SizedBox(height: 60),
                                  Center(
                                    child: Text(
                                      'Welcome Back, Ready to Dive In?',
                                      style:
                                          AppTextStyles.headingStyleWithShadow,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      'Reconnect and continue your journey of simplifying the complex. SycX is here to keep you ahead with just a few clicks.',
                                      style: AppTextStyles.subheadingStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 60),
                                  CustomTextField(
                                    hintText: 'Username',
                                    onChanged: (value) => {},
                                    validator: (value) => value!.isEmpty
                                        ? 'Enter username'
                                        : null,
                                    focusNode: _usernameFocusNode,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocusNode);
                                    },
                                    prefixIcon: Icons.person,
                                    controller: _usernameController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    hintText: 'Password',
                                    obscureText: _obscurePassword,
                                    onChanged: (value) => {},
                                    validator: (value) => value!.isEmpty
                                        ? 'Enter password'
                                        : null,
                                    focusNode: _passwordFocusNode,
                                    onFieldSubmitted: (_) => _login(),
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
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/forgot_password');
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.bodyTextStyle
                                            .copyWith(
                                          color: AppColors.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AnimatedButton(
                                    text: 'Login',
                                    onPressed: _login,
                                    backgroundColor:
                                        AppColors.primaryButtonColor,
                                    textColor: AppColors.primaryButtonTextColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Or sign in with',
                                    style: AppTextStyles.bodyTextStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSocialButton(
                                        'assets/images/google.png',
                                        _loginWithGoogle,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSocialButton(
                                        'assets/images/apple.png',
                                        _loginWithApple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/register');
                                      },
                                      child: Text(
                                        'Don\'t have an account? Sign up',
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
