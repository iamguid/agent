import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent extends AgentBaseEvent {
  final int eventId;
  TestEvent(this.eventId);
}

class BroadcastAgent extends Agent {
  final List<AgentBaseEvent> recordedEvents = [];

  BroadcastAgent() {
    on<AgentBaseEvent>('*', (_, event) => recordedEvents.add(event));
  }
}

class TopicAgent extends Agent {
  final List<AgentBaseEvent> agentRecordedEvents = [];
  final List<AgentBaseEvent> topicRecordedEvents = [];

  TopicAgent(String topic) {
    on<AgentBaseEvent>(topic, (_, event) => topicRecordedEvents.add(event));
  }
}

void main() {
  group('one agent', () {
    test('agent creates correctly', () {
      final agent = BroadcastAgent();
      expect(agent.connections.length, 0);
      expect(agent.recordedEvents.length, 0);
    });

    test('agent connect with self should throw error', () {
      final agent = BroadcastAgent();

      expect(
        () => agent.connect(agent),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });
  });

  group('two agents', () {
    test('(agentA <-> agentB) connect and disconnect', () {
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();

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
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentA.emit('test', event);

      expect(agentA.recordedEvents.length, 2);
      expect(agentA.recordedEvents[1], event);
      expect(agentB.recordedEvents.length, 2);
      expect(agentB.recordedEvents[1], event);
    });
  });

  group('three agents', () {
    test('(agentA <-> agentB <-> agentC) connect and disconnect', () {
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();
      final agentC = BroadcastAgent();

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
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();
      final agentC = BroadcastAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.connect(agentC);

      agentA.emit('test', event);

      expect(agentA.recordedEvents.length, 3);
      expect(agentA.recordedEvents[2], event);

      expect(agentB.recordedEvents.length, 3);
      expect(agentB.recordedEvents[2], event);

      expect(agentC.recordedEvents.length, 2);
      expect(agentC.recordedEvents[1], event);
    });
  });

  group('four agents', () {
    test(
        '(agentA <-> agentB, agentA <-> agentC, agentA <-> agentD) connect and disconnect',
        () {
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();
      final agentC = BroadcastAgent();
      final agentD = BroadcastAgent();

      agentA.connect(agentB);
      agentA.connect(agentC);
      agentA.connect(agentD);

      // Check connections and listeners
      expect(agentA.connections.length, 3);
      expect(agentA.connections[0], agentB);
      expect(agentA.connections[1], agentC);
      expect(agentA.connections[2], agentD);
      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentA);
      expect(agentC.connections.length, 1);
      expect(agentC.connections[0], agentA);
      expect(agentD.connections.length, 1);
      expect(agentD.connections[0], agentA);

      // Connected event fired
      expect(agentA.recordedEvents.length, 3);
      expect(agentA.recordedEvents[0] is AgentConnected, true);
      expect(agentA.recordedEvents[1] is AgentConnected, true);
      expect(agentA.recordedEvents[2] is AgentConnected, true);
      expect(agentB.recordedEvents.length, 3);
      expect(agentB.recordedEvents[0] is AgentConnected, true);
      expect(agentB.recordedEvents[1] is AgentConnected, true);
      expect(agentB.recordedEvents[2] is AgentConnected, true);
      expect(agentC.recordedEvents.length, 2);
      expect(agentC.recordedEvents[0] is AgentConnected, true);
      expect(agentC.recordedEvents[1] is AgentConnected, true);
      expect(agentD.recordedEvents.length, 1);
      expect(agentD.recordedEvents[0] is AgentConnected, true);

      agentA.disconnect(agentB);
      agentA.disconnect(agentC);
      agentA.disconnect(agentD);

      // Disconnected event fired
      expect(agentA.recordedEvents.length, 6);
      expect(agentA.recordedEvents[3] is AgentDisconnected, true);
      expect(agentA.recordedEvents[4] is AgentDisconnected, true);
      expect(agentA.recordedEvents[5] is AgentDisconnected, true);
      expect(agentB.recordedEvents.length, 4);
      expect(agentB.recordedEvents[3] is AgentDisconnected, true);
      expect(agentC.recordedEvents.length, 4);
      expect(agentC.recordedEvents[2] is AgentDisconnected, true);
      expect(agentC.recordedEvents[3] is AgentDisconnected, true);
      expect(agentD.recordedEvents.length, 4);
      expect(agentD.recordedEvents[1] is AgentDisconnected, true);
      expect(agentC.recordedEvents[2] is AgentDisconnected, true);
      expect(agentC.recordedEvents[3] is AgentDisconnected, true);
    });

    test(
        '(agentA <-> agentB, agentA <-> agentC, agentA <-> agentD) send and receive events',
        () {
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();
      final agentC = BroadcastAgent();
      final agentD = BroadcastAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentA.connect(agentC);
      agentA.connect(agentD);

      agentA.emit('test', event);

      expect(agentA.recordedEvents.length, 4);
      expect(agentA.recordedEvents[3], event);

      expect(agentB.recordedEvents.length, 4);
      expect(agentB.recordedEvents[3], event);

      expect(agentC.recordedEvents.length, 3);
      expect(agentC.recordedEvents[2], event);

      expect(agentD.recordedEvents.length, 2);
      expect(agentD.recordedEvents[1], event);
    });
  });

  group('misc', () {
    test('(agentA <-> agentB, agentA <-> agentB) should throws error', () {
      final agentA = BroadcastAgent();
      final agentB = BroadcastAgent();

      expect(
        () {
          agentA.connect(agentB);
          agentA.connect(agentB);
        },
        throwsA(TypeMatcher<AssertionError>()),
      );
    });
  });

  test('topics', () {
    final agentA = TopicAgent('topicA');
    final agentB = TopicAgent('topicA');
    final agentC = TopicAgent('topicB');

    agentA.connect(agentB);
    agentA.connect(agentC);

    agentA.emit('topicA', TestEvent(0));

    expect(agentA.topicRecordedEvents.length, 1);
    expect(agentB.topicRecordedEvents.length, 1);
    expect(agentC.topicRecordedEvents.length, 0);
  });
}
