import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'temp_holder.dart';
import 'dart:ui' as ui;
import 'package:rxdart/rxdart.dart';

import 'package:drawing_test3/src/blocs/drawing/drawing_bloc.dart';
import 'package:drawing_test3/src/blocs/drawing/drawing_events.dart';
//import 'package:drawing_test3/src/blocs/drawing/drawing_states.dart';
import 'package:drawing_test3/src/blocs/drawing/redux_state_object.dart';

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

  void _onPanStart(BuildContext context, DragStartDetails details, ui.Picture picture, ReduxStateObject state) {
    RenderBox box = context.findRenderObject();
    Offset tapPos = box.globalToLocal(details.globalPosition);

    List cur = state.cur;
    if(cur == null)cur = List<Offset>();

    bloc.dispatch(DrawingUpdatedEvent(cur: cur..add(tapPos), image: state.image, picture: state.picture, state: state));
  }

  void _onPanUpdate(BuildContext context,
      DragUpdateDetails details,
      List<Offset> cur,
      ui.Picture picture,
      MyCustomPainter painter,
      ReduxStateObject state) {
    RenderBox box = context.findRenderObject();
    Offset tapPos = box.globalToLocal(details.globalPosition);
    ui.Picture picture = state.picture;
    /*if(cur != null && cur.length > 20) {
      picture = painter.savePicture();
      cur = List();
    }*/
    List cur = state.cur;
    if(cur == null)cur = List<Offset>();
    if(cur.length > 120)_backupImage(painter, cur, state);
    bloc.dispatch(DrawingUpdatedEvent(cur: cur..add(tapPos), picture: picture, image: state.image, state: state));
  }

  /*void _saveImage(List<Offset> cur, MyCustomPainter painter,) async {
    ui.Image image = await painter.savePicture();
    bloc.dispatch(DrawingSaveImageEvent(image: image, offset: cur.length -1));
  }*/

  void _onPanUp(MyCustomPainter painter, ReduxStateObject state) {
    List cur = state.cur;
    if(cur == null)cur = List<Offset>();
    //cur..add(null);
    _backupImage(painter, cur, state);
    bloc.dispatch(DrawingUpdatedEvent(cur: cur, picture: null, image: state.image, state: state));
  }

  void _backupImage(MyCustomPainter painter, List<Offset> cur, ReduxStateObject state) async {
    var image = await painter.saveImage();
    //bloc.dispatch(DrawingUpdatedEvent(cur: List(), picture: state.picture, image: image, state: state));
    int lastIndex = cur == null ? -1 : cur.length -1;
    bloc.dispatch(DrawingSaveImageEvent(image: image, state: state, lastIndex: lastIndex));
  }

  void _clear() {
    print("Clear!");
    bloc.dispatch(DrawingClearEvent(
      state: null
    ));
  }

  Widget getGestureDetector(List<Offset> current,
      ui.Picture picture,
      ui.Image image,
      ReduxStateObject state) {

    MyCustomPainter painter = MyCustomPainter(current, picture, image);
    return GestureDetector(
        onPanStart: (DragStartDetails details) => _onPanStart(context, details, picture, state),
        onPanUpdate: (DragUpdateDetails details) =>
            _onPanUpdate(context, details, current, picture, painter, state),
        onPanEnd: (DragEndDetails details) => _onPanUp(painter, state),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: painter,
            willChange: true,
          ),
        ),);
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<PublishSubject<String>>(context).listen((event) => _clear());
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        return Center(
            child: SizedBox.expand(
              child: getGestureDetector(state.cur, state.picture, state.image, state),
            ));
      }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}


class MyCustomPainter extends ChangeNotifier implements CustomPainter {
  //final List<ui.Image> backUp = new List();
  final List<Offset> current;
  final Color chosenColor = Colors.amberAccent;
  final ui.Image image;
  final ui.Picture picture;
  Size _size;

  MyCustomPainter(this.current, this.picture, this.image);

  @override
  bool shouldRepaint(MyCustomPainter old) {
    return true;
  }

  bool hitTest(Offset position) => null;

  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate);

  SemanticsBuilderCallback get semanticsBuilder => null;

  void paint(Canvas canvas, Size size) {
    print("paint");
    Paint paint = Paint()
    //..color = chosenColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    /*
    if (picture != null) {
      //canvas.drawImage(image, Offset(0.0, 0.0), paint);
      print(picture.approximateBytesUsed);
      canvas.drawPicture(picture);
    }*/

    if (image != null) {
      canvas.drawImage(image, Offset(0.0, 0.0), paint);
    }

    if (size != null) {
      _size = size;
    }

    if (this.current != null && this.current.length > 1) {
      paint.color = chosenColor;
      Path strokePath = new Path();
      strokePath.addPolygon(current, false);
      canvas.drawPath(strokePath, paint);
    } else if(this.current != null && this.current.length > 0) {
      paint.color = chosenColor;
      canvas.drawPoints(ui.PointMode.points, current, paint);
    }

  }

  ui.Picture savePicture() {
    final recorder = new ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(_size.width, _size.height)));

    paint(canvas, null);

    final picture = recorder.endRecording();
    //picture.
    //final img = await picture.toImage(375, 812);
    return picture;
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
  }

  Future<ui.Image> saveImage() async {
    final recorder = new ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(_size.width, _size.height)));

    paint(canvas, null);

    final picture = recorder.endRecording();
    //picture.
    final img = await picture.toImage(375, 812);
    //return picture;
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    return img;
  }

  /*ui.Image getImage() {
    return image;
  }*/
}