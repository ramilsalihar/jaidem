import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
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
  late final AnimationStatusListener _statusListener;
  late int _groupIndex;
  int _storyIndex = 0;

  /// true, если группы вообще нет или у выбранной группы нет сторисов —
  /// в этом случае показывать нечего и вьювер закрывается сразу после первого кадра.
  bool _isEmpty = false;

  /// true с момента первого вызова [_close] и до конца жизни виджета.
  ///
  /// auto_route анимирует закрытие страницы (реверс-транзишен ~300мс), и всё
  /// это время виджет остаётся mounted. Без этого флага статус-листенер
  /// контроллера, сработавший в эти 300мс, мог бы отметить следующую сторис
  /// как просмотренную (хотя она не показывалась) и вызвать повторный pop.
  bool _isClosing = false;

  StoryGroupModel get _group => widget.groups[_groupIndex];
  StoryModel get _story => _group.stories[_storyIndex];

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _statusListener = (status) {
      if (status == AnimationStatus.completed) _next();
    };
    _controller = AnimationController(vsync: this, duration: kStoryDuration)
      ..addStatusListener(_statusListener);

    // Пока пользователь печатает ответ — держим сторис на паузе, как при
    // долгом нажатии. Расфокус (отправка/закрытие клавиатуры) снимает паузу.
    _replyFocus.addListener(_onReplyFocusChange);

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
        if (mounted) _close();
      });
      return;
    }

    _start();
  }

  void _start() {
    if (_isEmpty || _isClosing) return;
    context.read<StoriesCubit>().markSeen(_story.id);
    _controller
      ..reset()
      ..forward();
  }

  void _next() {
    if (_isClosing) return;
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
      _close();
    }
  }

  void _previous() {
    if (_isClosing) return;
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

  /// Единственная точка закрытия вьювера — X, свайп вниз, конец последней
  /// сторис последней группы и постдеятельность после удаления обязаны идти
  /// через неё. Гарантирует, что контроллер останавливается и `pop()`
  /// вызывается ровно один раз, независимо от того, какой путь закрытия
  /// сработал первым.
  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    _controller.stop();
    context.router.pop();
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
      if (!_isClosing) _controller.forward();
      return;
    }

    final ok = await storiesCubit.deleteStory(_story.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(ok ? 'stories_deleted' : 'error')),
      ),
    );
    if (mounted) _close();
  }

  void _onReplyFocusChange() {
    if (_isEmpty || _isClosing) return;
    if (_replyFocus.hasFocus) {
      _controller.stop();
    } else {
      _controller.forward();
    }
  }

  /// Ответ на сторис уходит автору в личный чат (chats/users/...) отдельным
  /// сообщением с миниатюрой сториса (photoUrl) — как в инстаграме. Best-effort:
  /// ошибка отправки не роняет вьювер, только тост.
  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final authorId = _group.author.id;
    final photo = _story.photo;
    final cubit = context.read<ChatCubit>();

    _replyController.clear();
    _replyFocus.unfocus();

    await cubit.sendMessageToUser(authorId.toString(), text, photoUrl: photo);
    if (!mounted) return;

    final failed = cubit.state.error != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(failed ? 'stories_reply_failed' : 'stories_reply_sent'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();
    _replyFocus.removeListener(_onReplyFocusChange);
    _replyFocus.dispose();
    _replyController.dispose();
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
          if ((details.primaryVelocity ?? 0) > 200) _close();
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
            if (!isOwn)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildReplyBar(),
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
    final relativeTime = _formatRelativeTime(_story.createdAt, context);

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
            child: Row(
              children: [
                Flexible(
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
                if (relativeTime.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    relativeTime,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isOwn)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          IconButton(
            onPressed: _close,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
    return GestureDetector(
      // Поглощаем тапы/вертикальные жесты в зоне ответа, чтобы они не долетали
      // до внешнего GestureDetector (переключение сторис и свайп-вниз-закрытие).
      onTap: () {},
      onVerticalDragUpdate: (_) {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 8,
          top: 10,
          bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocus,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendReply(),
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: context.tr('stories_reply_hint'),
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _sendReply,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Относительное время («2 ч назад») для шапки вьювера — тот же формат,
  /// что и в `ForumCard._formatDate`: локализованные суффиксы для минут/часов/
  /// дней и «дд месяц» для более старых дат. Здесь дата уже распарсена
  /// (см. `StoryModel.createdAt`), поэтому парсинг не дублируется.
  /// На фолбэк-эпохе (1970 год, см. `StoryModel.fromJson`) не падает — просто
  /// уходит в ветку «дд месяц».
  String _formatRelativeTime(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return context.tr('just_now');
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${context.tr('minutes_short')}';
    }
    if (diff.inHours < 24) return '${diff.inHours}${context.tr('hours_short')}';
    if (diff.inDays < 7) return '${diff.inDays}${context.tr('days_short')}';

    final day = date.day.toString().padLeft(2, '0');
    final month = _monthName(date.month);
    return '$day $month';
  }

  String _monthName(int month) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return months[month - 1];
  }
}
