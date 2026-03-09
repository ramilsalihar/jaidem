const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Trigger: New chat message
 * When a message is created in any chat subcollection,
 * send push notification to the receiver.
 *
 * Path: chats/{chatType}/chats/{chatId}/messages/{messageId}
 */
exports.onNewChatMessage = onDocumentCreated(
  "chats/{chatType}/chats/{chatId}/messages/{messageId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const messageData = snap.data();
    const senderId = messageData.senderId;
    const receiverId = messageData.receiverId;
    const text = messageData.text || "";

    if (!senderId || !receiverId) {
      console.log("Missing senderId or receiverId in message");
      return;
    }

    // Don't notify sender about their own message
    if (senderId === receiverId) return;

    const db = getFirestore();

    // Get receiver's FCM token
    const receiverDoc = await db.collection("users").doc(receiverId).get();
    if (!receiverDoc.exists) {
      console.log(`Receiver ${receiverId} not found in users collection`);
      return;
    }

    const receiverData = receiverDoc.data();
    const receiverToken = receiverData.fcmToken;
    if (!receiverToken || typeof receiverToken !== "string") {
      console.log(`No valid FCM token for receiver ${receiverId}`);
      return;
    }

    // Get sender name from chat participants
    const { chatType, chatId } = event.params;
    const chatDoc = await db
      .collection("chats")
      .doc(chatType)
      .collection("chats")
      .doc(chatId)
      .get();

    let senderName = "Жаңы билдирүү";
    if (chatDoc.exists) {
      const chatData = chatDoc.data();
      const users = chatData.users || [];
      const sender = users.find((u) => u.id === senderId);
      if (sender && sender.name) {
        senderName = sender.name;
      }
    }

    const messaging = getMessaging();

    try {
      await messaging.send({
        token: receiverToken,
        notification: {
          title: senderName,
          body: text.length > 100 ? text.substring(0, 100) + "..." : text,
        },
        data: {
          type: "chat",
          chatType: chatType,
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
        },
      });
      console.log(`Chat notification sent to ${receiverId} from ${senderId}`);
    } catch (error) {
      console.log(`Error sending chat notification: ${error.message}`);

      // Clean up invalid token
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        await db.collection("users").doc(receiverId).update({
          fcmToken: null,
        });
        console.log(`Removed invalid token for user ${receiverId}`);
      }
    }
  }
);

/**
 * Trigger 1: New Firestore notification
 * When a document is created in "notifications" collection,
 * send push notification to ALL users with an FCM token.
 */
exports.onNewNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const notification = snap.data();
    const message = notification.message || "Жаңы билдирүү";

    const db = getFirestore();
    const usersSnapshot = await db
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const tokens = usersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token) => token && typeof token === "string");

    if (tokens.length === 0) {
      console.log("No FCM tokens found");
      return;
    }

    // FCM supports max 500 tokens per multicast
    const chunks = [];
    for (let i = 0; i < tokens.length; i += 500) {
      chunks.push(tokens.slice(i, i + 500));
    }

    const messaging = getMessaging();

    for (const chunk of chunks) {
      const response = await messaging.sendEachForMulticast({
        tokens: chunk,
        notification: {
          title: "Jaidem",
          body: message,
        },
        data: {
          type: "notification",
          notificationId: event.params.notificationId,
        },
      });

      console.log(
        `Sent: ${response.successCount}, Failed: ${response.failureCount}`
      );

      // Clean up invalid tokens
      response.responses.forEach((resp, idx) => {
        if (
          resp.error &&
          (resp.error.code === "messaging/invalid-registration-token" ||
            resp.error.code === "messaging/registration-token-not-registered")
        ) {
          const badToken = chunk[idx];
          // Find and remove the invalid token
          usersSnapshot.docs.forEach((doc) => {
            if (doc.data().fcmToken === badToken) {
              db.collection("users").doc(doc.id).update({
                fcmToken: null,
              });
              console.log(`Removed invalid token for user ${doc.id}`);
            }
          });
        }
      });
    }
  }
);

/**
 * Trigger 2: New training published
 * When a document is created in "training_notifications" collection,
 * send push notification only to users with the matching flowId.
 *
 * The Django backend should create a document like:
 * {
 *   "trainingName": "Training Title",
 *   "flowId": 327,
 *   "createdAt": Timestamp
 * }
 */
exports.onNewTraining = onDocumentCreated(
  "training_notifications/{docId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const trainingName = data.trainingName || "Жаңы тренинг";
    const flowId = data.flowId;

    if (!flowId) {
      console.log("No flowId in training_notifications document");
      return;
    }

    const db = getFirestore();
    const usersSnapshot = await db
      .collection("users")
      .where("flowId", "==", flowId)
      .where("fcmToken", "!=", null)
      .get();

    const tokens = usersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token) => token && typeof token === "string");

    if (tokens.length === 0) {
      console.log(`No users found for flowId ${flowId}`);
      return;
    }

    const messaging = getMessaging();

    const chunks = [];
    for (let i = 0; i < tokens.length; i += 500) {
      chunks.push(tokens.slice(i, i + 500));
    }

    for (const chunk of chunks) {
      const response = await messaging.sendEachForMulticast({
        tokens: chunk,
        notification: {
          title: "Jaidem",
          body: `Жаңы тренинг: ${trainingName}`,
        },
        data: {
          type: "training",
        },
      });

      console.log(
        `Training push for flow ${flowId}: Sent: ${response.successCount}, Failed: ${response.failureCount}`
      );
    }
  }
);
