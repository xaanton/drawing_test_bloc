import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'temp_holder.dart';
import 'dart:ui' as ui;

import 'package:drawing_test3/src/blocs/drawing/drawing_bloc.dart';
import 'package:drawing_test3/src/blocs/drawing/drawing_events.dart';
import 'package:drawing_test3/src/blocs/drawing/drawing_states.dart';

class DrawingHolder extends StatefulWidget {
  DrawingHolder({Key key, this.title, this.width, this.height})
      : super(key: key);
  final String title;
  final double width;
  final double height;

  @override
  _DrawingHolderState createState() =>
      _DrawingHolderState(width: width, height: height);
}

class _DrawingHolderState extends State<DrawingHolder> {
  GlobalKey globalKey = GlobalKey();

  final double width;
  final double height;
  final double buttonHeight = 75.0;
  final DrawingBloc bloc = DrawingBloc();

  _DrawingHolderState({this.width, this.height});

  @override
  void initState() {
    super.initState();

  }

  void _onPanStart(BuildContext context, DragStartDetails details, ui.Image image) {
    print("On tap");
    RenderBox box = context.findRenderObject();
    Offset tapPos = box.globalToLocal(details.globalPosition);
    bloc.dispatch(DrawingUpdatedEvent(cur: List<Offset>()..add(tapPos)));
  }

  void _onPanUpdate(BuildContext context,
      DragUpdateDetails details,
      List<Offset> cur,
      ui.Image image, MyCustomPainter painter, bool haveToSave) {
    RenderBox box = context.findRenderObject();
    Offset tapPos = box.globalToLocal(details.globalPosition);
    if(haveToSave) {
      _saveImage(cur, painter);
    }
    bloc.dispatch(DrawingUpdatedEvent(cur: cur..add(tapPos)));
  }

  void _saveImage(List<Offset> cur, MyCustomPainter painter,) async {
    ui.Image image = await painter.savePicture();
    bloc.dispatch(DrawingSaveImageEvent(image: image, offset: cur.length -1));
  }

  void _onPanUp(MyCustomPainter painter) async {
    var image = await painter.savePicture();
    bloc.dispatch(DrawingSaveImageEvent(image: image, offset: 0));
    //holder.painter.endStroke();
  }

  void clear() {
    print("Clear!");
  }

  Widget getGestureDetector(List<Offset> current, ui.Image image, bool haveToSaveImage) {
    MyCustomPainter painter = MyCustomPainter(current, image);
    return GestureDetector(
        onPanStart: (DragStartDetails details) => _onPanStart(context, details, image),
        onPanUpdate: (DragUpdateDetails details) =>
            _onPanUpdate(context, details, current, image, painter, haveToSaveImage),
        onPanEnd: (DragEndDetails details) => _onPanUp(painter),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: painter,
            willChange: true,
          ),
        ),);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {

        if(state is DrawingEmpty) {
          return Center(
              child: SizedBox.expand(
                child: getGestureDetector(List<ui.Offset>(), null, false),
              ));
        }
        if(state is DrawingLoaded) {
          return Center(
              child: SizedBox.expand(
                child: getGestureDetector(state.cur, state.image, state.haveToSaveImage),
              ));
        }
      }
    );
  }
}


class MyCustomPainter extends ChangeNotifier implements CustomPainter {
  //final List<ui.Image> backUp = new List();
  final List<Offset> current;
  Color chosenColor = Colors.amberAccent;
  final ui.Image image;
  Size _size;

  MyCustomPainter(this.current, this.image,);

  @override
  bool shouldRepaint(MyCustomPainter old) {
    return true;
  }

  void clearAll() {
    //_image = null;
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

    if (image != null) {
      canvas.drawImage(image, Offset(0.0, 0.0), paint);
    }

    if (size != null) {
      _size = size;
    }

    if(this.current != null && this.current.length > 0) {
      paint.color = chosenColor;
      Path strokePath = new Path();
      strokePath.addPolygon(current, false);
      canvas.drawPath(strokePath, paint);
    }

  }

  Future<ui.Image> savePicture() async {
    final recorder = new ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(_size.width, _size.height)));

    paint(canvas, null);

    final picture = recorder.endRecording();
    final img = await picture.toImage(375, 812);
    return img;
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
  }

  ui.Image getImage() {
    return image;
  }
}