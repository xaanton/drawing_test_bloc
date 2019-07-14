import 'dart:ui';

import 'package:drawing_test3/src/objects/drawing_object.dart';
export 'package:drawing_test3/src/objects/drawing_object.dart';

class ReduxStateObject {
  final DrawingObject cur;
  final List<DrawingObject> backup;
  final Image image;
  final bool shouldSave;
  ReduxStateObject(this.cur, this.backup, this.image, this.shouldSave);
}