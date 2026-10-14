import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');

  static String formatCurrency(num? amount) {
    if (amount == null) return 'N/A';
    return _currencyFormat.format(amount);
  }

  static String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      return _dateFormat.format(parsed);
    }
    if (date is DateTime) {
      return _dateFormat.format(date);
    }
    return '';
  }

  static String formatDateRange(dynamic start, dynamic end) {
    if (start == null || end == null) return '';
    final s = start is DateTime ? start : DateTime.tryParse(start.toString());
    final e = end is DateTime ? end : DateTime.tryParse(end.toString());
    if (s == null || e == null) return '';
    return '${_shortDateFormat.format(s)} – ${_dateFormat.format(e)}';
  }

  static String getCategoryLabel(String categoryId) {
    final found = AppConstants.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'label': categoryId},
    );
    return found['label'] ?? categoryId;
  }

  static String getConditionLabel(String conditionId) {
    final found = AppConstants.conditions.firstWhere(
      (c) => c['id'] == conditionId,
      orElse: () => {'label': conditionId},
    );
    return found['label'] ?? conditionId;
  }

  static String timeAgo(dynamic date) {
    if (date == null) return '';
    final d = date is DateTime ? date : DateTime.tryParse(date.toString());
    if (d == null) return '';

    final difference = DateTime.now().difference(d);
    if (difference.inDays > 7) {
      return _dateFormat.format(d);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
