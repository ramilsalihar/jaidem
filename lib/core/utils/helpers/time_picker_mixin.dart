import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

mixin TimePickerMixin {
  /// Shows a Cupertino-style time picker modal
  /// 
  /// [context] - The build context
  /// [initialTime] - Initial time to show (defaults to current time)
  /// [use24hFormat] - Whether to use 24h format (defaults to true)
  /// [onTimeSelected] - Callback when time is selected
  /// [cancelText] - Text for cancel button (defaults to 'Отмена')
  /// [doneText] - Text for done button (defaults to 'Готово')
  Future<void> showCupertinoTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    bool use24hFormat = true,
    required Function(TimeOfDay) onTimeSelected,
    String cancelText = 'Отмена',
    String doneText = 'Готово',
  }) async {
    TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();
    
    DateTime initialDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 260,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header with Cancel and Done buttons
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        cancelText,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        onTimeSelected(selectedTime);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        doneText,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Time picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  use24hFormat: use24hFormat,
                  onDateTimeChanged: (DateTime newDateTime) {
                    selectedTime = TimeOfDay.fromDateTime(newDateTime);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a Material-style time picker
  /// 
  /// [context] - The build context
  /// [initialTime] - Initial time to show (defaults to current time)
  /// [onTimeSelected] - Callback when time is selected
  Future<void> showMaterialTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    required Function(TimeOfDay) onTimeSelected,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  /// Formats TimeOfDay to string in HH:MM format
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Shows a Cupertino-style date picker modal
  /// 
  /// [context] - The build context
  /// [initialDate] - Initial date to show (defaults to current date)
  /// [minimumDate] - Minimum selectable date
  /// [maximumDate] - Maximum selectable date
  /// [onDateSelected] - Callback when date is selected
  /// [cancelText] - Text for cancel button (defaults to 'Отмена')
  /// [doneText] - Text for done button (defaults to 'Готово')
  Future<void> showCupertinoDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    required Function(DateTime) onDateSelected,
    String cancelText = 'Отмена',
    String doneText = 'Готово',
  }) async {
    DateTime selectedDate = initialDate ?? DateTime.now();

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext popupContext) => Container(
        height: 310,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(popupContext).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(popupContext),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header with Cancel and Done buttons
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(popupContext).pop(),
                      child: Text(
                        cancelText,
                        style: popupContext.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        onDateSelected(selectedDate);
                        Navigator.of(popupContext).pop();
                      },
                      child: Text(
                        doneText,
                        style: popupContext.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Date picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
              // Enter manually button
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.of(popupContext).pop();
                    _showManualDateEntryDialog(
                      context: context,
                      initialDate: selectedDate,
                      minimumDate: minimumDate,
                      maximumDate: maximumDate,
                      onDateSelected: onDateSelected,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('enter_manually'),
                        style: popupContext.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showManualDateEntryDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final controller = TextEditingController(
      text: initialDate != null
          ? '${initialDate.day.toString().padLeft(2, '0')}-${initialDate.month.toString().padLeft(2, '0')}-${initialDate.year}'
          : '',
    );
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            context.tr('select_date'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                inputFormatters: [_DateInputFormatter()],
                decoration: InputDecoration(
                  hintText: context.tr('enter_date_hint'),
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr('cancel'),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = _parseDDMMYYYY(controller.text);
                if (parsed == null) {
                  setDialogState(() {
                    errorText = context.tr('invalid_date_format');
                  });
                  return;
                }
                if (minimumDate != null && parsed.isBefore(minimumDate) ||
                    maximumDate != null && parsed.isAfter(maximumDate)) {
                  setDialogState(() {
                    errorText = context.tr('invalid_date_format');
                  });
                  return;
                }
                onDateSelected(parsed);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDDMMYYYY(String text) {
    final parts = text.split('-');
    if (parts.length != 3) return null;
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1000) return null;
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  /// Parses string in HH:MM format to TimeOfDay
  TimeOfDay? parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Formats DateTime to string in DD.MM.YYYY format
  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  /// Parses string in DD.MM.YYYY format to DateTime
  DateTime? parseDateString(String dateString) {
    try {
      final parts = dateString.split('.');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('-');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
