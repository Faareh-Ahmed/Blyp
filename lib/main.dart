import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blyp_app/core/theme/app_theme.dart';
import 'package:blyp_app/core/widgets/responsive_wrapper.dart';
import 'package:blyp_app/features/landing/presentation/screens/landing_screen.dart';
import 'package:blyp_app/features/interests/presentation/screens/interest_selection_screen.dart';
import 'package:blyp_app/features/matching/presentation/screens/matching_screen.dart';
import 'package:blyp_app/features/matching/domain/models/match_result.dart';
import 'package:blyp_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:blyp_app/features/landing/presentation/screens/username_screen.dart';
import 'package:blyp_app/features/landing/presentation/screens/how_it_works_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(
      path: '/username',
      builder: (context, state) => const UsernameScreen(),
    ),
    GoRoute(
      path: '/how-it-works',
      builder: (context, state) => const HowItWorksScreen(),
    ),
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
        final matchResult = state.extra as MatchResult;
        return ChatScreen(
          roomId: matchResult.roomId,
          partnerId: matchResult.matchedUserId,
        );
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
