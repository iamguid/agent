import 'dart:async';

import 'agent.dart';

abstract class StateAgent<TEvent, TState> extends Agent<TEvent>
    implements Stateful<TState> {
  late StreamController<TState> _statesStreamController;

  @override
  late Stream<TState> statesStream;

  @override
  late TState state;

  StateAgent(this.state) : super() {
    _statesStreamController = StreamController.broadcast(sync: true);
    statesStream = _statesStreamController.stream;
  }

  @override
  void nextState(TState state) {
    this.state = state;
    _statesStreamController.add(this.state);
  }
}
