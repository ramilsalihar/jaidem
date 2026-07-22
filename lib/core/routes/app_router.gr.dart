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
class AddGoalRoute extends PageRouteInfo<AddGoalRouteArgs> {
  AddGoalRoute({Key? key, GoalModel? goal, List<PageRouteInfo>? children})
      : super(
          AddGoalRoute.name,
          args: AddGoalRouteArgs(key: key, goal: goal),
          initialChildren: children,
        );

  static const String name = 'AddGoalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddGoalRouteArgs>(
        orElse: () => const AddGoalRouteArgs(),
      );
      return AddGoalPage(key: args.key, goal: args.goal);
    },
  );
}

class AddGoalRouteArgs {
  const AddGoalRouteArgs({this.key, this.goal});

  final Key? key;

  final GoalModel? goal;

  @override
  String toString() {
    return 'AddGoalRouteArgs{key: $key, goal: $goal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddGoalRouteArgs) return false;
    return key == other.key && goal == other.goal;
  }

  @override
  int get hashCode => key.hashCode ^ goal.hashCode;
}

/// generated route for
/// [AddIndicatorPage]
class AddIndicatorRoute extends PageRouteInfo<AddIndicatorRouteArgs> {
  AddIndicatorRoute({
    Key? key,
    int? goalId,
    GoalIndicatorModel? existingIndicator,
    List<PageRouteInfo>? children,
  }) : super(
          AddIndicatorRoute.name,
          args: AddIndicatorRouteArgs(
            key: key,
            goalId: goalId,
            existingIndicator: existingIndicator,
          ),
          initialChildren: children,
        );

  static const String name = 'AddIndicatorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddIndicatorRouteArgs>(
        orElse: () => const AddIndicatorRouteArgs(),
      );
      return AddIndicatorPage(
        key: args.key,
        goalId: args.goalId,
        existingIndicator: args.existingIndicator,
      );
    },
  );
}

class AddIndicatorRouteArgs {
  const AddIndicatorRouteArgs({this.key, this.goalId, this.existingIndicator});

  final Key? key;

  final int? goalId;

  final GoalIndicatorModel? existingIndicator;

  @override
  String toString() {
    return 'AddIndicatorRouteArgs{key: $key, goalId: $goalId, existingIndicator: $existingIndicator}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddIndicatorRouteArgs) return false;
    return key == other.key &&
        goalId == other.goalId &&
        existingIndicator == other.existingIndicator;
  }

  @override
  int get hashCode =>
      key.hashCode ^ goalId.hashCode ^ existingIndicator.hashCode;
}

/// generated route for
/// [AddTaskPage]
class AddTaskRoute extends PageRouteInfo<AddTaskRouteArgs> {
  AddTaskRoute({
    Key? key,
    int? indicatorId,
    GoalTaskModel? existingTask,
    List<PageRouteInfo>? children,
  }) : super(
          AddTaskRoute.name,
          args: AddTaskRouteArgs(
            key: key,
            indicatorId: indicatorId,
            existingTask: existingTask,
          ),
          initialChildren: children,
        );

  static const String name = 'AddTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTaskRouteArgs>(
        orElse: () => const AddTaskRouteArgs(),
      );
      return AddTaskPage(
        key: args.key,
        indicatorId: args.indicatorId,
        existingTask: args.existingTask,
      );
    },
  );
}

class AddTaskRouteArgs {
  const AddTaskRouteArgs({this.key, this.indicatorId, this.existingTask});

  final Key? key;

  final int? indicatorId;

  final GoalTaskModel? existingTask;

  @override
  String toString() {
    return 'AddTaskRouteArgs{key: $key, indicatorId: $indicatorId, existingTask: $existingTask}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddTaskRouteArgs) return false;
    return key == other.key &&
        indicatorId == other.indicatorId &&
        existingTask == other.existingTask;
  }

  @override
  int get hashCode =>
      key.hashCode ^ indicatorId.hashCode ^ existingTask.hashCode;
}

/// generated route for
/// [AdvisorsPage]
class AdvisorsRoute extends PageRouteInfo<void> {
  const AdvisorsRoute({List<PageRouteInfo>? children})
      : super(AdvisorsRoute.name, initialChildren: children);

  static const String name = 'AdvisorsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdvisorsPage();
    },
  );
}

/// generated route for
/// [BottomBarPage]
class BottomBarRoute extends PageRouteInfo<BottomBarRouteArgs> {
  BottomBarRoute({
    Key? key,
    int initialIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
          BottomBarRoute.name,
          args: BottomBarRouteArgs(key: key, initialIndex: initialIndex),
          initialChildren: children,
        );

  static const String name = 'BottomBarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BottomBarRouteArgs>(
        orElse: () => const BottomBarRouteArgs(),
      );
      return BottomBarPage(key: args.key, initialIndex: args.initialIndex);
    },
  );
}

