import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:jaidem/features/profile/presentation/widgets/layout/profile_body.dart';
import 'package:jaidem/features/profile/presentation/widgets/layout/profile_header.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.person});

  final PersonModel? person;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with NotificationMixin {
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.person == null) {
      editMode = true;
      _loadUserProfile();
    }
  }

  void _loadUserProfile() {
    context.read<ProfileCubit>().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leadingWidth: editMode ? 130 : 40,
        leading: editMode
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset('assets/images/profile_logo.png'),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: !editMode
            ? Text(
                widget.person?.fullname ?? 'Профиль',
                style: context.textTheme.headlineLarge,
              )
            : null,
        actions: !editMode
            ? null
            : [
                GestureDetector(
                  onTap: () => showNotificationPopup(),
                  child: Image.asset(
                    'assets/icons/notification.png',
                    color: Colors.black,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Image.asset(
                  'assets/icons/menu.png',
                  color: Colors.black,
                  height: 16,
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user =
              widget.person ?? (state is ProfileLoaded ? state.user : null);

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ProfileHeader(person: user),
                ProfileBody(
                  person: user,
                  canEdit: editMode,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
