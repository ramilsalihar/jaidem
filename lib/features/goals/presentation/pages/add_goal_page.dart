import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/helpers/time_picker_mixin.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals/goals_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/indicators/indicators_cubit.dart';

@RoutePage()
class AddGoalPage extends StatefulWidget {
  final GoalModel? goal; // For editing existing goal

  const AddGoalPage({super.key, this.goal});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> with Show, TimePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _reminderController = TextEditingController();

  final List<GoalIndicatorModel> _indicators = [];
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedReminderTime;
  String? _selectedFrequency;
  int _createdIndicatorsCount = 0;
  int _totalIndicatorsToCreate = 0;

  bool get _isEditMode => widget.goal != null;

  List<Map<String, dynamic>> _getFrequencies(BuildContext context) => [
    {'value': 'daily', 'label': context.tr('daily'), 'icon': Icons.today_rounded},
    {'value': 'weekly', 'label': context.tr('weekly'), 'icon': Icons.view_week_rounded},
    {'value': 'monthly', 'label': context.tr('monthly'), 'icon': Icons.calendar_month_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _initializeForEdit();
  }

  void _initializeForEdit() {
    if (_isEditMode) {
      final goal = widget.goal!;
      _titleController.text = goal.title;
      _descriptionController.text = goal.description ?? '';
      _selectedDeadline = goal.deadline;
      if (goal.deadline != null) {
        _deadlineController.text = formatDate(goal.deadline!);
      }
      _selectedFrequency = goal.frequency;
      if (goal.reminder != null && goal.reminder!.isNotEmpty) {
        _reminderController.text = goal.reminder!;
        // Parse reminder time
        final parts = goal.reminder!.split(':');
        if (parts.length >= 2) {
          _selectedReminderTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddTask() async {
    HapticFeedback.lightImpact();
    final result = await context.router.push<GoalIndicatorModel>(
      AddIndicatorRoute(),
    );

    if (result != null) {
      setState(() {
        _indicators.add(result);
      });
    }
  }

  void _removeIndicator(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _indicators.removeAt(index);
    });
  }

  Future<void> _selectDeadlineDate() async {
    HapticFeedback.lightImpact();
    await showCupertinoDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      onDateSelected: (selectedDate) {
        setState(() {
          _selectedDeadline = selectedDate;
          _deadlineController.text = formatDate(selectedDate);
        });
      },
    );
  }

  Future<void> _selectReminderTime() async {
    HapticFeedback.lightImpact();
    await showCupertinoTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      onTimeSelected: (selectedTime) {
        setState(() {
          _selectedReminderTime = selectedTime;
          _reminderController.text = formatTimeOfDay(selectedTime);
        });
      },
    );
  }

  String? _validateForm(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      return context.tr('goal_name_required');
    }

    if (_titleController.text.trim().length < 3) {
      return context.tr('name_min_length');
    }

    if (_selectedDeadline == null) {
      return context.tr('deadline_required');
    }

    if (_selectedDeadline!.isBefore(DateTime.now())) {
      return context.tr('deadline_past_error');
    }

    if (_selectedFrequency == null || _selectedFrequency!.isEmpty) {
      return context.tr('frequency_required');
    }

    if (_selectedReminderTime == null) {
      return context.tr('reminder_time_required');
    }

    return null;
  }

  void _saveGoal() {
    HapticFeedback.mediumImpact();
    String? errorMessage = _validateForm(context);

    if (errorMessage != null) {
      showErrorMessage(context, message: errorMessage);
      return;
    }

    final goalModel = GoalModel(
      id: _isEditMode ? widget.goal!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      status: _isEditMode ? widget.goal!.status : 'in_progress',
      dateCreated: _isEditMode ? widget.goal!.dateCreated : DateTime.now(),
      dateUpdated: DateTime.now(),
      deadline: _selectedDeadline,
      frequency: _selectedFrequency!,
      reminder: _selectedReminderTime != null
          ? formatTimeOfDay(_selectedReminderTime!)
          : null,
      progress: _isEditMode ? widget.goal!.progress : 0.0,
      student: _isEditMode ? widget.goal!.student : null,
      category: _isEditMode ? widget.goal!.category : null,
    );

    // Set the count of indicators to create
    _totalIndicatorsToCreate = _indicators.length;
    _createdIndicatorsCount = 0;

    if (_isEditMode) {
      context.read<GoalsCubit>().updateGoal(goalModel);
    } else {
      context.read<GoalsCubit>().createGoal(goalModel);
    }
  }

