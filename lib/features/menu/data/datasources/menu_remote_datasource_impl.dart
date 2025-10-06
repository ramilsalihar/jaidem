import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';



class MenuRemoteDatasourceImpl implements MenuRemoteDatasource {
  final FirebaseFirestore firestore;
  final SharedPreferences sharedPreferences;

  const MenuRemoteDatasourceImpl(this.firestore, this.sharedPreferences);

  Future<void> seedDummyData() async {
    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    final usersRef = firestore.collection(AppConstants.usersCollection);
    final mentorsRef = firestore.collection(AppConstants.mentorsCollection);
    final adminRef = firestore.collection(AppConstants.adminCollection);

    // Get current user ID from SharedPreferences
    final currentUserId = sharedPreferences.getString(AppConstants.userId) ?? 'current_user';

    // Admin data
    final admin = {
      "id": "admin_1",
      "name": "Администратор",
      "photoUrl": "https://randomuser.me/api/portraits/lego/1.jpg",
      "role": "admin",
    };

    // Mentor data
    final mentor = {
      "id": "mentor_1",
      "name": "Наставник Александр",
      "photoUrl": "https://randomuser.me/api/portraits/men/10.jpg",
      "role": "mentor",
    };

    // Current user (from SharedPreferences)
    final currentUser = {
      "id": currentUserId,
      "name": "Текущий пользователь",
      "photoUrl": "https://randomuser.me/api/portraits/men/1.jpg",
      "role": "user",
    };

    // Other dummy users
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
      "id": "user_3",
      "name": "Петр",
      "photoUrl": "https://randomuser.me/api/portraits/men/4.jpg",
      "role": "user",
    };

    final allUsers = [currentUser, user1, user2, user3];

    // Clean up existing collections and add new data
    final existingUsers = await usersRef.get();
    for (final doc in existingUsers.docs) {
      await doc.reference.delete();
    }
    
    final existingMentors = await mentorsRef.get();
    for (final doc in existingMentors.docs) {
      await doc.reference.delete();
    }
    
    final existingAdmins = await adminRef.get();
    for (final doc in existingAdmins.docs) {
      await doc.reference.delete();
    }

    // Add users to users collection
    for (final user in allUsers) {
      await usersRef.doc(user['id'] as String).set(user);
    }
    
    // Add mentor to mentors collection
    await mentorsRef.doc(mentor['id'] as String).set(mentor);
    
    // Add admin to admin collection
    await adminRef.doc(admin['id'] as String).set(admin);

    // Clean up existing chats to avoid duplicates
    final existingChats = await chatsRef.get();
    for (final doc in existingChats.docs) {
      await doc.reference.delete();
    }

