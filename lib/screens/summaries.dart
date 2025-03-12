import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:SycX/models/user.dart' as app_user;
import 'package:SycX/models/summary.dart';
import 'package:SycX/services/database.dart';
import 'package:SycX/screens/search_results.dart';
import 'package:SycX/utils/constants.dart';
import 'package:SycX/widgets/custom_app_bar.dart';
import 'package:SycX/widgets/custom_bottom_nav_bar.dart';
import 'package:SycX/widgets/custom_textfield.dart';
import 'package:SycX/widgets/loading.dart';
import 'package:SycX/widgets/summary_card.dart';

class Summaries extends StatefulWidget {
  const Summaries({super.key});

  @override
  SummariesState createState() => SummariesState();
}

class SummariesState extends State<Summaries>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;
  late AnimationController _animationController;

  List<Summary> _summaries = [];
  List<Summary> _pinnedSummaries = [];
  List<String> _searches = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // User data
  app_user.User? _currentUser;
  final Database _database = Database();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadData();
    CustomBottomNavBar.updateLastMainRoute('/summaries');
  }

  Future<void> _loadData() async {
    try {
      // Get current user ID
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Fetch user data
        final user = await _database.getUser(firebaseUser.uid);

        // Set up a stream listener for user summaries
        _database.getUserSummaries(firebaseUser.uid).listen((summariesList) {
          if (mounted) {
            setState(() {
              // Sort non-pinned summaries by createdAt in descending order and take the latest 4
              _summaries =
                  summariesList.where((summary) => !summary.isPinned).toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
                    ..take(4);

              // Separate pinned summaries
              _pinnedSummaries =
                  summariesList.where((summary) => summary.isPinned).toList();
            });
          }
        });

        // Fetch recent searches
        final searches = await _fetchRecentSearches(firebaseUser.uid);

        if (mounted) {
          setState(() {
            _currentUser = user;
            _searches = searches;
            _isLoading = false;
            _animationController.forward();
          });
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<String>> _fetchRecentSearches(String userId) async {
    try {
      QuerySnapshot searchesSnapshot = await _database.firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return searchesSnapshot.docs
          .map((doc) => doc['query'] as String)
          .toList();
    } catch (e) {
      print('Error fetching searches: $e');
      return [];
    }
  }

  Future<void> _saveSearch(String query) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await _database.firestore.collection('searches').add({
          'userId': firebaseUser.uid,
          'query': query,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving search: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_showAppBarBackground) {
      setState(() => _showAppBarBackground = true);
    } else if (_scrollController.offset <= 10 && _showAppBarBackground) {
      setState(() => _showAppBarBackground = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
              user: _currentUser,
              showBackground: false,
              title: 'SycX',
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildBody(),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavBar(
              currentRoute: '/summaries',
            ),
          );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        _buildSearchBar(),
        _buildSummaries(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController, curve: Curves.easeOut))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.easeOut))
                .value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Summaries',
              style: AppTextStyles.headingStyleWithShadow,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your summarized content. SycX helps you keep track of all your summaries in one place.',
              style: AppTextStyles.subheadingStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        child: CustomTextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          hintText: 'Search for summaries...',
          onChanged: (value) {},
          validator: (value) => null,
          prefixIcon: Icons.search,
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              // Save the search
              _saveSearch(value);

              setState(() {
                if (!_searches.contains(value)) {
                  _searches.insert(0, value);
                }
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResults(searchQuery: value),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaries() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First show pinned summaries
            if (_pinnedSummaries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Pinned Summaries',
                    style: AppTextStyles.titleStyle.copyWith(fontSize: 18)),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _pinnedSummaries.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: SummaryCard(
                          summary: _pinnedSummaries[index],
                          onTogglePin: _togglePin,
                          isEmpty: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Then show all summaries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('All Summaries',
                  style: AppTextStyles.titleStyle.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _summaries.isEmpty ? 1 : _summaries.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _summaries.isEmpty
                          ? SummaryCard(
                              summary: Summary(
                                // Create an empty Summary
                                userId: '',
                                originalDocuments: [],
                                pdfUrl: '',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                              onTogglePin: (_) {},
                              isEmpty: true,
                            )
                          : SummaryCard(
                              summary: _summaries[index],
                              onTogglePin: _togglePin,
                              isEmpty: false,
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _togglePin(String id) async {
    try {
      // Find summary in either list
      final allSummaries = [..._pinnedSummaries, ..._summaries];
      final summaryToToggle = allSummaries.firstWhere((s) => s.id == id);

      // Toggle pin status
      summaryToToggle.isPinned = !summaryToToggle.isPinned;

      // Update database ONLY - stream will handle UI refresh
      await _database.updateSummary(summaryToToggle);

      _showToast(
          summaryToToggle.isPinned ? 'Summary pinned' : 'Summary unpinned');
    } catch (e) {
      _showToast('Error toggling pin', isError: true);
      print('Toggle pin error: $e');
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : AppColors.gradientMiddle,
      textColor: Colors.white,
    );
  }

  Future<void> _handleRefresh() async {
    CustomBottomNavBar.updateLastMainRoute('/summaries');
    await _loadData();
  }
}
