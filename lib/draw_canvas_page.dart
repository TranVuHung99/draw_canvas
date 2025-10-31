import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';

enum DrawingMode {
  draw,
  erase,
}

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingPoint?> _points = [];
  final List<Sticker> _stickers = [];
  bool _isErasing = false;
  double _strokeWidth = 5.0;
  bool _isFabOpen = false; // New state variable for Speed Dial
  DrawingMode _currentMode = DrawingMode.draw; // New state variable for current mode
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<String> _stickerAssets = [
    'resources/images/cat.png',
    'resources/images/cup.png',
    'resources/images/heart.png',
    'resources/images/moon_sticker.png',
    'resources/images/ticket.png',
  ];

  final Map<String, ui.Image> _stickerImages = {};

  @override
  void initState() {
    super.initState();
    _loadStickerImages();
  }

  Future<void> _loadStickerImages() async {
    for (final path in _stickerAssets) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _stickerImages[path] = frame.image;
    }
  }

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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localOffset = renderBox.globalToLocal(details.offset);
                    final adjustedLocalOffset = localOffset + const Offset(20, -10);
                    setState(() {
                      _stickers.add(Sticker(
                        imagePath: details.data,
                        position: adjustedLocalOffset,
                      ));
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      key: const Key('drawing_canvas'),
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
                                            child: Screenshot(
                                              controller: _screenshotController,
                                              child: CustomPaint(
                                                painter: DrawingPainter(points: _points, stickers: _stickers, stickerImages: _stickerImages),
                                                size: Size.infinite,
                                              ),
                                            ),                      ),
                    );
                  },
                ),
              ),
              StickerPalette(stickerAssets: _stickerAssets),
            ],
          ),
          if (_isFabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFabOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen)
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'clearFab',
                  mini: true,
                  key: const Key('clear_button'),
                  onPressed: () {
                    setState(() {
                      _points.clear();
                      _stickers.clear();
                      _isFabOpen = false; // Close Speed Dial after action
                    });
                  },
                  child: const Icon(Icons.clear),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'saveFab',
                  mini: true,
                  onPressed: () async {
                    _isFabOpen = false; // Close Speed Dial immediately
                    await _screenshotController.capture().then((image) async {
                      if (image != null) {
                        final directory = await getTemporaryDirectory();
                        final imagePath = await File('${directory.path}/canvas_${DateTime.now().millisecondsSinceEpoch}.png').create();
                        await imagePath.writeAsBytes(image);
                        final success = await GallerySaver.saveImage(imagePath.path);
                        if (success != null && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image saved to gallery!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to save image.')),
                          );
                        }
                      }
                    });
                    setState(() {}); // Rebuild to reflect _isFabOpen change
                  },
                  child: const Icon(Icons.save),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'drawFab',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _isErasing = false;
                      _currentMode = DrawingMode.draw;
                      _isFabOpen = false; // Close Speed Dial after action
                    });
                  },
                  child: const Icon(Icons.brush),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'eraseFab',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _isErasing = true;
                      _currentMode = DrawingMode.erase;
                      _isFabOpen = false; // Close Speed Dial after action
                    });
                  },
                  child: const Icon(Icons.cleaning_services),
                ),
                const SizedBox(height: 10),
              ],
            ),
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
              });
            },
            child: Icon(
              _isFabOpen
                  ? Icons.close
                  : (_currentMode == DrawingMode.draw ? Icons.brush : Icons.cleaning_services),
            ),
          ),
        ],
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

class Sticker {
  final String imagePath;
  final Offset position;
  final double size;

  Sticker({required this.imagePath, required this.position, this.size = 100.0});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  final List<Sticker> stickers;
  final Map<String, ui.Image> stickerImages;

  DrawingPainter({required this.points, required this.stickers, required this.stickerImages});

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

    for (final sticker in stickers) {
      final image = stickerImages[sticker.imagePath];
      if (image != null) {
        final rect = Rect.fromCenter(
          center: sticker.position,
          width: sticker.size,
          height: sticker.size,
        );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          rect,
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class StickerPalette extends StatelessWidget {
  final List<String> stickerAssets;

  const StickerPalette({super.key, required this.stickerAssets});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stickerAssets.length,
        itemBuilder: (context, index) {
          final asset = stickerAssets[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Draggable<String>(
              data: asset,
              feedback: Image.asset(asset, width: 100),
              child: Image.asset(asset, width: 80),
            ),
          );
        },
      ),
    );
  }
}
