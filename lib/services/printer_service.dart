import 'dart:typed_data';
import 'package:windows_printer/windows_printer.dart';

class PrinterService {
  static Future<List<String>> getAvailablePrinters() async {
    return await WindowsPrinter.getAvailablePrinters();
  }

  static Future<dynamic> printPdf(Uint8List pdfData, String printerName) async {
    return await WindowsPrinter.printPdf(data: pdfData, printerName: printerName);
  }

  static Future<dynamic> printRichTextDocument(String content, String printerName,
      {String fontName = 'Arial', int fontSize = 12}) async {
    return await WindowsPrinter.printRichTextDocument(
      content: content,
      printerName: printerName,
      fontName: fontName,
      fontSize: fontSize,
    );
  }

  static Future<dynamic> printRawData(Uint8List data, String printerName) async {
    return await WindowsPrinter.printRawData(data: data, printerName: printerName);
  }

  static Future<dynamic> setDefaultPrinter(String printerName) async {
    return await WindowsPrinter.setDefaultPrinter(printerName);
  }

  static Future<dynamic> openPrinterProperties(String printerName) async {
    return await WindowsPrinter.openPrinterProperties(printerName);
  }
}
