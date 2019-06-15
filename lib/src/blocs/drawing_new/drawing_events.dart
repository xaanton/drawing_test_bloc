import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'redux_state_object.dart';

abstract class DrawingEvent extends Equatable {
  DrawingEvent([List props = const []]) : super(props);
}

class DrawingUpdatedEvent extends DrawingEvent {

  final Offset cur;
  final Picture picture;

  DrawingUpdatedEvent({@required this.cur, @required this.picture})
      : super([cur, picture]);

}

class DrawingSaveInitEvent extends DrawingEvent {

}

class DrawingSaveEvent extends DrawingEvent {
  final Image image;
  final int lastIndex;
  DrawingSaveEvent(this.image, this.lastIndex);
}

class DrawingClearEvent extends DrawingEvent{
  DrawingClearEvent() : super([]);
}