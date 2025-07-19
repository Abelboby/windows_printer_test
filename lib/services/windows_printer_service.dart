import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/printer_service.dart';

class WindowsPrinterService extends ChangeNotifier {
  List<String> printers = [];
  String? selectedPrinter;
  final List<String> logs = [];
  bool isBusy = false;

  void _log(String message) {
    logs.insert(0, message);
    notifyListeners();
  }

  Future<void> getList() async {
    isBusy = true;
    notifyListeners();
    try {
      printers = await PrinterService.getAvailablePrinters();
      if (!printers.contains(selectedPrinter)) {
        selectedPrinter = printers.isNotEmpty ? printers.first : null;
      }
      _log('Printers: ${printers.join(", ")}');
    } catch (e) {
      _log('Error getting printers: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void selectDevice(String printer) {
    selectedPrinter = printer;
    _log('Printer selected: $printer');
    notifyListeners();
  }

  Future<void> printPdf(Uint8List? pdfBytes) async {
    if (pdfBytes == null || selectedPrinter == null) {
      _log('Select a PDF and printer first.');
      return;
    }
    isBusy = true;
    notifyListeners();
    try {
      final result = await PrinterService.printPdf(pdfBytes, selectedPrinter!);
      _log('Print PDF result: $result');
    } catch (e) {
      _log('Error printing PDF: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> printRichText() async {
    if (selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    isBusy = true;
    notifyListeners();
    try {
      final result = await PrinterService.printRichTextDocument(
        '<b>Test Rich Text Print</b><br><i>Printer: $selectedPrinter</i>',
        selectedPrinter!,
        fontName: 'Arial',
        fontSize: 12,
      );
      _log('Print Rich Text result: $result');
    } catch (e) {
      _log('Error printing rich text: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> printRawData() async {
    if (selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    isBusy = true;
    notifyListeners();
    try {
      final result = await PrinterService.printRawData(
        Uint8List.fromList('RAW DATA TEST\n'.codeUnits),
        selectedPrinter!,
      );
      _log('Print Raw Data result: $result');
    } catch (e) {
      _log('Error printing raw data: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> setDefault() async {
    if (selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    isBusy = true;
    notifyListeners();
    try {
      final result = await PrinterService.setDefaultPrinter(selectedPrinter!);
      _log('Set Default Printer result: $result');
    } catch (e) {
      _log('Error setting default printer: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> properties() async {
    if (selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    isBusy = true;
    notifyListeners();
    try {
      final result = await PrinterService.openPrinterProperties(selectedPrinter!);
      _log('Open Printer Properties result: $result');
    } catch (e) {
      _log('Error opening printer properties: $e');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
