import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:path/path.dart' as path;

class Cloudinary {
  static Future<String?> uploadFile(File file, {String? title}) async {
    try {
      // Prepare the file name
      final fileName = title ?? path.basename(file.path);
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId = '${fileName}_$uniqueId'.replaceAll(' ', '_');

      // Create timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature
      final signature = _generateSignature({
        'public_id': publicId,
        'folder': 'SycX Files',
        'timestamp': timestamp.toString(),
      });

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${Constants.cloudinaryCloudName}/auto/upload'),
      );

      // Add fields
      request.fields.addAll({
        'api_key': Constants.cloudinaryApiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
        'folder': 'SycX Files',
        'public_id': publicId,
        'overwrite': 'true',
        'context': 'author=SycX AI',
      });

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        return responseJson['secure_url'];
      } else {
        print('Cloudinary upload error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  static String _generateSignature(Map<String, String> params) {
    // Sort params by key
    final sortedKeys = params.keys.toList()..sort();

    // Create string to sign
    String stringToSign = '';
    for (var key in sortedKeys) {
      stringToSign += '$key=${params[key]}&';
    }

    // Append API secret
    stringToSign += Constants.cloudinaryApiSecret;

    // Create signature
    return sha1.convert(utf8.encode(stringToSign)).toString();
  }
}
