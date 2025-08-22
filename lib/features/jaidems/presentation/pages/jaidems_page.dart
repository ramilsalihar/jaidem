import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/jaidems/data/datasources/dummy_data.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/cards/jaidem_card.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Create rows of 2 items each
                  if (index.isEven) {
                    final leftIndex = index ~/ 2 * 2;
                    final rightIndex = leftIndex + 1;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: JaidemCard(person: jaidemList[leftIndex]),
                          ),
                          if (rightIndex < jaidemList.length) ...[
                            const SizedBox(width: 15),
                            Expanded(
                              child: JaidemCard(person: jaidemList[rightIndex]),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                childCount: (jaidemList.length / 2).ceil(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
