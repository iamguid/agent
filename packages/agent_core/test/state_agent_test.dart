import 'dart:async';

import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent extends AgentBaseEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class TestState {
  final int stateId;
  TestState(this.stateId);
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

void main() {
  group('one state agent', () {
    test('state agent creates correctly', () async {
      final testInitialState = TestState(0);
      final stateAgent = TestStateAgent(testInitialState);

      expect(stateAgent.state, testInitialState);
      expect(stateAgent.recordedStates.length, 0);

      await stateAgent.dispose();
    });

    test('when call nextState state should be changed', () async {
      final testInitialState = TestState(0);
      final stateAgent = TestStateAgent(testInitialState);
      final testState1 = TestState(1);
      final testState2 = TestState(1);

      stateAgent.nextState(testState1);
      expect(stateAgent.state, testState1);

      stateAgent.nextState(testState2);
      expect(stateAgent.state, testState2);

      await stateAgent.dispose();
    });

    test('when call nextState stateStream should be emit new state', () async {
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

      await stateAgent.dispose();
    });
  });

  group('two state agents', () {
    test('(agentA <-> agnetB) send and recieve events', () async {
      final stateAgentAInitialState = TestState(0);
      final stateAgentBInitialState = TestState(1);
      final stateAgentANewState = TestState(2);
      final stateAgentBNewState = TestState(3);
      final stateAgentA = TestStateAgent(stateAgentAInitialState);
      final stateAgentB = TestStateAgent(stateAgentBInitialState);

      stateAgentA.connect(stateAgentB);

      stateAgentA.nextState(stateAgentANewState);
      stateAgentB.nextState(stateAgentBNewState);

      expect(stateAgentA.recordedEvents.length, 3);
      expect((stateAgentA.recordedEvents[1] as StateAgentStateChanged).state,
          stateAgentANewState);
      expect((stateAgentA.recordedEvents[2] as StateAgentStateChanged).state,
          stateAgentBNewState);
      expect(stateAgentB.recordedEvents.length, 3);
      expect((stateAgentB.recordedEvents[1] as StateAgentStateChanged).state,
          stateAgentANewState);
      expect((stateAgentB.recordedEvents[2] as StateAgentStateChanged).state,
          stateAgentBNewState);

      stateAgentA.disconnect(stateAgentB);

      await stateAgentA.dispose();
      await stateAgentB.dispose();
    });
  });

  group('three state agents', () {
    test('(agentA <-> agnetB, agentA <-> agentC) send and recieve events',
        () async {
      final stateAgentAInitialState = TestState(0);
      final stateAgentBInitialState = TestState(1);
      final stateAgentCInitialState = TestState(2);
      final stateAgentANewState = TestState(3);
      final stateAgentBNewState = TestState(4);
      final stateAgentCNewState = TestState(5);
      final stateAgentA = TestStateAgent(stateAgentAInitialState);
      final stateAgentB = TestStateAgent(stateAgentBInitialState);
      final stateAgentC = TestStateAgent(stateAgentCInitialState);

      stateAgentA.connect(stateAgentB);
      stateAgentA.connect(stateAgentC);

      stateAgentA.nextState(stateAgentANewState);
      stateAgentB.nextState(stateAgentBNewState);
      stateAgentC.nextState(stateAgentCNewState);

      expect(stateAgentA.recordedEvents.length, 5);
      expect((stateAgentA.recordedEvents[2] as StateAgentStateChanged).state,
          stateAgentANewState);
      expect((stateAgentA.recordedEvents[3] as StateAgentStateChanged).state,
          stateAgentBNewState);
      expect((stateAgentA.recordedEvents[4] as StateAgentStateChanged).state,
          stateAgentCNewState);
      expect(stateAgentB.recordedEvents.length, 5);
      expect((stateAgentB.recordedEvents[2] as StateAgentStateChanged).state,
          stateAgentANewState);
      expect((stateAgentB.recordedEvents[3] as StateAgentStateChanged).state,
          stateAgentBNewState);
      expect((stateAgentB.recordedEvents[4] as StateAgentStateChanged).state,
          stateAgentCNewState);
      expect(stateAgentC.recordedEvents.length, 4);
      expect((stateAgentC.recordedEvents[1] as StateAgentStateChanged).state,
          stateAgentANewState);
      expect((stateAgentC.recordedEvents[2] as StateAgentStateChanged).state,
          stateAgentBNewState);
      expect((stateAgentC.recordedEvents[3] as StateAgentStateChanged).state,
          stateAgentCNewState);

      stateAgentA.disconnect(stateAgentB);
      stateAgentA.disconnect(stateAgentC);

      await stateAgentA.dispose();
      await stateAgentB.dispose();
      await stateAgentC.dispose();
    });
  });
}
