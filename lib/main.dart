import 'package:flutter/material.dart';
import 'screens/printer_test_screen.dart';

void main() {
  runApp(const PrinterTestApp());
}

class PrinterTestApp extends StatelessWidget {
  const PrinterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Windows Printer Test',
      home: const PrinterTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
