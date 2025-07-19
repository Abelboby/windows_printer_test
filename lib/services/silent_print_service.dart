import 'dart:io';

class SilentPrintService {
  static Future<bool> printPdfSilently({
    required String sumatraPath,
    required String printerName,
    required String pdfFilePath,
  }) async {
    try {
      final command = '& "${sumatraPath}" -print-to "${printerName}" "${pdfFilePath}"';
      final result = await Process.run(
        'powershell',
        ['-Command', command],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        return true;
      } else {
        throw Exception(result.stderr);
      }
    } catch (e) {
      rethrow;
    }
  }
}
