import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';



class MenuRemoteDatasourceImpl implements MenuRemoteDatasource {
  final FirebaseFirestore firestore;

  const MenuRemoteDatasourceImpl(this.firestore);

  Future<void> seedDummyData() async {
    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    final usersRef = firestore.collection(AppConstants.usersCollection);

    // Dummy users
    final admin = {
      "id": "admin_1",
      "name": "Администратор",
      "photoUrl": "https://randomuser.me/api/portraits/lego/1.jpg",
      "role": "admin",
    };

    final mentor = {
      "id": "mentor_1",
      "name": "Наставник",
      "photoUrl": "https://randomuser.me/api/portraits/men/10.jpg",
      "role": "mentor",
    };

    final user1 = {
      "id": "user_1",
      "name": "Иван",
      "photoUrl": "https://randomuser.me/api/portraits/men/2.jpg",
      "role": "user",
    };

    final user2 = {
      "id": "user_2",
      "name": "Мария",
      "photoUrl": "https://randomuser.me/api/portraits/women/3.jpg",
      "role": "user",
    };

    final user3 = {
      "id": "3",
      "name": "Monkey D.Luffy",
      "photoUrl": "https://randomuser.me/api/portraits/men/4.jpg",
      "role": "user",
    };

    final allUsers = [admin, mentor, user1, user2, user3];

    // Clean up existing users and add new ones
    final existingUsers = await usersRef.get();
    for (final doc in existingUsers.docs) {
      await doc.reference.delete();
    }
    for (final user in allUsers) {
      await usersRef.doc(user['id'] as String).set(user);
    }

    // Clean up existing chats to avoid duplicates
    final existingChats = await chatsRef.get();
    for (final doc in existingChats.docs) {
      await doc.reference.delete();
    }

    // --- Chat 1: User and Mentor ---
    await _createDummyChat(
      chatsRef,
      user1,
      mentor,
      "Привет! Нужна помощь с карьерным планом.",
      [
        MessageModel(
          id: 'msg1',
          senderId: user1['id'] as String,
          receiverId: mentor['id'] as String,
          text: "Привет! Нужна помощь с карьерным планом.",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          readBy: [user1['id'] as String],
        ),
        MessageModel(
          id: 'msg2',
          senderId: mentor['id'] as String,
          receiverId: user1['id'] as String,
          text: "Конечно, Иван. Давай обсудим твои цели.",
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1, minutes: -5)),
          readBy: [mentor['id'] as String],
        ),
      ],
    );

    // --- Chat 2: User and Admin ---
    await _createDummyChat(
      chatsRef,
      user2,
      admin,
      "Здравствуйте, у меня вопрос по использованию приложения.",
      [
        MessageModel(
          id: 'msg3',
          senderId: user2['id'] as String,
          receiverId: admin['id'] as String,
          text: "Здравствуйте, у меня вопрос по использованию приложения.",
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          readBy: [user2['id'] as String],
        ),
        MessageModel(
          id: 'msg4',
          senderId: admin['id'] as String,
          receiverId: user2['id'] as String,
          text: "Добрый день, Мария. Слушаю вас.",
          createdAt:
              DateTime.now().subtract(const Duration(hours: 5, minutes: -2)),
          readBy: [admin['id'] as String],
        ),
      ],
    );

    // --- Chat 3: User to User ---
    await _createDummyChat(
      chatsRef,
      user1,
      user3,
      "Петр, привет! Как успехи с проектом?",
      [
        MessageModel(
          id: 'msg5',
          senderId: user1['id'] as String,
          receiverId: user3['id'] as String,
          text: "Петр, привет! Как успехи с проектом?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          readBy: [user1['id'] as String],
        ),
        MessageModel(
          id: 'msg6',
          senderId: user3['id'] as String,
          receiverId: user1['id'] as String,
          text: "Привет, Иван! Все идет по плану, скоро будет демо.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
          readBy: [user3['id'] as String],
        ),
      ],
    );

    print("✅ Dummy data in Russian has been seeded!");
  }

  Future<void> _createDummyChat(
    CollectionReference chatsRef,
    Map<String, dynamic> userA,
    Map<String, dynamic> userB,
    String lastMessage,
    List<MessageModel> messages,
  ) async {
    // Determine chat type based on user roles
    final String chatType;
    if (userB['role'] == 'mentor') {
      chatType = 'mentors';
    } else if (userB['role'] == 'admin') {
      chatType = 'admin';
    } else {
      chatType = 'users';
    }

    final chatData = {
      "participants": [userA['id'], userB['id']],
      "users": [userA, userB],
      "lastMessage": lastMessage,
      "lastMessageAt": messages.last.createdAt,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // Create chat under the appropriate type collection
    final chatDoc = await chatsRef.doc(chatType).collection('chats').add(chatData);
    final messagesRef = chatDoc.collection("messages");

    for (final msg in messages) {
      await messagesRef.add(msg.toFirestore());
    }
  }

  @override
  Future<ChatModel> createChat(
    String currentUserId,
    String otherUserId,
    List<Map<String, dynamic>> users,
  ) async {
    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    final existing = await chatsRef
        .where('participants', arrayContains: currentUserId)
        .get();

    // Try to find if chat already exists
    for (var doc in existing.docs) {
      final data = doc.data();
      if ((data['participants'] as List).contains(otherUserId)) {
        return ChatModel.fromFirestore(doc);
      }
    }

    // If not exists, create new
    final newChat = {
      'participants': [currentUserId, otherUserId],
      'users': users,
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await chatsRef.add(newChat);
    final snap = await docRef.get();
    return ChatModel.fromFirestore(snap);
  }

  @override
  Stream<List<ChatModel>> getChats(String userId) {
    // Create a reference to the base chats collection
    final chatsRef = firestore.collection(AppConstants.chatsCollection);

    // Create a stream of chat updates by listening to each subcollection
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      final results = await Future.wait([
        chatsRef
            .doc('mentors')
            .collection('chats')
            .where('participants', arrayContains: userId)
            .get(),
        chatsRef
            .doc('admin')
            .collection('chats')
            .where('participants', arrayContains: userId)
            .get(),
        chatsRef
            .doc('users')
            .collection('chats')
            .where('participants', arrayContains: userId)
            .get(),
      ]);

      final allChats = [
        ...results[0].docs.map((doc) => ChatModel.fromFirestore(doc)),
        ...results[1].docs.map((doc) => ChatModel.fromFirestore(doc)),
        ...results[2].docs.map((doc) => ChatModel.fromFirestore(doc)),
      ];

      // Sort by lastMessageAt
      allChats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return allChats;
    });
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId, String chatType) {
    return firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatType)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
    String chatType,
  ) async {
    final msgRef = firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatType)
        .collection(chatId)
        .doc(messageId);

    await msgRef.update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> sendMessage(
    String chatId,
    String chatType,
    MessageModel message,
  ) async {
    final chatRef = firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatType)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await chatRef.set(message.toFirestore());

    // update chat metadata
    await firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatType)
        .collection('chats')
        .doc(chatId)
        .update({
      'lastMessage': message.text,
      'lastMessageAt': message.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ChatUserModel>> getUsers() {
    return firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatUserModel.fromFirestore(doc))
            .toList());
  }
}
