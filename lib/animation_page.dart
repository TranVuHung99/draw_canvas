import 'package:draw_canvas/animation_heart_widget.dart';
import 'package:flutter/material.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> with TickerProviderStateMixin {
  List<bool> selected = [false, false, false];

  late final AnimationController _fadeController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );

  late final AnimationController _progressController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  late Animation<double> _progress;

  final cartKey = GlobalKey();

  double lastProgress = 0;

  @override
  void initState() {
    _progress = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    super.initState();
  }

  Future<void> _setProgress() async {
    await Future.delayed(const Duration(milliseconds: 1700));
    final heartCount = selected.where((e) => e).length;
    _progress = Tween<double>(
      begin: lastProgress,
      end: heartCount / 10,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _progressController.reset();
    _progressController.forward();
    lastProgress = heartCount / 10;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animation demo"),
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
                      begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black12.withOpacity(0.1), Colors.transparent])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...List<Widget>.generate(3, (i) {
                    return AnimationHeartWidget(
                      onSelect: (callBack) {
                        if (!selected[i]) {
                          final cartBox = cartKey.currentContext?.findRenderObject() as RenderBox;
                          callBack(cartBox.localToGlobal(Offset.zero));
                          setState(() {
                            selected[i] = true;
                          });
                          _setProgress();
                        }
                      },
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
              decoration: BoxDecoration(color: Colors.black12.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text("NEXT MILESTONES")),
                          Icon(key: cartKey, Icons.heart_broken_sharp),
                          Text("${selected.where((e) => e).length}/10")
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: 400,
                            height: 10,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                          ),
                          AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  width: _progress.value * 400,
                                  height: 10,
                                  decoration: BoxDecoration(color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(5)),
                                );
                              })
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
