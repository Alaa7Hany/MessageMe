# Documentation: Push Notification Feature

This document outlines the architecture, implementation, and troubleshooting process for the push notification feature in the MessageMe application.

---

## 1. Feature Overview

The goal of this feature is to notify users of new messages in real-time, even when the application is in the background or terminated. This is achieved using a combination of Firebase services, including Firestore, Cloud Functions for Firebase, and Firebase Cloud Messaging (FCM).

### Core Architecture

The system is designed to be event-driven and secure, ensuring that the client application does not handle the complex logic of sending notifications.

1.  **Client-Side (Flutter App):** Responsible for registering a device to receive notifications and handling incoming notifications.
2.  **Trigger (Firestore):** A new message document created in Firestore acts as the trigger for the entire process.
3.  **Backend Logic (Cloud Function):** A serverless function wakes up in response to the trigger, prepares the notification, and sends it.
4.  **Delivery Service (FCM):** Firebase Cloud Messaging handles the final, complex delivery of the notification to the correct device via native OS services (APNs for iOS, Google Play Services for Android).



---

## 2. Implementation Steps

The implementation was divided into two main parts: the backend sender and the frontend receiver.

### Backend: Cloud Function (`index.js`)

A Node.js function was created and deployed to Firebase to handle the server-side logic.

-   **Trigger:** The function is configured to trigger whenever a new document is created at the path `Chats/{chatId}/Messages/{messageId}`.
-   **Logic:**
    1.  It retrieves the data from the new message document.
    2.  It reads the parent `Chat` document to get the list of `members`.
    3.  It filters out the message sender to create a list of recipients.
    4.  For each recipient, it looks up their `User` document in Firestore to find their saved FCM token.
    5.  It constructs the notification payload (title and body).
    6.  It sends the notification to the list of valid tokens using the Firebase Admin SDK.

### Frontend: Flutter Application

The Flutter app was updated to register for and handle notifications.

1.  **`notification_service.dart`:** A new service class was created to encapsulate all FCM-related logic, including:
    -   Requesting notification permissions from the user.
    -   Retrieving the unique FCM token for the device.
    -   Saving the token to the user's document in Firestore.
    -   Setting up listeners for foreground, background, and terminated notification events.
2.  **`user_model.dart`:** The `UserModel` was updated to include a nullable `fcm_token` field to store the device token.
3.  **`auth_cubit.dart`:** The `AuthCubit` was modified to call the `NotificationService` and save the FCM token immediately after a user successfully logs in or registers.

---

## 3. The Troubleshooting Journey

Implementing this feature involved solving a series of complex, interconnected issues related to security, configuration, and the testing environment.

### Problem 1: `PERMISSION_DENIED` from Firestore
-   **Symptom:** After implementing security rules, the app could no longer read data from Firestore.
-   **Cause:** The security rules were too restrictive. They blocked the `list` (query) and `get` (read) operations that the app and other rules depended on. A circular dependency was created where a rule needed to `get` a document to check permissions, but the `get` rule itself required those same permissions.
-   **Solution:** The Firestore rules were rewritten to be more specific, separating `get` and `list` permissions from `update` and `delete`. We used `resource.data` for update/delete operations to break the circular dependency.

### Problem 2: `404 Not Found` Error from Cloud Function
-   **Symptom:** The Cloud Function was triggering but crashing when trying to send the notification. The logs showed a `404 Not Found` error from the FCM service.
-   **Cause:** The project was missing a required backend API. For the Firebase Admin SDK to communicate with the messaging service, the **Firebase Cloud Messaging API** needed to be manually enabled in the Google Cloud Console.
-   **Solution:** We navigated to the Google Cloud API Library and enabled the "Firebase Cloud Messaging API" for the project.

### Problem 3: Invalid FCM Token Rejection
-   **Symptom:** After fixing the `404` error, the function ran successfully but the logs showed `success: false` and `failureCount: 1`. The FCM service was actively rejecting the token as invalid, even though it was correctly generated and saved.
-   **Cause:** This was the most difficult issue. It stemmed from a combination of a stale testing environment and an incomplete trust relationship between the app and the Firebase project.
-   **Solution:** This required a multi-step, definitive solution:
    1.  We confirmed the token was valid by sending a test message directly from the Firebase Console, which worked. This isolated the problem to the Cloud Function's code.
    2.  We rewrote the Cloud Function's sending logic from a batch request (`sendEachForMulticast`) to a more robust individual loop (`send`).
    3.  This revealed a final payload formatting error (`Unknown name "sound"`), which was fixed by removing the unsupported field.

This thorough process of elimination and correction finally resulted in the successful delivery of notifications, completing the feature implementation.