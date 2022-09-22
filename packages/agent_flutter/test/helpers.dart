import 'dart:async';

import 'package:agent_core/agent_core.dart';

class TestEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class TestState {
  final int state;
  TestState(this.state);
}

class TestAgent extends Agent<TestEvent> {
  final List<TestEvent> recordedEvents = [];

  @override
  void onEvent(event) {
    if (event is TestEvent) {
      recordedEvents.add(event);
    }
  }

  @override
  Future<void> dispose() async {
    disconnectAll();
  }
}

class TestStateAgent extends StateAgent<TestState, TestEvent> {
  final List<TestEvent> recordedEvents = [];
  final List<TestState> recordedStates = [];
  late StreamSubscription stateSubscription;

  TestStateAgent(super.state) {
    stateSubscription = stateStream.listen((s) => recordedStates.add(s));
  }

  @override
  Future<void> dispose() async {
    await stateSubscription.cancel();
  }

  @override
  void onEvent(event) {
    if (event is TestEvent) {
      recordedEvents.add(event);
    }
  }
}
