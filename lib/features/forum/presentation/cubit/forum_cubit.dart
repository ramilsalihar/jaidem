import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'forum_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
}
