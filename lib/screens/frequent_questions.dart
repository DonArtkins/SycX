import 'package:flutter/material.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar_mini.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';

class FrequentQuestions extends StatelessWidget {
  const FrequentQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarMini(title: 'Frequently Asked Questions(FAQ)'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFAQItem(
            'What is SycX?',
            'SycX is an innovative AI-powered summarization app that helps you quickly digest long texts by providing concise, accurate summaries.',
          ),
          _buildFAQItem(
            'How does SycX work?',
            'SycX uses advanced natural language processing algorithms to analyze text and extract the most important information, creating a coherent and concise summary. In addition to all these, we have the golden functionality of adding relevant images and graphics to make summaries more interesting and easy to recall.',
          ),
          _buildFAQItem(
            'What types of content can I summarize with SycX?',
            'SycX can summarize a wide range of content, including articles, research papers, reports, news stories, and even lengthy emails or documents.',
          ),
          _buildFAQItem(
            'How accurate are the summaries?',
            'SycX generates highly accurate summaries, capturing the main points and key details of the original text. However, for critical information, we recommend reviewing the full text as well.',
          ),
          _buildFAQItem(
            'Can I customize the summary length?',
            'Yes, SycX offers flexible summarization options. You can adjust the summary depth in the upload screen when uploading documents to get shorter or more detailed summaries based on your preferences.',
          ),
          _buildFAQItem(
            'What file formats does SycX support?',
            'SycX supports various text-based formats including .txt, .pdf, .docx, .png, .jpeg, .jpg, .epub, and many other file types.',
          ),
          _buildFAQItem(
            'Is my data secure when using SycX?',
            'Absolutely. We prioritize data security and privacy. All uploaded documents and generated summaries are encrypted in transit and at rest. We don\'t store your original documents or summaries permanently on our servers.',
          ),
          _buildFAQItem(
            'Can I use SycX offline?',
            'While an internet connection is required for optimal performance, SycX offers a limited offline mode for previously processed documents.',
          ),
          _buildFAQItem(
            'How does SycX handle different languages?',
            'At the moment, SycX supports only English and is able to generate summaries in the same language as the input text, but in later versions we plan to make sure it can support multiple languages.',
          ),
          _buildFAQItem(
            'Is there a limit to how much text I can summarize?',
            'SycX can handle large volumes of text without any limitations.',
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/frequent_questions',
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
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
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: AppTextStyles.bodyTextStyle.copyWith(
              color: AppColors.primaryTextColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