  void _cancelGoal() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<GoalsCubit>()),
        BlocProvider(create: (context) => sl<IndicatorsCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GoalsCubit, GoalsState>(
            listener: (context, state) {
              if (state is GoalCreated || state is GoalUpdated) {
                if (_indicators.isNotEmpty && !_isEditMode) {
                  final goalId = state.goals.first.id;
                  for (final indicator in _indicators) {
                    final updatedIndicator = indicator.copyWith(goal: goalId);
                    context
                        .read<IndicatorsCubit>()
                        .createGoalIndicator(updatedIndicator);
                  }
                } else {
                  showMessage(
                    context,
                    message: _isEditMode
                        ? context.tr('goal_updated_success')
                        : context.tr('goal_created_success'),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.of(context).pop(true);
                }
              } else if (state is GoalCreationError) {
                showErrorMessage(context, message: state.message);
              } else if (state is GoalUpdateError) {
                showErrorMessage(context, message: state.message);
              }
            },
          ),
          BlocListener<IndicatorsCubit, IndicatorsState>(
            listener: (context, state) {
              if (state is IndicatorCreated) {
                _createdIndicatorsCount++;
                if (_createdIndicatorsCount >= _totalIndicatorsToCreate) {
                  showMessage(
                    context,
                    message: context.tr('goal_and_indicators_created'),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.of(context).pop(true);
                }
              } else if (state is IndicatorCreationError) {
                showErrorMessage(context,
                    message: '${context.tr('indicator_create_error')}: ${state.message}');
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(context),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _buildHeaderCard(context),
                  const SizedBox(height: 24),

                  // Title field
                  _buildSectionTitle(context.tr('basic_info'), Icons.info_outline_rounded),
                  const SizedBox(height: 12),
                  _buildModernTextField(
                    controller: _titleController,
                    label: context.tr('goal_name'),
                    hint: context.tr('goal_name_hint'),
                    icon: Icons.flag_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  _buildModernTextField(
                    controller: _descriptionController,
                    label: context.tr('description_optional'),
                    hint: context.tr('description_hint'),
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Schedule section
                  _buildSectionTitle(context.tr('deadline_and_frequency'), Icons.schedule_rounded),
                  const SizedBox(height: 12),

                  // Deadline field
                  _buildModernTextField(
                    controller: _deadlineController,
                    label: context.tr('end_date'),
                    hint: context.tr('select_date'),
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _selectDeadlineDate,
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Frequency selection
                  _buildFrequencySelector(),
                  const SizedBox(height: 24),

                  // Indicators section
                  _buildSectionTitle(context.tr('indicators'), Icons.track_changes_rounded),
                  const SizedBox(height: 12),
                  _buildIndicatorsList(),
                  const SizedBox(height: 24),

                  // Reminder section
                  _buildSectionTitle(context.tr('reminder'), Icons.notifications_outlined),
                  const SizedBox(height: 12),
                  _buildModernTextField(
                    controller: _reminderController,
                    label: context.tr('reminder_time'),
                    hint: context.tr('select_time'),
                    icon: Icons.access_time_rounded,
                    readOnly: true,
                    onTap: _selectReminderTime,
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
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: _cancelGoal,
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
        _isEditMode ? context.tr('edit_goal') : context.tr('add_goal'),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
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
              Icons.flag_rounded,
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
                  _isEditMode ? context.tr('edit_goal') : context.tr('new_goal'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? context.tr('update_goal_info')
                      : context.tr('set_goal_for_success'),
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

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('frequency'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _getFrequencies(context).map((freq) {
              final isSelected = _selectedFrequency == freq['value'];
              final frequencies = _getFrequencies(context);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedFrequency = freq['value'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: freq != frequencies.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          freq['icon'] as IconData,
                          size: 22,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          freq['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsList() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Existing indicators
          ..._indicators.asMap().entries.map((entry) {
            final indicator = entry.value;
            return Container(
              margin: EdgeInsets.only(
                bottom: entry.key < _indicators.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          indicator.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (indicator.startTime != null &&
                            indicator.endTime != null)
                          Text(
                            '${indicator.startTime} - ${indicator.endTime}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeIndicator(entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add indicator button
          if (_indicators.isNotEmpty) const SizedBox(height: 12),
          if (_indicators.length < 3)
            GestureDetector(
              onTap: _navigateToAddTask,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.tr('add_indicator'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_indicators.isEmpty && _indicators.length >= 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr('max_indicators'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, goalsState) {
        return BlocBuilder<IndicatorsCubit, IndicatorsState>(
          builder: (context, indicatorsState) {
            final isLoading = goalsState is GoalCreating ||
                goalsState is GoalUpdating ||
                indicatorsState is IndicatorCreating;

            return Column(
              children: [
                // Save button
                GestureDetector(
                  onTap: isLoading ? null : _saveGoal,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [Colors.grey.shade400, Colors.grey.shade500]
                            : [AppColors.primary, AppColors.primary.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('save'),
                                  style: const TextStyle(
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
                  onTap: _cancelGoal,
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
                        context.tr('cancel'),
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
          },
        );
      },
    );
  }
}
