import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const accentColor = Color(0xFF22C55E); // green

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 40.0), // center the title balancing icon width
                      child: Text(
                        "How it Works",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Hero Image/Illustration Area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: 0.1),
                            accentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo/logobg.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Getting Started",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Steps Section
                    _buildStep(
                      icon: Icons.fingerprint,
                      iconColor: primaryColor,
                      title: "Set Your Identity",
                      description: "Enter a temporary name to stay anonymous. Change it whenever you like to keep things fresh.",
                      stepNumber: "Step 01",
                      hasLine: true,
                    ),
                    _buildStep(
                      icon: Icons.explore,
                      iconColor: accentColor,
                      title: "Pick Your Interests",
                      description: "Select tags that match your vibe. Our algorithm connects you with people sharing your pulse in real-time.",
                      stepNumber: "",
                      hasLine: true,
                      extraContent: Row(
                        children: [
                          _buildTag("#Tech", accentColor),
                          const SizedBox(width: 8),
                          _buildTag("#Gaming", primaryColor),
                          const SizedBox(width: 8),
                          _buildTag("#Music", const Color(0xFF94A3B8), bgColor: const Color(0xFF1E293B)),
                        ],
                      ),
                    ),
                    _buildStep(
                      icon: Icons.auto_delete,
                      iconColor: Colors.white,
                      title: "Chat & Vanish",
                      description: "Safety first. Your messages, media, and presence disappear instantly the moment you leave the chat room.",
                      stepNumber: "",
                      hasLine: false,
                      extraContent: Row(
                        children: const [
                          Icon(Icons.lock, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 4),
                          Text(
                            "End-to-end ephemeral encryption",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // CTA Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.5),
                            const Color(0xFF0F172A).withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Ready to start your first anonymous conversation?",
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/username'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: primaryColor.withValues(alpha: 0.2),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Got it, let's chat!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.forum, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  _buildAvatarPlaceholder(),
                                  Transform.translate(offset: const Offset(-8, 0), child: _buildAvatarPlaceholder()),
                                  Transform.translate(offset: const Offset(-16, 0), child: _buildAvatarPlaceholder()),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "1.2k people chatting now",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "By continuing, you agree to our ephemeral data policy.",
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String stepNumber,
    required bool hasLine,
    Widget? extraContent,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: iconColor),
                ),
              ),
              if (hasLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF334155),
                          const Color(0xFF1E293B),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      height: 1.5,
                    ),
                  ),
                  if (stepNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: iconColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stepNumber.toUpperCase(),
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (extraContent != null) ...[
                    const SizedBox(height: 16),
                    extraContent,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0F172A), width: 2),
      ),
      child: const Icon(Icons.person, size: 16, color: Color(0xFF94A3B8)),
    );
  }
}
