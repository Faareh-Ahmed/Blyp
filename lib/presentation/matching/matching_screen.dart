import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blyp_app/presentation/matching/match_controller.dart';
import 'package:blyp_app/domain/models/match_result.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen>
    with TickerProviderStateMixin {
  late AppLifecycleListener _listener;
  late AnimationController _sweepController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Start searching immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchControllerProvider.notifier).startSearching();
    });

    _listener = AppLifecycleListener(onStateChange: _onStateChanged);
  }

  void _onStateChanged(AppLifecycleState state) {
    // If the app is hidden (backgrounded) or inactive, we might want to cancel search
    // to avoid phantom matches or battery usage.
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      ref.read(matchControllerProvider.notifier).cancelSearch();
      if (mounted) {
        context.pop(); // Exit screen
      }
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _cancelSearch() {
    ref.read(matchControllerProvider.notifier).cancelSearch();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF3C83F6); // Electric Blue
    final neonColor = const Color(0xFF22C55E); // Neon Green

    _listenToMatchState();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // background-dark
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ).blurred(blurRadius: 100),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: neonColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ).blurred(blurRadius: 100),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Status Bar Placeholder & Privacy Badge
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Privacy Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'END-TO-END ENCRYPTED',
                              style: GoogleFonts.plusJakartaSans(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Radar Section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Grid Background (Simulated with custom paint or simplified)
                              // Avoiding complex custom paint for grid for now, using radial pulse rings

                              // Pulsing Rings
                              _buildPulsingRing(
                                _pulseController,
                                0.0,
                                neonColor,
                              ),
                              _buildPulsingRing(
                                _pulseController,
                                0.3,
                                neonColor,
                              ),
                              _buildPulsingRing(
                                _pulseController,
                                0.6,
                                neonColor,
                              ),

                              // Radar Container (Glass Panel)
                              ClipOval(
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                    sigmaX: 12,
                                    sigmaY: 12,
                                  ),
                                  child: Container(
                                    width: 260,
                                    height: 260,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: neonColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Static Concentric Circles
                                        Center(
                                          child: Container(
                                            width: 195,
                                            height: 195,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: neonColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 130,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: neonColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: neonColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Crosshairs
                                        Center(
                                          child: Container(
                                            width: double.infinity,
                                            height: 1,
                                            color: neonColor.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 1,
                                            height: double.infinity,
                                            color: neonColor.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),

                                        // The Sweep
                                        RotationTransition(
                                          turns: _sweepController,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: SweepGradient(
                                                center: Alignment.center,
                                                startAngle: 0.0,
                                                endAngle: math.pi * 2,
                                                colors: [
                                                  neonColor.withValues(
                                                    alpha: 0.0,
                                                  ),
                                                  neonColor.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                ],
                                                stops: const [0.75, 1.0],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),

                                        // Active Signal Points (Random Dots)
                                        const Positioned(
                                          top: 52,
                                          left: 78,
                                          child: _SignalDot(size: 8, blur: 1),
                                        ),
                                        const Positioned(
                                          top: 169,
                                          left: 195,
                                          child: _SignalDot(
                                            size: 6,
                                            blur: 1,
                                            opacity: 0.6,
                                          ),
                                        ),
                                        const Positioned(
                                          top: 104,
                                          left: 156,
                                          child: _SignalDot(
                                            size: 10,
                                            blur: 2,
                                            opacity: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Center Point
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: neonColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: neonColor,
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Searching for a stranger...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Matching you based on interests',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8), // slate-400
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      // Stats Badge
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Blinking Effect for the Green Dot
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.5, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      curve: Curves.easeInOut,
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 12 * value,
                                          height: 12 * value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: neonColor.withValues(
                                              alpha: 1.0 - value,
                                            ),
                                          ),
                                        );
                                      },
                                      onEnd: () {},
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: neonColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: const Color(
                                        0xFFCBD5E1,
                                      ), // slate-300
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ref
                                            .watch(onlineUsersProvider)
                                            .when(
                                              data: (count) =>
                                                  '${count > 0 ? count : 1} ',
                                              error: (_, __) => '... ',
                                              loading: () => '... ',
                                            ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: 'users online now'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Cancel Button
                      GestureDetector(
                        onTap: _cancelSearch,
                        child: Column(
                          children: [
                            Text(
                              'Cancel',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8), // slate-400
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 32,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155), // slate-700
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToMatchState() {
    ref.listen<AsyncValue<MatchResult?>>(matchControllerProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (matchResult) {
          if (matchResult != null) {
            context.pushReplacement('/chat', extra: matchResult.roomId);
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error finding match: $error')),
          );
          // Optional: Retry logic or pop?
          // For now, let's just show error. User can cancel.
        },
        loading: () {},
      );
    });
  }

  Widget _buildPulsingRing(
    AnimationController controller,
    double delay,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + delay) % 1.0;
        final scale = 0.5 + (progress * 1.5); // Scale from 0.5 to 2.0
        final opacity = 0.8 * (1.0 - progress);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SignalDot extends StatelessWidget {
  final double size;
  final double blur;
  final double opacity;

  const _SignalDot({this.size = 8, this.blur = 1, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    ).blurred(blurRadius: blur);
  }
}

extension BlurredExtension on Widget {
  Widget blurred({required double blurRadius}) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
      child: this,
    );
  }
}
