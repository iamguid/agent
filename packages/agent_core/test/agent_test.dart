import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent extends AgentBaseEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class TestAgent extends Agent<TestEvent> {
  final List<dynamic> recordedEvents = [];

  TestAgent() {
    on<AgentBaseEvent>(recordedEvents.add);
  }
}

void main() {
  group('one agent', () {
    test('agent creates correctly', () {
      final agent = TestAgent();
      expect(agent.connections.length, 0);
      expect(agent.recordedEvents.length, 0);
    });

    test('agent connect with self should throw error', () {
      final agent = TestAgent();

      expect(
        () => agent.connect(agent),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });
  });

  group('two agents', () {
    test('(agentA <-> agentB) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();

      agentA.connect(agentB);

      // Check connections and listeners
      expect(agentA.connections.length, 1);
      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);
      expect(agentA.listeners.length, 1);
      expect(agentA.listeners[0], agentB);
      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentA);
      expect(agentB.listeners.length, 1);
      expect(agentB.listeners[0], agentA);

      // Connected event fired
      expect(agentA.recordedEvents.length, 1);
      expect(agentA.recordedEvents[0] is AgentConnected, true);
      expect(agentB.recordedEvents.length, 1);
      expect(agentB.recordedEvents[0] is AgentConnected, true);

      agentA.disconnect(agentB);

      // Check connections and listeners
      expect(agentA.connections.length, 0);
      expect(agentA.listeners.length, 0);
      expect(agentB.connections.length, 0);
      expect(agentB.listeners.length, 0);

      // Disconnected event fired
      expect(agentA.recordedEvents.length, 2);
      expect(agentA.recordedEvents[1] is AgentDisconnected, true);
      expect(agentB.recordedEvents.length, 2);
      expect(agentB.recordedEvents[1] is AgentDisconnected, true);
    });

    test('(agentA <-> agentB) send and recieve events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentA.dispatch(event);

      expect(agentA.recordedEvents.length, 2);
      expect(agentA.recordedEvents[1], event);
      expect(agentB.recordedEvents.length, 2);
      expect(agentB.recordedEvents[1], event);
    });
  });

  group('three agents', () {
    test('(agentA <-> agentB <-> agentC) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();

      agentA.connect(agentB);
      agentB.connect(agentC);

      // Check connections and listeners
      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);
      expect(agentB.connections.length, 2);
      expect(agentB.connections[0], agentA);
      expect(agentB.connections[1], agentC);
      expect(agentC.connections.length, 1);
      expect(agentC.connections[0], agentB);

      // Connected event fired
      expect(agentA.recordedEvents.length, 2);
      expect(agentA.recordedEvents[0] is AgentConnected, true);
      expect(agentA.recordedEvents[1] is AgentConnected, true);
      expect(agentB.recordedEvents.length, 2);
      expect(agentB.recordedEvents[0] is AgentConnected, true);
      expect(agentB.recordedEvents[1] is AgentConnected, true);
      expect(agentC.recordedEvents.length, 1);
      expect(agentC.recordedEvents[0] is AgentConnected, true);

      agentA.disconnect(agentB);
      agentB.disconnect(agentC);

      // Disconnected event fired
      expect(agentA.recordedEvents.length, 3);
      expect(agentA.recordedEvents[2] is AgentDisconnected, true);
      expect(agentB.recordedEvents.length, 4);
      expect(agentB.recordedEvents[2] is AgentDisconnected, true);
      expect(agentB.recordedEvents[3] is AgentDisconnected, true);
      expect(agentC.recordedEvents.length, 3);
      expect(agentC.recordedEvents[2] is AgentDisconnected, true);
    });

    test('(agentA <-> agentB <-> agentC) send and receive events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.connect(agentC);

      agentA.dispatch(event);

      expect(agentA.recordedEvents.length, 3);
      expect(agentA.recordedEvents[2], event);

      expect(agentB.recordedEvents.length, 3);
      expect(agentB.recordedEvents[2], event);

      expect(agentC.recordedEvents.length, 2);
      expect(agentC.recordedEvents[1], event);
    });
  });

  group('misc', () {
    test('(agentA <-> agentB, agentA <-> agentB) should throws error', () {
      final agentA = TestAgent();
      final agentB = TestAgent();

      expect(
        () {
          agentA.connect(agentB);
          agentA.connect(agentB);
        },
        throwsA(TypeMatcher<AssertionError>()),
      );
    });
  });
}
