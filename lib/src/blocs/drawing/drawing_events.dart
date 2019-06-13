import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'redux_state_object.dart';

abstract class DrawingEvent extends Equatable {
  final ReduxStateObject state;
  DrawingEvent(this.state, [List props = const []]) : super(props);
}

class DrawingUpdatedEvent extends DrawingEvent {

  final List<Offset> cur;
  final Picture picture;
  final Image image;
  DrawingUpdatedEvent({@required this.cur, @required this.picture, @required ReduxStateObject state, @required this.image})
      : assert(cur != null), super(state, [cur, picture]);

}

class DrawingSaveImageEvent extends DrawingEvent{
  final Image image;
  final int lastIndex;
  DrawingSaveImageEvent({@required this.image, @required this.lastIndex, @required ReduxStateObject state})
      : assert(image != null), super(state, [image]);
}

class DrawingClearEvent extends DrawingEvent{
  DrawingClearEvent({@required ReduxStateObject state}) : super(state);
}