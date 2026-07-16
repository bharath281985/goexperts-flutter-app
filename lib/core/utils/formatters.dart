import 'package:intl/intl.dart';

/// Formatting helpers for currency, numbers, dates and relative time.
class Formatters {
  Formatters._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final NumberFormat _compact = NumberFormat.compact(locale: 'en_IN');

  static String currency(num value) => _inr.format(value);

  static String compactCurrency(num value) {
    if (value >= 10000000) {
      return '\u20B9${(value / 10000000).toStringAsFixed(value % 10000000 == 0 ? 0 : 1)}Cr';
    }
    if (value >= 100000) {
      return '\u20B9${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 1)}L';
    }
    if (value >= 1000) {
      return '\u20B9${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return _inr.format(value);
  }

  static String compact(num value) => _compact.format(value);

  static String date(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

  /// WhatsApp-style chat day label (TODAY / YESTERDAY / date).
  static String chatDayLabel(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return DateFormat('dd MMM yyyy').format(local).toUpperCase();
  }

  static String dateTime(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);

  static String time(DateTime dt) => DateFormat('hh:mm a').format(dt);

  static String dayMonth(DateTime dt) => DateFormat('dd MMM').format(dt);

  static String monthYear(DateTime dt) => DateFormat('MMMM yyyy').format(dt);

  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
