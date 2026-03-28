import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Returns 'Today', 'Yesterday', date, or time depending on age
  String toChatDateString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(year, month, day);

    if (msgDate == today) return DateFormat.Hm().format(this);
    if (msgDate == yesterday) return 'Yesterday';
    if (now.difference(this).inDays < 7) return DateFormat.EEEE().format(this);
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Short time HH:mm
  String toTimeString() => DateFormat.Hm().format(this);

  /// Full date for section dividers
  String toSectionHeader() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(year, month, day);

    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(this);
  }
}

extension StringExtensions on String {
  /// Capitalizes the first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns initials (up to 2 chars) for avatar placeholder
  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isValidEmail =>
      RegExp(r'^[\w.+\-]+@[\w\-]+\.\w+$').hasMatch(this);
}
