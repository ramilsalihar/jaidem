import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/jaidems/domain/usecases/get_jaidems_usecase.dart';

part 'jaidems_state.dart';

class JaidemsCubit extends Cubit<JaidemsState> {
  JaidemsCubit({
    required this.getJaidemsUsecase,
  }) : super(JaidemsInitial());

  final GetJaidemsUsecase getJaidemsUsecase;

  /// Get Jaidems list
  Future<void> getJaidems() async {
    try {
      emit(JaidemsLoading());

      final result = await getJaidemsUsecase();

      result.fold(
        (failure) => emit(JaidemsError(message: failure.toString())),
        (response) => emit(JaidemsLoaded(response: response)),
      );
    } catch (e) {
      emit(JaidemsError(message: e.toString()));
    }
  }
}
