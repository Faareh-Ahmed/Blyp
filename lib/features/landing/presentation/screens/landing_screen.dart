import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with TickerProviderStateMixin {
  final bool _isLoading = false;
  bool _isHighlighted = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Highlight text animation trigger
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isHighlighted = true);
    });

    // SCALE ANIMATION (button pulse)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // ROTATION ANIMATION (logo spin)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
          ),

          // Blurred blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ).blurred(blurRadius: 80),
          ),

          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ).blurred(blurRadius: 80),
          ),

          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),

                  // MAIN CONTENT
                  Column(
                    children: [
                      // 🔁 ROTATING LOGO + HERO
                      RotationTransition(
                        turns: _rotationController,
                        child: Hero(
                          tag: 'app-logo',
                          child: Image.asset(
                            'assets/logo/logobg.png',
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Blyp',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: 72, letterSpacing: -2),
                      ),

                      const SizedBox(height: 16),

                      // TEXT STYLE ANIMATION
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: _isHighlighted ? 22 : 18,
                          fontWeight: _isHighlighted
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _isHighlighted
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF64748B),
                        ),
                        child: const Text('Connect, Chat, Vanish'),
                      ),

                      const SizedBox(height: 48),

                      // FEATURES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureItem(
                            context,
                            Icons.lock_outline,
                            'Encrypted',
                            Theme.of(context).colorScheme.primary,
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.speed,
                            'Instant',
                            Theme.of(context).colorScheme.secondary,
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.visibility_off_outlined,
                            'Ghost',
                            const Color(0xFFC084FC),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // BOTTOM ACTION
                  Column(
                    children: [
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        // 🔁 SCALE ANIMATION BUTTON
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ElevatedButton(
                            onPressed: () => context.push('/username'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Start Anonymous Chat'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => context.push('/how-it-works'),
                        child: const Text('How it works'),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'No login. No logs. Stay anonymous.',
                        style: TextStyle(color: Colors.white54),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

// Blur extension
extension BlurredExtension on Widget {
  Widget blurred({required double blurRadius}) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
      child: this,
    );
  }
}
