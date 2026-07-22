import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';
import 'package:jaidem/features/stories/presentation/cubit/stories_cubit.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoriesStrip extends StatefulWidget {
  const StoriesStrip({super.key});

  @override
  State<StoriesStrip> createState() => _StoriesStripState();
}

class _StoriesStripState extends State<StoriesStrip> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<StoriesCubit>();
    cubit.currentUserId = _readCurrentUserId();
    cubit.fetchFeed();
  }

  int? _readCurrentUserId() {
    final token = sl<SharedPreferences>().getString(AppConstants.accessToken);
    if (token == null || token.isEmpty) return null;
    try {
      final claims = JwtDecoder.decode(token);
      // Тот же порядок ключей, что и в AuthLocalDataSourceImpl.saveToken:
      // бэкенд (SIMPLE_JWT.USER_ID_CLAIM = 'user_id') кладёт id пользователя
      // именно в 'user_id', остальные ключи — защита на случай изменений.
      final raw = claims['sub'] ??
          claims['user_id'] ??
          claims['id'] ??
          claims['userId'];
      if (raw == null) return null;
      return raw is int ? raw : int.tryParse('$raw');
    } catch (_) {
      return null;
    }
  }

  Future<void> _addStory() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploading = true);
    final ok = await context.read<StoriesCubit>().createStory(File(picked.path));
    if (!mounted) return;
    setState(() => _isUploading = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('stories_create_failed'))),
      );
    }
  }

  void _openViewer(List<StoryGroupModel> groups, int index) {
    context.router.push(
      StoryViewerRoute(
        groups: groups,
        initialGroupIndex: index,
        currentUserId: context.read<StoriesCubit>().currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      builder: (context, state) {
        // Ошибку и загрузку не показываем: сторисы второстепенны и не должны
        // мешать списку участников. В худшем случае видно только «Твоя история».
        // Ретрай на этом экране не нужен: JaidemsPage сама вызывает
        // fetchFeed() заново при pull-to-refresh и при нажатии «Повторить»
        // в состоянии ошибки списка участников (см. jaidems_page.dart).
        final groups = state is StoriesLoaded
            ? state.groups
            : const <StoryGroupModel>[];
        final seen = state is StoriesLoaded ? state.seenStoryIds : const <int>{};

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: groups.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddTile();
                final group = groups[index - 1];
                final isSeen =
                    group.stories.every((s) => seen.contains(s.id));
                return _buildAuthorTile(
                  group: group,
                  isSeen: isSeen,
                  onTap: () => _openViewer(groups, index - 1),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTile() {
    return GestureDetector(
      onTap: _isUploading ? null : _addStory,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: _isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Icon(Icons.add_rounded,
                      color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('stories_your_story'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorTile({
    required StoryGroupModel group,
    required bool isSeen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSeen
                    ? null
                    : LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: isSeen
                    ? Border.all(color: Colors.grey.shade300, width: 2)
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary.shade100,
                  backgroundImage:
                      (group.author.avatar != null && group.author.avatar!.isNotEmpty)
                          ? NetworkImage(group.author.avatar!)
                          : null,
                  child: (group.author.avatar == null ||
                          group.author.avatar!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 22)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              group.author.fullname ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
