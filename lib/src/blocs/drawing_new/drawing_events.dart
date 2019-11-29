import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'state_object.dart';

abstract class DrawingEvent extends Equatable {
  DrawingEvent([List props = const []]) : super(props);
}

class DrawingUpdatedEvent extends DrawingEvent {

  final Offset cur;

  DrawingUpdatedEvent({@required this.cur})
      : super([cur]);

}

class DrawingRedrawEvent extends DrawingEvent {

  final StateObject state;

  DrawingRedrawEvent({@required this.state})
      : assert(state != null), super([state]);

}

class DrawingSaveInitEvent extends DrawingEvent {

}

class DrawingSaveEvent extends DrawingEvent {
  final Image image;
  final int lastIndex;
  DrawingSaveEvent(this.image, this.lastIndex);
}

class DrawingClearEvent extends DrawingEvent {
  DrawingClearEvent() : super([]);
}

class DrawingOverEvent extends DrawingEvent {

}
class DrawingChangeObjectEvent extends DrawingEvent {
  final DrawingObject newObject;
  DrawingChangeObjectEvent(this.newObject);
}
