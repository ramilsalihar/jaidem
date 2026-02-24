import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/presentation/cubit/opros_cubit.dart';

@RoutePage()
class OprosSurveyPage extends StatelessWidget {
  const OprosSurveyPage({super.key, required this.surveyType});

  final String surveyType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<OprosCubit>()..fetchOprosQuestions(questionType: surveyType),
      child: _OprosSurveyContent(surveyType: surveyType),
    );
  }
}

class _OprosSurveyContent extends StatefulWidget {
  final String surveyType;

  const _OprosSurveyContent({required this.surveyType});

  @override
  State<_OprosSurveyContent> createState() => _OprosSurveyContentState();
}

class _OprosSurveyContentState extends State<_OprosSurveyContent> {
  int _currentIndex = 0;
  final Map<int, int> _ratings = {};
  final Map<int, String> _textAnswers = {};
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int questionId) {
    return _controllers.putIfAbsent(questionId, () {
      final c = TextEditingController(text: _textAnswers[questionId] ?? '');
      c.addListener(() => _textAnswers[questionId] = c.text);
      return c;
    });
  }

  bool _isCurrentAnswered(OprosQuestionModel question) {
    if (question.isRate) {
      return _ratings.containsKey(question.id);
    } else {
      final text = _textAnswers[question.id] ?? '';
      return text.trim().isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<OprosCubit, OprosState>(
        listener: (context, state) {
          if (state is OprosSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('opros_submitted_success')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is OprosSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OprosQuestionsLoading) {
            return _buildLoading();
          }
          if (state is OprosQuestionsError) {
            return _buildError(state.message);
          }
          if (state is OprosQuestionsLoaded) {
            return _buildSurvey(context, state.questions);
          }
          if (state is OprosSubmitting) {
            return _buildLoading();
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context
                  .read<OprosCubit>()
                  .fetchOprosQuestions(questionType: widget.surveyType),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurvey(
      BuildContext context, List<OprosQuestionModel> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    final question = questions[_currentIndex];
    final total = questions.length;
    final progress = (_currentIndex + 1) / total;
    final isLast = _currentIndex == total - 1;
    final isFirst = _currentIndex == 0;
    final title = widget.surveyType == 'before'
        ? context.tr('opros_before_survey')
        : context.tr('opros_after_survey');

    return SafeArea(
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey.shade600,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / $total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),

          // Question content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildQuestionCard(question, key: ValueKey(question.id)),
            ),
          ),

          // Navigation buttons
          _buildNavButtons(context, questions, isFirst, isLast),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(OprosQuestionModel question, {Key? key}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final questionText = question.getLocalizedText(languageCode);

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Text(
              questionText,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Answer area
          if (question.isRate) _buildRatingSelector(question.id) else _buildTextField(question.id),
        ],
      ),
    );
  }

  Widget _buildRatingSelector(int questionId) {
    final selectedRating = _ratings[questionId];

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '10',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 40 - 40 - 72) / 5,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(int questionId) {
    return Container(
      padding: const EdgeInsets.all(4),
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
        controller: _controllerFor(questionId),
        maxLines: 5,
        minLines: 3,
        decoration: InputDecoration(
          hintText: context.tr('opros_write_answer'),
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade800,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavButtons(BuildContext context,
      List<OprosQuestionModel> questions, bool isFirst, bool isLast) {
    final question = questions[_currentIndex];
    final answered = _isCurrentAnswered(question);

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirst)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIndex--);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('back'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            flex: isFirst ? 1 : 1,
            child: GestureDetector(
              onTap: answered
                  ? () {
                      HapticFeedback.mediumImpact();
                      if (isLast) {
                        context.read<OprosCubit>().submitAnswers(
                              surveyType: widget.surveyType,
                              questions: questions,
                              ratings: _ratings,
                              textAnswers: _textAnswers,
                            );
                      } else {
                        setState(() => _currentIndex++);
                      }
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: answered
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: answered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast
                            ? context.tr('opros_submit')
                            : context.tr('next'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