    // --- Chat 1: Current User and Mentor ---
    await _createDummyChat(
      chatsRef,
      currentUser,
      mentor,
      "Привет! Нужна помощь с карьерным планом.",
      [
        MessageModel(
          id: 'msg1',
          senderId: currentUser['id'] as String,
          receiverId: mentor['id'] as String,
          text: "Привет! Нужна помощь с карьерным планом.",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          readBy: [currentUser['id'] as String],
        ),
        MessageModel(
          id: 'msg2',
          senderId: mentor['id'] as String,
          receiverId: currentUser['id'] as String,
          text: "Конечно! Давай обсудим твои цели и составим план развития.",
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1, minutes: -5)),
          readBy: [mentor['id'] as String],
        ),
      ],
    );

    // --- Chat 2: Current User and Admin ---
    await _createDummyChat(
      chatsRef,
      currentUser,
      admin,
      "Здравствуйте, у меня вопрос по использованию приложения.",
      [
        MessageModel(
          id: 'msg3',
          senderId: currentUser['id'] as String,
          receiverId: admin['id'] as String,
          text: "Здравствуйте, у меня вопрос по использованию приложения.",
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          readBy: [currentUser['id'] as String],
        ),
        MessageModel(
          id: 'msg4',
          senderId: admin['id'] as String,
          receiverId: currentUser['id'] as String,
          text: "Добрый день! Какой у вас вопрос? Готов помочь.",
          createdAt:
              DateTime.now().subtract(const Duration(hours: 5, minutes: -2)),
          readBy: [admin['id'] as String],
        ),
      ],
    );

    // --- Chat 3: Current User to Another User ---
    await _createDummyChat(
      chatsRef,
      currentUser,
      user1,
      "Иван, привет! Как дела с учебой?",
      [
        MessageModel(
          id: 'msg5',
          senderId: currentUser['id'] as String,
          receiverId: user1['id'] as String,
          text: "Иван, привет! Как дела с учебой?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          readBy: [currentUser['id'] as String],
        ),
        MessageModel(
          id: 'msg6',
          senderId: user1['id'] as String,
          receiverId: currentUser['id'] as String,
          text: "Привет! Все отлично, готовлюсь к экзаменам. А у тебя как дела?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
          readBy: [user1['id'] as String],
        ),
      ],
    );

    print("✅ Dummy data with current user ($currentUserId) has been seeded!");
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

  String _getCurrentUserId() {
    return sharedPreferences.getString(AppConstants.userId) ?? '';
  }

  @override
  Future<ChatModel?> getChatWithUser(String userId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return null;

    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    
    // Search in users subcollection
    final querySnapshot = await chatsRef
        .doc('users')
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(userId)) {
        return ChatModel.fromFirestore(doc);
      }
    }

    return null;
  }

  @override
  Future<ChatModel?> getChatWithMentor() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return null;

    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    
    // Search in mentors subcollection
    final querySnapshot = await chatsRef
        .doc('mentors')
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return ChatModel.fromFirestore(querySnapshot.docs.first);
    }

    return null;
  }

  @override
  Future<ChatModel?> getChatWithAdmin() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return null;

    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    
    // Search in admin subcollection
    final querySnapshot = await chatsRef
        .doc('admin')
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return ChatModel.fromFirestore(querySnapshot.docs.first);
    }

    return null;
  }

  Future<ChatUserModel?> _getUserById(String userId) async {
    try {
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return ChatUserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  Future<ChatUserModel?> _getMentor() async {
    try {
      final mentorsSnapshot = await firestore
          .collection(AppConstants.mentorsCollection)
          .limit(1)
          .get();
      
      if (mentorsSnapshot.docs.isNotEmpty) {
        return ChatUserModel.fromFirestore(mentorsSnapshot.docs.first);
      }
    } catch (e) {
      print('Error fetching mentor: $e');
    }
    return null;
  }

  Future<ChatUserModel?> _getAdmin() async {
    try {
      final adminSnapshot = await firestore
          .collection(AppConstants.adminCollection)
          .limit(1)
          .get();
      
      if (adminSnapshot.docs.isNotEmpty) {
        return ChatUserModel.fromFirestore(adminSnapshot.docs.first);
      }
    } catch (e) {
      print('Error fetching admin: $e');
    }
    return null;
  }

  Future<ChatModel> _createChatIfNotExists(
    String currentUserId,
    String otherUserId,
    String chatType,
    ChatUserModel currentUser,
    ChatUserModel otherUser,
  ) async {
    final chatsRef = firestore.collection(AppConstants.chatsCollection);
    
    final chatData = {
      'participants': [currentUserId, otherUserId],
      'users': [currentUser.toMap(), otherUser.toMap()],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await chatsRef
        .doc(chatType)
        .collection('chats')
        .add(chatData);
    
    final snap = await docRef.get();
    return ChatModel.fromFirestore(snap);
  }

  @override
  Future<void> sendMessageToUser(String userId, String messageText) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    // Check if chat exists
    ChatModel? chat = await getChatWithUser(userId);
    
    if (chat == null) {
      // Create new chat
      final currentUser = await _getUserById(currentUserId);
      final otherUser = await _getUserById(userId);
      
      if (currentUser == null || otherUser == null) {
        throw Exception('Users not found');
      }
      
      chat = await _createChatIfNotExists(
        currentUserId,
        userId,
        'users',
        currentUser,
        otherUser,
      );
    }

    // Send message
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: userId,
      text: messageText,
      createdAt: DateTime.now(),
      readBy: [currentUserId],
    );

    await sendMessage(chat.id, 'users', message);
  }

  @override
  Future<void> sendMessageToMentor(String messageText) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    // Get mentor
    final mentor = await _getMentor();
    if (mentor == null) {
      throw Exception('Mentor not found');
    }

    // Check if chat exists
    ChatModel? chat = await getChatWithMentor();
    
    if (chat == null) {
      // Create new chat
      final currentUser = await _getUserById(currentUserId);
      if (currentUser == null) {
        throw Exception('Current user not found');
      }
      
      chat = await _createChatIfNotExists(
        currentUserId,
        mentor.id,
        'mentors',
        currentUser,
        mentor,
      );
    }

    // Send message
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: mentor.id,
      text: messageText,
      createdAt: DateTime.now(),
      readBy: [currentUserId],
    );

    await sendMessage(chat.id, 'mentors', message);
  }

  @override
  Future<void> sendMessageToAdmin(String messageText) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    // Get admin
    final admin = await _getAdmin();
    if (admin == null) {
      throw Exception('Admin not found');
    }

    // Check if chat exists
    ChatModel? chat = await getChatWithAdmin();
    
    if (chat == null) {
      // Create new chat
      final currentUser = await _getUserById(currentUserId);
      if (currentUser == null) {
        throw Exception('Current user not found');
      }
      
      chat = await _createChatIfNotExists(
        currentUserId,
        admin.id,
        'admin',
        currentUser,
        admin,
      );
    }

    // Send message
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: admin.id,
      text: messageText,
      createdAt: DateTime.now(),
      readBy: [currentUserId],
    );

    await sendMessage(chat.id, 'admin', message);
  }
}
