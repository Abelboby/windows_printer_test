import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:print_usb/model/usb_device.dart';
import 'package:print_usb/print_usb.dart';

class PrinterUsbScreen extends StatefulWidget {
  final String? selectedPdfName;
  final Uint8List? selectedPdfBytes;
  const PrinterUsbScreen({super.key, this.selectedPdfName, this.selectedPdfBytes});

  @override
  State<PrinterUsbScreen> createState() => _PrinterUsbScreenState();
}

class _PrinterUsbScreenState extends State<PrinterUsbScreen> {
  List<UsbDevice> _devices = [];
  UsbDevice? _connectedDevice;
  final List<String> _logs = [];
  bool _isBusy = false;

  void _log(String message) {
    setState(() {
      _logs.insert(0, message);
    });
  }

  Future<void> _getDevices() async {
    setState(() => _isBusy = true);
    try {
      final devices = await PrintUsb.getList();
      setState(() {
        _devices = devices;
      });
      _log('Devices: ${devices.map((d) => d.name).join(", ")}');
    } catch (e) {
      _log('Error getting devices: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _connectDevice(UsbDevice device) async {
    setState(() => _isBusy = true);
    try {
      bool result = await PrintUsb.connect(name: device.name);
      if (result) {
        setState(() {
          _connectedDevice = device;
        });
        _log('Connected to: ${device.name}');
      } else {
        _log('Failed to connect: ${device.name}');
      }
    } catch (e) {
      _log('Error connecting: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _printTest(UsbDevice device) async {
    setState(() => _isBusy = true);
    try {
      String paperFeed = '\x1B\x64\x04';
      String cutPaper = '\x1D\x56\x00';
      List<int> bytes = "Hello developer flutter $paperFeed $cutPaper".codeUnits;
      bool result = await PrintUsb.printBytes(bytes: bytes, device: device);
      if (result) {
        _log('Printed to: ${device.name}');
      } else {
        _log('Print failed for: ${device.name}');
      }
    } catch (e) {
      _log('Error printing: $e');
    } finally {
      setState(() => _isBusy = false);
    }
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
              child: Row(
                children: [
                  SizedBox(
                    width: 170,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isBusy ? null : _getDevices,
                      icon: const Icon(Icons.usb, color: Colors.black),
                      label: const Text('Get Devices', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Devices',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          final isConnected = _connectedDevice != null && _connectedDevice!.name == device.name;
                          return Card(
                            color: isConnected ? Colors.black12 : Colors.white,
                            child: ListTile(
                              onTap: _isBusy ? null : () => _connectDevice(device),
                              title: Text(device.name, style: const TextStyle(color: Colors.black)),
                              subtitle: Text(device.model, style: const TextStyle(color: Colors.black54)),
                              leading: Text(device.available.toString(), style: const TextStyle(color: Colors.black)),
                              trailing: isConnected
                                  ? IconButton(
                                      onPressed: _isBusy ? null : () => _printTest(device),
                                      icon: const Icon(Icons.print, color: Colors.black),
                                    )
                                  : const SizedBox(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                    height: 120,
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
