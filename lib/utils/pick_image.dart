import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PickImage {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduce quality for faster upload
      );

      if (image != null) {
        File file = File(image.path);
        return await _compressImage(file);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Reduce quality for faster upload
      );

      if (image != null) {
        File file = File(image.path);
        return await _compressImage(file);
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
    return null;
  }

  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 70,
      );

      if (result != null) {
        return File(result.path);
      } else {
        // Return original file if compression fails
        return file;
      }
    } catch (e) {
      print('Error compressing image: $e');
      // Return original file if compression fails
      return file;
    }
  }
}
