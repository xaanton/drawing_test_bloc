import 'dart:ui';

import 'drawing_object.dart';
import 'dart:math';
import 'package:flutter/material.dart' as mat;

class Flower extends DrawingObject {

  Offset firstPoint;
  Offset secondPoint;


  static final numberOfVertexes = 5;

  static final double _snVertex = sin(toRadian(360/numberOfVertexes));
  static final double _csVertex = cos(toRadian(360/numberOfVertexes));

  Flower() {
    this.color = getColor();
    if(this.color == mat.Colors.green)this.color = mat.Colors.deepOrangeAccent;
  }

  @override
  void drawObject(Canvas canvas, Paint paint) {
    if( firstPoint != null && secondPoint != null ) {
      print("STAR 8");

      Offset centerVector = Offset((secondPoint.dx - firstPoint.dx)/2, (secondPoint.dy - firstPoint.dy)/2);
      Offset center = Offset(
          firstPoint.dx + centerVector.dx,
          firstPoint.dy + centerVector.dy
      );

      double radius =
          sqrt(pow(secondPoint.dx - firstPoint.dx, 2) +
              pow(secondPoint.dy - firstPoint.dy, 2))/2;

      Offset unitVector = Offset(
          (center.dx - secondPoint.dx)/radius,
          (center.dy - secondPoint.dy)/radius
      );

      int count = 0;
      paint.color = this.color;
      paint.style = PaintingStyle.fill;
      double helperRadius = radius/3;
      while(count < numberOfVertexes) {

        unitVector = _getNextUnitVector(unitVector, _snVertex, _csVertex);
        //Offset addUnitVector = _getNextUnitVector(unitVector, _snHelper, _csHelper);
        //Offset nextPoint = _getNextVertex(center, unitVector, radius);
        Offset helperPointOne = _getNextVertex(center, unitVector, radius/2);
        canvas.drawCircle(helperPointOne, helperRadius, paint);
        count++;
      }

      paint.color = mat.Colors.black;
      canvas.drawCircle(center, helperRadius, paint);

      //drawPoint(firstPoint, mat.Colors.red, paint, canvas);
      //drawPoint(secondPoint, mat.Colors.red, paint, canvas);
      /*pointList.add(firstVertex);
      Path strokePath = new Path();
      strokePath.addPolygon(pointList, false);
      canvas.drawPath(strokePath, paint);*/

      //canvas.dr
      //canvas.drawLine(firstVertex, prevHelperPoint, paint);
    }
  }

  @override
  DrawingObject getEmptyInstance() {
    return Flower();
  }

  @override
  void handleTap(Offset offset) {
    if(firstPoint == null) firstPoint = offset;
    else secondPoint = offset;
  }

  @override
  bool shouldBackupNow() {
    return false;
  }

  Offset _getNextUnitVector(Offset currentUnitVector, double sin, double cos) {
    return Offset(
        currentUnitVector.dx * cos - currentUnitVector.dy * sin,
        currentUnitVector.dx * sin + currentUnitVector.dy * cos
    );
  }

  Offset _getNextVertex(Offset center, Offset unitVector, double radius) {
    return Offset(
        center.dx + (unitVector.dx * radius),
        center.dy + (unitVector.dy * radius)
    );
  }

  static double toRadian(double angle) {
    return (pi / 180) * angle;
  }

}