import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final bool _isLoading = false;
  bool _isHighlighted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isHighlighted = true);
    });
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

          // Blurred Blobs
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
              child: const SizedBox(),
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
              child: const SizedBox(),
            ).blurred(blurRadius: 80),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header (Status Bar Placeholder if needed, but SafeArea handles standard status bar)
                        // We can add a top spacer if we want to push content down slightly like the design
                        const SizedBox(height: 20),

                        // Main Content
                        Column(
                          children: [
                            // Glowing Icon
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.6),
                                    blurRadius: 40,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Hero(
                                  tag: 'app-logo',
                                  child: Image.asset(
                                    'assets/logo/logobg.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Title
                            Text(
                              'Blyp',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontSize: 72,
                                    height: 1.0,
                                    letterSpacing: -2,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeInOut,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    fontSize: _isHighlighted ? 22 : 18,
                                    fontWeight: _isHighlighted 
                                        ? FontWeight.w700 
                                        : FontWeight.w600,
                                    color: _isHighlighted 
                                        ? const Color(0xFFE2E8F0) // lighter slate
                                        : const Color(0xFF64748B), // darker slate
                                    letterSpacing: _isHighlighted ? 1.0 : 0.5,
                                  ),
                              child: const Text('Connect, Chat, Vanish'),
                            ),
                            const SizedBox(height: 48),

                            // Feature Grid
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
                                  const Color(0xFFC084FC), // purple-400
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Bottom Action
                        Column(
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => context.push('/username'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
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
                              onPressed: () {
                                context.push('/how-it-works');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFCBD5E1),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.05,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const SizedBox(
                                width: double.infinity,
                                child: Center(child: Text('How it works')),
                              ),
                            ),
                            const SizedBox(height: 24),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(
                                        0xFF64748B,
                                      ), // slate-500
                                      letterSpacing: 0.5,
                                    ),
                                children: const [
                                  TextSpan(text: 'No login. No logs. '),
                                  TextSpan(
                                    text: 'Stay anonymous.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8), // slate-400
                                    ),
                                  ),
                                ],
                              ),
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
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1E293B,
            ).withValues(alpha: 0.5), // slate-800/50
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: const Color(0xFF64748B), // slate-500
            fontSize: 10,
          ),
        ),
      ],
    );
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
