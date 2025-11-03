import 'package:flutter/material.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Scale Animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Color Animation
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _colorAnimation = ColorTween(begin: Colors.grey, end: Colors.red).animate(_colorController);

    // Rotation Animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    _colorController.forward();
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    setState(() {
      if (_progress < 1.0) {
        _progress += 0.1;
      } else {
        _progress = 1.0;
      }
    });
  }

  void _resetAnimation() {
    _colorController.reset();
    setState(() {
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _startAnimation,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation,
                  _colorAnimation,
                  _rotationAnimation,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Icon(
                        Icons.favorite,
                        color: _colorAnimation.value,
                        size: 100,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetAnimation,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
