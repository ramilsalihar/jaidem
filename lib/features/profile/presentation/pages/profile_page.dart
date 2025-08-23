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
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileSignedOut) {
            // Navigate to login screen or handle sign out
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
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
                      // Add more profile widgets here
                      _buildProfileActions(),
                    ],
                  )
                else if (state is ProfileError)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load profile',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadUserProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  // Initial state or other states
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

  Widget _buildProfileActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Refresh button
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Profile'),
            onTap: _loadUserProfile,
          ),
          
          // Sign out button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showSignOutDialog(),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ProfileCubit>().signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
