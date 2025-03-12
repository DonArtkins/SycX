import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/screens/auth/login.dart';
import 'package:sycx_flutter_app/screens/auth/register.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _navigateWithAnimation(BuildContext context, String routeName) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            routeName == '/register' ? const Register() : const Login(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        // Do nothing as this is the initial screen
      },
      child: Scaffold(
        body: RefreshIndicator(
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/welcome.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.gradientStart.withOpacity(0.6),
                              AppColors.gradientMiddle.withOpacity(0.6),
                              AppColors.gradientEnd.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Unlock the Power of Knowledge in Seconds',
                          style: AppTextStyles.headingStyleWithShadow,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Experience information overload no more!\nSycX distills oceans of content into pearls of wisdom.',
                          style: AppTextStyles.subheadingStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        AnimatedButton(
                          text: 'Sign up',
                          onPressed: () =>
                              _navigateWithAnimation(context, '/register'),
                          backgroundColor: AppColors.primaryButtonColor,
                          textColor: AppColors.primaryButtonTextColor,
                        ),
                        const SizedBox(height: 20),
                        AnimatedButton(
                          text: 'Log in',
                          onPressed: () =>
                              _navigateWithAnimation(context, '/login'),
                          backgroundColor: AppColors.secondaryButtonColor,
                          textColor: AppColors.secondaryButtonTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