class BottomBarRouteArgs {
  const BottomBarRouteArgs({this.key, this.initialIndex = 0});

  final Key? key;

  final int initialIndex;

  @override
  String toString() {
    return 'BottomBarRouteArgs{key: $key, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BottomBarRouteArgs) return false;
    return key == other.key && initialIndex == other.initialIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialIndex.hashCode;
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
    required String chatType,
    String? chatId,
    String? userId,
    String? userName,
    String? userAvatar,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(
            key: key,
            chatType: chatType,
            chatId: chatId,
            userId: userId,
            userName: userName,
            userAvatar: userAvatar,
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
        chatType: args.chatType,
        chatId: args.chatId,
        userId: args.userId,
        userName: args.userName,
        userAvatar: args.userAvatar,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.chatType,
    this.chatId,
    this.userId,
    this.userName,
    this.userAvatar,
  });

  final Key? key;

  final String chatType;

  final String? chatId;

  final String? userId;

  final String? userName;

  final String? userAvatar;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, chatType: $chatType, chatId: $chatId, userId: $userId, userName: $userName, userAvatar: $userAvatar}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        chatType == other.chatType &&
        chatId == other.chatId &&
        userId == other.userId &&
        userName == other.userName &&
        userAvatar == other.userAvatar;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      chatType.hashCode ^
      chatId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userAvatar.hashCode;
}

/// generated route for
/// [EventDetailPage]
class EventDetailRoute extends PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    Key? key,
    required EventEntity event,
    List<PageRouteInfo>? children,
  }) : super(
          EventDetailRoute.name,
          args: EventDetailRouteArgs(key: key, event: event),
          initialChildren: children,
        );

  static const String name = 'EventDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventDetailRouteArgs>();
      return EventDetailPage(key: args.key, event: args.event);
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({this.key, required this.event});

  final Key? key;

  final EventEntity event;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, event: $event}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventDetailRouteArgs) return false;
    return key == other.key && event == other.event;
  }

  @override
  int get hashCode => key.hashCode ^ event.hashCode;
}

/// generated route for
/// [FilesPage]
class FilesRoute extends PageRouteInfo<void> {
  const FilesRoute({List<PageRouteInfo>? children})
      : super(FilesRoute.name, initialChildren: children);

  static const String name = 'FilesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FilesPage();
    },
  );
}

/// generated route for
/// [ForumDetailPage]
class ForumDetailRoute extends PageRouteInfo<ForumDetailRouteArgs> {
  ForumDetailRoute({
    Key? key,
    required int forumId,
    List<PageRouteInfo>? children,
  }) : super(
          ForumDetailRoute.name,
          args: ForumDetailRouteArgs(key: key, forumId: forumId),
          rawPathParams: {'id': forumId},
          initialChildren: children,
        );

  static const String name = 'ForumDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumDetailRouteArgs>(
        orElse: () => ForumDetailRouteArgs(forumId: pathParams.getInt('id')),
      );
      return ForumDetailPage(key: args.key, forumId: args.forumId);
    },
  );
}

class ForumDetailRouteArgs {
  const ForumDetailRouteArgs({this.key, required this.forumId});

  final Key? key;

  final int forumId;

  @override
  String toString() {
    return 'ForumDetailRouteArgs{key: $key, forumId: $forumId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForumDetailRouteArgs) return false;
    return key == other.key && forumId == other.forumId;
  }

  @override
  int get hashCode => key.hashCode ^ forumId.hashCode;
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
/// [JaidemDetailPage]
class JaidemDetailRoute extends PageRouteInfo<JaidemDetailRouteArgs> {
  JaidemDetailRoute({
    Key? key,
    required PersonModel person,
    List<PageRouteInfo>? children,
  }) : super(
          JaidemDetailRoute.name,
          args: JaidemDetailRouteArgs(key: key, person: person),
          initialChildren: children,
        );

  static const String name = 'JaidemDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JaidemDetailRouteArgs>();
      return JaidemDetailPage(key: args.key, person: args.person);
    },
  );
}

class JaidemDetailRouteArgs {
  const JaidemDetailRouteArgs({this.key, required this.person});

  final Key? key;

  final PersonModel person;

  @override
  String toString() {
    return 'JaidemDetailRouteArgs{key: $key, person: $person}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JaidemDetailRouteArgs) return false;
    return key == other.key && person == other.person;
  }

  @override
  int get hashCode => key.hashCode ^ person.hashCode;
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
/// [OprosSurveyPage]
class OprosSurveyRoute extends PageRouteInfo<OprosSurveyRouteArgs> {
  OprosSurveyRoute({
    Key? key,
    required String surveyType,
    List<PageRouteInfo>? children,
  }) : super(
          OprosSurveyRoute.name,
          args: OprosSurveyRouteArgs(key: key, surveyType: surveyType),
          initialChildren: children,
        );

