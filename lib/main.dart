import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blyp_app/core/theme/app_theme.dart';
import 'package:blyp_app/presentation/responsive_wrapper.dart';
import 'package:blyp_app/presentation/landing/landing_screen.dart';
import 'package:blyp_app/presentation/interests/interest_selection_screen.dart';
import 'package:blyp_app/presentation/matching/matching_screen.dart';
import 'package:blyp_app/presentation/chat/chat_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(
      path: '/interests',
      builder: (context, state) => const InterestSelectionScreen(),
    ),
    GoRoute(
      path: '/matching',
      builder: (context, state) => const MatchingScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final roomId = state.extra as String? ?? 'default_room';
        return ChatScreen(roomId: roomId);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blyp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      builder: (context, child) => ResponsiveWrapper(child: child!),
    );
  }
}
