import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/helpers/time_picker_mixin.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:jaidem/features/goals/presentation/pages/add_task_page.dart';
import 'package:jaidem/features/goals/presentation/widgets/buttons/task_add_button.dart';
import 'package:jaidem/features/goals/presentation/widgets/dropdowns/frequency_dropdown.dart';

@RoutePage()
class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> with Show, TimePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _reminderController = TextEditingController();
  // final _categoryController = TextEditingController();

  final List<GoalIndicatorModel> _indicators = [];
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedReminderTime;
  String? _selectedFrequency;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    _reminderController.dispose();
    // _categoryController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddTask() async {
    final result = await Navigator.of(context).push<GoalIndicatorModel>(
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(goalId: -1),
      ),
    );

    if (result != null) {
      setState(() {
        _indicators.add(result);
      });
    }
  }

  void _removeIndicator(int index) {
    setState(() {
      _indicators.removeAt(index);
    });
  }

  Future<void> _selectDeadlineDate() async {
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
    await showCupertinoTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      onTimeSelected: (selectedTime) {
        setState(() {
          _selectedReminderTime = selectedTime;
          _reminderController.text = 'Утром ${formatTimeOfDay(selectedTime)}';
        });
      },
    );
  }

  String? _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      return 'Название цели обязательно';
    }

    if (_titleController.text.trim().length < 3) {
      return 'Название должно содержать минимум 3 символа';
    }

    if (_selectedDeadline == null) {
      return 'Срок цели обязателен';
    }

    if (_selectedDeadline!.isBefore(DateTime.now())) {
      return 'Дата завершения цели не может быть в прошлом';
    }

    if (_selectedFrequency == null || _selectedFrequency!.isEmpty) {
      return 'Частота обязательна';
    }

    if (_selectedReminderTime == null) {
      return 'Время напоминания обязательно';
    }

    return null;
  }

  void _saveGoal() {
    String? errorMessage = _validateForm();

    if (errorMessage != null) {
      showErrorMessage(context, message: errorMessage);
      return;
    }


    final goalModel = GoalModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      status: 'in_progress', // Changed to 'Active' instead of 'active'
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      deadline: _selectedDeadline,
      frequency: _selectedFrequency!,
      reminder: _selectedReminderTime != null 
          ? formatTimeOfDay(_selectedReminderTime!) // Format as HH:MM
          : null,
      progress: 0.0,
    );

    // Use the cubit to create goal with indicators
    context.read<GoalsCubit>().createGoalWithIndicators(goalModel, _indicators);
  }

  void _cancelGoal() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GoalsCubit>(),
      child: BlocListener<GoalsCubit, GoalsState>(
        listener: (context, state) {
          if (state is GoalCreated) {
            showMessage(context, 
              message: 'Цель успешно создана!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.of(context).pop();
          } else if (state is GoalCreationError) {
            showErrorMessage(context, message: state.message);
          } else if (state is GoalIndicatorCreationError) {
            showErrorMessage(context, message: 'Ошибка создания задачи: ${state.message}');
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            title: Text(
              'Добавить цель',
              style: context.textTheme.headlineMedium,
            ),
          ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                height: 50,
                color: AppColors.grey,
              ),
              AppTextFormField(
                label: 'Название цели',
                hintText: 'Улучшить грамматику английского языка',
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Описание (опционально)',
                hintText: 'Описание',
                controller: _descriptionController,
              ),
              const SizedBox(height: 16),
              // AppTextFormField(
              //   label: 'Категория',
              //   hintText: 'Выберите категорию',
              //   readOnly: true,
              //   trailing: IconButton(
              //     onPressed: _selectCategory,
              //     icon: const Icon(Icons.keyboard_arrow_down_rounded),
              //   ),
              //   controller: _categoryController,
              // ),

              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Срок цели',
                hintText: 'Выберите дату завершения',
                readOnly: true,
                trailing: IconButton(
                  onPressed: _selectDeadlineDate,
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.grey,
                  ),
                ),
                controller: _deadlineController,
              ),
              const SizedBox(height: 16),
              FrequencyDropdown(
                selectedFrequency: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Индикаторы',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Display existing indicators
              for (final entry in _indicators.asMap().entries)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.title,
                              style: context.textTheme.titleSmall,
                            ),
                            if (entry.value.startTime != null &&
                                entry.value.endTime != null)
                              Text(
                                '${entry.value.startTime} - ${entry.value.endTime}',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeIndicator(entry.key),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              // Add Task Button (hidden if 3 or more indicators)
              if (_indicators.length < 3)
                TaskAddButton(
                  onTap: _navigateToAddTask,
                ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Напоминание',
                hintText: 'Выберите время напоминания',
                readOnly: true,
                trailing: IconButton(
                  onPressed: _selectReminderTime,
                  icon: const Icon(Icons.access_time_rounded),
                ),
                controller: _reminderController,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<GoalsCubit, GoalsState>(
                      builder: (context, state) {
                        final isLoading = state is GoalCreating || 
                                         state is GoalIndicatorCreating;
                        return AppButton(
                          text: isLoading ? 'Сохранение...' : 'Сохранить',
                          borderRadius: 10,
                          padding: EdgeInsets.zero,
                          onPressed: isLoading ? null : _saveGoal,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Отменить',
                      isOutlined: true,
                      borderRadius: 10,
                      padding: EdgeInsets.zero,
                      onPressed: _cancelGoal,
                    ),
                  )
                ],
              ),
              const SizedBox(height: kToolbarHeight),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
