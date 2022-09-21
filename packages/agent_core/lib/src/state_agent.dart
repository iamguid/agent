import 'dart:async';

import 'abstract.dart';

abstract class StateAgent<State, Event>
    implements BaseAgent<Event>, Stateful<State> {
  final Set<CanStoreListeners> _connectionsSet = {};
  late StreamController<State> _statesStreamController;
  late StreamController<Event> _eventsStreamController;

  @override
  late Stream<Event> eventsStream;

  @override
  late Stream<State> stateStream;

  @override
  late State state;

  StateAgent(this.state) : super() {
    _eventsStreamController = StreamController.broadcast(sync: true);
    _statesStreamController = StreamController.broadcast(sync: true);
    eventsStream = _eventsStreamController.stream;
    stateStream = _statesStreamController.stream;
  }

  @override
  void onEvent(Event event) {
    _eventsStreamController.add(event);
  }

  @override
  void nextState(Object? state) {
    if (state is State) {
      this.state = state;
      _statesStreamController.add(this.state);
    }
  }

  @override
  void connect(CanStoreListeners target) {
    assert(
      !_connectionsSet.contains(target),
      'StateAgent is already connected to the target',
    );

    target.addEventListener(this);
    _connectionsSet.add(target);
  }

  @override
  void disconnect(CanStoreListeners target) {
    assert(
      _connectionsSet.contains(target),
      'StateAgent is not connected to the target',
    );

    target.removeEventListener(this);
    _connectionsSet.remove(target);
  }
}
