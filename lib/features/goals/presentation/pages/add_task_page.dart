import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/utils/helpers/time_picker_mixin.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';

@RoutePage()
class AddTaskPage extends StatefulWidget {
  final int? indicatorId;
  final GoalTaskModel? existingTask;

  const AddTaskPage({
    super.key,
    this.indicatorId,
    this.existingTask,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with TimePickerMixin, Show {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _reminderController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingTask != null) {
      final task = widget.existingTask!;

      // Initialize title
      _titleController.text = task.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    await showCupertinoTimePicker(
      context: context,
      initialTime: _startTime,
      onTimeSelected: (time) {
        setState(() {
          _startTime = time;
          _startTimeController.text = formatTimeOfDay(time);
        });
      },
    );
  }

  Future<void> _selectEndTime() async {
    await showCupertinoTimePicker(
      context: context,
      initialTime: _endTime,
      onTimeSelected: (time) {
        setState(() {
          _endTime = time;
          _endTimeController.text = formatTimeOfDay(time);
        });
      },
    );
  }

  Future<void> _selectReminderTime() async {
    await showCupertinoTimePicker(
      context: context,
      initialTime: _reminderTime,
      onTimeSelected: (time) {
        setState(() {
          _reminderTime = time;
          _reminderController.text = formatTimeOfDay(time);
        });
      },
    );
  }

  void _saveTask() {
    String? errorMessage = _validateForm();

    if (errorMessage != null) {
      showErrorMessage(context, message: errorMessage);
      return;
    }

    final goalTask = GoalTaskModel(
      id: widget.existingTask?.id,
      title: _titleController.text.trim(),
      isCompleted: widget.existingTask?.isCompleted ?? false,
      indicator: widget.indicatorId ?? widget.existingTask?.indicatorId ?? -1,
      dateCreated: widget.existingTask?.dateCreated,
      dateUpdated: widget.existingTask != null ? DateTime.now() : null,
    );

    Navigator.of(context).pop(goalTask);
  }

  String? _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      return 'Тапшырманын аталышы талап кылынат';
    }

    if (_titleController.text.trim().length < 3) {
      return 'Аталыш кеминде 3 символдон турушу керек';
    }

    // Require both start and end time
    if (_startTime == null) {
      return 'Баштоо убактысы милдеттүү түрдө көрсөтүлүшү керек';
    }

    if (_endTime == null) {
      return 'Аяктоо убактысы талап кылынат';
    }

    // Validate time order
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (startMinutes >= endMinutes) {
      return 'Аяктоо убактысы баштоо убактысынан кечирээк болушу керек.';
    }

    // Check if the time difference is at least 15 minutes
    // if (endMinutes - startMinutes < 15) {
    //   return 'Минимальная продолжительность задачи 15 минут';
    // }

    return null;
  }

  void _cancelTask() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          widget.existingTask != null ? 'Тапшырманы түзөтүү' : 'Жаңы тапшырма',
          style: context.textTheme.headlineMedium,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Divider(
                height: 50,
                color: AppColors.grey,
              ),
              AppTextFormField(
                label: 'Тапшырманын аталышы',
                hintText: '20 сөз үйрөнүңүз',
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Убакыт менен',
                hintText: 'Баштоо убактысын тандаңыз',
                readOnly: true,
                controller: _startTimeController,
                trailing: IconButton(
                  onPressed: _selectStartTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Буга чейинки убакыт',
                hintText: 'Аяктоо убактысын тандаңыз',
                readOnly: true,
                controller: _endTimeController,
                trailing: IconButton(
                  onPressed: _selectEndTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Эскерткич',
                hintText: 'Эскертме убакытын тандаңыз',
                readOnly: true,
                controller: _reminderController,
                trailing: IconButton(
                  onPressed: _selectReminderTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Сактоо',
                      borderRadius: 10,
                      padding: EdgeInsets.zero,
                      onPressed: _saveTask,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Жокко чыгаруу',
                      isOutlined: true,
                      borderRadius: 10,
                      padding: EdgeInsets.zero,
                      onPressed: _cancelTask,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
