import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

Future<String> convertFileToBase64(File file) async {
  try {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  } catch (e) {
    print('Error converting file to base64: $e');
    return '';
  }
}

Future<String> convertFileToBase64Compute(File file) {
  return compute(_convertFileToBase64, file);
}

String _convertFileToBase64(File file) {
  try {
    final bytes = file.readAsBytesSync();
    return base64Encode(bytes);
  } catch (e) {
    print('Error converting file to base64: $e');
    return '';
  }
}
