import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import 'dart:io';

class PrinterTestScreen extends StatefulWidget {
  final String? selectedPdfName;
  final Uint8List? selectedPdfBytes;
  const PrinterTestScreen({super.key, this.selectedPdfName, this.selectedPdfBytes});

  @override
  State<PrinterTestScreen> createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  List<String> _printers = [];
  String? _selectedPrinter;
  final List<String> _logs = [];
  bool _isBusy = false;

  void _log(String message) {
    setState(() {
      _logs.insert(0, message);
    });
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
    if (widget.selectedPdfBytes == null || _selectedPrinter == null) {
      _log('Select a PDF and printer first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final result = await PrinterService.printPdf(widget.selectedPdfBytes!, _selectedPrinter!);
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

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 170,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildActionButton(
                          icon: Icons.print, label: 'Get Printers', onPressed: _isBusy ? null : _getPrinters),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedPrinter,
                          decoration: const InputDecoration(
                            labelText: 'Select Printer',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _printers
                              .map((printer) => DropdownMenuItem(
                                    value: printer,
                                    child: Text(printer, style: const TextStyle(color: Colors.black)),
                                  ))
                              .toList(),
                          onChanged: _isBusy
                              ? null
                              : (val) {
                                  setState(() => _selectedPrinter = val);
                                  if (val != null) {
                                    _log('Printer selected: $val');
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  if (widget.selectedPdfName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Selected PDF: ${widget.selectedPdfName}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                      icon: Icons.picture_as_pdf, label: 'Print PDF', onPressed: _isBusy ? null : _printPdf),
                  const SizedBox(width: 16),
                  _buildActionButton(
                      icon: Icons.text_fields, label: 'Print Rich Text', onPressed: _isBusy ? null : _printRichText),
                  const SizedBox(width: 16),
                  _buildActionButton(
                      icon: Icons.code, label: 'Print Raw Data', onPressed: _isBusy ? null : _printRawData),
                  const SizedBox(width: 16),
                  _buildActionButton(
                      icon: Icons.star, label: 'Set Default', onPressed: _isBusy ? null : _setDefaultPrinter),
                  const SizedBox(width: 16),
                  _buildActionButton(
                      icon: Icons.settings, label: 'Properties', onPressed: _isBusy ? null : _openPrinterProperties),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Logger',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(color: Colors.white, fontFamily: 'Fira Mono, monospace', fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
