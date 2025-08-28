// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

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
  ChatRoute({
    Key? key,
    required String contactName,
    required String contactStatus,
    String? contactAvatarUrl,
    List<Message>? initialMessages,
    dynamic Function(String)? onSendMessage,
    VoidCallback? onBackPressed,
    VoidCallback? onAttachmentPressed,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(
            key: key,
            contactName: contactName,
            contactStatus: contactStatus,
            contactAvatarUrl: contactAvatarUrl,
            initialMessages: initialMessages,
            onSendMessage: onSendMessage,
            onBackPressed: onBackPressed,
            onAttachmentPressed: onAttachmentPressed,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return ChatPage(
        key: args.key,
        contactName: args.contactName,
        contactStatus: args.contactStatus,
        contactAvatarUrl: args.contactAvatarUrl,
        initialMessages: args.initialMessages,
        onSendMessage: args.onSendMessage,
        onBackPressed: args.onBackPressed,
        onAttachmentPressed: args.onAttachmentPressed,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.contactName,
    required this.contactStatus,
    this.contactAvatarUrl,
    this.initialMessages,
    this.onSendMessage,
    this.onBackPressed,
    this.onAttachmentPressed,
  });

  final Key? key;

  final String contactName;

  final String contactStatus;

  final String? contactAvatarUrl;

  final List<Message>? initialMessages;

  final dynamic Function(String)? onSendMessage;

  final VoidCallback? onBackPressed;

  final VoidCallback? onAttachmentPressed;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, contactName: $contactName, contactStatus: $contactStatus, contactAvatarUrl: $contactAvatarUrl, initialMessages: $initialMessages, onSendMessage: $onSendMessage, onBackPressed: $onBackPressed, onAttachmentPressed: $onAttachmentPressed}';
  }
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
