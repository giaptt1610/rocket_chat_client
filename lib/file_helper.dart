import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FileHelper {
  static Future<List<PlatformFile>> chooseFiles({
    List<String>? extensions,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: extensions,
      type: extensions != null ? FileType.custom : FileType.any,
    );

    if (result != null) {
      // final files = result.paths.map((path) => File(path!)).toList();
      final platformFiles = result.files;

      return platformFiles;
    } else {
      // User canceled the picker
      return [];
    }
  }

  static Future<List<File>> chooseImages() async {
    final ImagePicker _picker = ImagePicker();
    final images = await _picker.pickMultiImage();

    if (images != null) {
      return images.map((e) => File(e.path)).toList();
    }
    return [];
  }
}
