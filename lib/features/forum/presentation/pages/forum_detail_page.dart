import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/widgets/cards/forum_card.dart';

@RoutePage()
class ForumDetailPage extends StatelessWidget {
  final int forumId;

  const ForumDetailPage({
    super.key,
    @PathParam('id') required this.forumId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForumCubit>()..fetchForumById(forumId),
      child: _ForumDetailView(forumId: forumId),
    );
  }
}

class _ForumDetailView extends StatelessWidget {
  final int forumId;

  const _ForumDetailView({required this.forumId});

  void _loadForum(BuildContext context) {
    context.read<ForumCubit>().fetchForumById(forumId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          context.tr('post_single'),
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ForumCubit, ForumState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('post_not_found'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadForum(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(context.tr('reload')),
                  ),
                ],
              ),
            );
          }

          if (state.selectedForum != null) {
            return SingleChildScrollView(
              child: ForumCard(forum: state.selectedForum!),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
