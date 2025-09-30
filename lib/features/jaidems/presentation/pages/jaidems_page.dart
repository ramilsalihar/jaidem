import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/jaidems/presentation/helpers/jaidem_filters.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/cards/jaidem_card.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

class JaidemsPage extends StatefulWidget {
  const JaidemsPage({super.key});

  @override
  State<JaidemsPage> createState() => _JaidemsPageState();
}

class _JaidemsPageState extends State<JaidemsPage>
    with NotificationMixin, JaidemFilters, AutomaticKeepAliveClientMixin {
  Map<String, String?> filters = {};
  String? searchQuery;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchJaidems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onScroll() {
    if (_isLoadingMore) return;

    final cubit = context.read<JaidemsCubit>();

    // Load more when near bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        cubit.nextUrl != null &&
        cubit.nextUrl!.isNotEmpty) {
      setState(() {
        _isLoadingMore = true;
      });

      cubit
          .getJaidems(
        next: cubit.nextUrl,
        flow: filters['flow'],
        generation: filters['generation'],
        university: filters['university'],
        speciality: filters['speciality'],
        age: filters['age'],
        search: searchQuery,
      )
          .whenComplete(() {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  void _fetchJaidems() {
    context.read<JaidemsCubit>().getJaidems(
          flow: filters['flow'],
          generation: filters['generation'],
          university: filters['university'],
          speciality: filters['speciality'],
          age: filters['age'],
          search: searchQuery,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            child: Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Поиск жайдемовцев...',
                    onChanged: (query) => searchQuery = query,
                    onSubmitted: (query) {
                      searchQuery = query;
                      _fetchJaidems();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showFilters(
                      onApply: (appliedFilters) {
                        filters = appliedFilters;
                        _fetchJaidems();
                      },
                      onReset: () {
                        filters = {};
                        _fetchJaidems();
                      },
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 45,
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(50)),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/filter.png',
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<JaidemsCubit, JaidemsState>(
        builder: (context, state) {
          if (state is JaidemsLoading && !_isLoadingMore) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JaidemsError) {
            return Center(child: Text(state.message));
          } else if (state is JaidemsLoaded) {
            final jaidemList = state.response.results;

            if (jaidemList.isEmpty) {
              return const Center(child: Text('No Jaidems found'));
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final leftIndex = index * 2;
                        final rightIndex = leftIndex + 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              ] else
                                const Spacer(),
                            ],
                          ),
                        );
                      },
                      childCount: (jaidemList.length / 2).ceil(),
                    ),
                  ),
                ),
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
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
