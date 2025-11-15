# 👗 Fashion & Hairstyle Recommendation App (Flutter)

An AI-powered mobile app that recommends outfits and hairstyles based on your wardrobe and face shape. Built with Flutter and Riverpod, and connects to a Django backend for data and AI recommendations.

---

## ✨ Features

- 📷 Face shape detection using your camera (Google ML Kit)
- 👕 Upload wardrobe items (clothes, shoes, etc.)
- 🤖 AI-powered outfit and hairstyle recommendations
- 🔄 Save, delete, and filter wardrobe items
- 🔐 User authentication (integrated with backend)
- 🏷️ Category, color, and style filtering
- 🖼️ Robust image upload and display

---

## 🛠 Tech Stack

- **Flutter** (cross-platform mobile)
- **Riverpod** (state management)
- **Google ML Kit** (face detection)
- **Dart** (language)
- **CachedNetworkImage** (image loading)

---

## 📁 Directory Structure (lib/)

```
lib/
  main.dart                  # App entry point
  firebase_options.dart      # Firebase config (if used)
  core/                      # App-wide config, network, theme, utils
    config/                  # API URLs, environment
    network/                 # API client
    providers.dart           # Global providers
    theme/                   # Theme data
    utils/                   # Helper functions
    widgets/                 # Reusable widgets
  features/                  # All business logic and UI, by feature
    auth/                    # Authentication (login, signup)
    home/                    # Home screen
    mylooks/                 # Face shape detection
    onboarding/              # Onboarding screens
    profile/                 # User profile
    recommendations/         # Outfit recommendations
    shared/                  # Shared logic/widgets
    user/                    # User data/services
    wardrobe/                # Wardrobe management
      data/
        models/              # Data models (e.g., wardrobe_item.dart)
        repositories/        # Data logic
        services/            # API calls
      presentation/
        controllers/         # State management
      wardrobe_screen.dart   # Main wardrobe UI
  common_widgets/            # Reusable UI widgets
```

---

## 🧑‍💻 Architecture & Logic

- **Feature-based:** Each feature (wardrobe, recommendations, etc.) is self-contained.
- **State Management:** Uses Riverpod for robust, testable state.
- **Separation of Concerns:**
  - **Models:** Define data structures (e.g., WardrobeItem, Outfit)
  - **Services:** Handle API calls
  - **Controllers:** Manage state and business logic
  - **Screens:** UI and user interaction
- **Networking:** All API requests go through a central ApiClient.
- **Image Handling:** Uses CachedNetworkImage for smooth image loading.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code (with Flutter & Dart plugins)
- Android/iOS emulator or real device
- Access to the backend API (Django server running)

### Setup

1. **Clone the repository:**
   ```bash
   git clone <REPO_URL>
   cd new_fashion_app
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure API URL:**
   - Edit `lib/core/config/api_config.dart` and set the correct backend URL.
4. **Add assets:**
   - Make sure all images and icons are present in the `assets/` folder.
   - Check `pubspec.yaml` for asset paths.
5. **Run the app:**
   - On emulator/device:
     ```bash
     flutter run
     ```
   - On web:
     ```bash
     flutter run -d chrome
     ```

---

## 🏗️ How the App Works (Example Flows)

- **Wardrobe:**
  - View, upload, and delete wardrobe items.
  - Filter by category (Top, Bottom, Footwear, etc.).
- **Face Shape Detection:**
  - Uses camera to detect your face shape in real time.
  - Suggests hairstyles based on detected shape.
- **Recommendations:**
  - Fetches AI-generated outfit suggestions from backend.
  - Displays top, bottom, and footwear images for each outfit.

---

## 🧑‍🎓 For Developers & Contributors

- **Add a new feature:**
  - Create a new folder in `features/` and follow the same structure.
- **Add a new model/service/controller:**
  - Place it in the appropriate subfolder under its feature.
- **Add a new asset:**
  - Place it in `assets/` and update `pubspec.yaml`.
- **Global utilities:**
  - Place in `core/utils/` or `core/widgets/`.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Create a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
