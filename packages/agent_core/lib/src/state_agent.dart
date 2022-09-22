import 'dart:async';

import 'abstract.dart';
import 'agent.dart';

abstract class StateAgent<State, Event> extends Agent<Event>
    implements Stateful<State> {
  late StreamController<State> _statesStreamController;

  @override
  late Stream<State> stateStream;

  @override
  late State state;

  StateAgent(this.state) : super() {
    _statesStreamController = StreamController.broadcast(sync: true);
    stateStream = _statesStreamController.stream;
  }

  @override
  void nextState(State state) {
    this.state = state;
    _statesStreamController.add(this.state);
  }
}
