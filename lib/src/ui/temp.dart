import 'package:flutter/material.dart';
import 'temp_holder.dart';
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
    return GestureDetector(
        onPanStart: (DragStartDetails details) => _onPanStart(context, details),
        onPanUpdate: (DragUpdateDetails details) =>
            _onPanUpdate(context, details),
        onPanEnd: (DragEndDetails details) => _onPanUp(),
        child: Container(child: holder));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
        child: SizedBox.expand(
      child: getGestureDetector(),
    ));
  }
}
