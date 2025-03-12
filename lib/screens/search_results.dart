import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:sycx_flutter_app/models/summary.dart';
import 'package:sycx_flutter_app/services/database.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';
import 'package:sycx_flutter_app/widgets/summary_card.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults({super.key, required this.searchQuery});

  @override
  SearchResultsState createState() => SearchResultsState();
}

class SearchResultsState extends State<SearchResults> {
  final Database _database = Database();
  List<Summary> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      // Get current user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
        return;
      }

      // Fetch all user's summaries
      QuerySnapshot querySnapshot = await _database.firestore
          .collection('summaries')
          .where('userId', isEqualTo: firebaseUser.uid)
          .get();

      // Filter results client-side for case-insensitive partial matching
      List<Summary> results = querySnapshot.docs
          .map((doc) => Summary.fromFirestore(doc))
          .where((summary) {
        final lowercaseQuery = widget.searchQuery.toLowerCase();
        return summary.title?.toLowerCase().contains(lowercaseQuery) == true ||
            (summary.pdfUrl?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error performing search: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
      }
    }
  }

  void _togglePin(String id) async {
    try {
      // Find the summary in the list
      Summary? summaryToToggle =
          _searchResults.firstWhere((summary) => summary.id == id);

      // Get the current user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      // Toggle the pinned status
      summaryToToggle.isPinned = !summaryToToggle.isPinned;

      // Update in the database
      await _database.updateSummary(summaryToToggle);

      // Update the local list
      setState(() {
        int index = _searchResults.indexWhere((summary) => summary.id == id);
        if (index != -1) {
          _searchResults[index] = summaryToToggle;
        }
      });
    } catch (e) {
      print('Error toggling pin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Loading()
        : Scaffold(
            appBar: CustomAppBarMini(
                title: 'Search Results: ${widget.searchQuery}'),
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
                        'Results for "${widget.searchQuery}"',
                        style: AppTextStyles.titleStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildSearchResults(),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavBar(
              currentRoute: '/search',
            ),
          );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(defaultPadding),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.primaryTextColor,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'No Results Found',
              style: AppTextStyles.headingStyleNoShadow.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'We couldn\'t find any results for "${widget.searchQuery}".\nPlease try a different search term.',
              style: AppTextStyles.bodyTextStyle
                  .copyWith(color: AppColors.altPriTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: SummaryCard(
                summary: _searchResults[index],
                onTogglePin: _togglePin,
                isEmpty: false,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    CustomBottomNavBar.updateLastMainRoute('/search');
    await _performSearch();
  }
}
