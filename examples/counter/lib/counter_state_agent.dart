import 'package:agent_flutter/agent_flutter.dart';
import 'package:counter/counter_events.dart';
import 'package:counter/counter_state.dart';

class CounterStateAgent extends StateAgent<CounterState, CounterEvent> {
  CounterStateAgent() : super(CounterState.empty());

  @override
  void onEvent(Object? event) {
    if (event is CounterIncrementedEvent) {
      nextState(CounterState(counter: state.counter + 1));
    }

    if (event is CounterDecrementedEvent) {
      nextState(CounterState(counter: state.counter - 1));
    }
  }
}
