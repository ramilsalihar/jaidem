import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/presentation/pages/goal_overview_page.dart';
import 'package:jaidem/features/goals/presentation/widgets/goal/circular_goal_progress.dart';
import 'package:jaidem/features/goals/presentation/widgets/goal/goal_expanded_content.dart';

class GoalCard extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isExpanded;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.readOnly = false,
    this.isExpanded = false,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return '31.12.2025';
    return '${deadline.day.toString().padLeft(2, '0')}.${deadline.month.toString().padLeft(2, '0')}.${deadline.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.readOnly) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GoalOverviewPage(
              goal: widget.goal,
              indicators: [],
            ),
          ));
        }
        ;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/goal_background.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.goal.title,
                    style: context.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CircularGoalProgress(progress: widget.goal.progress),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Срок цели: ${_formatDeadline(widget.goal.deadline)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: GoalExpandedContent(goal: widget.goal),
            ),
          ],
        ),
      ),
    );
  }
}
