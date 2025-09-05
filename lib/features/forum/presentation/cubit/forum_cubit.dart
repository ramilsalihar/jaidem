import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/domain/usecases/get_all_forums.dart';
import 'package:jaidem/features/forum/domain/usecases/get_forum_comment.dart';
import 'package:jaidem/features/forum/domain/usecases/post_forum_comment.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';

part 'forum_state.dart';

class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required this.getAllForums,
    required this.getForumComment,
    required this.postForumComment,
  }) : super(const ForumState());

  final GetAllForums getAllForums;
  final GetForumComment getForumComment;
  final PostForumComment postForumComment;

  Future<void> fetchAllForums() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getAllForums();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.toString()));
      },
      (forums) {
        emit(state.copyWith(isLoading: false, forums: forums, error: null));
      },
    );
  }

  Future<void> fetchForumComments(int forumId) async {
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));
    final result = await getForumComment(forumId);
    result.fold(
      (failure) {
        emit(state.copyWith(isCommentsLoading: false, commentsError: failure.toString()));
      },
      (comments) {
        emit(state.copyWith(isCommentsLoading: false, comments: comments, commentsError: null));
      },
    );
  }

  Future<void> submitForumComment(CommentEntity comment) async {
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));
    final result = await postForumComment(comment: comment);
    result.fold(
      (failure) {
        emit(state.copyWith(isCommentsLoading: false, commentsError: failure.toString()));
      },
      (comment) {
        emit(state.copyWith(isCommentsLoading: false, lastPostedComment: comment, commentsError: null));
      },
    );
  }
}
