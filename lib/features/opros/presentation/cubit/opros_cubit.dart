import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';
import 'package:jaidem/features/opros/domain/usecases/get_opros_questions_usecase.dart';
import 'package:jaidem/features/opros/domain/usecases/get_opros_status_usecase.dart';
import 'package:jaidem/features/opros/domain/usecases/submit_opros_answers_usecase.dart';

part 'opros_state.dart';

class OprosCubit extends Cubit<OprosState> {
  final GetOprosStatusUseCase _getOprosStatusUseCase;
  final GetOprosQuestionsUseCase _getOprosQuestionsUseCase;
  final SubmitOprosAnswersUseCase _submitOprosAnswersUseCase;

  OprosCubit({
    required GetOprosStatusUseCase getOprosStatusUseCase,
    required GetOprosQuestionsUseCase getOprosQuestionsUseCase,
    required SubmitOprosAnswersUseCase submitOprosAnswersUseCase,
  })  : _getOprosStatusUseCase = getOprosStatusUseCase,
        _getOprosQuestionsUseCase = getOprosQuestionsUseCase,
        _submitOprosAnswersUseCase = submitOprosAnswersUseCase,
        super(const OprosInitial());

  Future<void> fetchOprosStatus() async {
    emit(const OprosStatusLoading());
    final result = await _getOprosStatusUseCase();
    if (isClosed) return;
    result.fold(
      (error) => emit(OprosStatusError(message: error)),
      (status) => emit(OprosStatusLoaded(status: status)),
    );
  }

  Future<void> fetchOprosQuestions({required String questionType}) async {
    emit(const OprosQuestionsLoading());
    final result =
        await _getOprosQuestionsUseCase(questionType: questionType);
    if (isClosed) return;
    result.fold(
      (error) => emit(OprosQuestionsError(message: error)),
      (questions) {
        final sorted = List<OprosQuestionModel>.from(questions)
          ..sort((a, b) => b.priority.compareTo(a.priority));
        emit(OprosQuestionsLoaded(questions: sorted));
      },
    );
  }

  Future<void> submitAnswers({
    required String surveyType,
    required List<OprosQuestionModel> questions,
    required Map<int, int> ratings,
    required Map<int, String> textAnswers,
  }) async {
    emit(const OprosSubmitting());

    final answers = questions.map((q) {
      if (q.isRate) {
        return {'question_id': q.id, 'rate': ratings[q.id] ?? 0};
      } else {
        return {'question_id': q.id, 'text': textAnswers[q.id] ?? ''};
      }
    }).toList();

    final result = await _submitOprosAnswersUseCase(
      surveyType: surveyType,
      answers: answers,
    );

    if (isClosed) return;
    result.fold(
      (error) => emit(OprosSubmitError(message: error)),
      (_) => emit(const OprosSubmitSuccess()),
    );
  }
}
