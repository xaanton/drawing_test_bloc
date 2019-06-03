import 'dart:async';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'drawing_events.dart';
import 'drawing_states.dart';


class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {

  Image _lastSavedImage;
  int _offset = 0;
  int _counter = 0;

  @override
  DrawingState get initialState => DrawingEmpty();

  @override
  Stream<DrawingState> mapEventToState(DrawingEvent event) async* {
    if (event is DrawingUpdatedEvent) {
      //yield DrawingLoading();
      try {
        if(_counter > 15)_counter = 0;
        if(event.cur.length < _offset)_offset = 0;
        print("copy from " + _offset.toString() + " to " + (event.cur.length -1).toString());
        var toDraw = event.cur.sublist(_offset, event.cur.length -1);
        yield DrawingLoaded(cur: toDraw, image: _lastSavedImage,haveToSaveImage: _counter > 14 ? true : false);
        _counter++;
      } catch (e) {
        print(e.toString());
        yield DrawingEmpty();
      }
    }

    if(event is DrawingSaveImageEvent) {
      _lastSavedImage = event.image;
      _offset = event.offset;
    }

    /*
    if (event is RefreshWeather) {
      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (_) {
        yield currentState;
      }
    }
    */
  }
}
