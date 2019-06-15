import 'dart:async';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'drawing_events.dart';
import 'drawing_states.dart';
import 'redux_state_object.dart';
import 'temp.dart';

export 'temp.dart';
export 'redux_state_object.dart';
export 'drawing_events.dart';


class DrawingBloc extends Bloc<DrawingEvent, ReduxStateObject> {

  List<List<Offset>> backUp = new List();
  List<Offset> current = new List();
  Image image;
  bool isSavingNow = false;
  //Temp temp;
  final BehaviorSubject<Temp> imageStream = new BehaviorSubject();
  final BehaviorSubject<Offset> offsetStream = new BehaviorSubject();
  //final PublishSubject<Offset> offsetStream;

  DrawingBloc() {
    offsetStream.listen((offset) {
      if(current == null) {
        current = new List();
      }
      print("listener: " + offset.toString());
      if(offset != null) current.add(offset);
      if(current.length > 50 || offset == null) {
        backUp.add(current);
        current = new List();
        if(offset != null) current.add(offset);
      }
    });
    imageStream.listen((temp) {
      image = temp.image;
      if(backUp.length -1 > temp.lastIndex) {
        backUp = backUp.sublist(temp.lastIndex);
      }
    });
   }

  @override
  ReduxStateObject get initialState => ReduxStateObject(null, null, null, false);

  @override
  Stream<DrawingEvent> transform(Stream<DrawingEvent> events) {
    return (events as Observable<DrawingEvent>).distinct((event1, event2) {
      if (event1 is DrawingSaveEvent && event2 is DrawingSaveEvent) {
        return true;
      } else {
        return false;
      }
    }).map((e) {
      // TODO delete
      /*
      if (e is FetchMoreProducts) {
        //print("fetching more products page = " + e.pageNo.toString());
      }
      e.test = e.runtimeType.toString();
      */
      return e;
    });
  }

  @override
  Stream<ReduxStateObject> mapEventToState(DrawingEvent event) async* {
    print(event.runtimeType);
    if (event is DrawingUpdatedEvent) {
      //yield DrawingLoading();

      try {
        print("event handler: " + event.cur.toString());
        offsetStream.add(event.cur);
        //Temp temp = await imageStream.last;

        yield ReduxStateObject(current, backUp, image, backUp.length > 0 && isSavingNow == false);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null, null, false);
      }
    }

    if(event is DrawingSaveInitEvent) {
      isSavingNow = true;
    }

    if(event is DrawingSaveEvent) {
      imageStream.add(Temp(event.image, event.lastIndex));
      isSavingNow = false;
      //yield ReduxStateObject(current, backUp, image, false);
    }

    if(event is DrawingClearEvent) {
      try {
        current = new List();
        backUp = new List();
        image = null;
        isSavingNow = false;
        yield ReduxStateObject(null, null, null, false);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null, null, false);
      }
    }
  }

  @override
  void dispose() {
    imageStream.close();
    offsetStream.close();
    super.dispose();
  }

}

