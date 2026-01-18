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
    String? region,
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
        region: region,
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

          nextUrl = response.next;
          previousUrl = response.previous;

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

  /// Check if there's a next page available
  bool get hasNextPage => nextUrl != null;

  /// Check if there's a previous page available
  bool get hasPreviousPage => previousUrl != null;

  /// Load next page if available
  Future<void> loadNextPage({
    String? flow,
    String? generation,
    String? university,
    String? speciality,
    String? age,
    String? search,
    String? region,
  }) async {
    if (hasNextPage) {
      await getJaidems(
        next: nextUrl,
        flow: flow,
        generation: generation,
        university: university,
        speciality: speciality,
        age: age,
        search: search,
        region: region,
      );
    }
  }

  /// Load previous page if available
  Future<void> loadPreviousPage({
    String? flow,
    String? generation,
    String? university,
    String? speciality,
    String? age,
    String? search,
    String? region,
  }) async {
    if (hasPreviousPage) {
      await getJaidems(
        previous: previousUrl,
        flow: flow,
        generation: generation,
        university: university,
        speciality: speciality,
        age: age,
        search: search,
        region: region,
      );
    }
  }

  /// Get a single person by ID
  Future<PersonModel?> getJaidemById(int id) async {
    try {
      final result = await getJaidemsUsecase.getById(id);
      return result.fold(
        (failure) => null,
        (person) => person,
      );
    } catch (e) {
      return null;
    }
  }
}
