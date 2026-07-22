import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';
import 'package:jaidem/features/stories/presentation/cubit/stories_cubit.dart';

const Duration kStoryDuration = Duration(seconds: 5);

@RoutePage()
class StoryViewerPage extends StatefulWidget {
  final List<StoryGroupModel> groups;
  final int initialGroupIndex;
  final int? currentUserId;

  const StoryViewerPage({
    super.key,
    required this.groups,
    required this.initialGroupIndex,
    required this.currentUserId,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _groupIndex;
  int _storyIndex = 0;

  /// true, если группы вообще нет или у выбранной группы нет сторисов —
  /// в этом случае показывать нечего и вьювер закрывается сразу после первого кадра.
  bool _isEmpty = false;

  StoryGroupModel get _group => widget.groups[_groupIndex];
  StoryModel get _story => _group.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kStoryDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });

    if (widget.groups.isEmpty) {
      _groupIndex = 0;
      _isEmpty = true;
    } else {
      // Индекс из навигации может прийти за пределами списка — подстраховываемся.
      var index = widget.initialGroupIndex;
      if (index < 0) index = 0;
      if (index > widget.groups.length - 1) index = widget.groups.length - 1;
      _groupIndex = index;
      _isEmpty = _group.stories.isEmpty;
    }

    if (_isEmpty) {
      // Нельзя вызвать pop прямо в initState — планируем закрытие на следующий кадр.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.router.pop();
      });
      return;
    }

    _start();
  }

  void _start() {
    if (_isEmpty) return;
    context.read<StoriesCubit>().markSeen(_story.id);
    _controller
      ..reset()
      ..forward();
  }

  void _next() {
    if (_storyIndex < _group.stories.length - 1) {
      setState(() => _storyIndex++);
      _start();
    } else if (_groupIndex < widget.groups.length - 1) {
      setState(() {
        _groupIndex++;
        _storyIndex = 0;
      });
      _start();
    } else {
      context.router.pop();
    }
  }

  void _previous() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _start();
    } else if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _storyIndex = _group.stories.length - 1;
      });
      _start();
    }
  }

  Future<void> _confirmDelete() async {
    _controller.stop();
    final storiesCubit = context.read<StoriesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(context.tr('stories_delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.tr('stories_delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _controller.forward();
      return;
    }

    final ok = await storiesCubit.deleteStory(_story.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(ok ? 'stories_deleted' : 'error')),
      ),
    );
    if (mounted) context.router.pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      // Закрытие уже запланировано в initState — просто не даём build упасть.
      return const Scaffold(backgroundColor: Colors.black);
    }

    final isOwn = widget.currentUserId != null &&
        _group.author.id == widget.currentUserId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previous();
          } else {
            _next();
          }
        },
        onLongPressStart: (_) => _controller.stop(),
        onLongPressEnd: (_) => _controller.forward(),
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 200) context.router.pop();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                _story.photo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: Colors.white54, size: 48),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildProgressBars(),
                  _buildHeader(isOwn),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(_group.stories.length, (index) {
          return Expanded(
            child: Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final double value = index < _storyIndex
                      ? 1
                      : index == _storyIndex
                          ? _controller.value
                          : 0;
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(bool isOwn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.shade200,
            backgroundImage: (_group.author.avatar != null &&
                    _group.author.avatar!.isNotEmpty)
                ? NetworkImage(_group.author.avatar!)
                : null,
            child: (_group.author.avatar == null ||
                    _group.author.avatar!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _group.author.fullname ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOwn)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          IconButton(
            onPressed: () => context.router.pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
