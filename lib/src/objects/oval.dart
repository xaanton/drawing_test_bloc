import 'dart:ui';

import 'drawing_object.dart';
import 'dart:math';
import 'package:flutter/material.dart' as mat;

class Oval extends DrawingObject {

  Offset firstPoint;
  Offset secondPoint;

  Oval() {
    this.color = getColor(index: Random().nextInt(7));
  }

  @override
  void drawObject(Canvas canvas, Paint paint) {
    if( firstPoint != null && secondPoint != null ) {
      print("OVAL");

      //Rect rect = Rect.fromPoints(firstPoint, secondPoint);

      Offset center = Offset(
          firstPoint.dx + (secondPoint.dx - firstPoint.dx)/2,
          firstPoint.dy + (secondPoint.dy - firstPoint.dy)/2
      );
      double radius =
        sqrt(pow(secondPoint.dx - firstPoint.dx, 2) +
            pow(secondPoint.dy - firstPoint.dy, 2))/2;
      paint.color = mat.Colors.blue;
      canvas.drawCircle(center, radius, paint);
      /*Rect rect = Rect.fromPoints(firstPoint, secondPoint);
      paint.color = mat.Colors.indigo;
      canvas.drawRect(rect, paint);*/
      paint.color = mat.Colors.red;
      canvas.drawCircle(center, 3, paint);
      paint.color = mat.Colors.green;
      canvas.drawCircle(firstPoint, 3, paint);
      canvas.drawCircle(secondPoint, 3, paint);
      //canvas.drawRect(rect, paint);
    }
  }

  @override
  DrawingObject getEmptyInstance() {
    return Oval();
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