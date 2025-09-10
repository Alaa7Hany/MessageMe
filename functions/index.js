const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore"); // Import FieldValue
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

        // --- NEW LOGIC TO UPDATE UNREAD COUNTS ---
        // 1. Prepare an update object.
        const unreadCountsUpdate = {};

        // 2. For each member who is NOT the sender, increment their count.
        members.forEach((memberUid) => {
            if (memberUid !== senderUid) {
                // Use dot notation to update a specific field in the map.
                unreadCountsUpdate[`unread_counts.${memberUid}`] = FieldValue.increment(1);
            }
        });

        // 3. Atomically update the unread counts in the chat document.
        if (Object.keys(unreadCountsUpdate).length > 0) {
            await chatDocRef.update(unreadCountsUpdate);
            console.log(`Updated unread counts for chat ${chatId}`);
        }
        // --- END OF NEW LOGIC ---

        // The rest of the function for sending notifications remains the same.
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