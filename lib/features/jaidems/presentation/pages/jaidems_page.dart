import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';

class JaidemsPage extends StatelessWidget {
  const JaidemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leadingWidth: 40,
        leading: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Image.asset(
              'assets/icons/menu.png',
              color: AppColors.primary,
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_colored.png',
          width: 100,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Handle search action
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/icons/notification.png',
                color: AppColors.primary,
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
    );
  }
}
