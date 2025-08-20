import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'jaidems_state.dart';

class JaidemsCubit extends Cubit<JaidemsState> {
  JaidemsCubit() : super(JaidemsInitial());
}
