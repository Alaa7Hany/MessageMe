const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendNewMessageNotification = onDocumentCreated(
    "Chats/{chatId}/Messages/{messageId}",
    async (event) => {
        const messageData = event.data.data();
        const chatId = event.params.chatId;
        const senderUid = messageData.sender_uid;

        const firestore = getFirestore();
        const chatDocRef = firestore.collection("Chats").doc(chatId);
        const chatDocSnap = await chatDocRef.get();

        if (!chatDocSnap.exists) {
            console.log(`Chat document ${chatId} does not exist.`);
            return;
        }

        const chatData = chatDocSnap.data();
        const members = chatData.members;

        const userPromises = members.map((uid) =>
            firestore.collection("Users").doc(uid).get(),
        );
        const userDocs = await Promise.all(userPromises);

        const recipients = userDocs.filter(
            (doc) => doc.id !== senderUid && doc.exists && doc.data().fcm_token,
        );

        if (recipients.length === 0) {
            console.log("No valid recipients to send notification to.");
            return;
        }

        const payload = {
            notification: {
                title: `New message from ${messageData.sender_name}`,
                body: messageData.content,

            },
            data: {
                chatId: chatId,
            },
        };

        const tokens = recipients.map((doc) => doc.data().fcm_token);
        console.log(`Sending notification to tokens: ${tokens}`);

        // --- THE FINAL FIX: Send messages individually ---
        // This is more robust than sending as a single batch.
        try {
            for (const token of tokens) {
                await getMessaging().send({
                    token: token,
                    ...payload,
                });
            }
            console.log("Successfully sent all messages.");
        } catch (error) {
            console.error("Error sending message:", error);
        }
    },
);