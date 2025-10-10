import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

enum Type { line, sticker }

typedef ItemLocation = (ui.Image?, Offset, Type);

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<ItemLocation?> items = [];
  final canvasKey = GlobalKey();
  bool isSaving = false;
  String displayText = "";
  final screenShotController = ScreenshotController();

  final listSticker = [
    "resources/images/moon_sticker.png",
    "resources/images/cup.png",
    "resources/images/ticket.png",
    "resources/images/cat.png",
  ];

  Future<void> onDrop(ui.Offset offset, String path) async {
    final image = await _loadImage(path);
    setState(() {
      items.add((image, offset, Type.sticker));
    });
  }

  bool checkPathValid(String path) {
    final regex = RegExp(r'^resources/images/[^/]+\.(png)$');
    return regex.hasMatch(path);
  }

  Future<ui.Image> _loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), completer.complete);
    final ui.Image image = await completer.future;
    return image;
  }

  Future<void> _onCaptureImage() async {
    setState(() {
      isSaving = true;
      displayText = "Saving picture to gallery ...";
    });
    try {
      final imgBytes = await screenShotController.capture();
      if (imgBytes != null) {
        final dir = await getTemporaryDirectory();
        final now = DateTime.now().millisecond;
        final dirName = "${dir.path}/$now.png";
        final file = File(dirName);
        await file.writeAsBytes(imgBytes);
        await GallerySaver.saveImage(file.path);
        setState(() {
          isSaving = false;
          displayText = "Saving success";
        });
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        displayText = "Saving failed";
      });
      print(e);
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      displayText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Draw Canvas"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: _onCaptureImage,
              child: const Icon(
                Icons.camera_alt_outlined,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            displayText,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          DragTarget(
            onAcceptWithDetails: (detail) {
              if (detail.data is String && checkPathValid(detail.data as String)) {
                final canvasRenderBox = canvasKey.currentContext?.findRenderObject() as RenderBox;
                final offset = canvasRenderBox.globalToLocal(detail.offset);
                onDrop(offset, detail.data as String);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Screenshot(
                  controller: screenShotController,
                  child: Container(
                    key: canvasKey,
                    width: double.infinity,
                    height: 400,
                    color: Colors.white,
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails details) {
                        if (details.localPosition.dx < 0 ||
                            details.localPosition.dy < 0 ||
                            details.localPosition.dx > 400 ||
                            details.localPosition.dy > 400) {
                          return;
                        }
                        setState(() {
                          items.add((null, details.localPosition, Type.line));
                        });
                      },
                      onPanEnd: (DragEndDetails details) => setState(() {
                        items.add(null);
                      }),
                      child: CustomPaint(
                        painter: Draw(
                          items: items,
                        ),
                        size: const Size(400, 400),
                      ),
                    ),
                  ));
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [..._buildListSticker()],
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.clear),
        label: const Text('Clear'),
        onPressed: () {
          setState(() {
            items.clear();
          });
        },
      ),
    );
  }

  List<Widget> _buildListSticker() {
    final res = <Widget>[];
    for (final path in listSticker) {
      final image = Image.asset(
        path,
        width: 60,
        height: 60,
      );
      final item = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Draggable(
          data: path,
          feedback: image,
          child: Opacity(
            opacity: 0.8,
            child: image,
          ),
        ),
      );
      res.add(item);
    }
    return res;
  }
}

class Draw extends CustomPainter {
  const Draw({
    required this.items,
  });

  final List<ItemLocation?> items;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue.shade900;
    paint.strokeWidth = 5.0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item != null) {
        if (item.$3 == Type.sticker) {
          final offset = item.$2;
          paintImage(
            canvas: canvas,
            fit: BoxFit.cover,
            rect: Rect.fromCenter(center: offset, width: 70, height: 70),
            image: item.$1!,
          );
        } else {
          final next = i < items.length - 1 ? items[i + 1] : null;
          if (next != null && next.$3 == Type.line) {
            canvas.drawLine(item.$2, next.$2, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(Draw oldDelegate) => true;
}
