import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/jaidems/domain/usecases/get_jaidems_usecase.dart';

part 'jaidems_state.dart';

class JaidemsCubit extends Cubit<JaidemsState> {
  final GetJaidemsUsecase getJaidemsUsecase;

  JaidemsCubit({required this.getJaidemsUsecase}) : super(JaidemsInitial());

  List<PersonModel> allResults = [];
  String? nextUrl;
  String? previousUrl;

  Future<void> getJaidems({
    String? next,
    String? previous,
    String? flow,
    String? generation,
    String? university,
    String? speciality,
    String? age,
    String? search,
  }) async {
    try {
      if (next == null && previous == null) emit(JaidemsLoading());

      final result = await getJaidemsUsecase(
        next: next,
        previous: previous,
        flow: flow,
        generation: generation,
        university: university,
        speciality: speciality,
        age: age,
        search: search,
      );

      result.fold(
        (failure) => emit(JaidemsError(message: failure.toString())),
        (response) {
          if (next != null) {
            allResults.addAll(response.results);
          } else if (previous != null) {
            allResults.insertAll(0, response.results);
          } else {
            allResults = response.results;
          }

          nextUrl = response.next.isNotEmpty ? response.next : null;
          previousUrl = response.previous.isNotEmpty ? response.previous : null;

          emit(JaidemsLoaded(
            response: ResponseModel(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: allResults,
            ),
          ));
        },
      );
    } catch (e) {
      emit(JaidemsError(message: e.toString()));
    }
  }
}
