import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/extensions/date_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/data/models/event_attendance_model.dart';
import 'package:jaidem/features/events/data/services/event_firebase_service.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/widgets/video/event_video_player.dart';
import 'package:jaidem/features/events/presentation/widgets/reviews/event_reviews_section.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    super.key,
    required this.event,
  });

  final EventEntity event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final EventFirebaseService _firebaseService = EventFirebaseService();

  int _likeCount = 0;
  final bool _isLiked = false;

  bool get _isEventInFuture => widget.event.date.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadLikeData();
    context.read<EventsCubit>().fetchEventAttendances(widget.event.id);
  }

  Future<void> _loadLikeData() async {
    final count = await _firebaseService.getLikeCount(widget.event.id);

    if (mounted) {
      setState(() {
        _likeCount = count;
      });
    }
  }

  bool _isValidVideoUrl(String url) {
    if (url.isEmpty) return false;

    // Check for YouTube URLs
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return true;
    }

    // Check for direct video URLs
    final videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.mkv'];
    for (final ext in videoExtensions) {
      if (url.toLowerCase().contains(ext)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Card
                _buildMainInfoCard(),

                // Video Section
                if (_isValidVideoUrl(widget.event.video))
                  _buildVideoSection(),

                // Description Card
                _buildDescriptionCard(),

                // Conditions Card
                if (widget.event.conditions.isNotEmpty)
                  _buildConditionsCard(),

                // Contact Card
                _buildContactCard(),

                // Participants Section
                _buildParticipantsSection(),

                // Reviews Section - only show for past events
                if (!_isEventInFuture) ...[
                  const SizedBox(height: 8),
                  EventReviewsSection(eventId: widget.event.id),
                ] else ...[
                  // Show "Event has not happened yet" message for future events
                  _buildUpcomingEventMessage(),
                ],

                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.router.pop();
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        // Like Button
        GestureDetector(
          onTap: () {
            // Like functionality handled in card
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLiked ? AppColors.red : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_likeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              widget.event.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.shade300,
                        AppColors.primary.shade700,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Required Badge
            if (widget.event.isRequired)
              Positioned(
                bottom: 60,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('required'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Title
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Text(
                widget.event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date & Time
          _buildInfoItem(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            label: context.tr('event_date'),
            value: widget.event.date.toReadableDateWithTime(),
          ),

          const SizedBox(height: 16),

          // Location
          _buildInfoItem(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.orange,
            label: context.tr('event_location'),
            value: widget.event.location,
          ),

        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.play_circle_rounded,
                  color: AppColors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('event_video'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EventVideoPlayer(videoUrl: widget.event.video),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('event_description'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Html(
            data: widget.event.description,
            style: {
              "body": Style(
                fontSize: FontSize(14),
                color: Colors.grey.shade700,
                lineHeight: LineHeight(1.6),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(
                margin: Margins.only(bottom: 8),
              ),
              "a": Style(
                color: AppColors.primary,
                textDecoration: TextDecoration.none,
              ),
            },
            onLinkTap: (url, _, __) async {
              if (url != null) {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('event_conditions'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.event.conditions,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_phone_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('event_contact'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone
          if (widget.event.phone.isNotEmpty)
            GestureDetector(
              onTap: () => _makePhoneCall(widget.event.phone),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.event.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

          // Email
          if (widget.event.email.isNotEmpty)
            GestureDetector(
              onTap: () => _sendEmail(widget.event.email),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.event.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return BlocBuilder<EventsCubit, EventsState>(
      buildWhen: (prev, curr) =>
          prev.eventAttendancesStatus != curr.eventAttendancesStatus ||
          prev.eventAttendances != curr.eventAttendances,
      builder: (context, state) {
        if (state.eventAttendancesStatus == EventAttendancesStatus.loading) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (state.eventAttendancesStatus != EventAttendancesStatus.loaded ||
            state.eventAttendances == null) {
          return const SizedBox.shrink();
        }

        final data = state.eventAttendances!;
        final willGo = data.results
            .where((a) => a.status == 'will go')
            .toList();
        final willNotGo = data.results
            .where((a) => a.status == 'will not go')
            .toList();
        final maybe = data.results
            .where((a) => a.status == 'maybe')
            .toList();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('participants'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Counts summary
              Row(
                children: [
                  _buildCountChip(
                    '${data.willGoCount}',
                    context.tr('will_go'),
                    AppColors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildCountChip(
                    '${data.willNotGoCount}',
                    context.tr('will_not_go'),
                    AppColors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildCountChip(
                    '${data.maybeCount}',
                    context.tr('maybe'),
                    AppColors.orange,
                  ),
                ],
              ),

              // Will go list
              if (willGo.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAttendanceGroup(
                  context.tr('will_go'),
                  willGo,
                  AppColors.green,
                ),
              ],

              // Maybe list
              if (maybe.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildAttendanceGroup(
                  context.tr('maybe'),
                  maybe,
                  AppColors.orange,
                ),
              ],

              // Will not go list
              if (willNotGo.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildAttendanceGroup(
                  context.tr('will_not_go'),
                  willNotGo,
                  AppColors.red,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceGroup(
    String title,
    List<EventAttendanceItem> items,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${items.length})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.1),
                    backgroundImage: item.student.avatar.isNotEmpty
                        ? NetworkImage(item.student.avatar)
                        : null,
                    child: item.student.avatar.isEmpty
                        ? Icon(Icons.person_rounded,
                            size: 16, color: color)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.student.fullname,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildUpcomingEventMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('event_not_happened'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('reviews_after_event'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
