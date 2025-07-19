import 'package:flutter/material.dart';
import '../services/silent_print_service.dart';

class SilentPrintScreen extends StatefulWidget {
  const SilentPrintScreen({Key? key}) : super(key: key);

  @override
  _SilentPrintScreenState createState() => _SilentPrintScreenState();
}

class _SilentPrintScreenState extends State<SilentPrintScreen> {
  final TextEditingController _pdfPathController = TextEditingController();
  final TextEditingController _printerNameController = TextEditingController();
  final TextEditingController _sumatraPathController =
      TextEditingController(text: r'C:\Users\Abel Boby\AppData\Local\SumatraPDF\SumatraPDF.exe');
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _pdfPathController.dispose();
    _printerNameController.dispose();
    _sumatraPathController.dispose();
    super.dispose();
  }

  Future<void> _handlePrint() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final success = await SilentPrintService.printPdfSilently(
        sumatraPath: _sumatraPathController.text.trim(),
        printerName: _printerNameController.text.trim(),
        pdfFilePath: _pdfPathController.text.trim(),
      );
      setState(() {
        _message = success ? '✅ Print command sent successfully' : '❌ Failed to print';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: \\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silent PDF Print')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pdfPathController,
              decoration: const InputDecoration(
                labelText: 'PDF File Path',
                hintText: r'C:\Users\Abel Boby\Documents\invoice.pdf',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _printerNameController,
              decoration: const InputDecoration(
                labelText: 'Printer Name',
                hintText: 'HP LaserJet P1108',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sumatraPathController,
              decoration: const InputDecoration(
                labelText: 'SumatraPDF Path',
                hintText: r'C:\Users\Abel Boby\AppData\Local\SumatraPDF\SumatraPDF.exe',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePrint,
                child: _isLoading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Print Silently'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 24),
              Text(_message!, style: TextStyle(color: _message!.startsWith('✅') ? Colors.green : Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
