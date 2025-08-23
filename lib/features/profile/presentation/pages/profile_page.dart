import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:jaidem/features/profile/presentation/widgets/layout/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user profile when page initializes
    _loadUserProfile();
  }

  void _loadUserProfile() {
    context.read<ProfileCubit>().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leadingWidth: 130,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/images/profile_logo.png'),
        ),
        actions: [
          Image.asset(
            'assets/icons/notification.png',
            color: Colors.black,
            height: 24,
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
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (state is ProfileLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is ProfileLoaded)
                  Column(
                    children: [
                      ProfileHeader(person: state.user),
                      const SizedBox(height: 16),
                    ],
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Loading profile...'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
