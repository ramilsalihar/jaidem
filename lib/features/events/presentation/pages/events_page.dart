import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/widgets/layout/event_pagination.dart';
import 'package:jaidem/features/menu/presentation/pages/app_drawer.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with NotificationMixin, Show {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // context.read<EventsCubit>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 40,
        backgroundColor: AppColors.backgroundColor,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              'assets/icons/menu.png',
              color: AppColors.primary,
              height: 24,
            ),
          ),
        ),
        title: Text(
          'Иш-чаралар',
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          GestureDetector(
            onTap: () => showNotificationPopup(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/icons/notification.png',
                color: AppColors.primary,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<EventsCubit, EventsState>(
          listener: (context, state) {
            if (state.attendanceStatus == AttendanceStatus.success) {
              showMessage(
                context,
                message: 'Сурам ийгиликтүү жөнөтүлдү!',
                backgroundColor: AppColors.green,
                textColor: Colors.white,
              );
            } else if (state.attendanceStatus == AttendanceStatus.error) {
              showMessage(
                context,
                message: 'Жөнөтүү ишке ашкан жок, кийинчерээк кайра аракет кылыңыз.',
                backgroundColor: AppColors.red,
                textColor: Colors.white,
              );
            }

            context.read<EventsCubit>().resetAttendanceStatus();
          },
          builder: (context, state) {
            if (state.eventsStatus == EventsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.eventsStatus == EventsStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Иш-чараларды жүктөөдө ката кетти',
                  style:
                      context.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              );
            }

            if (state.eventsStatus == EventsStatus.loaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Row(
                    //   children: [
                    //     Expanded(child: AppSearchField()),
                    //     const SizedBox(width: 8),
                    //     // AppFilterButton(),
                    //   ],
                    // ),
                    const SizedBox(height: 12),
                    EventPagination(
                      events: state.requiredEvents,
                      label: 'Милдеттүү иш-чаралар',
                    ),
                    const SizedBox(height: 12),
                    EventPagination(
                      events: state.optionalEvents,
                      label: 'Баары үчүн',
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