  static const String name = 'OprosSurveyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OprosSurveyRouteArgs>();
      return OprosSurveyPage(key: args.key, surveyType: args.surveyType);
    },
  );
}

class OprosSurveyRouteArgs {
  const OprosSurveyRouteArgs({this.key, required this.surveyType});

  final Key? key;

  final String surveyType;

  @override
  String toString() {
    return 'OprosSurveyRouteArgs{key: $key, surveyType: $surveyType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OprosSurveyRouteArgs) return false;
    return key == other.key && surveyType == other.surveyType;
  }

  @override
  int get hashCode => key.hashCode ^ surveyType.hashCode;
}

/// generated route for
/// [PdfViewerPage]
class PdfViewerRoute extends PageRouteInfo<PdfViewerRouteArgs> {
  PdfViewerRoute({
    Key? key,
    required String pdfUrl,
    required String title,
    List<PageRouteInfo>? children,
  }) : super(
          PdfViewerRoute.name,
          args: PdfViewerRouteArgs(key: key, pdfUrl: pdfUrl, title: title),
          initialChildren: children,
        );

  static const String name = 'PdfViewerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PdfViewerRouteArgs>();
      return PdfViewerPage(
        key: args.key,
        pdfUrl: args.pdfUrl,
        title: args.title,
      );
    },
  );
}

class PdfViewerRouteArgs {
  const PdfViewerRouteArgs({
    this.key,
    required this.pdfUrl,
    required this.title,
  });

  final Key? key;

  final String pdfUrl;

  final String title;

  @override
  String toString() {
    return 'PdfViewerRouteArgs{key: $key, pdfUrl: $pdfUrl, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PdfViewerRouteArgs) return false;
    return key == other.key && pdfUrl == other.pdfUrl && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ pdfUrl.hashCode ^ title.hashCode;
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
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
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

/// generated route for
/// [StoryViewerPage]
class StoryViewerRoute extends PageRouteInfo<StoryViewerRouteArgs> {
  StoryViewerRoute({
    Key? key,
    required List<StoryGroupModel> groups,
    required int initialGroupIndex,
    required int? currentUserId,
    List<PageRouteInfo>? children,
  }) : super(
          StoryViewerRoute.name,
          args: StoryViewerRouteArgs(
            key: key,
            groups: groups,
            initialGroupIndex: initialGroupIndex,
            currentUserId: currentUserId,
          ),
          initialChildren: children,
        );

  static const String name = 'StoryViewerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StoryViewerRouteArgs>();
      return StoryViewerPage(
        key: args.key,
        groups: args.groups,
        initialGroupIndex: args.initialGroupIndex,
        currentUserId: args.currentUserId,
      );
    },
  );
}

class StoryViewerRouteArgs {
  const StoryViewerRouteArgs({
    this.key,
    required this.groups,
    required this.initialGroupIndex,
    required this.currentUserId,
  });

  final Key? key;

  final List<StoryGroupModel> groups;

  final int initialGroupIndex;

  final int? currentUserId;

  @override
  String toString() {
    return 'StoryViewerRouteArgs{key: $key, groups: $groups, initialGroupIndex: $initialGroupIndex, currentUserId: $currentUserId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StoryViewerRouteArgs) return false;
    return key == other.key &&
        const ListEquality().equals(groups, other.groups) &&
        initialGroupIndex == other.initialGroupIndex &&
        currentUserId == other.currentUserId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality().hash(groups) ^
      initialGroupIndex.hashCode ^
      currentUserId.hashCode;
}

/// generated route for
/// [TrainingDetailPage]
class TrainingDetailRoute extends PageRouteInfo<TrainingDetailRouteArgs> {
  TrainingDetailRoute({
    Key? key,
    required TrainingModel training,
    List<PageRouteInfo>? children,
  }) : super(
          TrainingDetailRoute.name,
          args: TrainingDetailRouteArgs(key: key, training: training),
          initialChildren: children,
        );

  static const String name = 'TrainingDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TrainingDetailRouteArgs>();
      return TrainingDetailPage(key: args.key, training: args.training);
    },
  );
}

class TrainingDetailRouteArgs {
  const TrainingDetailRouteArgs({this.key, required this.training});

  final Key? key;

  final TrainingModel training;

  @override
  String toString() {
    return 'TrainingDetailRouteArgs{key: $key, training: $training}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrainingDetailRouteArgs) return false;
    return key == other.key && training == other.training;
  }

  @override
  int get hashCode => key.hashCode ^ training.hashCode;
}

/// generated route for
/// [TrainingsPage]
class TrainingsRoute extends PageRouteInfo<void> {
  const TrainingsRoute({List<PageRouteInfo>? children})
      : super(TrainingsRoute.name, initialChildren: children);

  static const String name = 'TrainingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TrainingsPage();
    },
  );
}
