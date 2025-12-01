import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/app_search_field.dart';
import 'package:jaidem/features/forum/presentation/widgets/cards/forum_card.dart';
import 'package:jaidem/features/menu/presentation/pages/app_drawer.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with NotificationMixin {
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
            padding: const EdgeInsets.only(left: 15),
            child: Image.asset(
              'assets/icons/menu.png',
              height: 20,
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_white.png',
          width: 90,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showNotificationPopup();
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
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 12),
            child: AppSearchField(
              hintText: 'Жерлерди, иш-чараларды издеңиз...',
              onChanged: (query) {
                context.read<ForumCubit>().fetchAllForums(search: query);
              },
              onSubmitted: (query) {
                context.read<ForumCubit>().fetchAllForums(search: query);
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ForumCubit, ForumState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error != null) {
            return Center(child: Text('Error: \\${state.error}'));
          } else if (state.forums.isEmpty) {
            return const Center(child: Text('No forums found.'));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.forums.length,
            itemBuilder: (context, index) {
              return ForumCard(forum: state.forums[index]);
            },
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
