import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sycx_flutter_app/utils/constants.dart';

class Unsplash {
  static const String _baseUrl = 'https://api.unsplash.com';

  /// Retrieve a random image URL based on the query
  ///
  /// @param query Search query for image retrieval
  /// @return Nullable image URL string
  static Future<String?> getRandomImageUrl(String query) async {
    try {
      // Sanitize the query by removing special characters and trimming
      final sanitizedQuery = query
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim()
          .substring(0, query.length > 50 ? 50 : query.length);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/photos/random?query=${Uri.encodeComponent(sanitizedQuery)}&orientation=landscape'),
        headers: {'Authorization': 'Client-ID ${Constants.accessKey}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['urls']['regular'];
      }
    } catch (e) {
      print('Error fetching Unsplash image: $e');
    }
    return null;
  }

  /// Retrieve a fallback image URL based on the file type
  ///
  /// @param fileType The file type of the original document
  /// @return Nullable image URL string
  static Future<String?> getFallbackImageUrl(String fileType) async {
    try {
      final fallbackQuery = _getFallbackQueryForFileType(fileType);
      if (fallbackQuery != null) {
        return await getRandomImageUrl(fallbackQuery);
      }
    } catch (e) {
      print('Error fetching fallback Unsplash image: $e');
    }
    return null;
  }

  /// Determine the appropriate fallback search query based on the file type
  ///
  /// @param fileType The file type of the original document
  /// @return Nullable fallback search query string
  static String? _getFallbackQueryForFileType(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'pdf document';
      case 'doc':
      case 'docx':
        return 'document';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image';
      case 'txt':
        return 'text file';
      default:
        return null;
    }
  }
}
