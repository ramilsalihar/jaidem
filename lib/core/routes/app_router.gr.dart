// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddGoalPage]
class AddGoalRoute extends PageRouteInfo<void> {
  const AddGoalRoute({List<PageRouteInfo>? children})
      : super(AddGoalRoute.name, initialChildren: children);

  static const String name = 'AddGoalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddGoalPage();
    },
  );
}

/// generated route for
/// [AddTaskPage]
class AddTaskRoute extends PageRouteInfo<void> {
  const AddTaskRoute({List<PageRouteInfo>? children})
      : super(AddTaskRoute.name, initialChildren: children);

  static const String name = 'AddTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddTaskPage();
    },
  );
}

/// generated route for
/// [BottomBarPage]
class BottomBarRoute extends PageRouteInfo<void> {
  const BottomBarRoute({List<PageRouteInfo>? children})
      : super(BottomBarRoute.name, initialChildren: children);

  static const String name = 'BottomBarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BottomBarPage();
    },
  );
}

/// generated route for
/// [ChangePasswordPage]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
      : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordPage();
    },
  );
}

/// generated route for
/// [ChatListPage]
class ChatListRoute extends PageRouteInfo<void> {
  const ChatListRoute({List<PageRouteInfo>? children})
      : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatListPage();
    },
  );
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({Key? key, required String chatType, List<PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          args: ChatRouteArgs(key: key, chatType: chatType),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return ChatPage(key: args.key, chatType: args.chatType);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.chatType});

  final Key? key;

  final String chatType;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, chatType: $chatType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key && chatType == other.chatType;
  }

  @override
  int get hashCode => key.hashCode ^ chatType.hashCode;
}

/// generated route for
/// [GoalsPage]
class GoalsRoute extends PageRouteInfo<void> {
  const GoalsRoute({List<PageRouteInfo>? children})
      : super(GoalsRoute.name, initialChildren: children);

  static const String name = 'GoalsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GoalsPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [ProfileEditFormPage]
class ProfileEditFormRoute extends PageRouteInfo<void> {
  const ProfileEditFormRoute({List<PageRouteInfo>? children})
      : super(ProfileEditFormRoute.name, initialChildren: children);

  static const String name = 'ProfileEditFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileEditFormPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({Key? key, PersonModel? person, List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          args: ProfileRouteArgs(key: key, person: person),
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>(
        orElse: () => const ProfileRouteArgs(),
      );
      return ProfilePage(key: args.key, person: args.person);
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, this.person});

  final Key? key;

  final PersonModel? person;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, person: $person}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileRouteArgs) return false;
    return key == other.key && person == other.person;
  }

  @override
  int get hashCode => key.hashCode ^ person.hashCode;
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}
