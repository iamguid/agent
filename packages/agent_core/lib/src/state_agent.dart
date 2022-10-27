import 'dart:async';

import 'abstract.dart';
import 'agent.dart';

abstract class StateAgentEvent extends AgentBaseEvent {}

class StateAgentStateChanged<State> extends StateAgentEvent {
  final State state;
  final StateAgent source;

  StateAgentStateChanged({
    required this.state,
    required this.source,
  });
}

abstract class StateAgent<State, Event extends AgentBaseEvent>
    extends Agent<Event> implements Stateful<State> {
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
    dispatch(StateAgentStateChanged(state: state, source: this));
    _statesStreamController.add(this.state);
  }
}
