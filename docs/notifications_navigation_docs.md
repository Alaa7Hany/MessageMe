# Notification Tap Handling & Navigation

This document explains the system that navigates a user to the correct chat screen when a notification is tapped, regardless of whether the app is in the background or terminated.

---

### 1. The FCM Payload (`index.js`)

The Cloud Function that triggers on a new message sends a push notification via FCM. Crucially, it attaches a `data` payload to this notification.

-   **Payload:** `data: { chatId: "the_chat_document_id" }`
-   **Purpose:** This `chatId` is the key that tells the client app which chat screen to open.

---

### 2. Handling Taps from a **Backgrounded** App

-   **Trigger:** The `FirebaseMessaging.onMessageOpenedApp` listener in `NotificationService`. This stream fires when the app is running in the background and a notification is tapped.
-   **Action:** The listener immediately calls the `handleMessageNavigation(message)` method.

---

### 3. Handling Taps from a **Terminated** App

This scenario requires careful handling to avoid race conditions with the app's startup and login process.

1.  **Initial Check:** When the app starts, the `AuthCubit`'s constructor calls `_checkForInitialMessage()`, which awaits `FirebaseMessaging.instance.getInitialMessage()`. This method returns the notification data if the app was launched from a tap.
2.  **Store the Message:** The `RemoteMessage` is stored in a temporary variable (`_initialMessageFromTerminatedState`) within the `AuthCubit`.
3.  **Wait for Login:** The `setupAuthStateListener` proceeds. Once it confirms the user is successfully logged in and the initial UI (`HomePage`) is ready, it checks if a stored message exists.
4.  **Execute Navigation:** If a message was stored, it then calls `handleMessageNavigation(message)`. This delay ensures the app's navigator is initialized and ready to receive commands.

---

### 4. The `handleMessageNavigation` Method

This is the central navigation logic, located in `NotificationService`, and is called in both the background and terminated scenarios.

1.  **Extract `chatId`:** It gets the chat ID from the message's `data` payload.
2.  **Fetch Chat Data:** It uses `getIt<ChatsRepo>().getChatById(chatId)` to fetch the complete `ChatModel` from Firestore. This is necessary because the `MessagesPage` requires the full model as an argument.
3.  **Navigate:** It uses a global `NavigationService` (via `getIt`) to access the app's `GlobalKey<NavigatorState>` and calls `navigatorKey.currentState.pushNamed(...)`. Using a global key is essential for triggering navigation from outside the widget tree.

This dual-state handling ensures a consistent and reliable user experience for all notification interactions.