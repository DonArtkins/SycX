import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:SycX/models/user.dart' as app_user;
import 'package:SycX/models/summary.dart';
import 'package:SycX/services/database.dart';
import 'package:SycX/utils/constants.dart';
import 'package:SycX/widgets/custom_app_bar_mini.dart';
import 'package:SycX/widgets/custom_bottom_nav_bar.dart';
import 'package:SycX/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourData extends StatefulWidget {
  const YourData({super.key});

  @override
  YourDataState createState() => YourDataState();
}

class YourDataState extends State<YourData>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  late AnimationController _animationController;
  late List<Summary> pinnedSummaries = [];
  List<String> recentSearches = [];
  app_user.User? userData;
  final Database _database = Database();

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

    try {
      // Get current user ID
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Fetch user data
        final user = await _database.getUser(firebaseUser.uid);

        // Fetch pinned summaries
        List<Summary> summariesList = await _fetchPinnedSummaries(firebaseUser.uid);

        // Fetch recent searches
        List<String> searches = await _fetchRecentSearches(firebaseUser.uid);

        if (mounted) {
          setState(() {
            userData = user;
            pinnedSummaries = summariesList;
            recentSearches = searches;
            _loading = false;
          });
          _animationController.forward();
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<List<Summary>> _fetchPinnedSummaries(String userId) async {
    try {
      // Create a new database listener for this specific query to avoid stream conflicts
      QuerySnapshot summariesSnapshot = await _database.firestore
          .collection('summaries')
          .where('userId', isEqualTo: userId)
          .where('isPinned', isEqualTo: true)
          .get();

      return summariesSnapshot.docs
          .map((doc) => Summary.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching pinned summaries: $e');
      return [];
    }
  }

  Future<List<String>> _fetchRecentSearches(String userId) async {
    try {
      QuerySnapshot searchesSnapshot = await _database.firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();

      return searchesSnapshot.docs
          .map((doc) => doc['query'] as String)
          .toList();
    } catch (e) {
      print('Error fetching searches: $e');
      return [];
    }
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
          _buildDataCard('Personal Information', Icons.person, _getUserInfo()),
          const SizedBox(height: 16),
          _buildDataCard('Pinned Summaries', Icons.summarize,
              {'Total': pinnedSummaries.length.toString()}),
          const SizedBox(height: 16),
          _buildDataCard('Recent Searches', Icons.search,
              {'Searches': recentSearches.take(7).join(', ')}),
        ],
      ),
    );
  }

  Map<String, dynamic> _getUserInfo() {
    if (userData == null) {
      return {};
    }

    return {
      'Name': userData!.name,
      'UserName': '@${userData!.userName}',
      'Email': userData!.email,
      'Joined': _formatDate(userData!.createdAt),
    };
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
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
                    recentSearches.take(7).length.toString()),
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
            if (title == 'Personal Information' && userData != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
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

  Widget _buildSummaryItem(Summary summary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primaryTextColorDark.withOpacity(0.1),
            ),
            child: summary.imageUrl != null && summary.imageUrl!.isNotEmpty
                ? Image.network(
              summary.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.article,
                color: AppColors.primaryTextColorDark.withOpacity(0.6),
                size: 30,
              ),
            )
                : Icon(
              Icons.article,
              color: AppColors.primaryTextColorDark.withOpacity(0.6),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title ?? 'Untitled Summary',
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.primaryTextColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatSummaryDate(summary.createdAt),
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

  String _formatSummaryDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }
}