import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/windows_printer_service.dart';

class PdfToPrinterScreen extends StatefulWidget {
  const PdfToPrinterScreen({super.key});

  @override
  State<PdfToPrinterScreen> createState() => _PdfToPrinterScreenState();
}

class _PdfToPrinterScreenState extends State<PdfToPrinterScreen> {
  String? _pdfPath;
  String? _pdfName;
  String? _selectedPrinter;
  bool _isPrinting = false;
  String? _log;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfPath = result.files.single.path;
        _pdfName = result.files.single.name;
      });
    }
  }

  Future<void> _printWithPdfToPrinter() async {
    if (_pdfPath == null || _selectedPrinter == null) {
      setState(() {
        _log = 'Select a PDF and printer first.';
      });
      return;
    }
    setState(() {
      _isPrinting = true;
      _log = null;
    });
    try {
      // Debug: Print current directory
      print('Current directory: ${Directory.current.path}');

      // For development and release builds, try these paths
      final possiblePaths = [
        'assets/PDFtoPrinter.exe',
        'data/flutter_assets/assets/PDFtoPrinter.exe',
        'flutter_assets/assets/PDFtoPrinter.exe',
        'PDFtoPrinter.exe',
        'windows/runner/resources/PDFtoPrinter.exe',
      ];

      String? exePath;
      for (final path in possiblePaths) {
        final file = File(path);
        print('Checking path: ${file.absolute.path}');
        if (await file.exists()) {
          exePath = file.absolute.path;
          print('Found PDFtoPrinter.exe at: $exePath');
          break;
        } else {
          print('File not found at: ${file.absolute.path}');
        }
      }

      if (exePath == null) {
        // List all files in current directory for debugging
        final currentDir = Directory.current;
        print('Files in current directory:');
        await for (final entity in currentDir.list()) {
          print('  ${entity.path}');
        }
        throw Exception('PDFtoPrinter.exe not found. Tried paths: ${possiblePaths.join(', ')}');
      }

      final args = [
        _pdfPath!,
        _selectedPrinter!,
      ];
      print('Running: $exePath ${args.join(' ')}');
      final result = await Process.run(exePath, args, runInShell: true);
      if (result.exitCode == 0) {
        setState(() {
          _log = '✅ Print command sent successfully.';
        });
      } else {
        setState(() {
          _log = '❌ Print failed: ${result.stderr ?? result.stdout}';
        });
      }
    } catch (e) {
      setState(() {
        _log = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WindowsPrinterService>(
      create: (_) => WindowsPrinterService()..getList(),
      child: Consumer<WindowsPrinterService>(
        builder: (context, printerService, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isPrinting ? null : _pickPdf,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                      label: Text(_pdfName ?? 'Pick PDF', style: const TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isPrinting ? null : printerService.getList,
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: const Text('Refresh Printers', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Available Printers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: printerService.isBusy
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: printerService.printers.length,
                          itemBuilder: (context, index) {
                            final printer = printerService.printers[index];
                            final isSelected = _selectedPrinter == printer;
                            return Card(
                              color: isSelected ? Colors.black12 : Colors.white,
                              child: ListTile(
                                title: Text(printer, style: const TextStyle(color: Colors.black)),
                                trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
                                onTap: _isPrinting
                                    ? null
                                    : () {
                                        setState(() => _selectedPrinter = printer);
                                      },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPrinting ? null : _printWithPdfToPrinter,
                    icon: _isPrinting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.print, color: Colors.black),
                    label: const Text('Print with PDFtoPrinter', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (_log != null) ...[
                  const SizedBox(height: 24),
                  Text(_log!, style: TextStyle(color: _log!.startsWith('✅') ? Colors.green : Colors.red)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
