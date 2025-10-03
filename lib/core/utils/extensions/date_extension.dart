import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toReadableDate() {
    final formatted = DateFormat("d MMMM yyyy").format(this);

    final monthShortMapper = {
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

    // Split the formatted string to get the month name
    final parts = formatted.split(' ');

    if (parts.length == 3) {
      final monthName = parts[1];
      final shortenedMonth = monthShortMapper[monthName];

      if (shortenedMonth != null) {
        return "${parts[0]} $shortenedMonth ${parts[2]} года";
      }
    }

    return formatted;
  }

  String formatDeadline(DateTime? deadline) {
    if (deadline == null) return '31.12.2025';
    return '${deadline.day.toString().padLeft(2, '0')}.${deadline.month.toString().padLeft(2, '0')}.${deadline.year}';
  }
}
