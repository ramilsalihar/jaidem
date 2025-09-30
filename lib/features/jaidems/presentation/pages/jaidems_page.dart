import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/cards/jaidem_card.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

class JaidemsPage extends StatefulWidget {
  const JaidemsPage({super.key});

  @override
  State<JaidemsPage> createState() => _JaidemsPageState();
}

class _JaidemsPageState extends State<JaidemsPage> with NotificationMixin {
  @override
  void initState() {
    super.initState();
    // Fetch Jaidems on page load
    context.read<JaidemsCubit>().getJaidems();
  }

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
            onTap: () => showNotificationPopup(),
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
                print('Search query: $query');
              },
              onSubmitted: (query) {
                print('Search submitted: $query');
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<JaidemsCubit, JaidemsState>(
        builder: (context, state) {
          if (state is JaidemsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JaidemsError) {
            return Center(child: Text(state.message));
          } else if (state is JaidemsLoaded) {
            final jaidemList = state.response.results;

            if (jaidemList.isEmpty) {
              return const Center(child: Text('No Jaidems found'));
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isEven) {
                          final leftIndex = index ~/ 2 * 2;
                          final rightIndex = leftIndex + 1;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                      JaidemCard(person: jaidemList[leftIndex]),
                                ),
                                if (rightIndex < jaidemList.length) ...[
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: JaidemCard(
                                        person: jaidemList[rightIndex]),
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
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
