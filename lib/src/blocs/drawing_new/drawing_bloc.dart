import 'dart:async';
import 'dart:io';
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
  final BehaviorSubject<ReduxStateObject> stateStream = new BehaviorSubject();
  final BehaviorSubject<bool> isSavingStream = new BehaviorSubject();
  //final PublishSubject<Offset> offsetStream;
  //StreamSubscription<Offset> t;
  DrawingBloc() {
    /*
    t = offsetStream.listen((offset) {
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
      print(imageStream.length);
      image = temp.image;
      if(backUp.length -1 > temp.lastIndex && temp.lastIndex > -1) {
        backUp = backUp.sublist(temp.lastIndex);
      }
    });
    */
    isSavingStream.distinct((p,n) => p == n);
    isSavingStream.add(false);
    stateStream.listen((state) {
      this.dispatch(DrawingRedrawEvent(state: state));
    });

   }

  ReduxStateObject getInitialState() {
    return ReduxStateObject(List(), List(), null, false);
  }

  bool shouldSave(int backUpLength) {
    print("backup length = " + backUpLength.toString());
    return backUpLength > 1 && isSavingStream.value == false;
  }
  @override
  ReduxStateObject get initialState => this.getInitialState();

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
    print("event = " + event.runtimeType.toString());

    if (event is DrawingRedrawEvent) {
      yield event.state;
    }

    /*
    if (event is DrawingUpdatedEvent) {
      //yield DrawingLoading();

      try {
        Image lImage;

        if(imageStream.hasValue) {
          Temp temp = imageStream.value;
          lImage = temp.image;
        }
        print("event handler: " + event.cur.toString());
        offsetStream.add(event.cur);
        print("cur length " + current.length.toString());
        yield ReduxStateObject(current, backUp, lImage, backUp.length > 0 && isSavingNow == false);
      } catch (e) {
        print(e.toString());
        yield ReduxStateObject(null, null, null, false);
      }
    }
    */

    if(event is DrawingUpdatedEvent) {
      ReduxStateObject curState = stateStream.value;
      List<Offset> newCur = curState.cur;
      List<List<Offset>> newBackUp = curState.backup;
      if(event.cur != null) newCur.add(event.cur);
      if(newCur.length > 50 || event.cur == null) {
        newBackUp.add(newCur);
        newCur = new List();
        if(event.cur != null) newCur.add(event.cur);
      }

      ReduxStateObject newState = ReduxStateObject(
          newCur,
          newBackUp,
          curState.image,
          shouldSave(curState.backup.length)
      );
      stateStream.add(newState);
    }

    if(event is DrawingSaveInitEvent) {
      /*ReduxStateObject curState = stateStream.value;
      ReduxStateObject newState = ReduxStateObject(
          curState.cur,
          curState.backup,
          curState.image,
          false
      );
      stateStream.add(newState);*/
      isSavingStream.add(true);
    }

    if(event is DrawingSaveEvent) {
      isSavingStream.add(false);
      ReduxStateObject curState = stateStream.value;
      List<List<Offset>> newBackup = curState.backup;
      print("last index = " + event.lastIndex.toString());
      print("cur backup length = " + newBackup.length.toString());
      if(newBackup.length -1 >= event.lastIndex && event.lastIndex > -1) {
        newBackup = newBackup.sublist(event.lastIndex);
      }

      ReduxStateObject newState = ReduxStateObject(
          curState.cur,
          newBackup,
          event.image,
          shouldSave(newBackup.length)
      );
      stateStream.add(newState);
    }

    if(event is DrawingClearEvent) {
      try {
        ReduxStateObject newState = this.getInitialState();
        stateStream.add(newState);
      } catch (e) {
        print(e.toString());
        yield this.getInitialState();
      }
    }
  }

  @override
  void dispose() {
    imageStream.close();
    offsetStream.close();
    stateStream.close();
    isSavingStream.close();
    super.dispose();
  }

}

