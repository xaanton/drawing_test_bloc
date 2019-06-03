import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:async';

class MasterPieceHolder extends StatelessWidget {
  final ui.Image image;
  final double height;
  final double width;
  final MasterPiecePainter painter;

  MasterPieceHolder({this.height, this.width, this.image})
      : painter = new MasterPiecePainter(image);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      child: RepaintBoundary(
        child: CustomPaint(
          painter: painter,
          isComplex: true,
          willChange: false,
        ),
      ),
    );
  }
}

class MasterPiecePainter extends ChangeNotifier implements CustomPainter {
  //final List<ui.Image> backUp = new List();
  final List<Offset> current = new List();
  Color chosenColor = Colors.amberAccent;
  ui.Image _image;
  Size _size;

  MasterPiecePainter([this._image]);

  @override
  bool shouldRepaint(MasterPiecePainter old) {
    return false;
  }

  void startStroke(Offset position) {
    print("startStroke");
    current.add(position);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    print("appendStroke");
    current.add(position);
    notifyListeners();
  }

  void endStroke() async {
    await savePicture();
    current.clear();
    notifyListeners();
  }

  void clearAll() {
    _image = null;
    notifyListeners();
  }

  void setColor(Color color) {
    chosenColor = color;
  }

  bool hitTest(Offset position) => null;

  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate);

  SemanticsBuilderCallback get semanticsBuilder => null;

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      //..color = chosenColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    if (_image != null) {
      canvas.drawImage(_image, Offset(0.0, 0.0), paint);
    }

    if (size != null) {
      _size = size;
    }

    paint.color = chosenColor;
    Path strokePath = new Path();
    strokePath.addPolygon(current, false);
    canvas.drawPath(strokePath, paint);
  }

  Future<void> savePicture() async {
    final recorder = new ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(_size.width, _size.height)));

    paint(canvas, null);

    final picture = recorder.endRecording();
    final img = await picture.toImage(375, 812);
    _image = img;
    print("done!");
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
  }

  ui.Image getImage() {
    return _image;
  }
}

/*
  CustomPaint
  CustomPainter

  decodeImageFromList() = ui.Image
  SizedBox for resizing image
  FittedBox for fitting and scaling
 */