import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    String username = _isAnonymous ? 'ANONYMOUS' : _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a display name or enable Anonymous Mode')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // background-dark
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Logo Section
                        Image.asset(
                          'assets/logo/logobg.png', // Assuming this is correct
                          width: 96,
                          height: 96,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon if logo not found
                            return const Icon(Icons.person_outline, size: 48, color: Colors.blue);
                          },
                        ),
                        const SizedBox(height: 40),

                        // Typography
                        const Text(
                          "Who are you today?",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Pick a temporary display name. It vanishes with your chat.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF94A3B8), // slate-400
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Input Form Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text(
                              "Display Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8), // slate-400
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF334155), // slate-700
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _usernameController,
                                  enabled: !_isAnonymous,
                                  style: TextStyle(
                                    color: _isAnonymous ? Colors.white54 : Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Enter a username...",
                                    hintStyle: TextStyle(color: Color(0xFF64748B)), // slate-500
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: Icon(Icons.person_outline, color: Color(0xFF475569)), // slate-600
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Anonymous Mode Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Anonymous Mode",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Remain fully anonymous",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8), // slate-400
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isAnonymous,
                                onChanged: (value) {
                                  setState(() {
                                    _isAnonymous = value;
                                    if (value) {
                                      _usernameController.clear();
                                    }
                                  });
                                },
                                activeThumbColor: const Color(0xFF4ADE80), // #4ade80 green
                                inactiveTrackColor: const Color(0xFF334155), // slate-700
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // CTA Button
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: _handleContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              child: const Text(
                                "Continue to Tags",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 48),
                        
                        // Footer Meta
                        const Text(
                          "No account required. Stay anonymous.",
                          style: TextStyle(
                            color: Color(0xFF64748B), // slate-500
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
