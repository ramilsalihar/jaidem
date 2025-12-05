import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/widgets/utils/forum_details.dart';

class ForumCard extends StatefulWidget {
  const ForumCard({super.key, required this.forum});

  final ForumEntity forum;

  @override
  State<ForumCard> createState() => _ForumCardState();
}

class _ForumCardState extends State<ForumCard> {
  bool _expanded = false; // initially collapsed

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Text(
              widget.forum.content ?? 'Без названия',
              style: context.textTheme.headlineMedium,
            ),
            secondChild: Text(
              widget.forum.content ?? 'Без названия',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium,
            ),
          ),

          const SizedBox(height: 5),

          /// Tapping the image toggles expand/collapse
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: SizedBox(
              height: 170,
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.forum.photo ?? AppConstants.defaultForumPost,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      AppConstants.defaultForumPost,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          ForumDetails(
            likesCount: widget.forum.likesCount,
            forumId: widget.forum.id,
            isLiked: widget.forum.isLikedByCurrentUser,
            onLikeTap: () {
              context.read<ForumCubit>().likeForumPost(widget.forum.id);
            },
          ),
        ],
      ),
    );
  }
}
