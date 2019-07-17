import 'dart:ui';

import 'drawing_object.dart';
import 'dart:math';
import 'package:flutter/material.dart' as mat;

class RectangleInCircle extends DrawingObject {

  Offset firstPoint;
  Offset secondPoint;

  RectangleInCircle() {
    this.color = getColor(index: Random().nextInt(7));
  }

  @override
  void drawObject(Canvas canvas, Paint paint) {
    if( firstPoint != null && secondPoint != null ) {
      print("OVAL");

      //Rect rect = Rect.fromPoints(firstPoint, secondPoint);

      Offset test = Offset((secondPoint.dx - firstPoint.dx)/2, (secondPoint.dy - firstPoint.dy)/2);
      Offset center = Offset(
          firstPoint.dx + test.dx,
          firstPoint.dy + test.dy
      );
      Offset thirdPoint = Offset(
        center.dx - test.dx,
        center.dy + test.dy
      );
      Offset forthPoint = Offset(
          center.dx + test.dx,
          center.dy - test.dy
      );

      double radius =
          sqrt(pow(secondPoint.dx - firstPoint.dx, 2) +
              pow(secondPoint.dy - firstPoint.dy, 2))/2;
      paint.color = mat.Colors.blue;
      canvas.drawCircle(center, radius, paint);

      

      //Offset thirdPoint = Offset(center.dx + radius);

      paint.color = mat.Colors.indigo;
      canvas.drawLine(firstPoint, thirdPoint, paint);
      canvas.drawLine(thirdPoint, secondPoint, paint);
      canvas.drawLine(secondPoint, forthPoint, paint);
      canvas.drawLine(forthPoint, firstPoint, paint);

      paint.color = mat.Colors.red;
      canvas.drawCircle(center, 3, paint);
      paint.color = mat.Colors.green;
      canvas.drawCircle(firstPoint, 3, paint);
      canvas.drawCircle(secondPoint, 3, paint);
      paint.color = mat.Colors.yellowAccent;
      canvas.drawCircle(thirdPoint, 3, paint);
      canvas.drawCircle(forthPoint, 3, paint);
      //canvas.drawRect(rect, paint);
    }
  }

  @override
  DrawingObject getEmptyInstance() {
    return RectangleInCircle();
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