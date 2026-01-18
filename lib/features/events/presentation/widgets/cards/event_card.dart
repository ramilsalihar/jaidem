import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/extensions/date_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/services/event_firebase_service.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/widgets/dialogs/event_dialog.dart';

class EventCard extends StatefulWidget {
  const EventCard({
    super.key,
    required this.event,
    this.isRequired = false,
  });

  final EventEntity event;
  final bool isRequired;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with EventDialog {
  final EventFirebaseService _firebaseService = EventFirebaseService();

  int _likeCount = 0;
  bool _isLiked = false;
  bool _isLikeLoading = false;

  bool get _isEventInFuture => widget.event.date.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadLikeData();
  }

  Future<void> _loadLikeData() async {
    final cubit = context.read<EventsCubit>();
    final userId = cubit.currentUserId;

    final count = await _firebaseService.getLikeCount(widget.event.id);
    final liked = userId.isNotEmpty
        ? await _firebaseService.hasUserLiked(widget.event.id, userId)
        : false;

    if (mounted) {
      setState(() {
        _likeCount = count;
        _isLiked = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    final cubit = context.read<EventsCubit>();
    final userId = cubit.currentUserId;

    if (userId.isEmpty) return;
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      final nowLiked = await _firebaseService.toggleLike(widget.event.id, userId);

      if (mounted) {
        setState(() {
          _isLiked = nowLiked;
          _likeCount = nowLiked ? _likeCount + 1 : _likeCount - 1;
          _isLikeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Header
          _buildImageHeader(),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  widget.event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Info Row - Date with Time
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  widget.event.date.toReadableDateWithTime(),
                ),

                const SizedBox(height: 4),

                _buildInfoRow(
                  Icons.location_on_outlined,
                  widget.event.location,
                ),

                const SizedBox(height: 10),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 8),

                // Detail Button
                _buildDetailButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(
            widget.event.image,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.shade200,
                      AppColors.primary.shade400,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.event_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              );
            },
          ),
        ),

        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),

        // Required Badge
        if (widget.isRequired)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Милдеттүү',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Like Badge - Clickable
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _toggleLike,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isLiked ? AppColors.red.withValues(alpha: 0.9) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLikeLoading)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isLiked ? Colors.white : AppColors.red,
                        ),
                      ),
                    )
                  else
                    Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.white : AppColors.red,
                      size: 14,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    '$_likeCount',
                    style: TextStyle(
                      color: _isLiked ? Colors.white : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.router.push(EventDetailRoute(event: widget.event));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade700,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Толук маалымат',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // If event date has passed, show "Event passed" indicator
    if (!_isEventInFuture) {
      return _buildEventPassedIndicator();
    }

    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final attendance = widget.event.attendance;
        final hasAnswered = attendance != null && attendance.status.isNotEmpty;

        if (hasAnswered) {
          // User has already answered - show current status with change option
          return _buildCurrentAttendanceStatus(attendance);
        }

        if (widget.isRequired) {
          // Required event - 3 buttons
          return Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Барам',
                  icon: Icons.check_rounded,
                  color: AppColors.green,
                  onTap: () => _handleAttendance('will go', 'will go'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  label: 'Барбайм',
                  icon: Icons.close_rounded,
                  color: AppColors.red,
                  onTap: () => _showDeclineDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  label: 'Ойлоном',
                  icon: Icons.help_outline_rounded,
                  color: AppColors.orange,
                  onTap: () => _handleAttendance('maybe', 'Думаю'),
                ),
              ),
            ],
          );
        } else {
          // Optional event - single button
          return _buildActionButton(
            label: 'Мен катышкым келет',
            icon: Icons.celebration_rounded,
            color: AppColors.green,
            onTap: () => _handleAttendance('will go', 'Хочу участвовать'),
            fullWidth: true,
          );
        }
      },
    );
  }

  Widget _buildEventPassedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Иш-чара өттү',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAttendanceStatus(AttendanceModel attendance) {
    final statusInfo = _getStatusInfo(attendance.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusInfo.icon,
            color: statusInfo.color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              statusInfo.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusInfo.color,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showChangeAttendanceDialog(attendance),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Өзгөртүү',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color color, IconData icon}) _getStatusInfo(String status) {
    switch (status) {
      case 'will go':
        return (label: 'Барам', color: AppColors.green, icon: Icons.check_circle_rounded);
      case 'will not go':
        return (label: 'Барбайм', color: AppColors.red, icon: Icons.cancel_rounded);
      case 'maybe':
        return (label: 'Ойлоном', color: AppColors.orange, icon: Icons.help_rounded);
      default:
        return (label: status, color: Colors.grey, icon: Icons.info_rounded);
    }
  }

  void _showChangeAttendanceDialog(AttendanceModel currentAttendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Жообуңузду өзгөртүү',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              // Options
              _buildChangeOption(
                label: 'Барам',
                icon: Icons.check_rounded,
                color: AppColors.green,
                isSelected: currentAttendance.status == 'will go',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _updateAttendance(currentAttendance, 'will go', 'will go');
                },
              ),
              const SizedBox(height: 10),
              _buildChangeOption(
                label: 'Барбайм',
                icon: Icons.close_rounded,
                color: AppColors.red,
                isSelected: currentAttendance.status == 'will not go',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeclineDialogForUpdate(currentAttendance);
                },
              ),
              const SizedBox(height: 10),
              _buildChangeOption(
                label: 'Ойлоном',
                icon: Icons.help_outline_rounded,
                color: AppColors.orange,
                isSelected: currentAttendance.status == 'maybe',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _updateAttendance(currentAttendance, 'maybe', 'Думаю');
                },
              ),
              SizedBox(height: MediaQuery.of(bottomSheetContext).padding.bottom + 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChangeOption({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey.shade800,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _updateAttendance(AttendanceModel currentAttendance, String status, String reason) {
    final updatedAttendance = currentAttendance.copyWith(
      status: status,
      reason: reason,
    );
    context.read<EventsCubit>().updateAttendance(updatedAttendance);
  }

  void _showDeclineDialogForUpdate(AttendanceModel currentAttendance) {
    showEventDialog(onConfirm: (val) {
      if (val != null && val.isNotEmpty) {
        _updateAttendance(currentAttendance, 'will not go', val);
      }
    });
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: fullWidth ? 12 : 6,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: fullWidth ? 16 : 12,
            ),
            SizedBox(width: fullWidth ? 6 : 3),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fullWidth ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAttendance(String status, String reason) {
    final attendance = AttendanceModel(
      status: status,
      reason: reason,
      student: '',
      event: widget.event.id,
    );
    context.read<EventsCubit>().sendRequest(attendance);
  }

  void _showDeclineDialog() {
    showEventDialog(onConfirm: (val) {
      if (val != null && val.isNotEmpty) {
        final attendance = AttendanceModel(
          status: 'will not go',
          reason: val,
          student: '',
          event: widget.event.id,
        );
        context.read<EventsCubit>().sendRequest(attendance);
      }
    });
  }
}
