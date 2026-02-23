# Campus Notes

A Flutter application designed for managing and organizing campus notes efficiently.

## 🚀 Setup Steps

To run this project locally, follow these steps:

1. **Ensure you have Flutter installed.**
   Check your Flutter version:
   ```bash
   flutter --version
   ```
   *Note: This project requires Flutter SDK.^3.9.2 or compatible.*

2. **Clone the repository.**
   (If applicable, replace with your actual repository URL)
   ```bash
   git clone https://github.com/jessojoseph/SJCET.git
   cd campus_notes
   ```

3. **Get dependencies.**
   Fetch the project packages using:
   ```bash
   flutter pub get
   ```

4. **Run the App.**
   Connect a device or start an emulator/simulator, then run:
   ```bash
   flutter run
   ```

## 📦 Dependencies Used

The project relies on several key packages (as defined in `pubspec.yaml`):

- **[flutter_bloc](https://pub.dev/packages/flutter_bloc) (^9.1.1):** For predictable state management using the BLoC pattern.
- **[equatable](https://pub.dev/packages/equatable) (^2.0.8):** To simplify equality comparisons in BLoC events and states.
- **[sqflite](https://pub.dev/packages/sqflite) (^2.4.2):** SQLite database plugin for local data storage.
- **[shared_preferences](https://pub.dev/packages/shared_preferences) (^2.5.4):** Used for platform-specific persistent storage for simple data (like user session).
- **[provider](https://pub.dev/packages/provider) (^6.1.5+1):** A wrapper around InheritedWidget to make them easier to use and more reusable.
- **[path_provider](https://pub.dev/packages/path_provider) (^2.1.5) & path (^1.9.1):** For finding commonly used locations on the filesystem, aiding in local database creation.
- **[google_fonts](https://pub.dev/packages/google_fonts) (^8.0.2):** For custom typography across the app.
- **[intl](https://pub.dev/packages/intl) (^0.20.2):** Provides internationalization and localized string formatting facilities (e.g., dates).
- **[cupertino_icons](https://pub.dev/packages/cupertino_icons) (^1.0.8):** Default icons used in Flutter.

## 🏗 Architecture Explanation

This application follows a structured, separation-of-concerns architecture centered around the **BLoC (Business Logic Component)** pattern to ensure scalability, testability, and clarity.

The `lib/` directory is organized into the following key folders:

* **`blocs/`**: Contains the core business logic (`auth_bloc.dart`, `notes_bloc.dart`). It handles events (like saving a note or authenticating a user) triggered by the UI and emits corresponding states.
* **`models/`**: Defines the data structures (`note_model.dart`, `user_model.dart`). These classes represent the entities handled by the app and often include `fromJson` / `toJson` capabilities.
* **`screens/`**: Contains the presentation layer (UI). Different screens (`home_screen.dart`, `onboarding_screen.dart`, `login_screen.dart`, etc.) are kept here. The screens primarily react to state changes emitted by the BLoCs.
* **`services/`**: Encapsulates external operations such as local database transactions (`database_service.dart`). The services interact directly with plugins like `sqflite` or APIs, providing a clean interface for the BLoCs to retrieve and store data.
* **`utils/`**: Contains helper classes and generic utilities (`responsive.dart`) that facilitate layout adaptations and overall app maintenance.
* **`widgets/`**: Houses reusable UI components (e.g., custom buttons, dialogs, cards) that are shared across multiple screens.
* **`theme/`**: Holds centralized thematic data (colors, text styles) making it easy to manage app-wide styling.
* **`main.dart`**: The entry point of the application where dependency injection (like BLoC providers) and basic configuration take place.

## ✨ Features & Functionalities

The application robustly handles end-to-end functionality for a student's note-taking needs:

* **1. User Authentication & Onboarding**: A fully functional, dynamic authentication system backed by an SQLite database (`users` table). It is not a dummy interface:
  * **Registration**: Users can create a new account by providing their name, email, password, and security question/answer. The data is securely inserted into the local SQLite database.
  * **Login**: Validates credentials against the stored database records.
  * **Session Persistence**: Upon a successful login, the `user_id` is securely stored in `SharedPreferences`. The app uses `CheckAuthStatusEvent` to bypass the login screen and load the active user's session without requiring them to re-enter credentials on subsequent app launches.
  * **Password Reset**: Users can recover accounts via their verified security questions, triggering a password update query.
  * **Logout**: Clears the active `user_id` from `SharedPreferences` and reverts the application state back to the unauthenticated onboarding/login interface.
* **2. Hierarchical Organization (Semesters > Subjects)**: Users can create dedicated spaces (Folders) representing individual Semesters and subjects, making sorting and retrieval significantly faster than a flat list.
* **3. Comprehensive Note Management**: Allows creating, viewing, editing, and deleting notes natively with rich responsive inputs.
* **4. Intelligent Search**: Real-time filtering and querying via the search bar within folders, making it easy to unearth required notes on-the-go.
* **5. Built-in Study Timer**: A productivity companion tool directly on the home screen tracks study duration allowing students to keep up with their learning goals contextually while reading notes.
* **6. Overview Analytics & Stats**: Dashboards summarizing key metrics like overall "Study Time" or "Total Notes" directly visible on user landing.
* **7. Local Data Persistence**: Powered by SQLite & SharedPreferences ensuring seamless offline usability and instantaneous load times. 
* **8. Modern & Accessible UI**: Distinct glassmorphic user interface paired with adaptable responsive design built to cater beautifully to multiple mobile displays.
