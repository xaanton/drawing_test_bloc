import 'dart:ui';

class ReduxStateObject {
  final List<Offset> cur;
  final List<List<Offset>> backup;
  final Image image;
  final bool shouldSave;
  ReduxStateObject(this.cur, this.backup, this.image, this.shouldSave);
}