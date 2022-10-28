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
  final List<AgentBaseEvent> recordedEvents = [];

  TestAgent() {
    on<AgentBaseEvent>(recordedEvents.add);
  }
}

class TestStateAgent extends StateAgent<TestState, TestEvent> {
  final List<AgentBaseEvent> recordedEvents = [];
  final List<TestState> recordedStates = [];
  late StreamSubscription stateSubscription;

  TestStateAgent(super.state) {
    on<AgentBaseEvent>(recordedEvents.add);
    stateSubscription = stateStream.listen((s) => recordedStates.add(s));
  }

  @override
  Future<void> dispose() async {
    await stateSubscription.cancel();
    await super.dispose();
  }
}
