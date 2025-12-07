import 'package:flutter/gestures.dart';
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
  bool _expanded = false;

  /// Cuts text so it fills only 1 line exactly.
  String _trimToOneLine(
      String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    if (!tp.didExceedMaxLines) return text;

    // Binary search to find max text fitting 1 line
    int min = 0;
    int max = text.length;
    String result = text;

    while (min < max) {
      final mid = (min + max) ~/ 2;
      final tpMid = TextPainter(
        text: TextSpan(text: text.substring(0, mid), style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (tpMid.didExceedMaxLines) {
        max = mid - 1;
      } else {
        result = text.substring(0, mid);
        min = mid + 1;
      }
    }

    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fullText = widget.forum.content ?? 'Без названия';
    final style = context.textTheme.headlineMedium!;

    // Trim to 1 line
    final oneLineText = _trimToOneLine(fullText, style, size.width - 32);
    final isLong = oneLineText.length < fullText.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// RichText using line-based logic
          RichText(
            text: TextSpan(
              style: style,
              children: [
                TextSpan(
                  text: _expanded ? fullText : oneLineText,
                ),
                if (isLong)
                  TextSpan(
                    text: _expanded ? '  азыраак' : '...дагы',
                    style: style.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() => _expanded = !_expanded);
                      },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: SizedBox(
              height: 170,
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.forum.photo ?? AppConstants.defaultForumPost,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
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
