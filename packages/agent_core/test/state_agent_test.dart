import 'dart:async';

import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class TestState {
  final int stateId;
  TestState(this.stateId);
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
  void onEvent(TestEvent event) {
    recordedEvents.add(event);
  }
}

void main() {
  group('one state agent', () {
    test('state agent creates correctly', () {
      final testInitialState = TestState(0);
      final stateAgent = TestStateAgent(testInitialState);

      expect(stateAgent.state, testInitialState);
      expect(stateAgent.recordedStates.length, 0);

      stateAgent.dispose();
    });

    test('when call nextState state should be changed', () {
      final testInitialState = TestState(0);
      final stateAgent = TestStateAgent(testInitialState);
      final testState1 = TestState(1);
      final testState2 = TestState(1);

      stateAgent.nextState(testState1);
      expect(stateAgent.state, testState1);

      stateAgent.nextState(testState2);
      expect(stateAgent.state, testState2);

      stateAgent.dispose();
    });

    test('when call nextState stateStream should be emit new state', () {
      final testInitialState = TestState(0);
      final stateAgent = TestStateAgent(testInitialState);
      final testState1 = TestState(1);
      final testState2 = TestState(1);

      stateAgent.nextState(testState1);
      expect(stateAgent.recordedStates.length, 1);
      expect(stateAgent.recordedStates[0], testState1);

      stateAgent.nextState(testState2);
      expect(stateAgent.recordedStates.length, 2);
      expect(stateAgent.recordedStates[1], testState2);

      stateAgent.dispose();
    });
  });
}
