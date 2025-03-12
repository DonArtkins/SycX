import 'package:http/http.dart' as http;
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/utils/secure_storage.dart';

class ApiClient {
  final http.Client httpClient;
  static const int maxChunkSize = 1024 * 1024; // 1MB chunks
  final String baseUrl; // Add baseUrl as an instance variable

  // Update constructor to accept baseUrl with a default value from constants
  ApiClient({required this.httpClient, String? baseUrl})
      : baseUrl = baseUrl ?? Constants.baseUrl;

  Uri buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool authRequired = false,
  }) async {
    final uri = buildUri(endpoint);
    final defaultHeaders = await _getHeaders(authRequired);
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return await httpClient.post(
      uri,
      headers: defaultHeaders,
      body: body,
    );
  }

  Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required Map<String, String> files,
    Map<String, String>? headers,
    bool authRequired = false,
    Function(double)? onProgress,
  }) async {
    final uri = buildUri(endpoint);
    final request = http.MultipartRequest('POST', uri);

    // Add headers
    final defaultHeaders = await _getHeaders(authRequired);
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    request.headers.addAll(defaultHeaders);

    // Add fields
    request.fields.addAll(fields);

    // Add files
    int totalBytes = 0;
    int processedBytes = 0;

    for (var entry in files.entries) {
      final content = entry.value;
      final totalChunks = (content.length / maxChunkSize).ceil();
      totalBytes += content.length;

      for (int i = 0; i < totalChunks; i++) {
        final start = i * maxChunkSize;
        final end = (i + 1) * maxChunkSize < content.length
            ? (i + 1) * maxChunkSize
            : content.length;
        final chunk = content.substring(start, end);

        request.files.add(
          http.MultipartFile.fromString(
            '${entry.key}_chunk_$i',
            chunk,
            filename: '${entry.key}_chunk_$i.txt',
          ),
        );

        processedBytes += chunk.length;
        onProgress?.call(processedBytes / totalBytes);
      }
    }

    return await request.send();
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    bool authRequired = false,
  }) async {
    final uri = buildUri(endpoint);
    final defaultHeaders = await _getHeaders(authRequired);
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await httpClient.get(
      uri,
      headers: defaultHeaders,
    );

    _handleErrors(response);
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool authRequired = false,
  }) async {
    final uri = buildUri(endpoint);
    final defaultHeaders = await _getHeaders(authRequired);
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await httpClient.put(
      uri,
      headers: defaultHeaders,
      body: body,
    );

    _handleErrors(response);
    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool authRequired = false,
  }) async {
    final uri = buildUri(endpoint);
    final defaultHeaders = await _getHeaders(authRequired);
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await httpClient.delete(
      uri,
      headers: defaultHeaders,
    );

    _handleErrors(response);
    return response;
  }

  Future<http.Response> getStreamedResponse(
      http.StreamedResponse streamedResponse) async {
    return await http.Response.fromStream(streamedResponse);
  }

  Future<Map<String, String>> _getHeaders(bool authRequired) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authRequired) {
      String? token = await SecureStorage.getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
