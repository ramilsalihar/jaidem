import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/cards/jaidem_card.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class AdvisorsPage extends StatelessWidget {
  const AdvisorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JaidemsCubit>(),
      child: const _AdvisorsView(),
    );
  }
}

class _AdvisorsView extends StatefulWidget {
  const _AdvisorsView();

  @override
  State<_AdvisorsView> createState() => _AdvisorsViewState();
}

class _AdvisorsViewState extends State<_AdvisorsView> {
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAdvisors();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        isAdvisor: true,
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

  void _fetchAdvisors() {
    context.read<JaidemsCubit>().getJaidems(isAdvisor: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
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

              return _buildAdvisorsList(jaidemList);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      leadingWidth: 56,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.router.maybePop();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Text(
        context.tr('chat_with_mentor'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
              onPressed: _fetchAdvisors,
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
              context.tr('advisors_not_found'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('advisors_not_found_description'),
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

  Widget _buildAdvisorsList(List jaidemList) {
    final currentUserId =
        sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
    final filtered = jaidemList
        .where((p) => p.id.toString() != currentUserId)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        _fetchAdvisors();
      },
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: filtered.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return JaidemCard(person: filtered[index]);
        },
      ),
    );
  }
}
