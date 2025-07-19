import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class PdfPickerService {
  static Future<Map<String, dynamic>?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        Uint8List? fileBytes = result.files.single.bytes ?? await File(result.files.single.path!).readAsBytes();
        return {
          'name': result.files.single.name,
          'bytes': fileBytes,
        };
      }
    } catch (e) {
      // Optionally handle error
    }
    return null;
  }
}
