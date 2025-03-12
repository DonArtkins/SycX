import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class DataUsage extends StatelessWidget {
  const DataUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Data Usage'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'How SycX uses your data',
            style: AppTextStyles.titleStyleX.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColorDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SycX uses your data to enhance our AI-summarization services and provide you with more accurate and personalized summaries. Here\'s how we utilize different types of data:',
            style: AppTextStyles.bodyTextStyle.copyWith(
              color: AppColors.secondaryTextColorDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          _buildDataUsageCard(
            'Summary Personalization',
            'We analyze your reading preferences and summarization history to tailor our AI algorithms for more relevant and concise summaries.',
            Icons.text_fields,
            AppColors.primaryTextColorDark,
          ),
          _buildDataUsageCard(
            'AI Model Improvement',
            'Your feedback on summaries helps us continuously refine and enhance our AI summarization models for better accuracy.',
            Icons.psychology,
            AppColors.primaryTextColorDark,
          ),
          _buildDataUsageCard(
            'Content Security',
            'We employ advanced algorithms to ensure the privacy and security of the texts you submit for summarization.',
            Icons.security,
            AppColors.primaryTextColorDark,
          ),
          _buildDataUsageCard(
            'User Experience',
            'We analyze usage patterns to optimize the app\'s interface and features, making summarization more efficient and user-friendly.',
            Icons.touch_app,
            AppColors.primaryTextColorDark,
          ),
        ],
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(currentRoute: '/data_usage'),
    );
  }

  Widget _buildDataUsageCard(
      String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTextColorDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColorDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.secondaryTextColorDark,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
