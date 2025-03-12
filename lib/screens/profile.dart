import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/models/user.dart' as app_user;
import 'package:sycx_flutter_app/services/database.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';
import 'package:sycx_flutter_app/screens/edit_profile.dart';
import 'package:sycx_flutter_app/screens/account_settings.dart';
import 'package:sycx_flutter_app/screens/data_access.dart';
import 'package:sycx_flutter_app/screens/help_center.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _animationController;
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
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Fetch user data using the database service
        final user = await _database.getUser(firebaseUser.uid);

        setState(() {
          userData = user;
          _loading = false;
        });

        _animationController.forward();
      } else {
        // Handle case where no user is logged in
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _loading = false;
      });
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
      appBar: const CustomAppBarMini(title: 'Profile'),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: userData != null ? _buildBody() : _buildNoUserContent(),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/profile',
      ),
    );
  }

  Widget _buildNoUserContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No user data available',
              style: AppTextStyles.titleStyle.copyWith(
                color: AppColors.primaryTextColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildProfileHeader(),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 3,
                child: _buildInfoCard(),
              ),
            ],
          ),
        ),
        _buildSettings(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    if (userData == null) return Container();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryButtonColor,
                  width: 3,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData!.profileImage ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userData!.name,
              style: AppTextStyles.titleStyle.copyWith(
                color: AppColors.primaryTextColorDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '@${userData!.userName}',
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.secondaryTextColorDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(userData: userData!),
                  ),
                );
                if (result != null) {
                  setState(() {
                    userData = result;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: AppColors.primaryButtonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Overview',
                style: AppTextStyles.titleStyle
                    .copyWith(color: AppColors.primaryTextColorDark)),
            const SizedBox(height: 8), // Reduced spacing
            Text(
              'Manage your account and settings.',
              style: AppTextStyles.bodyTextStyle
                  .copyWith(color: AppColors.secondaryTextColorDark),
            ),
            const SizedBox(height: 10),
            for (var item in [
              'Edit profile',
              'Manage settings',
              'Control data',
              'Support'
            ]) // Condensed item labels
              _buildInfoItem(item),
            const SizedBox(height: 10),
            Text(
              'Need help? Go to Help Center.',
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.altPriTextColorDark,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: AppColors.primaryButtonColor),
          const SizedBox(width: defaultPadding / 2),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyTextStyle
                    .copyWith(color: AppColors.secondaryTextColorDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Settings',
            style: AppTextStyles.titleStyle.copyWith(
              color: AppColors.primaryTextColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildSettingItem(
          'Account Settings',
          'Manage your account details and preferences',
          Icons.person,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountSettings()),
            );
          },
        ),
        _buildSettingItem(
          'Access to Data',
          'View and manage your personal data',
          Icons.data_usage,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataAccess()),
            );
          },
        ),
        _buildSettingItem(
          'Help Center',
          'Get support and answers to your questions',
          Icons.help,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenter()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem(
      String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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

  Future<void> _handleRefresh() async {
    await _loadData();
  }
}
