import 'dart:math';

import 'package:flutter/material.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with TickerProviderStateMixin {
  final List<bool> _isHeartSelected = [false, false, false];
  final GlobalKey _cartKey = GlobalKey();
  final List<GlobalKey> _heartKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  late List<AnimationController> _animationControllers;
  late List<AnimationController> _bounceAnimationControllers;
  late List<AnimationController> _drainAnimationControllers;
  late List<ColorTween> _drainColorTweens;
  late List<Animation<Color?>> _drainColorAnimations;

  late final AnimationController _fadeController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _bounceAnimationControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _drainAnimationControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _drainColorTweens = List.generate(
      3,
      (index) => ColorTween(begin: Colors.red, end: Colors.grey),
    );
    _drainColorAnimations = List.generate(
      3,
      (index) =>
          _drainColorTweens[index].animate(_drainAnimationControllers[index]),
    );
  }

  void _runAnimation(int index) async {
    final RenderBox heartRenderBox =
        _heartKeys[index].currentContext!.findRenderObject() as RenderBox;
    final RenderBox cartRenderBox =
        _cartKey.currentContext!.findRenderObject() as RenderBox;

    final heartOffset = heartRenderBox.localToGlobal(Offset.zero);
    final cartOffset = cartRenderBox.localToGlobal(Offset.zero);

    final angle = atan2(cartOffset.dy - heartOffset.dy, cartOffset.dx - heartOffset.dx) - pi / 2;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    // Bounce animation
    final bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _bounceAnimationControllers[index], curve: Curves.elasticOut),
    );

    // Rotation animation
    final rotationAnimation = Tween<double>(begin: 0.0, end: angle).animate(
      CurvedAnimation(
          parent: _animationControllers[index], curve: Curves.easeInOut),
    );

    // Scale animation
    final scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _animationControllers[index], curve: Curves.easeIn),
    );

    // Fade animation
    final fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _animationControllers[index], curve: Curves.easeIn),
    );

    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _bounceAnimationControllers[index],
            _animationControllers[index],
          ]),
          builder: (context, child) {
            final value = _animationControllers[index].value;
            final offset = Offset.lerp(heartOffset, cartOffset, value)!;
            return Positioned(
              top: offset.dy,
              left: offset.dx,
              child: Transform.rotate(
                angle: rotationAnimation.value,
                child: Transform.scale(
                  scale: bounceAnimation.value * scaleAnimation.value,
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child:
                        const Icon(Icons.favorite, color: Colors.red, size: 50),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);

    await _bounceAnimationControllers[index].forward();
    _bounceAnimationControllers[index].reset();

    await _animationControllers[index].forward();
    _animationControllers[index].reset();

    entry.remove();
  }



  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    for (var controller in _bounceAnimationControllers) {
      controller.dispose();
    }
    for (var controller in _drainAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animation demo"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              key: _cartKey,
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 5),
                Text("${_isHeartSelected.where((e) => e).length}"),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black12.withOpacity(0.1),
                        Colors.transparent
                      ])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...List<Widget>.generate(3, (i) {
                    return GestureDetector(
                      key: _heartKeys[i],
                      onTap: () {
                        if (!_isHeartSelected[i]) {
                          _drainAnimationControllers[i].reset(); // Reset drain animation when selecting
                          _animationControllers[i].reset();
                          _runAnimation(i);
                          setState(() {
                            _isHeartSelected[i] = true;
                          });
                        } else {
                          _drainAnimationControllers[i].forward().whenComplete(() {
                            _drainAnimationControllers[i].reset();
                            setState(() {
                              _isHeartSelected[i] = false;
                            });
                          });
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _drainColorAnimations[i],
                        builder: (context, child) {
                          final color = _isHeartSelected[i]
                              ? (_drainColorAnimations[i].value ?? Colors.red)
                              : Colors.grey;
                          return Icon(
                            Icons.favorite,
                            size: 50,
                            color: color,
                          );
                        },
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FadeTransition(
            opacity: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.black12.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text("NEXT MILESTONES")),
                          const Icon(Icons.heart_broken_sharp),
                          Text("${_isHeartSelected.where((e) => e).length}/10")
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: (MediaQuery.of(context).size.width - 64) *
                                (_isHeartSelected.where((e) => e).length / 10),
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      )
                    ],
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
