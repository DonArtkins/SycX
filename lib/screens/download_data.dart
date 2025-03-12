import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class DownloadData extends StatefulWidget {
  const DownloadData({super.key});

  @override
  DownloadDataState createState() => DownloadDataState();
}

class DownloadDataState extends State<DownloadData> {
  final Map<String, bool> dataTypes = {
    'Personal Information': true,
    'Pinned Summaries': true,
    'Recent Searches': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Download Your Data'),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request a copy of your personal data',
                  style: AppTextStyles.titleStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColorDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You can request a copy of your personal data associated with your account. This process may take some time to complete.',
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.secondaryTextColorDark,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select data to include:',
                  style: AppTextStyles.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTextColorDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...dataTypes.keys.map((String key) => _buildDataTypeCard(key)),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _requestDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButtonColor,
                      foregroundColor: AppColors.primaryButtonTextColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Request Download',
                      style: AppTextStyles.buttonTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(currentRoute: '/download_data'),
    );
  }

  Widget _buildDataTypeCard(String title) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyTextStyle.copyWith(
                  color: AppColors.primaryTextColorDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: dataTypes[title]!,
              onChanged: (bool value) {
                setState(() {
                  dataTypes[title] = value;
                });
              },
              activeColor: AppColors.primaryButtonColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Add refresh logic here
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh the state if needed
    });
  }

  void _requestDownload() {
    // Add download request logic here
    // You can use the dataTypes map to determine which data to include
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Request', style: AppTextStyles.titleStyle),
          content: Text(
            'Your data download request has been received. We\'ll notify you when it\'s ready.',
            style: AppTextStyles.bodyTextStyle,
          ),
          actions: [
            TextButton(
              child: Text('OK', style: AppTextStyles.buttonTextStyle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
