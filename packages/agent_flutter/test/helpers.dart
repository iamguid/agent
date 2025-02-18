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

class TestAgent extends Agent {
  final List<AgentBaseEvent> recordedEvents = [];

  TestAgent() {
    on<AgentBaseEvent>('*', (_, event) => recordedEvents.add(event));
  }
}

class TestStateAgent extends StateAgent<TestState> {
  final List<AgentBaseEvent> recordedEvents = [];
  final List<TestState> recordedStates = [];
  late StreamSubscription stateSubscription;

  TestStateAgent(super.state) {
    on<AgentBaseEvent>('*', (_, event) => recordedEvents.add(event));
    stateSubscription = stateStream.listen((s) => recordedStates.add(s));
  }

  @override
  Future<void> dispose() async {
    await stateSubscription.cancel();
    await super.dispose();
  }
}
