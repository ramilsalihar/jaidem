import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:jaidem/features/training/data/models/training_model.dart';
import 'package:jaidem/features/training/presentation/cubit/training_cubit.dart';

@RoutePage()
class TrainingDetailPage extends StatelessWidget {
  const TrainingDetailPage({super.key, required this.training});

  final TrainingModel training;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrainingCubit>(),
      child: _TrainingDetailContent(training: training),
    );
  }
}

class _TrainingDetailContent extends StatefulWidget {
  const _TrainingDetailContent({required this.training});

  final TrainingModel training;

  @override
  State<_TrainingDetailContent> createState() => _TrainingDetailContentState();
}

class _TrainingDetailContentState extends State<_TrainingDetailContent> {
  String? _userId;
  bool _isCheckingAnswers = true;
  bool _hasAnswered = false;
  List<TrainingAnswer> _existingAnswers = [];
  bool _showQuestionnaire = false;
  List<NPSQuestion> _questions = [];
  final Map<int, int> _ratings = {};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCheckAnswers();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserIdAndCheckAnswers() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final userId = await authLocalDataSource.getUserId();
    if (mounted) {
      setState(() {
        _userId = userId;
      });
      if (userId != null) {
        _checkExistingAnswers(userId);
      } else {
        setState(() {
          _isCheckingAnswers = false;
        });
      }
    }
  }

  Future<void> _checkExistingAnswers(String userId) async {
    if (!mounted) return;
    final cubit = context.read<TrainingCubit>();
    await cubit.checkTrainingAnswers(
      trainingId: widget.training.id,
      authorId: userId,
    );
  }

  Future<void> _loadQuestions() async {
    final cubit = context.read<TrainingCubit>();
    await cubit.fetchNPSQuestions();
  }

  Future<void> _submitAnswers() async {
    if (_userId == null || _questions.isEmpty) return;

    // Validate all rating questions are answered (except last one which is comment)
    for (int i = 0; i < _questions.length - 1; i++) {
      if (!_ratings.containsKey(_questions[i].id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('training_answer_all_questions')),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    final cubit = context.read<TrainingCubit>();
    await cubit.submitAnswers(
      questions: _questions,
      ratings: _ratings,
      lastQuestionComment: _commentController.text,
      authorId: _userId!,
      trainingId: widget.training.id,
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrainingCubit, TrainingState>(
      listener: (context, state) {
        if (state is TrainingAnswersLoaded) {
          setState(() {
            _isCheckingAnswers = false;
            _hasAnswered = state.answers.isNotEmpty;
            _existingAnswers = state.answers;
          });
          // Load questions to display question text with answers
          if (state.answers.isNotEmpty) {
            _loadQuestions();
          }
        } else if (state is TrainingAnswersError) {
          setState(() {
            _isCheckingAnswers = false;
          });
        } else if (state is NPSQuestionsLoaded) {
          setState(() {
            _questions = state.questions;
            // Only show questionnaire if user hasn't answered yet
            if (!_hasAnswered) {
              _showQuestionnaire = true;
            }
          });
        } else if (state is NPSQuestionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        } else if (state is SubmitAnswersSuccess) {
          setState(() {
            _isSubmitting = false;
            _showQuestionnaire = false;
            _hasAnswered = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('training_answers_sent')),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is SubmitAnswersError) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final totalAttendees = widget.training.totalAttendees;
    final attendancePercentage = widget.training.attendancePercentage;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: () => context.router.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.shade300,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.training.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          _formatDate(widget.training.dateCreated),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Questionnaire Section
                  if (_showQuestionnaire)
                    _buildQuestionnaireSection()
                  else
                    _buildAnswerStatusSection(),

                  const SizedBox(height: 16),

                  // Flow Info
                  if (widget.training.flow != null) ...[
                    _buildSectionCard(
                      title: context.tr('training_flow_info'),
                      icon: Icons.stream_rounded,
                      child: Column(
                        children: [
                          _buildInfoRow(context.tr('training_name'), widget.training.flow!.name),
                          _buildInfoRow(context.tr('training_description'), widget.training.flow!.description),
                          _buildInfoRow(context.tr('training_year'), widget.training.flow!.year.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attendance Stats
                  _buildSectionCard(
                    title: context.tr('training_attendance_stats'),
                    icon: Icons.bar_chart_rounded,
                    child: Column(
                      children: [
                        // Progress Bar
                        if (totalAttendees > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr('training_attendance'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${attendancePercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getAttendanceColor(attendancePercentage),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: attendancePercentage / 100,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getAttendanceColor(attendancePercentage),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle_rounded,
                                label: context.tr('training_present'),
                                value: widget.training.presentCount.toString(),
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.cancel_rounded,
                                label: context.tr('training_absent'),
                                value: widget.training.absentCount.toString(),
                                color: AppColors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.info_rounded,
                                label: context.tr('training_respectful'),
                                value: widget.training.respectfulCount.toString(),
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.tr('training_total_participants'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                totalAttendees.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Attendance List
                  if (widget.training.attendances.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: context.tr('training_participants_list'),
                      icon: Icons.list_alt_rounded,
                      child: Column(
                        children: widget.training.attendances.map((attendance) {
                          return _buildAttendanceItem(attendance);
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStatusSection() {
    final state = context.watch<TrainingCubit>().state;

    if (_isCheckingAnswers || state is TrainingAnswersLoading) {
      return _buildSectionCard(
        title: context.tr('training_rating'),
        icon: Icons.star_rounded,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_hasAnswered) {
      return _buildSectionCard(
        title: context.tr('training_rating'),
        icon: Icons.star_rounded,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('training_already_answered'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('training_rating_accepted'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_existingAnswers.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._existingAnswers.map((answer) => _buildAnswerItem(answer)),
            ],
          ],
        ),
      );
    }

    return _buildSectionCard(
      title: context.tr('training_rating'),
      icon: Icons.star_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rate_review_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('training_rate_training'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('training_opinion_important'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state is NPSQuestionsLoading
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _loadQuestions();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state is NPSQuestionsLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('training_answer_questions'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerItem(TrainingAnswer answer) {
    // Find the question for this answer
    final question = _questions.isNotEmpty
        ? _questions.firstWhere(
            (q) => q.id == answer.question,
            orElse: () => NPSQuestion(
              id: answer.question,
              question: '',
              textRu: '',
              textKg: '',
              textEn: '',
            ),
          )
        : null;

    // Get localized question text
    final languageCode = Localizations.localeOf(context).languageCode;
    final questionText = question?.getLocalizedText(languageCode) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          if (questionText.isNotEmpty) ...[
            Text(
              questionText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Answer row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    answer.rate > 0 ? answer.rate.toString() : '-',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  answer.comment.isNotEmpty
                      ? answer.comment
                      : (answer.rate > 0 ? '${answer.rate}/10' : '-'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireSection() {
    return _buildSectionCard(
      title: context.tr('training_questions'),
      icon: Icons.quiz_rounded,
      child: Column(
        children: [
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final isLastQuestion = index == _questions.length - 1;

            return _buildQuestionItem(
              question: question,
              index: index,
              isLastQuestion: isLastQuestion,
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _showQuestionnaire = false;
                            _ratings.clear();
                            _commentController.clear();
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr('back'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('training_submit'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem({
    required NPSQuestion question,
    required int index,
    required bool isLastQuestion,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final questionText = question.getLocalizedText(languageCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLastQuestion)
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: context.tr('training_write_comment'),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            )
          else
            _buildRatingSelector(question.id),
        ],
      ),
    );
  }

  Widget _buildRatingSelector(int questionId) {
    final selectedRating = _ratings[questionId];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(10, (index) {
        final rating = index + 1;
        final isSelected = selectedRating == rating;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _ratings[questionId] = rating;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(TrainingAttendance attendance) {
    Color statusColor;
    String statusKey;
    IconData statusIcon;

    switch (attendance.status) {
      case 'present':
        statusColor = AppColors.green;
        statusKey = 'training_present';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'absent':
        statusColor = AppColors.red;
        statusKey = 'training_absent';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'respectful':
        statusColor = AppColors.orange;
        statusKey = 'training_respectful';
        statusIcon = Icons.info_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusKey = '';
        statusIcon = Icons.help_outline_rounded;
    }

    final statusText = statusKey.isNotEmpty ? context.tr(statusKey) : attendance.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${attendance.jaidemchiId}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (attendance.comment.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    attendance.comment,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 70) return AppColors.green;
    if (percentage >= 50) return AppColors.orange;
    return AppColors.red;
  }
}
