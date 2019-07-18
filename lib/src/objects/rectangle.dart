import 'dart:ui';

import 'drawing_object.dart';

class Rectangle extends DrawingObject {

  Offset firstPoint;
  Offset secondPoint;

  @override
  void drawObject(Canvas canvas, Paint paint) {
    if( firstPoint != null && secondPoint != null ) {
      print("RECT");
      paint.color = Color.fromRGBO(150, 100, 100, 0.9);
      Rect rect = Rect.fromPoints(firstPoint, secondPoint);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  DrawingObject getEmptyInstance() {
    return Rectangle();
  }

  @override
  void handleTap(Offset offset) {
    secondPoint = offset;
    if(firstPoint == null) firstPoint = secondPoint;
  }

  @override
  bool shouldBackupNow() {
    return false;
  }

}