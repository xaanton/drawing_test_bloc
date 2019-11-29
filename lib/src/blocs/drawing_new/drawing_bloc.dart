import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'drawing_events.dart';
import 'state_object.dart';

export 'temp.dart';
export 'state_object.dart';
export 'drawing_events.dart';



class DrawingBloc extends Bloc<DrawingEvent, StateObject> {

  final BehaviorSubject<StateObject> stateStream = new BehaviorSubject();
  final BehaviorSubject<bool> isSavingStream = new BehaviorSubject();

  DrawingBloc() {
    isSavingStream.distinct((p,n) => p == n);
    isSavingStream.add(false);
    stateStream.listen((state) {
      this.dispatch(DrawingRedrawEvent(state: state));
    });
    stateStream.add(initialState);
   }

  StateObject getInitialState() {
    return StateObject(CustomPath(), List(), null, false);
  }

  bool shouldSave(int backUpLength) {
    return backUpLength > 1 && isSavingStream.value == false;
  }

  @override
  StateObject get initialState => this.getInitialState();

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
  Stream<StateObject> mapEventToState(DrawingEvent event) async* {
    print("event2 = " + event.runtimeType.toString());

    if (event is DrawingRedrawEvent) {
      yield event.state;
    }

    if(event is DrawingUpdatedEvent) {
      StateObject curState = stateStream.value;
      DrawingObject newCur = curState.cur;
      List<DrawingObject> newBackUp = curState.backup;
      if(event.cur != null) newCur.handleTap(event.cur);
      if(newCur.shouldBackupNow() || event.cur == null) {
        newBackUp.add(newCur);
        newCur = newCur.getEmptyInstance();
        if(event.cur != null) newCur.handleTap(event.cur);
      }

      StateObject newState = StateObject(
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
      StateObject curState = stateStream.value;
      List<DrawingObject> newBackup = curState.backup;
      if(newBackup.length -1 >= event.lastIndex && event.lastIndex > -1) {
        newBackup = newBackup.sublist(event.lastIndex);
      }

      StateObject newState = StateObject(
          curState.cur,
          newBackup,
          event.image,
          shouldSave(newBackup.length)
      );
      stateStream.add(newState);
    }

    if(event is DrawingClearEvent) {
      try {
        StateObject newState = this.getInitialState();
        stateStream.add(newState);
      } catch (e) {
        print(e.toString());
        yield this.getInitialState();
      }
    }

    if(event is DrawingOverEvent) {
      StateObject curState = stateStream.value;
      DrawingObject newCur = curState.cur;
      List<DrawingObject> newBackUp = curState.backup;
      newBackUp.add(newCur);
      newCur = newCur.getEmptyInstance();

      StateObject newState = StateObject(
          newCur,
          newBackUp,
          curState.image,
          shouldSave(curState.backup.length)
      );
      stateStream.add(newState);
    }

    if(event is DrawingChangeObjectEvent) {
      StateObject curState = stateStream.value;
      DrawingObject newCur = event.newObject;
      List<DrawingObject> newBackUp = curState.backup;
      StateObject newState = StateObject(
          newCur,
          newBackUp,
          curState.image,
          shouldSave(curState.backup.length)
      );
      stateStream.add(newState);
    }

  }

  @override
  void dispose() {
    stateStream.close();
    isSavingStream.close();
    super.dispose();
  }

}

