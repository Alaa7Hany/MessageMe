const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
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

        const unreadCountsUpdate = {};
        members.forEach((memberUid) => {
            if (memberUid !== senderUid) {
                unreadCountsUpdate[`unread_counts.${memberUid}`] = FieldValue.increment(1);
            }
        });

        if (Object.keys(unreadCountsUpdate).length > 0) {
            await chatDocRef.update(unreadCountsUpdate);
            console.log(`Updated unread counts for chat ${chatId}`);
        }

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

        let notificationBody = '';
        if (messageData.type === 'image') {
            notificationBody = '📷 Attachment';
        } else {
            notificationBody = messageData.content;
        }

        const payload = {
            notification: {
                title: `${messageData.sender_name}`,
                body: notificationBody,
            },
            android: {
                notification: {
                    sound: "default",
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: "default",
                    },
                },
            },
            data: {
                chatId: chatId,
            },
        };

        const tokens = recipients.map((doc) => doc.data().fcm_token);
        console.log(`Sending notification to tokens: ${tokens}`);

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