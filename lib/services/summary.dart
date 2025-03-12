import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sycx_flutter_app/services/api_client.dart';
import 'package:sycx_flutter_app/services/cloudinary.dart';
import 'package:sycx_flutter_app/services/database.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/utils/secure_storage.dart';
import 'package:sycx_flutter_app/models/summary.dart';

class SummaryService {
  static final ApiClient apiClient =
      ApiClient(httpClient: http.Client(), baseUrl: Constants.baseUrl);
  static final Database database = Database();

  /// Handles document summarization for a single file
  static Future<List<Summary>> summarizeDocuments({
    required List<File> files,
    required double summaryDepth,
    required String userId,
  }) async {
    try {
      if (files.isEmpty) throw Exception('No files provided');
      final file = files.first; // Get the single uploaded file

      // Prepare multipart request for the summarization API
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.baseUrl}/summarize'),
      );

      // Add fields
      request.fields.addAll({
        'summary_depth': summaryDepth.toString(),
        'user_id': userId,
      });

      // Send the file directly to the API
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        if (responseJson['status'] != 'success') {
          throw Exception('Summarization failed: ${responseJson['message']}');
        }

        // AFTER API response is successful, upload to Cloudinary
        final fileUrl = await Cloudinary.uploadFile(
          file,
          title: path.basename(file.path),
        );

        if (fileUrl == null) {
          print(
              'Warning: Failed to upload file to Cloudinary, continuing without file URL');
        }

        // Create original document with Cloudinary URL (if available)
        final originalDocuments = [
          OriginalDocument(
            title: path.basename(file.path),
            fileUrl: fileUrl, // This will be null if Cloudinary upload failed
            type: path.extension(file.path).replaceFirst('.', ''),
          )
        ];

        // Create summary from response data
        final summary = Summary(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          originalDocuments: originalDocuments,
          pdfUrl: responseJson['pdf_url'],
          title: responseJson['title'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to DB and return
        await database.createSummary(summary);
        return [summary];
      } else {
        throw Exception('Failed to summarize: ${response.body}');
      }
    } catch (e) {
      print('Error in summarizeDocuments: $e');
      rethrow;
    }
  }

  // Existing feedback method remains unchanged
  static Future<void> giveFeedback(
    String summaryId,
    String userId,
    String feedback,
    String pdfUrl,
  ) async {
    final token = await SecureStorage.getToken();
    final response = await apiClient.post(
      '/feedback',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'summary_id': summaryId,
        'user_id': userId,
        'feedback': feedback,
        'summary_content': pdfUrl,
      }),
      authRequired: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit feedback: ${response.body}');
    }
  }
}
