import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Help Center'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            'Frequently Asked Questions',
            'Find answers to common questions.',
            Icons.question_answer,
            '/frequent_questions',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Contact Support',
            'Get in touch with our support team.',
            Icons.support_agent,
            '/contact_support',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'User Guide',
            'Learn how to use the app effectively.',
            Icons.book,
            '/user_guide',
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/help_center',
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String description,
      IconData icon, String route) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTextColorDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(icon, color: AppColors.primaryTextColorDark, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleStyle.copyWith(
                        color: AppColors.primaryTextColorDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyTextStyle.copyWith(
                        color: AppColors.secondaryTextColorDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.arrow_forward_ios,
                    size: 20, color: AppColors.primaryTextColorDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
