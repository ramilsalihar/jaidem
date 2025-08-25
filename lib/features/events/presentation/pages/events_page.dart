import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_filter_button.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/events/presentation/widgets/layout/event_pagination.dart';
import 'package:jaidem/features/menu/presentation/pages/app_drawer.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with NotificationMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
          'Мероприятия',
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          GestureDetector(
            onTap: () => showNotificationPopup([]),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: AppSearchField()),
                const SizedBox(width: 8),
                AppFilterButton()
              ],
            ),
            const SizedBox(height: 16),
            const EventPagination(
              events: [
                'Event 1',
                'Event 2',
                'Event 3',
              ],
              label: 'Обязательные мероприятия',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
