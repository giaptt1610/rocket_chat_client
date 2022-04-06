import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<File?> downloadFile(
    String fileUrl, {
    void Function(int, int?)? onByteReceived,
  }) async {
    HttpClient httpClient = HttpClient();
    File? file;
    String filePath = '';

    try {
      final imageUri = Uri.parse(fileUrl);
      final _fileName = fileUrl.split('/').last;

      var request = await httpClient.getUrl(imageUri);
      var response = await request.close();
      if (response.statusCode != 200) {
        print('Error code: ' + response.statusCode.toString());
        return null;
      }

      var bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: onByteReceived,
      );

      if (Platform.isIOS) {
        final documents = await getApplicationDocumentsDirectory();
        print('-- doc dir: ${documents.path}');
        filePath = '${documents.path}/$_fileName';
      } else if (Platform.isAndroid) {
        final externalStorage = await getExternalStorageDirectories();
        if (externalStorage != null) {
          final dir = externalStorage.firstWhere(
              (element) => element.path.contains('/storage/emulated'));

          print('-- doc dir: ${dir.path}');
          filePath = '${dir.path}/$_fileName';
        }
      }

      file = File(filePath);
      await file.writeAsBytes(bytes);
    } catch (ex) {
      print('-- Exception: ${ex.toString()}');
      return null;
    }
    return file;
  }
}
