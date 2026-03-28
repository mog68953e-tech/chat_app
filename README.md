# ✨ Flutter ChatApp

A production-ready, real-time chat application built with Flutter & Firebase.

## 🚀 Features

*   **Clean Architecture**: Separation of concerns across Data, Domain, and Presentation layers.
*   **State Management**: `flutter_bloc` (Cubit) for predictable state containers.
*   **Dependency Injection**: `get_it` for decoupling components.
*   **Authentication**: Firebase Auth (Email/Password & Google Sign-In) with custom Animated Splash Screen.
*   **Real-time Messaging**: Firestore streams for instant 1-on-1 chats.
*   **Message Types**: Text, Images (Firebase Storage), and Voice (record/audioplayers).
*   **Status Indicators**: Sent, Delivered, and Read receipts with visual checkmarks.
*   **Typing Indicator**: Real-time "Typing..." animations.
*   **UI/UX**: Custom WhatsApp-meets-Telegram styling, Dark/Light mode (persisted with Hive), smooth screen transitions (GoRouter), micro-interactions (Lottie & flutter_animate).
*   **User Directory**: Search and find registered users to start conversations.
*   **Profile**: Manage Display Name, Status, and Avatar (uploaded to Firebase Storage).

## 🛠️ Tech Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Auth, Cloud Firestore, Cloud Storage)
*   **Routing**: `go_router`
*   **Local DB**: `hive_flutter`
*   **Media**: `image_picker`, `record`, `audioplayers`, `cached_network_image`

---

## 🚦 Getting Started: Required Firebase Setup

Before running the application, you **must** configure Firebase. This codebase is fully generated but relies on a Firebase project.

### 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it (e.g., "ChatApp").
3. Disable Google Analytics (optional but faster setup).

### 2. Enable Firebase Services
In your Firebase project dashboard, enable the following services:
*   **Authentication**: Enable **Email/Password** and **Google** sign-in providers.
*   **Firestore Database**: Create the database in test mode (or configure secure rules).
*   **Cloud Storage**: Set up storage to save avatars, images, and voice notes.

### 3. Add Android App to Firebase
1. Click the **Android icon** (</>) in the project overview.
2. Enter the package name: `com.chatapp.chat_app` (or whatever you defined in `pubspec.yaml` / `android/app/build.gradle`).
3. **Important for Google Sign-In**: Add your SHA-1 certificate fingerprint.
   * *Run this in terminal to get the SHA-1:*
     ```bash
     cd android
     ./gradlew signingReport
     ```
   * Paste the resulting `SHA1` fingerprint into Firebase.
4. Download the `google-services.json` file.
5. Move the downloaded file into the `android/app/` folder of this project.

*(Optional)* Do the same for iOS by downloading `GoogleService-Info.plist` and placing it in `ios/Runner/`.

### 4. Install Dependencies & Run

```bash
# Get Flutter packages
flutter pub get

# Run the app
flutter run
```

## 📂 Architecture Overview
This app strictly follows Uncle Bob's Clean Architecture approach:

*   `Core`: Contains constants, error handling models, extensions, router, shared widgets, and Firebase service wrappers.
*   `Features`: Divided into `auth`, `chat`, `users`, and `profile`.
    *   `Data`: Models, serializers, remote/local datasources, and repository implementations.
    *   `Domain`: Entities, Use Cases, and repository interfaces.
    *   `Presentation`: UI Screens, Widgets, and Cubits handling the logic flow.
*   `Injection Container (get_it)`: Ties everything together using Dependency Injection.

---
*Built with ❤️ using Flutter x Firebase*
