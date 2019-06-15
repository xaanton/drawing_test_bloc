import 'package:flutter/material.dart';

//import 'temp_holder2.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:rxdart/rxdart.dart';

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
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                flex: 10,
                child:
                SizedBox.expand(
                    child: holder
                )
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.red,
                child: FlatButton(onPressed: () => holder.painter.clearAll(),
                    child: Icon(Icons.assistant_photo)),),
            )
          ],
        ));
  }
}


class MasterPieceHolder extends StatelessWidget {
  final ui.Image image;
  final double height;
  final double width;
  final MasterPiecePainter painter;

  void _onPanStart(BuildContext context, DragStartDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset _tapPos = box.globalToLocal(details.globalPosition);
    this.painter.startStroke(_tapPos);
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset _tapPos = box.globalToLocal(details.globalPosition);
    this.painter.appendStroke(_tapPos);
  }

  void _onPanUp() {
    this.painter.endStroke();
  }

  void clear() {
    print("Clear!");
    this.painter.clearAll();
  }

  MasterPieceHolder({this.height, this.width, this.image})
      : painter = new MasterPiecePainter(imageStream: PublishSubject<Temp>(),
      offsetStream: PublishSubject<Offset>());

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue[50],
      child: GestureDetector(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: painter,
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
  }
}

class MasterPiecePainter extends ChangeNotifier implements CustomPainter {
  //final List<ui.Image> backUp = new List();
  List<List<Offset>> backUp = new List();
  List<Offset> current = new List();
  Color chosenColor = Colors.amberAccent;
  ui.Image _image;
  Temp temp;
  Size _size;
  final PublishSubject<Temp> imageStream;
  final PublishSubject<Offset> offsetStream;

  MasterPiecePainter({this.imageStream, this.offsetStream}) {
    imageStream.listen((temp) {
      _image = temp.image;
      backUp = backUp.sublist(temp.lastIndex);
    });
  }

  @override
  bool shouldRepaint(MasterPiecePainter old) {
    return false;
  }

  void startStroke(Offset position) {
    print("startStroke");
    backUp.add(current);
    List<Offset> newList = List();
    current = newList..add(position);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    print("appendStroke");
    current.add(position);
    notifyListeners();
  }

  void endStroke() {
    savePicture();
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
    if (current.length > 20) {
      List<Offset> newList = List();
      newList.add(current.last);
      backUp.add(current);
      current = newList;
      savePicture();
    }
    backUp.forEach((el) {
      paint.color = chosenColor;
      Path strokePath = new Path();
      strokePath.addPolygon(el, false);
      canvas.drawPath(strokePath, paint);
    });
    if (current.length > 0) {
      paint.color = chosenColor;
      Path strokePath = new Path();
      strokePath.addPolygon(current, false);
      canvas.drawPath(strokePath, paint);
    }
  }

  Future<void> savePicture() async {
    final lastIndex = backUp.length - 1;
    final recorder = new ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(_size.width, _size.height)));

    paint(canvas, null);

    final picture = recorder.endRecording();

    final img = await picture.toImage(375, 812);
    _image = img;
    Temp temp = Temp();
    temp.image = _image;
    temp.lastIndex = lastIndex;
    imageStream.add(temp);
    print("done!");
    //final pngBytes = await img.toByteData(format: ImageByteFormat.png);
  }

  ui.Image getImage() {
    return _image;
  }
}

class Temp {
  ui.Image image;
  int lastIndex;
}

/*
  CustomPaint
  CustomPainter

  decodeImageFromList() = ui.Image
  SizedBox for resizing image
  FittedBox for fitting and scaling
 */