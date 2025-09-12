import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:jaidem/features/notifications/presentation/widgets/card/notification_card.dart';

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  @override
  void initState() {
    context.read<NotificationsCubit>().fetchNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            );
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return SizedBox(
                height: size.width * 0.8,
                width: size.width * 0.8,
                child: Center(
                  child: Text('There are no notifications yet'),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 10,
              ),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.lightGrey,
                height: 20,
              ),
              itemBuilder: (_, index) {
                final item = notifications[index];
                return NotificationCard(item: item);
              },
            );
          } else if (state is NotificationsError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
