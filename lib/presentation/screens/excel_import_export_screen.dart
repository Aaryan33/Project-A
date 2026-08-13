import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';

import '../../data/services/excel_service.dart';
import '../../data/services/pdf_export_service.dart';
import '../providers/order_providers.dart';
import '../widgets/custom_app_bar.dart';

class ExcelImportExportScreen extends ConsumerStatefulWidget {
  const ExcelImportExportScreen({super.key});

  @override
  ConsumerState<ExcelImportExportScreen> createState() => _ExcelImportExportScreenState();
}

class _ExcelImportExportScreenState extends ConsumerState<ExcelImportExportScreen> {
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Excel & Data Management',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.slateNavy, AppColors.darkCard],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentOrange.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.table_chart_rounded, color: AppColors.accentOrange, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excel Spreadsheet Integration',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Seamlessly replace Excel files, import bulk rows to Firestore, and export formatted reports.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              '1. Import Spreadsheet Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload .xlsx or .csv files containing Date, Vehicle, From, To, Material, Quantity, and Company columns.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickAndImportFile,
                      icon: const Icon(Icons.file_upload_rounded),
                      label: const Text('SELECT EXCEL / CSV FILE', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. Export Filtered Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredOrders.length} Records Selected',
                    style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildExportTile(
              context,
              title: 'Export to Excel (.xlsx)',
              subtitle: 'Full raw data formatted in Excel table with column headers',
              icon: Icons.table_view_rounded,
              color: AppColors.statusDelivered,
              onTap: () => _exportExcel(filteredOrders),
            ),
            const SizedBox(height: 12),
            _buildExportTile(
              context,
              title: 'Export to PDF Report (.pdf)',
              subtitle: 'Enterprise trip summary report with UMIYA & PNJ header',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.accentOrange,
              onTap: () => _exportPdf(filteredOrders),
            ),
            const SizedBox(height: 12),
            _buildExportTile(
              context,
              title: 'Export to CSV (.csv)',
              subtitle: 'Standard comma-separated text data format',
              icon: Icons.description_rounded,
              color: AppColors.royalBlue,
              onTap: () => _exportCsv(filteredOrders),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.statusDelivered.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusDelivered),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: AppColors.statusDelivered, fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }

  Future<void> _pickAndImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isProcessing = true;
          _statusMessage = 'Reading file and checking for duplicates...';
        });

        final bytes = result.files.single.bytes!;
        final name = result.files.single.name;

        final importedOrders = ExcelService.parseFile(bytes, name);
        await ref.read(orderRepositoryProvider).importOrders(importedOrders);

        setState(() {
          _isProcessing = false;
          _statusMessage = 'Successfully imported ${importedOrders.length} trip orders into Firestore database!';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Import Error: $e';
      });
    }
  }

  void _exportExcel(List orders) async {
    final bytes = ExcelService.exportToExcel(orders.cast());
    await Printing.sharePdf(bytes: bytes, filename: 'UMIYA_PNJ_Orders.xlsx');
  }

  void _exportPdf(List orders) async {
    final pdfBytes = await PdfExportService.generateReportPdf(orders.cast(), 'Trip & Material Report');
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  void _exportCsv(List orders) async {
    final csvStr = ExcelService.exportToCsv(orders.cast());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV Exported (${csvStr.length} bytes): ${orders.length} records ready!')),
    );
  }
}
