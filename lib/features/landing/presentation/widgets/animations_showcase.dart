
import 'package:flutter/material.dart';

class AnimationsShowcase extends StatefulWidget {
  const AnimationsShowcase({super.key});

  @override
  State<AnimationsShowcase> createState() => _AnimationsShowcaseState();
}

class _AnimationsShowcaseState extends State<AnimationsShowcase>
    with SingleTickerProviderStateMixin {
  bool _isToggled = false;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isToggled = !_isToggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. AnimatedPositioned
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: _isToggled ? 20 : 100,
              left: _isToggled ? 20 : 100,
              child: const Icon(Icons.star, color: Colors.yellow, size: 50),
            ),
            
            // 2. AnimatedOpacity
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isToggled ? 1.0 : 0.2,
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 80),
            ),

            // 3. AnimatedContainer
            Align(
              alignment: Alignment.bottomRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _isToggled ? 80 : 120,
                height: _isToggled ? 80 : 40,
                decoration: BoxDecoration(
                  color: _isToggled ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(_isToggled ? 40 : 8),
                ),
                alignment: Alignment.center,
                child: Text(_isToggled ? 'ON' : 'OFF', style: const TextStyle(color: Colors.white)),
              ),
            ),

            // 4. AnimatedDefaultTextStyle
            Align(
              alignment: Alignment.bottomLeft,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  fontSize: _isToggled ? 24 : 14,
                  fontWeight: _isToggled ? FontWeight.bold : FontWeight.normal,
                  color: _isToggled ? Colors.green : Colors.grey,
                ),
                child: const Text("Tap Me!"),
              ),
            ),

            // 5. ScaleTransition
            Align(
              alignment: Alignment.topCenter,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(Icons.favorite, color: Colors.pink, size: 60),
              ),
            ),

            // 6. Hero Animation
            Align(
              alignment: Alignment.topRight,
              child: Hero(
                tag: 'animations-hero-tag',
                child: const Icon(Icons.rocket_launch, color: Colors.purple, size: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
