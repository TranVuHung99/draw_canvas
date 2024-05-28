import 'package:flutter/material.dart';
import 'dart:math';

class AnimationHeartWidget extends StatefulWidget {
  final Function(Function(Offset)) onSelect;

  const AnimationHeartWidget({
    super.key,
    required this.onSelect,
  });

  @override
  State<AnimationHeartWidget> createState() => _AnimationHeartWidgetState();
}

class _AnimationHeartWidgetState extends State<AnimationHeartWidget> with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final Animation<double> _animationBlink;
  late final Animation<Color?> _animationColor;
  late final Animation<double> _animationScale;
  late final Animation<double> _animationScaleReverse;
  late final Animation<double> _animationRotate;
  late Animation<Offset> _animationPosition2;
  late final Animation<double> _animationScale2;

  final itemKey = GlobalKey();

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationBlink = Tween<double>(begin: 0.95, end: 1.05).animate(_controller1);

    _animationScale =
        Tween<double>(begin: 1, end: 1.3).animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.0, 0.3, curve: Curves.easeInOut)));

    _animationColor = ColorTween(
      begin: Colors.grey,
      end: null,
    ).animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.2, 0.25, curve: Curves.easeInOut)));

    _animationScaleReverse =
        Tween<double>(begin: 0, end: 0.3).animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.4, 0.7, curve: Curves.easeInOut)));

    _animationRotate = Tween<double>(begin: 0, end: -(2 * pi / 8))
        .animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.7, 0.8, curve: Curves.easeInOut)));


    _animationPosition2 = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.8, 1, curve: Curves.easeInOut)));

    _animationScale2 =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.8, 1, curve: Curves.easeInOut)));
  }

  Future<void> _startAnimation(Offset cartOffset) async {
    await _controller1.forward();
    await _controller1.reverse();
    final itemBox = itemKey.currentContext?.findRenderObject() as RenderBox;
    final start = itemBox.localToGlobal(Offset.zero);
    setState(() {
      _animationPosition2 = Tween<Offset>(begin: Offset.zero, end: Offset(cartOffset.dx - start.dx, cartOffset.dy - start.dy))
          .animate(CurvedAnimation(parent: _controller2, curve: const Interval(0.8, 1, curve: Curves.easeInOut)));
    });
    await _controller2.forward();
    setState(() {
      _isSelected = true;
    });
    _controller1.reset();
    _controller2.reset();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !_isSelected
        ? AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: _controller1,
                builder: (context, child) {
                  return InkWell(
                    onTap: () => widget.onSelect(_startAnimation),
                    child: Transform.translate(
                      offset: _animationPosition2.value,
                      child: Transform.scale(
                        scale: _animationScale.value - _animationScaleReverse.value - _animationScale2.value,
                        child: Transform.rotate(
                          angle: _animationRotate.value,
                          child: Image.asset(
                            key: itemKey,
                            "resources/images/heart.png",
                            width: 70 * _animationBlink.value,
                            height: 70 * _animationBlink.value,
                            color: _animationColor.value,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })
        : Image.asset(
            "resources/images/heart.png",
            width: 70,
            height: 70,
          );
  }
}
