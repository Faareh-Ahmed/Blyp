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

## 📱 App Flow & Implementation Status

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

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/blyp_app.git
    cd blyp_app
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

4.  **Supabase Setup (Future)**:
    -   Update `main.dart` with your `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## 🔮 Roadmap

-   [ ] Integrate Supabase User Management (Anonymous Auth).
-   [ ] Implement Real-time DB triggers for matching logic.
-   [ ] Build full Chat UI with message bubbles and timestamps.
-   [ ] Add "Typing..." indicators and read receipts.
-   [ ] Implement End-to-End Encryption (E2EE) for messages.
