import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class DataAccess extends StatelessWidget {
  const DataAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Data Access'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            'Your Data',
            'View and manage the data associated with your account.',
            Icons.folder_open,
            '/your_data',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Download Your Data',
            'Request a copy of your personal data.',
            Icons.cloud_download,
            '/download_data',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Data Usage',
            'See how your data is used to improve our services.',
            Icons.bar_chart,
            '/data_usage',
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/data_access',
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
