import 'package:flutter/material.dart';
import 'temp_holder2.dart';
import 'dart:ui';

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

  void _onPanStart(BuildContext context, DragStartDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset _tapPos = box.globalToLocal(details.globalPosition);
    holder.painter.startStroke(_tapPos);
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    RenderBox box = context.findRenderObject();
    print(details.globalPosition);
    Offset _tapPos = box.globalToLocal(details.globalPosition);
    holder.painter.appendStroke(_tapPos);
  }

  void _onPanUp() {
    holder.painter.endStroke();
  }

  void clear() {
    print("Clear!");
    holder.painter.clearAll();
  }

  Widget getGestureDetector() {
    return Center(

        child: Column(
          mainAxisSize: MainAxisSize.max,

          children: <Widget>[
            Expanded(
              flex: 10,
                child:
                SizedBox.expand(
                  //color: Colors.green,
                  child: GestureDetector(
                      child: holder,
                      onPanStart: (DragStartDetails details) => _onPanStart(context, details),
                      onPanUpdate: (DragUpdateDetails details) =>
                      _onPanUpdate(context, details),
                      onPanEnd: (DragEndDetails details) => _onPanUp(),
                  ),
                )
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.red,
                child: FlatButton(onPressed: () => holder.painter.clearAll(), child: Icon(Icons.assistant_photo)),),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return getGestureDetector();
  }
}
