# MessageMe - Flutter Chat Application

A real-time messaging application built with Flutter and Firebase, featuring one-on-one and group chats, user presence, media sharing, and message reactions.

---

## 📖 About The Project

MessageMe is a modern, real-time chat application designed to provide a seamless and responsive messaging experience. Built with Flutter for the frontend and Firebase for the backend, it offers a robust set of features including secure user authentication, instant messaging, and user presence indicators. The project follows a clean, feature-first architecture, making it scalable and easy to maintain.

---

## ✨ Features

* **Firebase Authentication:** Secure email & password login and registration.
* **Real-time Messaging:** Instant message delivery powered by Cloud Firestore streams.
* **Group Chats:** Create and participate in group conversations.
* **User Discovery:** Search for other registered users to start conversations.
* **Online Presence:** See when users are online and view their last active time.
* **Image Sharing:** Upload and share images in chats.
* **Message Reactions:** React to messages with emojis.
* **Unread Message Counter:** Keep track of unread messages in each chat.
* **Push Notifications:** Receive notifications for new messages even when the app is in the background, powered by FCM.
* **Connectivity Status:** Get notified when your connection status changes.
* **Remote Build Disabling:** Remotely disable older versions of the app using Firebase Remote Config.
* **Clean Architecture:** Code is organized by feature with a clear separation of UI, logic (Cubit), and data (Repository) layers.

---

## 🛠️ Built With

* **Framework:** [Flutter](https://flutter.dev/)
* **Backend & Database:** [Firebase](https://firebase.google.com/)
    * **Authentication:** Firebase Auth
    * **Database:** Cloud Firestore
    * **File Storage:** Firebase Cloud Storage
    * **Notifications:** Firebase Cloud Messaging
    * **Remote Config:** Firebase Remote Config
* **State Management:** [Flutter Bloc (Cubit)](https://bloclibrary.dev/)
* **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
* **Image Caching:** [cached\_network\_image](https://pub.dev/packages/cached_network_image)
* **Image Compression:** [flutter\_image\_compress](https://pub.dev/packages/flutter_image_compress)
