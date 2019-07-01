import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'drawing_events.dart';
import 'redux_state_object.dart';

export 'temp.dart';
export 'redux_state_object.dart';
export 'drawing_events.dart';


class DrawingBloc extends Bloc<DrawingEvent, ReduxStateObject> {

  final BehaviorSubject<ReduxStateObject> stateStream = new BehaviorSubject();
  final BehaviorSubject<bool> isSavingStream = new BehaviorSubject();

  DrawingBloc() {
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
      isSavingStream.add(true);
    }

    if(event is DrawingSaveEvent) {
      isSavingStream.add(false);
      ReduxStateObject curState = stateStream.value;
      List<List<Offset>> newBackup = curState.backup;
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
    stateStream.close();
    isSavingStream.close();
    super.dispose();
  }

}

