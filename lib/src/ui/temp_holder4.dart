import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:drawing_test3/src/blocs/drawing_new/drawing_bloc.dart';
import 'package:bloc/bloc.dart';

class MyMasterPiece extends StatefulWidget {
  MyMasterPiece({Key key, this.title, this.width, this.height})
      : super(key: key);
  final String title;
  final double width;
  final double height;

  @override
  _MyMasterPieceState createState() =>
      _MyMasterPieceState(width: width, height: height);
}

class _MyMasterPieceState extends State<MyMasterPiece> {
  GlobalKey globalKey = GlobalKey();

  MasterPieceHolder holder;
  final double width;
  final double height;
  final double buttonHeight = 75.0;

  _MyMasterPieceState({this.width, this.height});

  @override
  void initState() {
    super.initState();
    holder = new MasterPieceHolder(height: height - buttonHeight, width: width);
  }

  @override
  Widget build(BuildContext context) {
    return
       Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(flex: 10,child: holder),
          Flexible(fit: FlexFit.tight,child: Center(child: FlatButton(
            color: Colors.blueAccent,
              onPressed: () => holder.bloc.dispatch(DrawingClearEvent()),
              child: Text("Clear"))))
        ],
    );
  }
}


class MasterPieceHolder extends StatelessWidget {
  final ui.Image image;
  final double height;
  final double width;
  final DrawingBloc bloc = DrawingBloc();

  void _onPanStart(BuildContext context, DragStartDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset tapPos = box.globalToLocal(details.globalPosition);
    bloc.dispatch(DrawingUpdatedEvent(cur: tapPos));
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset tapPos = box.globalToLocal(details.globalPosition);
    bloc.dispatch(DrawingUpdatedEvent(cur: tapPos));
  }

  void _onPanUp() {
    bloc.dispatch(DrawingUpdatedEvent(cur: null));
  }

  void clear() {
    print("Clear!");
    bloc.dispatch(DrawingClearEvent());
  }

  MasterPieceHolder({this.height, this.width, this.image});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReduxStateObject>(
        bloc: bloc,
        builder: (context, state) {
          if(state != null) {
            return SizedBox.expand(
              child: GestureDetector(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: MyDrawingPainter(state.cur, state.backup, state.image, bloc, state.shouldSave),
                    isComplex: true,
                    willChange: false,
                  ),
                ),
                onPanStart: (DragStartDetails details) => _onPanStart(context, details),
                onPanUpdate: (DragUpdateDetails details) =>
                    _onPanUpdate(context, details),
                onPanEnd: (DragEndDetails details) => _onPanUp(),
              ),
            );
          } else {
            return Center(
              child: RefreshProgressIndicator()
            );
          }

        }
    );
  }
}

class MyDrawingPainter extends ChangeNotifier implements CustomPainter {

  final List<DrawingObject> backUp;
  final DrawingObject current;
  Color chosenColor = Colors.indigoAccent;
  final ui.Image image;
  final DrawingBloc bloc;
  final shouldSave;

  MyDrawingPainter(this.current, this.backUp, this.image, this.bloc, this.shouldSave);

  @override
  bool shouldRepaint(MyDrawingPainter old) {
    return true;
  }

  bool hitTest(Offset position) => null;

  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate);

  SemanticsBuilderCallback get semanticsBuilder => null;

  void paint(Canvas canvas, Size size) {
    print("paint");
    _paintHelper(canvas, size);
    if (shouldSave) {
      _paintAndSave(canvas, size);
    }
  }

  void _paintAndSave(Canvas canvas, Size size) async {
    final recorder = new ui.PictureRecorder();
    Canvas test = new Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(size.width, size.height)));
    _paintHelper(test, size);
    final picture = recorder.endRecording();
    savePicture(picture, size);
  }

  void _paintHelper(Canvas canvas, Size size) {
    Paint paint = Paint()
    //..color = chosenColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    if (image != null) {
      print("image is not null");
      canvas.drawImage(image, Offset(0.0, 0.0), paint);
    }

    if (backUp != null) {
      backUp.forEach((el) {
        //paint.color = chosenColor;
        /*Path strokePath = new Path();
        strokePath.addPolygon(el, false);
        canvas.drawPath(strokePath, paint);*/
        //el.color = chosenColor;
        el.drawObject(canvas, paint);
      });
    }

    if (current != null) {
      //paint.color = chosenColor;
      /*Path strokePath = new Path();
      strokePath.addPolygon(current, false);
      canvas.drawPath(strokePath, paint);*/
      //current.color = chosenColor;
      current.drawObject(canvas, paint);
    }

  }


  Future<void> savePicture(Picture picture, Size size) async {
    bloc.dispatch(DrawingSaveInitEvent());
    final lastIndex = backUp.length - 1;

    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    picture.dispose();
    bloc.dispatch(DrawingSaveEvent(img, lastIndex));
    print("done!");
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
  }

  ui.Image getImage() {
    return image;
  }
}