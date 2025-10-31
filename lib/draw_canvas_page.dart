import 'package:flutter/material.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingPoint?> _points = [];
  bool _isErasing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _points.add(DrawingPoint(
                offset: details.localPosition, isErasing: _isErasing));
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

  DrawingPoint({required this.offset, this.isErasing = false});
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
          ..strokeWidth = 5.0;

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