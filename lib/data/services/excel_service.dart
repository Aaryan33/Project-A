import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../../domain/models/order_model.dart';
import '../../core/utils/date_formatter.dart';

class ExcelService {
  /// Parse Excel or CSV bytes into list of OrderModel
  static List<OrderModel> parseFile(Uint8List bytes, String filename) {
    if (filename.toLowerCase().endsWith('.csv')) {
      return _parseCsv(bytes);
    } else {
      return _parseExcel(bytes);
    }
  }

  static List<OrderModel> _parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final List<OrderModel> orders = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.maxRows <= 1) continue;

      // Find header index
      List<String> headers = [];
      int headerRowIndex = -1;

      for (int i = 0; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        final rowText = row.map((cell) => cell?.value.toString().toUpperCase() ?? '').join(' ');
        if (rowText.contains('VEHICL') || rowText.contains('MATERIAL') || rowText.contains('DATE')) {
          headerRowIndex = i;
          headers = row.map((cell) => cell?.value.toString().trim() ?? '').toList();
          break;
        }
      }

      if (headerRowIndex == -1) continue;

      for (int i = headerRowIndex + 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty) continue;

        String dateStr = _getCellValue(row, headers, ['DATE']);
        String vehicle = _getCellValue(row, headers, ['VEHICLE', 'VEHICL E NO.', 'VEHICLE NO.']);
        String fromLoc = _getCellValue(row, headers, ['FROM']);
        String toLoc = _getCellValue(row, headers, ['TO']);
        String material = _getCellValue(row, headers, ['MATERIAL']);
        String qtyStr = _getCellValue(row, headers, ['QUANTITY']);
        String netWtStr = _getCellValue(row, headers, ['NET WEIGHT', 'NET WEIGHT FROM UKAI']);
        String companyStr = _getCellValue(row, headers, ['UMIYA & PNJ', 'COMPANY']);

        if (vehicle.isEmpty && qtyStr.isEmpty) continue;

        final DateTime date = DateFormatter.parseDate(dateStr) ?? DateTime.now();
        final double qty = double.tryParse(qtyStr) ?? 0.0;
        final double? netWt = double.tryParse(netWtStr);

        orders.add(
          OrderModel(
            id: 'IMP-${DateTime.now().millisecondsSinceEpoch}-$i',
            date: date,
            vehicleNumber: vehicle.isNotEmpty ? vehicle : 'GJ-05-XXXX',
            fromLocation: fromLoc.isNotEmpty ? fromLoc : 'PLANT',
            toLocation: toLoc.isNotEmpty ? toLoc : 'SITE',
            material: material.isNotEmpty ? material.toUpperCase() : 'FLYASH',
            quantity: qty,
            netWeightUkai: netWt,
            company: companyStr.contains('PNJ') ? 'PNJ' : 'UMIYA',
            status: 'Completed',
            createdBy: 'Excel Import',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    return orders;
  }

  static String _getCellValue(List<Data?> row, List<String> headers, List<String> possibleNames) {
    for (int colIndex = 0; colIndex < headers.length; colIndex++) {
      final header = headers[colIndex].toUpperCase();
      for (final name in possibleNames) {
        if (header.contains(name.toUpperCase())) {
          if (colIndex < row.length) {
            return row[colIndex]?.value.toString().trim() ?? '';
          }
        }
      }
    }
    return '';
  }

  static List<OrderModel> _parseCsv(Uint8List bytes) {
    final csvString = utf8.decode(bytes);
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
    final List<OrderModel> orders = [];

    if (csvData.length <= 1) return orders;

    final headers = csvData[0].map((e) => e.toString().toUpperCase()).toList();

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.isEmpty) continue;

      String dateStr = _getCsvValue(row, headers, ['DATE']);
      String vehicle = _getCsvValue(row, headers, ['VEHICLE']);
      String fromLoc = _getCsvValue(row, headers, ['FROM']);
      String toLoc = _getCsvValue(row, headers, ['TO']);
      String material = _getCsvValue(row, headers, ['MATERIAL']);
      String qtyStr = _getCsvValue(row, headers, ['QUANTITY']);
      String companyStr = _getCsvValue(row, headers, ['COMPANY']);

      orders.add(
        OrderModel(
          id: 'CSV-${DateTime.now().millisecondsSinceEpoch}-$i',
          date: DateFormatter.parseDate(dateStr) ?? DateTime.now(),
          vehicleNumber: vehicle.isNotEmpty ? vehicle : 'GJ-05-XXXX',
          fromLocation: fromLoc,
          toLocation: toLoc,
          material: material.toUpperCase(),
          quantity: double.tryParse(qtyStr) ?? 0.0,
          company: companyStr.contains('PNJ') ? 'PNJ' : 'UMIYA',
          status: 'Completed',
          createdBy: 'CSV Import',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    return orders;
  }

  static String _getCsvValue(List<dynamic> row, List<String> headers, List<String> possibleNames) {
    for (int colIndex = 0; colIndex < headers.length; colIndex++) {
      final header = headers[colIndex];
      for (final name in possibleNames) {
        if (header.contains(name.toUpperCase()) && colIndex < row.length) {
          return row[colIndex].toString().trim();
        }
      }
    }
    return '';
  }

  /// Generate Excel file bytes from Order list
  static Uint8List exportToExcel(List<OrderModel> orders) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Orders'];

    final headers = [
      'ID',
      'Date',
      'Vehicle Number',
      'From Location',
      'To Location',
      'Material',
      'Quantity (MT)',
      'Net Weight (Ukai)',
      'Company',
      'Status',
      'Payment Days',
      'Payment Date',
      'Remarks',
      'Created By',
      'Created At',
    ];

    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (var o in orders) {
      sheet.appendRow([
        TextCellValue(o.id),
        TextCellValue(DateFormatter.formatDate(o.date)),
        TextCellValue(o.vehicleNumber),
        TextCellValue(o.fromLocation),
        TextCellValue(o.toLocation),
        TextCellValue(o.material),
        DoubleCellValue(o.quantity),
        DoubleCellValue(o.netWeightUkai ?? 0.0),
        TextCellValue(o.company),
        TextCellValue(o.status),
        IntCellValue(o.paymentDays ?? 0),
        TextCellValue(DateFormatter.formatDate(o.paymentDate)),
        TextCellValue(o.remarks ?? ''),
        TextCellValue(o.createdBy),
        TextCellValue(DateFormatter.formatDateTime(o.createdAt)),
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }

  /// Generate CSV string from Order list
  static String exportToCsv(List<OrderModel> orders) {
    List<List<dynamic>> rows = [
      [
        'ID',
        'Date',
        'Vehicle Number',
        'From',
        'To',
        'Material',
        'Quantity (MT)',
        'Net Weight',
        'Company',
        'Status',
        'Remarks'
      ]
    ];

    for (var o in orders) {
      rows.add([
        o.id,
        DateFormatter.formatDate(o.date),
        o.vehicleNumber,
        o.fromLocation,
        o.toLocation,
        o.material,
        o.quantity,
        o.netWeightUkai ?? '',
        o.company,
        o.status,
        o.remarks ?? ''
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
