import 'dart:async';

import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent {
  final int eventId;
  TestEvent(this.eventId);
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
    test('(agentA <- agentB) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();

      agentA.connect(agentB);

      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);
      expect(agentA.listeners.length, 0);
      expect(agentB.connections.length, 0);
      expect(agentB.listeners.length, 1);
      expect(agentB.listeners[0], agentA);

      agentA.disconnect(agentB);

      expect(agentA.connections.length, 0);
      expect(agentA.listeners.length, 0);
      expect(agentB.connections.length, 0);
      expect(agentB.listeners.length, 0);
    });

    test('(agentA <-> agentB) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();

      agentA.connect(agentB);
      agentB.connect(agentA);

      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);
      expect(agentA.listeners.length, 1);
      expect(agentA.listeners[0], agentB);

      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentA);
      expect(agentB.listeners.length, 1);
      expect(agentB.listeners[0], agentA);

      agentA.disconnect(agentB);
      agentB.disconnect(agentA);

      expect(agentA.connections.length, 0);
      expect(agentA.listeners.length, 0);

      expect(agentB.connections.length, 0);
      expect(agentB.listeners.length, 0);
    });

    test('(agentA <- agentB) send and recieve events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.dispatch(event);

      expect(agentA.recordedEvents.length, 1);
      expect(agentA.recordedEvents[0], event);
      expect(agentB.recordedEvents.length, 1);
      expect(agentB.recordedEvents[0], event);
    });

    test('(agentA <-> agentB) send and recieve events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.connect(agentA);
      agentA.dispatch(event);

      expect(agentA.recordedEvents.length, 1);
      expect(agentA.recordedEvents[0], event);
      expect(agentB.recordedEvents.length, 1);
      expect(agentB.recordedEvents[0], event);
    });
  });

  group('three agents', () {
    test('(agentA <- agentB <- agentC) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();

      agentA.connect(agentB);
      agentB.connect(agentC);

      expect(agentA.connections.length, 1);
      expect(agentA.listeners.length, 0);

      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentC);
      expect(agentB.listeners.length, 1);
      expect(agentB.listeners[0], agentA);

      expect(agentC.connections.length, 0);
      expect(agentC.listeners.length, 1);
      expect(agentC.listeners[0], agentB);
    });

    test('(agentA <- agentB <- agentC) send and receive events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();

      final event0 = TestEvent(0);
      final event1 = TestEvent(1);
      final event2 = TestEvent(2);

      agentA.connect(agentB);
      agentB.connect(agentC);

      agentA.dispatch(event0);
      agentB.dispatch(event1);
      agentC.dispatch(event2);

      expect(agentA.recordedEvents.length, 3);
      expect(agentA.recordedEvents[0], event0);
      expect(agentA.recordedEvents[1], event1);
      expect(agentA.recordedEvents[2], event2);

      expect(agentB.recordedEvents.length, 2);
      expect(agentB.recordedEvents[0], event1);
      expect(agentB.recordedEvents[1], event2);

      expect(agentC.recordedEvents.length, 1);
      expect(agentC.recordedEvents[0], event2);
    });

    test('(agentA <- agentB <- agentC <- agentA) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();

      agentA.connect(agentB);
      agentB.connect(agentC);
      agentC.connect(agentA);

      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);

      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentC);

      expect(agentC.connections.length, 1);
      expect(agentC.connections[0], agentA);
    });

    test('(agentA <- agentB <- agentC <- agentA) send and receive events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.connect(agentC);
      agentC.connect(agentA);
      agentA.dispatch(event);

      expect(agentA.recordedEvents.length, 1);
      expect(agentA.recordedEvents[0], event);

      expect(agentB.recordedEvents.length, 1);
      expect(agentB.recordedEvents[0], event);

      expect(agentC.recordedEvents.length, 1);
      expect(agentC.recordedEvents[0], event);
    });

    test('(agentA <-> agentB <-> agentC) connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();

      agentA.connect(agentB);
      agentB.connect(agentA);
      agentB.connect(agentC);
      agentC.connect(agentB);

      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);

      expect(agentB.connections.length, 2);
      expect(agentB.connections[0], agentA);
      expect(agentB.connections[1], agentC);

      expect(agentC.connections.length, 1);
      expect(agentC.connections[0], agentB);
    });

    test('(agentA <-> agentB <-> agentC) send and receive events', () {
      final agentA = TestAgent();
      final agentB = TestAgent();
      final agentC = TestAgent();
      final event = TestEvent(0);

      agentA.connect(agentB);
      agentB.connect(agentA);
      agentB.connect(agentC);
      agentC.connect(agentB);

      agentA.dispatch(event);

      expect(agentA.recordedEvents.length, 1);
      expect(agentA.recordedEvents[0], event);

      expect(agentB.recordedEvents.length, 1);
      expect(agentB.recordedEvents[0], event);

      expect(agentC.recordedEvents.length, 1);
      expect(agentC.recordedEvents[0], event);
    });
  });

  group('misc', () {
    test('(agentA -> agentB, agentA -> agentB) should throws error', () {
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
