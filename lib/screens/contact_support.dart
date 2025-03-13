import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SycX/utils/constants.dart';
import 'package:SycX/widgets/custom_app_bar_mini.dart';
import 'package:SycX/widgets/custom_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Contact Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: AppTextStyles.titleStyle.copyWith(
                color: AppColors.primaryTextColorDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our support team is here to assist you 24/7. Choose your preferred method of contact:',
              style: AppTextStyles.bodyTextStyle.copyWith(
                color: AppColors.secondaryTextColorDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildContactMethod(
              context,
              Icons.email,
              'Email Us',
              'info.sycx.ke@gmail.com',
              'mailto:info.sycx.ke@gmail.com',
            ),
            _buildContactMethod(
              context,
              Icons.phone,
              'Call Us',
              '+254714230692',
              'tel:+254714230692',
            ),
            _buildContactMethod(
              context,
              Icons.message,
              'Text Us',
              '+254714230692',
              'sms:+254714230692',
            ),
            _buildContactMethod(
              context,
              FontAwesomeIcons.whatsapp,
              'WhatsApp',
              '+254714230692',
              'https://wa.me/254714230692',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/contact_support',
      ),
    );
  }

  Widget _buildContactMethod(BuildContext context, IconData icon, String title,
      String details, String url) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _launchUrl(context, url, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      details,
                      style: AppTextStyles.bodyTextStyle.copyWith(
                        color: AppColors.secondaryTextColorDark,
                        fontSize: 16,
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

  void _launchUrl(BuildContext context, String url, String methodType) async {
    final Uri uri = Uri.parse(url);
    try {
      // Different handling based on URL scheme
      if (await canLaunchUrl(uri)) {
        // For most URL schemes, we want to use external application
        LaunchMode mode = LaunchMode.externalApplication;

        // For web URLs, we might want to use in-app browser if available
        if (url.startsWith('http') && !url.contains('wa.me')) {
          mode = LaunchMode.externalApplication;
        }

        await launchUrl(uri, mode: mode);
      } else {
        _handleFallback(context, uri, methodType);
      }
    } catch (e) {
      _showToast('Error launching $methodType: ${e.toString()}');
    }
  }

  void _handleFallback(BuildContext context, Uri uri, String methodType) async {
    try {
      // Specific fallbacks for different contact methods
      if (methodType == 'Email Us') {
        // Email fallback
        final String email = uri.path.replaceAll('/', '');
        final emailFallback = Uri.parse('mailto:$email');
        if (await canLaunchUrl(emailFallback)) {
          await launchUrl(emailFallback);
          return;
        }
      } else if (methodType == 'WhatsApp') {
        // WhatsApp fallback - try web version
        final String phone = uri.path.replaceAll('/', '');
        final whatsappFallback =
            Uri.parse('https://web.whatsapp.com/send?phone=$phone');
        if (await canLaunchUrl(whatsappFallback)) {
          await launchUrl(whatsappFallback,
              mode: LaunchMode.externalApplication);
          return;
        }
      } else if (methodType == 'Text Us') {
        // SMS fallback
        final String phone = uri.path.replaceAll('/', '');
        final smsFallback = Uri.parse('sms:$phone');
        if (await canLaunchUrl(smsFallback)) {
          await launchUrl(smsFallback);
          return;
        }
      } else if (methodType == 'Call Us') {
        // Call fallback
        final String phone = uri.path.replaceAll('/', '');
        final callFallback = Uri.parse('tel:$phone');
        if (await canLaunchUrl(callFallback)) {
          await launchUrl(callFallback);
          return;
        }
      }

      // If all fallbacks fail
      _showToast('Could not launch $methodType');
    } catch (e) {
      _showToast('Error with fallback: ${e.toString()}');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.gradientMiddle,
      textColor: Colors.white,
    );
  }
}
