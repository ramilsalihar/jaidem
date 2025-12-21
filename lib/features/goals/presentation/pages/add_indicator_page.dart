import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/utils/helpers/time_picker_mixin.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';

@RoutePage()
class AddIndicatorPage extends StatefulWidget {
  final int? goalId;
  final GoalIndicatorModel? existingIndicator;

  const AddIndicatorPage({
    super.key,
    this.goalId,
    this.existingIndicator,
  });

  @override
  State<AddIndicatorPage> createState() => _AddIndicatorPageState();
}

class _AddIndicatorPageState extends State<AddIndicatorPage>
    with TimePickerMixin, Show {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reminderController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingIndicator != null) {
      final indicator = widget.existingIndicator!;

      _titleController.text = indicator.title;

      if (indicator.startTime != null) {
        _startDate = _parseDate(indicator.startTime!);
        _startDateController.text = indicator.startTime!;
      }

      if (indicator.endTime != null) {
        _endDate = _parseDate(indicator.endTime!);
        _endDateController.text = indicator.endTime!;
      }

      if (indicator.reminder != null) {
        _reminderDate = _parseDate(indicator.reminder!);
        _reminderController.text = indicator.reminder!;
      }
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    HapticFeedback.lightImpact();
    await _selectDate(
      initialDate: _startDate,
      onSelected: (date) {
        setState(() {
          _startDate = date;
          _startDateController.text = _formatDate(date);
        });
      },
    );
  }

  Future<void> _selectEndDate() async {
    HapticFeedback.lightImpact();
    await _selectDate(
      initialDate: _endDate ?? _startDate,
      onSelected: (date) {
        setState(() {
          _endDate = date;
          _endDateController.text = _formatDate(date);
        });
      },
    );
  }

  Future<void> _selectReminderDate() async {
    HapticFeedback.lightImpact();
    await _selectDate(
      initialDate: _reminderDate ?? _startDate,
      onSelected: (date) {
        setState(() {
          _reminderDate = date;
          _reminderController.text = _formatDate(date);
        });
      },
    );
  }

  Future<void> _selectDate({
    DateTime? initialDate,
    required Function(DateTime) onSelected,
  }) async {
    final now = DateTime.now();
    DateTime tempPicked = initialDate ?? now;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Жокко чыгаруу',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Күндү тандаңыз',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onSelected(tempPicked);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Даяр',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate ?? now,
                  minimumDate: now.subtract(const Duration(days: 365)),
                  maximumDate: now.add(const Duration(days: 365 * 5)),
                  onDateTimeChanged: (DateTime value) {
                    tempPicked = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _saveIndicator() {
    HapticFeedback.mediumImpact();
    String? errorMessage = _validateForm();

    if (errorMessage != null) {
      showErrorMessage(context, message: errorMessage);
      return;
    }

    final goalIndicator = GoalIndicatorModel(
      id: widget.existingIndicator?.id,
      title: _titleController.text.trim(),
      startTime: _startDate != null ? _formatDateForApi(_startDate!) : null,
      endTime: _endDate != null ? _formatDateForApi(_endDate!) : null,
      reminder: _reminderDate != null ? _formatDateForApi(_reminderDate!) : null,
      progress: widget.existingIndicator?.progress ?? 0.0,
      goal: widget.goalId ?? widget.existingIndicator?.goalId ?? -1,
    );

    Navigator.of(context).pop(goalIndicator);
  }

  String? _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      return 'Индикатордун аты милдеттүү';
    }

    if (_titleController.text.trim().length < 3) {
      return 'Аталыш кеминде 3 символдон турушу керек';
    }

    if (_startDate == null) {
      return 'Башталуу күнү милдеттүү';
    }

    if (_endDate == null) {
      return 'Аяктоо күнү милдеттүү';
    }

    if (_startDate!.isAfter(_endDate!)) {
      return 'Аяктоо күнү башталуу күнүнөн кийин болушу керек';
    }

    return null;
  }

  void _cancelIndicator() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingIndicator != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(isEditing),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _buildHeaderCard(isEditing),
              const SizedBox(height: 24),

              // Title field
              _buildSectionTitle('Индикатор маалыматы', Icons.track_changes_rounded),
              const SizedBox(height: 12),
              _buildModernTextField(
                controller: _titleController,
                label: 'Индикатордун аты',
                hint: '20 сөз үйрөнүү',
                icon: Icons.edit_rounded,
              ),
              const SizedBox(height: 24),

              // Date section
              _buildSectionTitle('Мөөнөт', Icons.date_range_rounded),
              const SizedBox(height: 12),

              // Start date
              _buildModernTextField(
                controller: _startDateController,
                label: 'Башталуу күнү',
                hint: 'Күндү тандаңыз',
                icon: Icons.play_arrow_rounded,
                readOnly: true,
                onTap: _selectStartDate,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),

              // End date
              _buildModernTextField(
                controller: _endDateController,
                label: 'Аяктоо күнү',
                hint: 'Күндү тандаңыз',
                icon: Icons.stop_rounded,
                readOnly: true,
                onTap: _selectEndDate,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),

              // Reminder section
              _buildSectionTitle('Эскертме', Icons.notifications_outlined),
              const SizedBox(height: 12),
              _buildModernTextField(
                controller: _reminderController,
                label: 'Эскертме күнү (милдеттүү эмес)',
                hint: 'Күндү тандаңыз',
                icon: Icons.calendar_today_rounded,
                readOnly: true,
                onTap: _selectReminderDate,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEditing) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: _cancelIndicator,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.grey.shade700,
          ),
        ),
      ),
      title: Text(
        isEditing ? 'Индикаторду өзгөртүү' : 'Жаңы индикатор',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderCard(bool isEditing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.shade400,
            AppColors.primary.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Индикаторду өзгөртүү' : 'Жаңы индикатор',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Максатыңызды өлчөө үчүн индикатор кошуңуз',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        onTap: onTap,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          suffixIcon: trailing != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: trailing,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        GestureDetector(
          onTap: _saveIndicator,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Сактоо',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel button
        GestureDetector(
          onTap: _cancelIndicator,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                'Жокко чыгаруу',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
