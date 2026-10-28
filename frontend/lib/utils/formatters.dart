import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _dateShort = DateFormat('dd MMM yyyy');
  static final _dateLong = DateFormat('dd MMMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final _monthYear = DateFormat('MMM yyyy');

  static String currency(double amount) => _currency.format(amount);

  static String currencyCompact(double amount) {
    if (amount.abs() >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount);
  }

  static String dateShort(DateTime date) => _dateShort.format(date);
  static String dateLong(DateTime date) => _dateLong.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return dateShort(date);
  }

  static String timeUntil(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) {
      final absDiff = now.difference(date);
      if (absDiff.inDays == 0) return 'Today (overdue)';
      return '${absDiff.inDays}d overdue';
    }
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays}d';
  }

  static String orderStatus(String status) {
    switch (status) {
      case 'new': return 'New';
      case 'in_progress': return 'In Progress';
      case 'waiting': return 'Waiting';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  static String debtStatus(String status) {
    switch (status) {
      case 'unpaid': return 'Unpaid';
      case 'partial': return 'Partial';
      case 'paid': return 'Paid';
      default: return status;
    }
  }
}
