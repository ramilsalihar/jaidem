import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/jaidems/presentation/helpers/jaidem_filters.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/cards/jaidem_card.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/features/menu/presentation/pages/app_drawer.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';
import 'package:jaidem/features/stories/presentation/cubit/stories_cubit.dart';
import 'package:jaidem/features/stories/presentation/widgets/stories_strip.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  Timer? _debounce;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchJaidems();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onScroll() {
    if (_isLoadingMore) return;

    final cubit = context.read<JaidemsCubit>();

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
        faculty: filters['faculty'],
        speciality: filters['speciality'],
        ageMin: filters['age_min'],
        ageMax: filters['age_max'],
        search: searchQuery,
        state: filters['state'],
        region: filters['region'],
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
          faculty: filters['faculty'],
          speciality: filters['speciality'],
          ageMin: filters['age_min'],
          ageMax: filters['age_max'],
          search: searchQuery,
          state: filters['state'],
          region: filters['region'],
        );
  }

  /// Повторяет загрузку и списка участников, и ленты сторисов. Используется
  /// в явных пользовательских действиях "обновить" (pull-to-refresh и кнопка
  /// "Повторить" в состоянии ошибки), а не при каждом фильтре/поиске — так
  /// разовый сбой сети в StoriesCubit не остаётся замороженным навсегда, но
  /// лента не дёргается на каждое нажатие клавиши в поиске.
  void _retryAll() {
    _fetchJaidems();
    context.read<StoriesCubit>().fetchFeed();
  }

  bool _hasActiveFilters() {
    return hasActiveFilters();
  }

  void _showFilterModal() {
    showFilterModal(
      onApply: (newFilters) {
        setState(() {
          filters = newFilters;
        });
        _fetchJaidems();
      },
      onReset: () {
        setState(() {
          filters = {};
        });
        _fetchJaidems();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            FocusScope.of(context).unfocus();
          }
          return false;
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(innerBoxIsScrolled),
              const SliverToBoxAdapter(child: StoriesStrip()),
            ];
          },
          body: BlocBuilder<JaidemsCubit, JaidemsState>(
            builder: (context, state) {
              if (state is JaidemsLoading && !_isLoadingMore) {
                return _buildLoadingState();
              } else if (state is JaidemsError) {
                return _buildErrorState(state.message);
              } else if (state is JaidemsLoaded) {
                final jaidemList = state.response.results;

                if (jaidemList.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildJaidemsList(jaidemList);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      leadingWidth: 56,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          FocusScope.of(context).unfocus();
          _scaffoldKey.currentState?.openDrawer();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      title: Text(
        context.tr('jaidems'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showNotificationPopup();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.push(ChatListRoute());
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 10),
              _buildFilterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: context.tr('search_jaidems'),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused ? AppColors.primary : Colors.grey.shade400,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = null;
                    _fetchJaidems();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (query) {
          setState(() {});
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            searchQuery = query.isEmpty ? null : query;
            _fetchJaidems();
          });
        },
        onSubmitted: (query) {
          searchQuery = query.isEmpty ? null : query;
          _fetchJaidems();
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    final hasFilters = _hasActiveFilters();
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showFilterModal();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasFilters ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasFilters
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              color: hasFilters ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            if (hasFilters) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getActiveFilterCount().toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    return getActiveFilterCount();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('loading'),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('error_occurred'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryAll,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(context.tr('reload')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('jaidems_not_found'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('change_search_criteria'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJaidemsList(List jaidemList) {
    final currentUserId =
        sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
    final filtered = jaidemList
        .where((p) => p.id.toString() != currentUserId)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        _retryAll();
      },
      color: AppColors.primary,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        itemCount: (filtered.length / 2).ceil() + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, rowIndex) {
          // Loading indicator row
          if (rowIndex >= (filtered.length / 2).ceil()) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final leftIndex = rowIndex * 2;
          final rightIndex = leftIndex + 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: JaidemCard(person: filtered[leftIndex])),
                  const SizedBox(width: 12),
                  if (rightIndex < filtered.length)
                    Expanded(child: JaidemCard(person: filtered[rightIndex]))
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
