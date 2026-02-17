# Blyp - Anonymous Interest-Based Chat

Blyp is a modern Flutter application designed to connect strangers for fleeting, meaningful conversations based on shared interests. It features a high-fidelity, dark-themed UI with neon accents coverage, glassmorphism effects, and fluid animations.

## 🚀 Project Goals

-   **Anonymity**: No complex sign-ups. users can start chatting instantly.
-   **Interest-Based Matching**: Connect with people who share your passions (Gaming, Tech, Music, etc.).
-   **Visual Excellence**: A premium, "cyberpunk-lite" aesthetic with smooth interactions.
-   **Privacy**: Built with a "privacy-first" mindset (End-to-End Encryption planned).

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/) (Channel: stable)
-   **Language**: Dart
-   **State Management**: [Riverpod](https://riverpod.dev/)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
-   **Styling**: Custom `ThemeData` with `GoogleFonts` (Plus Jakarta Sans, Inter).
-   **Backend (Planned)**: [Supabase](https://supabase.com/) for Authentication and Realtime database.
-   **Asset Generation**: `flutter_gen` (planned).

## 📂 Directory Structure

The project follows a **Feature-First Clean Architecture** within the `lib` folder to ensure scalability and maintainability:

```
lib/
├── core/                  # Core functionality (Theme, Constants, Utilities)
│   └── theme/             # App Theme definitions
├── data/                  # Data layer (Repositories, Data Sources)
├── domain/                # Domain layer (Entities, Use Cases)
├── presentation/          # UI layer (Screens, Widgets, Controllers)
│   ├── chat/              # Chat screen and logic
│   ├── interests/         # Interest selection feature
│   ├── landing/           # Landing page
│   ├── matching/          # Matching mechanics and UI
│   └── responsive_wrapper.dart # Wrapper for responsive layout
└── main.dart              # Entry point and routing configuration
```

## 📱 App Flow & Implementation Status

The user journey is designed to be frictionless and immersive:

1.  **Onboarding**: Users land on a visually striking welcome screen and proceed as anonymous users.
2.  **Personalization**: Users select their interests from a curated list to help the matching algorithm.
3.  **Discovery**: A radar-like matching screen searches for other users with similar interests.
4.  **Connection**: Once matched, users enter a private chat room to converse.

### 1. Landing Screen (`/`)
-   **Status**: ✅ Completed
-   **Features**:
    -    immersive radial gradient background.
    -   Blurred ambient light orbs.
    -   "Start Anonymous Chat" with glow effects.
    -   Supabase Auth bypass for development ease.

### 2. Interest Selection (`/interests`)
-   **Status**: ✅ Completed
-   **Features**:
    -   Search bar for filtering topics.
    -   Grid of selectable interest chips.
    -   Visual feedback for selected states.
    -   Direct navigation to matching.

### 3. Matching Screen (`/matching`)
-   **Status**: ✅ Completed
-   **Features**:
    -   Complex radar sweep animation using `AnimationController`.
    -   Pulsing "signal" rings.
    -   Glassmorphism stats badge & radar container.
    -   Simulated finding delay (5s).
    -   "Cancel" navigation logic.

### 4. Chat Screen (`/chat`)
-   **Status**: 🚧 Partially Implemented
-   **Features**:
    -   Basic UI shell.
    -   *Next Step*: Implement real-time message exchange via Supabase.

## 🧭 Navigation
The app uses a `GoRouter` configuration in `main.dart`.
-   **Push**: Used for forward navigation (`Landing` -> `Interests` -> `Matching`) to preserve the stack.
-   **PushReplacement**: Used when a match is found (`Matching` -> `Chat`) so back navigation skips the "Searching" screen.
-   **Pop**: Used for "Back" and "Cancel" actions.

## 🏃‍♂️ Getting Started

### 1. Prerequisites
- Flutter SDK
- Supabase CLI (`npm install -g supabase`)

### 2. Installation
```bash
git clone https://github.com/Faareh-Ahmed/Blyp.git
cd Blyp
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the root directory:
```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

### 4. Database Setup (Supabase)
Initialize and push the schema to your remote project:
```bash
supabase login
supabase link --project-ref your_project_ref
supabase db push
```

### 5. Run the App
```bash
flutter run
```

## 🔮 Roadmap

-   [ ] Integrate Supabase User Management (Anonymous Auth).
-   [ ] Implement Real-time DB triggers for matching logic.
-   [ ] Build full Chat UI with message bubbles and timestamps.
-   [ ] Add "Typing..." indicators and read receipts.
-   [ ] Implement End-to-End Encryption (E2EE) for messages.
