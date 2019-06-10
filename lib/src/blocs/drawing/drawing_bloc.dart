import 'dart:async';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'drawing_events.dart';
import 'drawing_states.dart';
import 'redux_state_object.dart';


class DrawingBloc extends Bloc<DrawingEvent, ReduxStateObject> {

  //Picture _lastSavedImage;
  //final BehaviorSubject<Image> imageStream = BehaviorSubject();

  @override
  ReduxStateObject get initialState => ReduxStateObject(null, null);

  @override
  Stream<ReduxStateObject> mapEventToState(DrawingEvent event) async* {
    if (event is DrawingUpdatedEvent) {
      //yield DrawingLoading();
      try {
        yield ReduxStateObject(event.cur, event.picture);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null);
      }
    }

    if(event is DrawingSaveImageEvent) {
      //_lastSavedImage = event.image;
    }

    if(event is DrawingClearEvent) {
      try {
        //_lastSavedImage = null;
        yield ReduxStateObject(null, null);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null);
      }
    }
  }

  @override
  void dispose() {
    //imageStream.close();
    super.dispose();
  }
}
