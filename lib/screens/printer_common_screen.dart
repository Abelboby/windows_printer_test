import 'package:flutter/material.dart';

class PrinterCommonScreen extends StatelessWidget {
  final List<String> devices;
  final String? selectedDevice;
  final VoidCallback onGetList;
  final ValueChanged<String> onSelectDevice;
  final VoidCallback onPrintPdf;
  final VoidCallback onPrintRichText;
  final VoidCallback onPrintRawData;
  final VoidCallback onSetDefault;
  final VoidCallback onProperties;
  final List<String> logs;
  final bool isBusy;
  final String? selectedPdfName;

  const PrinterCommonScreen({
    super.key,
    required this.devices,
    required this.selectedDevice,
    required this.onGetList,
    required this.onSelectDevice,
    required this.onPrintPdf,
    required this.onPrintRichText,
    required this.onPrintRawData,
    required this.onSetDefault,
    required this.onProperties,
    required this.logs,
    required this.isBusy,
    this.selectedPdfName,
  });

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 150,
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
                  _buildActionButton(icon: Icons.print, label: 'Get List', onPressed: isBusy ? null : onGetList),
                  const SizedBox(width: 12),
                  _buildActionButton(
                      icon: Icons.picture_as_pdf, label: 'Print PDF', onPressed: isBusy ? null : onPrintPdf),
                  const SizedBox(width: 12),
                  _buildActionButton(
                      icon: Icons.text_fields, label: 'Print Rich Text', onPressed: isBusy ? null : onPrintRichText),
                  const SizedBox(width: 12),
                  _buildActionButton(
                      icon: Icons.code, label: 'Print Raw Data', onPressed: isBusy ? null : onPrintRawData),
                  const SizedBox(width: 12),
                  _buildActionButton(icon: Icons.star, label: 'Set Default', onPressed: isBusy ? null : onSetDefault),
                  const SizedBox(width: 12),
                  _buildActionButton(
                      icon: Icons.settings, label: 'Properties', onPressed: isBusy ? null : onProperties),
                ],
              ),
            ),
          ),
          if (selectedPdfName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Selected PDF: $selectedPdfName', style: const TextStyle(color: Colors.black54)),
              ),
            ),
          Card(
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
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isSelected = selectedDevice == device;
                        return Card(
                          color: isSelected ? Colors.black12 : Colors.white,
                          child: ListTile(
                            title: Text(device, style: const TextStyle(color: Colors.black)),
                            trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
                            onTap: isBusy ? null : () => onSelectDevice(device),
                          ),
                        );
                      },
                    ),
                  ),
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
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: logs.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          logs[index],
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
