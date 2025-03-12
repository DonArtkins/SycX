import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'User Guide'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGuideItem(
            'Getting Started',
            'Learn how to set up your account and start using the SycX app.',
            [
              'Download and install the SycX app from your device\'s app store.',
              'Open the app and either register for a new account or log in if you already have one.',
            ],
          ),
          _buildGuideItem(
            'Uploading Documents',
            'How to upload documents for summarization.',
            [
              'Navigate to the upload screen by tapping the upload icon in the bottom navigation bar (second option).',
              'Select a file from your device or cloud storage to upload.',
              'Choose the desired summarization depth/length (short or detailed) on the upload screen.',
              'Tap the "Summarize" button to generate your summary.',
            ],
          ),
          _buildGuideItem(
            'Customizing Summaries',
            'Adjust summary settings to fit your needs.',
            [
              'On the upload screen, you can customize the summary depth/length.',
              'Choose between a short summary or a more detailed one based on your preferences.',
              'The summary depth affects how concise or comprehensive your generated summary will be.',
            ],
          ),
          _buildGuideItem(
            'Managing Your Library',
            'Organize and access your summarized documents.',
            [
              'On the home screen, you\'ll see your 4 most recent summaries displayed in a grid.',
              'Use the search bar on the home screen to find specific summaries.',
              'View all your summaries in a grid layout on the summaries screen (last icon in the bottom nav bar).',
            ],
          ),
          _buildGuideItem(
            'Advanced Features',
            'Explore additional tools and features.',
            [
              'View summaries in PDF format for easy reading and sharing.',
              'In the summary details screen (accessed by tapping a summary card), you can delete or download individual summaries.',
              'Rate summaries and provide feedback in the summary details screen to help us improve.',
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/user_guide',
      ),
    );
  }

  Widget _buildGuideItem(
      String question, String description, List<String> steps) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.titleStyle.copyWith(
            color: AppColors.primaryTextColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodyTextStyle.copyWith(
            color: AppColors.primaryTextColorDark,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              step,
                              style: AppTextStyles.bodyTextStyle.copyWith(
                                color: AppColors.primaryTextColorDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
