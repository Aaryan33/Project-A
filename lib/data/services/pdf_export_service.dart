import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/order_model.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_constants.dart';

class PdfExportService {
  static Future<Uint8List> generateReportPdf(List<OrderModel> orders, String title) async {
    final pdf = pw.Document();

    final totalQuantity = orders.fold<double>(0.0, (sum, item) => sum + item.quantity);
    final totalTrips = orders.length;

    final Map<String, double> materialQty = {};
    for (var o in orders) {
      materialQty[o.material] = (materialQty[o.material] ?? 0) + o.quantity;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppConstants.appTitle,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.Text(
                        'Trip & Material Management System',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.Text(
                        'Generated: ${DateFormatter.formatDateTime(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.orange400),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('UMIYA IMPEX | PNJ VENTURES Confidential', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          );
        },
        build: (pw.Context context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfKpi('Total Trips', totalTrips.toString()),
                _buildPdfKpi('Total Tonnage', '${totalQuantity.toStringAsFixed(2)} MT'),
                _buildPdfKpi('Fly Ash', '${(materialQty['FLYASH'] ?? 0).toStringAsFixed(1)} MT'),
                _buildPdfKpi('GGBS', '${(materialQty['GGBS'] ?? 0).toStringAsFixed(1)} MT'),
                _buildPdfKpi('Cement', '${(materialQty['CEMENT'] ?? 0).toStringAsFixed(1)} MT'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Text('Trip Log Records', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Date', 'Vehicle', 'From', 'To Customer', 'Material', 'Qty (MT)', 'Company', 'Status'],
            data: orders.map((o) {
              return [
                DateFormatter.formatDate(o.date),
                o.vehicleNumber,
                o.fromLocation,
                o.toLocation,
                o.material,
                o.quantity.toStringAsFixed(2),
                o.company,
                o.status,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfKpi(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
    );
  }
}
