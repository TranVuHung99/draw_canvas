import 'package:flutter/material.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingPoint?> _points = [];
  bool _isErasing = false;
  double _strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
        actions: [
          Text('Stroke: ${_strokeWidth.toStringAsFixed(1)}'),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Stroke Width:'),
            RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: _strokeWidth,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: _strokeWidth.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _strokeWidth = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _points.add(DrawingPoint(
                offset: details.localPosition,
                isErasing: _isErasing,
                strokeWidth: _strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {
            _points.add(null);
          });
        },
        child: Container(
          color: Colors.white,
          child: CustomPaint(
            painter: DrawingPainter(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isErasing = !_isErasing;
          });
        },
        child: Icon(_isErasing ? Icons.brush : Icons.cleaning_services),
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final bool isErasing;
  final double strokeWidth;

  DrawingPoint(
      {required this.offset,
      this.isErasing = false,
      required this.strokeWidth});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i]!.strokeWidth;

        if (points[i]!.isErasing) {
          paint.blendMode = BlendMode.clear;
          paint.color = Colors.transparent;
        } else {
          paint.color = Colors.black;
        }
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
