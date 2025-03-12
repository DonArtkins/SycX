import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/dummy_data.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';

class YourData extends StatefulWidget {
  const YourData({super.key});

  @override
  YourDataState createState() => YourDataState();
}

class YourDataState extends State<YourData>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _animationController;
  late List<Map<String, dynamic>> pinnedSummaries;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    pinnedSummaries = DummyData.summaries
        .where((summary) => summary['isPinned'] == true)
        .toList();
    setState(() {
      _loading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Loading()
        : Scaffold(
            appBar: const CustomAppBarMini(title: 'Your Data'),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildBody(),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavBar(
              currentRoute: '/your_data',
            ),
          );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataOverview(),
          const SizedBox(height: 24),
          _buildDataCard('Personal Information', Icons.person, DummyData.user),
          const SizedBox(height: 16),
          _buildDataCard('Pinned Summaries', Icons.summarize,
              {'Total': pinnedSummaries.length.toString()}),
          const SizedBox(height: 16),
          _buildDataCard('Recent Searches', Icons.search,
              {'Searches': DummyData.searches.take(7).join(', ')}),
        ],
      ),
    );
  }

  Widget _buildDataOverview() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Overview',
              style: AppTextStyles.titleStyle.copyWith(
                color: AppColors.primaryTextColorDark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your personal data.',
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.secondaryTextColorDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDataStat(
                    'Pinned Summaries', pinnedSummaries.length.toString()),
                _buildDataStat('Recent Searches',
                    DummyData.searches.take(7).length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleStyle.copyWith(
            color: AppColors.primaryButtonColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyTextStyle.copyWith(
            color: AppColors.secondaryTextColorDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(
      String title, IconData icon, Map<String, dynamic> data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTextColorDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: AppColors.primaryTextColorDark, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleStyle.copyWith(
                      color: AppColors.primaryTextColorDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries
                .where((entry) => entry.key != 'avatar')
                .map((entry) => _buildDataItem(entry.key, entry.value)),
            if (title == 'Personal Information')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(DummyData.user['avatar']!),
                    ),
                  ),
                ),
              ),
            if (title == 'Pinned Summaries')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    ...pinnedSummaries
                        .map((summary) => _buildSummaryItem(summary)),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/summaries');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: AppColors.primaryButtonTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('View All Summaries'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.secondaryTextColorDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.primaryTextColorDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(Map<String, dynamic> summary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(summary['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary['title'],
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.primaryTextColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  summary['date'],
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.secondaryTextColorDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }
}
