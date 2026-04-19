import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();

  bool _isAnonymous = false;
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Page entrance animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    String username = _isAnonymous
        ? 'ANONYMOUS'
        : _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name or enable anonymous mode'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        await Supabase.instance.client.auth.signInAnonymously();
      }

      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'username': username,
          'is_searching': false,
        });
      }

      if (mounted) {
        context.push('/interests');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // 🔙 Back Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1E293B,
                        ).withValues(alpha: 0.5),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // 🧠 HERO ANIMATION (matches landing screen)
                        Hero(
                          tag: 'app-logo',
                          child: Image.asset(
                            'assets/logo/logobg.png',
                            width: 90,
                            height: 90,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Who are you today?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Pick a temporary name. It disappears after chat.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),

                        const SizedBox(height: 40),

                        // 🟣 Animated input container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            enabled: !_isAnonymous,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter username",
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔘 Animated toggle row
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: 1.0,
                          child: SwitchListTile(
                            title: const Text(
                              "Anonymous Mode",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: const Text(
                              "No identity stored",
                              style: TextStyle(color: Colors.white54),
                            ),
                            value: _isAnonymous,
                            onChanged: (val) {
                              setState(() {
                                _isAnonymous = val;
                                if (val) _usernameController.clear();
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🚀 BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleContinue,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Continue"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
