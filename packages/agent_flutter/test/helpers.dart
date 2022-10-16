import 'dart:async';

import 'package:agent_core/agent_core.dart';

class TestEvent extends AgentBaseEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class TestState {
  final int state;
  TestState(this.state);
}

class TestAgent extends Agent<TestEvent> {
  final List<TestEvent> recordedEvents = [];

  TestAgent() {
    on<TestEvent>(recordedEvents.add);
  }
}

class TestStateAgent extends StateAgent<TestState, TestEvent> {
  final List<TestEvent> recordedEvents = [];
  final List<TestState> recordedStates = [];
  late StreamSubscription stateSubscription;

  TestStateAgent(super.state) {
    stateSubscription = stateStream.listen((s) => recordedStates.add(s));
    on<TestEvent>(recordedEvents.add);
  }

  @override
  Future<void> dispose() async {
    await stateSubscription.cancel();
  }
}
