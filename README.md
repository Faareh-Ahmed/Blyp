# Blyp - Anonymous Interest-Based Chat

Blyp is a modern Flutter application designed to connect strangers for fleeting, meaningful conversations based on shared interests. It features a high-fidelity, dark-themed UI with neon accents, glassmorphism effects, and fluid animations.

## 🚀 Project Goals

-   **Anonymity**: No complex sign-ups. Users can start chatting instantly with Anonymous Authentication.
-   **Interest-Based Matching**: Connect with people who share your passions (Gaming, Tech, Music, etc.).
-   **Visual Excellence**: A premium, "cyberpunk-lite" aesthetic with smooth interactions.
-   **Privacy**: Built with a privacy-first mindset (Anonymous by default).

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/) (Channel: stable)
-   **Language**: Dart
-   **State Management**: [Riverpod](https://riverpod.dev/)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
-   **Styling**: Custom `ThemeData` with `GoogleFonts` (Plus Jakarta Sans, Inter).
-   **Backend**: [Supabase](https://supabase.com/)
    -   **Authentication**: Anonymous Sign-ins.
    -   **Realtime**: Presence (Online Users) and Postgres Changes (Matchmaking).
    -   **Database**: Postgres with Row Level Security (RLS).

## 📂 Directory Structure

The project follows a **Feature-First Clean Architecture** within the `lib` folder to ensure scalability and maintainability:

```
lib/
├── core/                  # Core functionality (Theme, Constants, Utilities)
│   └── theme/             # App Theme definitions
├── data/                  # Data layer (Repositories, Data Sources)
│   └── repositories/      # MatchRepository (Supabase interactions)
├── domain/                # Domain layer (Entities, Use Cases)
│   └── models/            # MatchResult, UserProfile
├── presentation/          # UI layer (Screens, Widgets, Controllers)
│   ├── chat/              # Chat screen and Realtime logic
│   ├── interests/         # Interest selection feature
│   ├── landing/           # Landing page with Auth logic
│   ├── matching/          # Matching mechanics (Radar UI, Presence)
│   └── responsive_wrapper.dart # Wrapper for responsive layout
└── main.dart              # Entry point and routing configuration
```

## 📱 App Flow & Implementation Status

The user journey is designed to be frictionless and immersive:

### 1. Landing Screen (`/`)
-   **Status**: ✅ Completed
-   **Features**:
    -   **Anonymous Authentication**: Automatically signs users in anonymously via Supabase Auth on entry.
    -   **Profile Creation**: silently creates a `profiles` entry for the new anonymous user.
    -   **UI**: Immersive radial gradient background with blurred ambient light orbs and "Start" interaction.

### 2. Interest Selection (`/interests`)
-   **Status**: ✅ Completed
-   **Features**:
    -   Search bar for filtering topics.
    -   Grid of selectable interest chips.
    -   Visual feedback for selected states.
    -   Direct navigation to matching.

### 3. Matching Screen (`/matching`)
-   **Status**: ✅ Completed (Realtime Integration)
-   **Features**:
    -   **Realtime Matchmaking**: Uses Supabase Realtime streams to listen for match events specifically for the current user.
    -   **Online User Count**: Displays a live count of active users using **Supabase Presence**.
    -   **UI**: Complex radar sweep animation, pulsing "signal" rings, and glassmorphism stats badge.
    -   **Logic**: Handles search cancellation and cleanup of database state.

### 4. Chat Screen (`/chat`)
-   **Status**: 🚧 Basic Implementation
-   **Features**:
    -   **Realtime Messaging**: Uses Supabase Broadcast channels for ephemeral message exchange.
    -   **UI**: Message bubbles, timestamping, and "typing" area.
    -   *Upcoming*: Persistent chat history (optional), Read receipts.

## 🗄️ Database & Security

### Schema
The app uses two main tables in Supabase:
1.  **`public.profiles`**:
    -   `id` (UUID, references `auth.users`)
    -   `interests` (Text Array)
    -   `is_searching` (Boolean)
2.  **`public.matches`**:
    -   `id` (UUID, Match Room ID)
    -   `user_1` (UUID)
    -   `user_2` (UUID)
    -   `created_at` (Timestamp)

### Security (RLS)
-   **Profiles**: Publicly readable (to allow matching), but only updateable by the owning user.
-   **Matches**: Restricted visibility. Users can only SELECT matches where they are either `user_1` or `user_2`.

## 🏃‍♂️ Getting Started

### 1. Prerequisites
-   Flutter SDK
-   Supabase Account

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

### 4. Supabase Setup
1.  **Create Project**: Start a new project on Supabase.
2.  **Enable Anonymous Auth**: Go to `Authentication` > `Providers` > `Anonymous` and toggle it **ON**.
3.  **Run Migrations**: Run the SQL scripts in `supabase/migrations` to set up tables and functions.
4.  **Enable Realtime**: Go to `Database` > `Replication` and enable replication for the `matches` table (or `supabase_realtime` publication).

### 5. Run the App
```bash
flutter run
```

## 🔮 Roadmap

-   [x] Integrate Supabase User Management (Anonymous Auth).
-   [x] Implement Real-time DB triggers for matching logic.
-   [x] Implement Realtime Online User Count (Presence).
-   [ ] Build full Chat UI with media support.
-   [ ] Implement End-to-End Encryption (E2EE) for messages.
