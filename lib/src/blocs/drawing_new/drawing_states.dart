import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class DrawingState extends Equatable {
  DrawingState([List props = const []]) : super(props);
}

class DrawingEmpty extends DrawingState {}

class DrawingLoading extends DrawingState {}

class DrawingLoaded extends DrawingState {
  final Image image;
  final List<Offset> cur;
  DrawingLoaded({@required this.image,
    @required this.cur,
  }):super([image, cur]);
}