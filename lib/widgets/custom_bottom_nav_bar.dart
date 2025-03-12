import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;
  const CustomBottomNavBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientMiddle,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(80),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            buildNavItem(Icons.home, 'Home', '/home'),
            buildNavItem(Icons.upload, 'Upload', '/upload'),
            buildNavItem(
                Icons.my_library_books_rounded, 'Summaries', '/summaries'),
          ],
          onTap: (index) {
            String route = ['/home', '/upload', '/summaries'][index];
            String currentParentRoute = getParentRoute(currentRoute);
            if (currentParentRoute != route) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          currentIndex: getCurrentIndex(),
        ),
      ),
    );
  }

  BottomNavigationBarItem buildNavItem(
    IconData icon,
    String label,
    String route,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: getParentRoute(currentRoute) == route
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24,
        ),
      ),
      label: label,
    );
  }

  String getParentRoute(String route) {
    final sharedRoutes = [
      '/profile',
      '/edit_profile',
      '/account_settings',
      '/data_access',
      '/your_data',
      '/download_data',
      '/data_usage',
      '/help_center',
      '/frequent_questions',
      '/contact_support',
      '/user_guide',
      '/search',
      '/summary_details',
      '/view_summary',
    ];

    if (route == '/home' ||
        (sharedRoutes.contains(route) && _lastMainRoute == '/home')) {
      return '/home';
    } else if (route == '/upload' ||
        (sharedRoutes.contains(route) && _lastMainRoute == '/upload')) {
      return '/upload';
    } else if (route == '/summaries' ||
        (sharedRoutes.contains(route) && _lastMainRoute == '/summaries')) {
      return '/summaries';
    }

    return route;
  }

  int getCurrentIndex() {
    String parentRoute = getParentRoute(currentRoute);
    switch (parentRoute) {
      case '/home':
        return 0;
      case '/upload':
        return 1;
      case '/summaries':
        return 2;
      default:
        return 0;
    }
  }

  // Add this variable to keep track of the last main route
  static String _lastMainRoute = '/home';

  // Add this method to update the last main route
  static void updateLastMainRoute(String route) {
    if (['/home', '/upload', '/summaries'].contains(route)) {
      _lastMainRoute = route;
    }
  }
}
