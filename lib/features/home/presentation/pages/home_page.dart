import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/menu/presentation/pages/app_drawer.dart';
import 'package:jaidem/features/notifications/data/models/dummy_data.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with NotificationMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Image.asset(
              'assets/icons/menu.png',
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_white.png',
          width: 100,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showNotificationPopup(dummyNotifications);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/icons/notification.png',
                height: 24,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchField(
              hintText: 'Search for places, events...',
              onChanged: (query) {
                // Handle search query changes
                print('Search query: $query');
              },
              onSubmitted: (query) {
                // Handle search submission
                print('Search submitted: $query');
              },
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
      drawer: const AppDrawer(),
    );
  }
}
