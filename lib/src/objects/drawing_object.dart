import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' as mat;
export 'rectangle.dart';
export 'oval.dart';
export 'star_eight.dart';
export 'star_five.dart';
export 'rect_in_circle.dart';
export 'star_sixteen.dart';
export 'flower.dart';

abstract class DrawingObject {
  Color color;
  void drawObject(Canvas canvas, Paint paint);
  void handleTap(Offset offset);
  bool shouldBackupNow();
  DrawingObject getEmptyInstance();

  Color getColor({int index = -1}) {
    if(index == -1) {
      index = Random().nextInt(7);
    }
    switch(index){
      case 0: return  mat.Colors.amber;
      case 1: return  mat.Colors.red;
      case 2: return  mat.Colors.blue;
      case 3: return  mat.Colors.green;
      case 4: return  mat.Colors.pink;
      case 5: return  mat.Colors.tealAccent;
      case 6: return  mat.Colors.cyan;
      case 7: return  mat.Colors.deepPurple;
    }
    return mat.Colors.black87;
  }

  void drawPoint( Offset point, Color color, Paint paint, Canvas canvas ) {
    paint.color = color;
    canvas.drawCircle(point, 3, paint);
  }
}

class CustomPath extends DrawingObject {

  final List<Offset> path = new List();

  CustomPath() {
    color = getColor(index: Random().nextInt(7));
  }

  @override
  void drawObject(Canvas canvas, Paint paint) {
    paint.color = this.color;
    Path strokePath = new Path();
    strokePath.addPolygon(path, false);
    canvas.drawPath(strokePath, paint);
  }

  void handleTap(Offset offset) {
    path.add(offset);
  }

  @override
  bool shouldBackupNow() {
    return path.length > 20;
  }

  @override
  DrawingObject getEmptyInstance() {
    return CustomPath();
  }

}