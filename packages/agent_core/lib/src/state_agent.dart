import 'dart:async';

import 'abstract.dart';
import 'agent.dart';

abstract class StateAgent<State> extends Agent implements Stateful<State> {
  late StreamController<State> _statesStreamController;

  @override
  late Stream<State> stateStream;

  @override
  late State state;

  StateAgent(this.state) {
    _statesStreamController = StreamController.broadcast(sync: true);
    stateStream = _statesStreamController.stream;
  }

  @override
  void nextState(State state) {
    this.state = state;
    emit('agent', AgentStateChanged(state: state, source: this));
    _statesStreamController.add(this.state);
  }
}
