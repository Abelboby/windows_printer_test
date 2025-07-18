import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/printer_service.dart';
import 'dart:io'; // Add this import at the top

class PrinterTestScreen extends StatefulWidget {
  const PrinterTestScreen({super.key});

  @override
  State<PrinterTestScreen> createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  List<String> _printers = [];
  String? _selectedPrinter;
  String? _selectedFilePath;
  Uint8List? _pdfData;
  final List<String> _logs = [];
  bool _isBusy = false;

  void _log(String message) {
    setState(() {
      _logs.insert(0, message);
    });
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        Uint8List? fileBytes = result.files.single.bytes ?? await File(result.files.single.path!).readAsBytes();
        setState(() {
          _selectedFilePath = result.files.single.path;
          _pdfData = fileBytes;
        });
        _log('PDF selected: $_selectedFilePath');
      } else {
        _log('PDF selection cancelled.');
      }
    } catch (e) {
      _log('Error picking PDF: $e');
    }
  }

  Future<void> _getPrinters() async {
    setState(() => _isBusy = true);
    try {
      final printers = await PrinterService.getAvailablePrinters();
      setState(() {
        _printers = printers;
        if (!_printers.contains(_selectedPrinter)) {
          _selectedPrinter = _printers.isNotEmpty ? _printers.first : null;
        }
      });
      _log('Printers: ${printers.join(", ")}');
    } catch (e) {
      _log('Error getting printers: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _printPdf() async {
    if (_pdfData == null || _selectedPrinter == null) {
      _log('Select a PDF and printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.printPdf(_pdfData!, _selectedPrinter!);
      _log('Print PDF result: $result');
    } catch (e) {
      _log('Error printing PDF: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _printRichText() async {
    if (_selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.printRichTextDocument(
        '<b>Test Rich Text Print</b><br><i>Printer: $_selectedPrinter</i>',
        _selectedPrinter!,
        fontName: 'Arial',
        fontSize: 12,
      );
      _log('Print Rich Text result: $result');
    } catch (e) {
      _log('Error printing rich text: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _printRawData() async {
    if (_selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.printRawData(
        Uint8List.fromList('RAW DATA TEST\n'.codeUnits),
        _selectedPrinter!,
      );
      _log('Print Raw Data result: $result');
    } catch (e) {
      _log('Error printing raw data: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _setDefaultPrinter() async {
    if (_selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.setDefaultPrinter(_selectedPrinter!);
      _log('Set Default Printer result: $result');
    } catch (e) {
      _log('Error setting default printer: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _openPrinterProperties() async {
    if (_selectedPrinter == null) {
      _log('Select a printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.openPrinterProperties(_selectedPrinter!);
      _log('Open Printer Properties result: $result');
    } catch (e) {
      _log('Error opening printer properties: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Windows Printer Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isBusy ? null : _pickPdf,
                  child: const Text('Pick PDF'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isBusy ? null : _getPrinters,
                  child: const Text('Get Printers'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPrinter,
                    hint: const Text('Select Printer'),
                    items: _printers
                        .map((printer) => DropdownMenuItem(
                              value: printer,
                              child: Text(printer),
                            ))
                        .toList(),
                    onChanged: _isBusy ? null : (val) => setState(() => _selectedPrinter = val),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isBusy ? null : _printPdf,
                  child: const Text('Print PDF'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isBusy ? null : _printRichText,
                  child: const Text('Print Rich Text'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isBusy ? null : _printRawData,
                  child: const Text('Print Raw Data'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isBusy ? null : _setDefaultPrinter,
                  child: const Text('Set Default'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isBusy ? null : _openPrinterProperties,
                  child: const Text('Properties'),
                ),
              ],
            ),
          ),
          if (_selectedFilePath != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Selected PDF: $_selectedFilePath'),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Logger', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                reverse: true,
                itemCount: _logs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    _logs[index],
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
