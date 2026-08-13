import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '-';
    return _monthYearFormat.format(date);
  }

  static DateTime? parseDate(String? str) {
    if (str == null || str.trim().isEmpty) return null;
    try {
      if (str.contains('/')) {
        final parts = str.split('/');
        if (parts.length == 3) {
          final m = int.parse(parts[0]);
          final d = int.parse(parts[1]);
          final y = int.parse(parts[2]);
          return DateTime(y, m, d);
        }
      }
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }

  static String formatQuantity(double qty) {
    return '${qty.toStringAsFixed(2)} MT';
  }

  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }
}
