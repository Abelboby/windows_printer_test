import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'screens/printer_test_screen.dart';
import 'screens/printer_usb_screen.dart';
import 'services/pdf_picker_service.dart';

void main() {
  runApp(const PrinterApp());
}

class PrinterApp extends StatelessWidget {
  const PrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const PrinterHomeScreen(),
    );
  }
}

class PrinterHomeScreen extends StatefulWidget {
  const PrinterHomeScreen({super.key});

  @override
  State<PrinterHomeScreen> createState() => _PrinterHomeScreenState();
}

class _PrinterHomeScreenState extends State<PrinterHomeScreen> {
  int _selectedIndex = 0;
  String? _selectedPdfName;
  Uint8List? _selectedPdfBytes;

  Future<void> _pickPdf() async {
    final result = await PdfPickerService.pickPdf();
    if (result != null) {
      setState(() {
        _selectedPdfName = result['name'] as String?;
        _selectedPdfBytes = result['bytes'] as Uint8List?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PrinterTestScreen(
        selectedPdfName: _selectedPdfName,
        selectedPdfBytes: _selectedPdfBytes,
      ),
      PrinterUsbScreen(
        selectedPdfName: _selectedPdfName,
        selectedPdfBytes: _selectedPdfBytes,
      ),
    ];
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.grey[100],
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.print, color: Colors.black),
                selectedIcon: Icon(Icons.print, color: Colors.black),
                label: Text('Windows Printer', style: TextStyle(color: Colors.black)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.usb, color: Colors.black),
                selectedIcon: Icon(Icons.usb, color: Colors.black),
                label: Text('USB Printer', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedIndex == 0 ? '🖨️ Windows Printer' : 'USB Printer',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    if (_selectedPdfName != null)
                      Text(
                        'Selected PDF: $_selectedPdfName',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                  ],
                ),
                backgroundColor: Colors.white,
                elevation: 2,
                iconTheme: const IconThemeData(color: Colors.black),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                    tooltip: 'Pick PDF',
                    onPressed: _pickPdf,
                  ),
                ],
              ),
              body: screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
