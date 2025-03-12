import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:SycX/firebase_options.dart';
import 'package:SycX/models/summary.dart';
import 'package:SycX/screens/account_settings.dart';
import 'package:SycX/screens/auth/forgot_password.dart';
import 'package:SycX/screens/auth/login.dart';
import 'package:SycX/screens/auth/register.dart';
import 'package:SycX/screens/contact_support.dart';
import 'package:SycX/screens/data_access.dart';
import 'package:SycX/screens/data_usage.dart';
import 'package:SycX/screens/download_data.dart';
import 'package:SycX/screens/edit_profile.dart';
import 'package:SycX/screens/frequent_questions.dart';
import 'package:SycX/screens/help_center.dart';
import 'package:SycX/screens/profile.dart';
import 'package:SycX/screens/search_results.dart';
import 'package:SycX/screens/splash.dart';
import 'package:SycX/screens/summaries.dart';
import 'package:SycX/screens/summary_details.dart';
import 'package:SycX/screens/upload.dart';
import 'package:SycX/screens/user_guide.dart';
import 'package:SycX/screens/view_summary.dart';
import 'package:SycX/screens/welcome.dart';
import 'package:SycX/screens/home.dart';
import 'package:SycX/screens/your_data.dart';
import 'package:SycX/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await Auth.initializeTokenExpirationTask();
    print('Token expiration task initialized successfully');
  } catch (e) {
    print('Error initializing token expiration task: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SycX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Splash(),
      routes: {
        '/welcome': (context) => const Welcome(),
        '/register': (context) => const Register(),
        '/login': (context) => const Login(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/home': (context) => const Home(),
        '/search': (context) => const SearchResults(searchQuery: ''),
        '/summary_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return SummaryDetails(
            summary: args['summary'],
            imageUrl: args['imageUrl'] ?? '',
          );
        },
        '/view_summary': (context) {
          final summary = ModalRoute.of(context)!.settings.arguments as Summary;
          return ViewSummary(summary: summary);
        },
        '/upload': (context) => const Upload(),
        '/summaries': (context) => const Summaries(),
        '/profile': (context) => const Profile(),
        '/edit_profile': (context) => const EditProfile(
              userData: null,
            ),
        '/account_settings': (context) => const AccountSettings(),
        '/data_access': (context) => const DataAccess(),
        '/your_data': (context) => const YourData(),
        '/download_data': (context) => const DownloadData(),
        '/data_usage': (context) => const DataUsage(),
        '/help_center': (context) => const HelpCenter(),
        '/frequent_questions': (context) => const FrequentQuestions(),
        '/contact_support': (context) => const ContactSupport(),
        '/user_guide': (context) => const UserGuide(),
      },
    );
  }
}
