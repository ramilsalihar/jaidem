import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/training/data/models/training_model.dart';
import 'package:jaidem/features/training/domain/usecases/get_trainings_usecase.dart';

part 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final GetTrainingsUsecase getTrainingsUsecase;
  final GetTrainingByIdUsecase getTrainingByIdUsecase;
  final GetTrainingAnswersUsecase getTrainingAnswersUsecase;
  final GetNPSQuestionsUsecase getNPSQuestionsUsecase;
  final SubmitTrainingAnswerUsecase submitTrainingAnswerUsecase;

  TrainingCubit({
    required this.getTrainingsUsecase,
    required this.getTrainingByIdUsecase,
    required this.getTrainingAnswersUsecase,
    required this.getNPSQuestionsUsecase,
    required this.submitTrainingAnswerUsecase,
  }) : super(const TrainingInitial());

  Future<void> fetchTrainings() async {
    emit(const TrainingLoading());

    final result = await getTrainingsUsecase();

    result.fold(
      (error) => emit(TrainingError(message: error)),
      (trainings) => emit(TrainingLoaded(trainings: trainings)),
    );
  }

  Future<void> fetchTrainingById(int id) async {
    emit(const TrainingDetailLoading());

    final result = await getTrainingByIdUsecase(id);

    result.fold(
      (error) => emit(TrainingDetailError(message: error)),
      (training) => emit(TrainingDetailLoaded(training: training)),
    );
  }

  Future<void> checkTrainingAnswers({
    required int trainingId,
    required String authorId,
  }) async {
    emit(const TrainingAnswersLoading());

    final result = await getTrainingAnswersUsecase(
      trainingId: trainingId,
      authorId: authorId,
    );

    result.fold(
      (error) => emit(TrainingAnswersError(message: error)),
      (answers) => emit(TrainingAnswersLoaded(answers: answers)),
    );
  }

  Future<void> fetchNPSQuestions() async {
    emit(const NPSQuestionsLoading());

    final result = await getNPSQuestionsUsecase();

    result.fold(
      (error) => emit(NPSQuestionsError(message: error)),
      (questions) => emit(NPSQuestionsLoaded(questions: questions)),
    );
  }

  Future<void> submitAnswers({
    required List<NPSQuestion> questions,
    required Map<int, int> ratings,
    required String lastQuestionComment,
    required String authorId,
    required int trainingId,
  }) async {
    emit(const SubmittingAnswers());

    try {
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final isLastQuestion = i == questions.length - 1;

        final result = await submitTrainingAnswerUsecase(
          rate: isLastQuestion ? 0 : (ratings[question.id] ?? 0),
          comment: isLastQuestion ? lastQuestionComment : '',
          author: authorId,
          training: trainingId,
          question: question.id,
        );

        if (result.isLeft()) {
          result.fold(
            (error) => emit(SubmitAnswersError(message: error)),
            (_) {},
          );
          return;
        }
      }

      emit(const SubmitAnswersSuccess());
    } catch (e) {
      emit(SubmitAnswersError(message: e.toString()));
    }
  }
}
