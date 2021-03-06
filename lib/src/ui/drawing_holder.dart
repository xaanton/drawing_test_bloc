import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:drawing_test3/src/blocs/drawing_new/drawing_bloc.dart';
import 'package:bloc/bloc.dart';

class MyDrawing extends StatefulWidget {
  MyDrawing({Key key, this.title, this.width, this.height})
      : super(key: key);
  final String title;
  final double width;
  final double height;

  @override
  _MyDrawingState createState() =>
      _MyDrawingState(width: width, height: height);
}

class _MyDrawingState extends State<MyDrawing> {
  GlobalKey globalKey = GlobalKey();

  MyDrawingHolder holder;
  final double width;
  final double height;
  final double buttonHeight = 300.0;

  _MyDrawingState({this.width, this.height});

  @override
  void initState() {
    super.initState();
    holder = new MyDrawingHolder(height: height - buttonHeight, width: width);
  }

  @override
  Widget build(BuildContext context) {
    return
       Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(flex: 10,child: holder),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              MaterialButton(
                  minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(StarFive())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        StarFive()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                  minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(StarEight())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        StarEight()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                  minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(StarSixteen())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        StarSixteen()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                  minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(Oval())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        Oval()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(Flower())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        Flower()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(CustomPath())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        CustomPath()
                          ..path.add(Offset(-10, -10))
                          ..path.add(Offset(10, 10)),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
              MaterialButton(
                minWidth: 40,
                  color: Colors.blueAccent,
                  onPressed: () => holder.bloc.dispatch(DrawingChangeObjectEvent(Rectangle())),
                  child: CustomPaint(
                    painter: MyDrawingPainter(
                        Rectangle()
                          ..firstPoint = Offset(-10, -10)
                          ..secondPoint = Offset(10, 10),
                        null, null, null, false),
                    isComplex: true,
                    willChange: false,
                  ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MaterialButton(
                    minWidth: 300,
                    color: Colors.lightBlue[200],
                    onPressed: () => holder.bloc.dispatch(DrawingClearEvent()),
                    child: Text("Clear")
                  ),
                ),
              ),
            ],
          )
        ],
    );
  }
}


class MyDrawingHolder extends StatelessWidget {
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
    //if(tapPos.dy > this.height)tapPos = Offset(tapPos.dx, this.height);
    bloc.dispatch(DrawingUpdatedEvent(cur: tapPos));
  }

  void _onPanUp() {
    bloc.dispatch(DrawingOverEvent());
  }

  void clear() {
    print("Clear!");
    bloc.dispatch(DrawingClearEvent());
  }

  MyDrawingHolder({this.height, this.width, this.image});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateObject>(
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
                  onPanStart: (DragStartDetails details) =>
                      _onPanStart(context, details),
                  onPanUpdate: (DragUpdateDetails details) =>
                      _onPanUpdate(context, details),
                  onPanEnd: (DragEndDetails details) =>
                      _onPanUp(),
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
    if(bloc != null) {
      savePicture(picture, size);
    }
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