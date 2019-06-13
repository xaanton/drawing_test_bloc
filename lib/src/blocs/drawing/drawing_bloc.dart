import 'dart:async';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'drawing_events.dart';
import 'drawing_states.dart';
import 'redux_state_object.dart';


class DrawingBloc extends Bloc<DrawingEvent, ReduxStateObject> {

  Image _lastSavedImage;
  int _lastIndex = -1;
  bool _shouldUpdate = false;
  //final BehaviorSubject<Image> imageStream = BehaviorSubject();

  @override
  ReduxStateObject get initialState => ReduxStateObject(null, null, null);

  @override
  Stream<ReduxStateObject> mapEventToState(DrawingEvent event) async* {
    if (event is DrawingUpdatedEvent) {
      //yield DrawingLoading();
      try {
        Image lastImage = event.state.image;
        List cur = event.cur;
        if (_shouldUpdate ) {
          lastImage = _lastSavedImage;
          if(_lastIndex < cur.length && _lastIndex > -1) {
            cur = event.cur.sublist(_lastIndex);
          }
          _shouldUpdate = false;
          _lastIndex = -1;
        }

        yield ReduxStateObject(cur, event.picture, lastImage);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null, null);
      }
    }

    if(event is DrawingSaveImageEvent) {
      _lastIndex = event.lastIndex;
      _lastSavedImage = event.image;
      _shouldUpdate = true;
    }

    if(event is DrawingClearEvent) {
      try {
        _lastSavedImage = null;
        _lastIndex = -1;
        _shouldUpdate = false;
        yield ReduxStateObject(null, null, null);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null, null);
      }
    }
  }

  @override
  void dispose() {
    //imageStream.close();
    super.dispose();
  }
}
