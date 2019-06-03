import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class DrawingEvent extends Equatable {
  DrawingEvent([List props = const []]) : super(props);
}

class DrawingUpdatedEvent extends DrawingEvent {

  final List<Offset> cur;

  //final Image image;

  DrawingUpdatedEvent({@required this.cur})
      :
      super([cur]);

}

class DrawingSaveImageEvent extends DrawingEvent{
  final Image image;
  final int offset;
  DrawingSaveImageEvent({@required this.image, @required this.offset}) : assert(image != null), super([image, offset]);
}