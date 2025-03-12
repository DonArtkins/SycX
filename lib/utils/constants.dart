import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Create a constants class to encapsulate constants
class Constants {
  // static const String baseUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'https://sycx-api.up.railway.app/api/v1';
  // static const String baseUrl = 'https://sycx.onrender.com';
  static const String accessKey = 'fBRa_VPz4YX_PYCkqNEJteeQJoLxe8MbQLDDDc436EE';
  // Cloudinary configuration
  static const String cloudinaryCloudName = 'dqyzd8vqh';
  static const String cloudinaryApiKey = '579729122399143';
  static const String cloudinaryApiSecret = 'XKn_LQgr8LA4sxNVSR-_Om-KZIo';
}

// Create an instance for easier access
final constants = Constants();

class AppColors {
  static const Color gradientStart = Color(0xFF6A11CB);
  static const Color gradientMiddle = Color(0xFFBC4E9C);
  static const Color gradientEnd = Color(0xFFF56565);

  static const Color primaryButtonColor = Color(0xFF3498DB);
  static const Color secondaryButtonColor = Color(0xFF2C3E50);
  static const Color primaryButtonTextColor = Colors.white;
  static const Color secondaryButtonTextColor = Colors.white;

  static const Color textFieldBorderColor = Color(0xFF4A5568);
  static const Color textFieldFillColor = Color(0xFF2D3748);

  static const Color primaryTextColor = Colors.white;
  static const Color primaryTextColorDark = Colors.black;
  static const Color secondaryTextColor = Color(0xFFA0AEC0);
  static const Color secondaryTextColorDark = Color(0xFF4A5568);
  static const Color altPriTextColor = Color(0xFFD0D8E0);
  static const Color altPriTextColorDark = Color(0xFF718096);
}

class AppTextStyles {
  static final TextStyle headingStyleWithShadow = GoogleFonts.exo2(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final TextStyle headingStyleNoShadow = GoogleFonts.exo2(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static final TextStyle subheadingStyle = GoogleFonts.exo2(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.altPriTextColor,
  );

  static final TextStyle titleStyle = GoogleFonts.exo2(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryTextColorDark,
  );

  static final TextStyle titleStyleX = GoogleFonts.exo2(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryTextColorDark,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.exo2(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle bodyTextStyle = GoogleFonts.exo2(
    fontSize: 16,
    color: AppColors.primaryTextColor,
  );
}

const double defaultPadding = 16.0;
const double defaultMargin = 16.0;
const Duration animationDuration = Duration(milliseconds: 300);
