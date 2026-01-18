import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  static const _monthShortMapper = {
    'January': 'янв',
    'February': 'фев',
    'March': 'мар',
    'April': 'апр',
    'May': 'май',
    'June': 'июн',
    'July': 'июл',
    'August': 'авг',
    'September': 'сен',
    'October': 'окт',
    'November': 'ноя',
    'December': 'дек',
  };

  String toReadableDate() {
    final formatted = DateFormat("d MMMM yyyy").format(this);

    final parts = formatted.split(' ');

    if (parts.length == 3) {
      final monthName = parts[1];
      final shortenedMonth = _monthShortMapper[monthName];

      if (shortenedMonth != null) {
        return "${parts[0]} $shortenedMonth ${parts[2]} года";
      }
    }

    return formatted;
  }

  String toReadableDateWithTime() {
    final formatted = DateFormat("d MMMM yyyy").format(this);
    final timeFormatted = DateFormat("HH:mm").format(this);

    final parts = formatted.split(' ');

    if (parts.length == 3) {
      final monthName = parts[1];
      final shortenedMonth = _monthShortMapper[monthName];

      if (shortenedMonth != null) {
        return "${parts[0]} $shortenedMonth, $timeFormatted";
      }
    }

    return "$formatted, $timeFormatted";
  }

  String toTimeOnly() {
    return DateFormat("HH:mm").format(this);
  }

  String formatDeadline(DateTime? deadline) {
    if (deadline == null) return '31.12.2025';
    return '${deadline.day.toString().padLeft(2, '0')}.${deadline.month.toString().padLeft(2, '0')}.${deadline.year}';
  }
}
