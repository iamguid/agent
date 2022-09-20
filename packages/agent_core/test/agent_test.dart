import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

class TestEvent {
  final int eventId;

  TestEvent(this.eventId);
}

class TestAgent extends Agent<TestEvent> {
  @override
  void onEvent(event) {}
}

void main() {
  group('Two agents', () {
    test('Two agents correctly connect and disconnect', () {
      final agentA = TestAgent();
      final agentB = TestAgent();

      agentA.connectWith(agentB);

      expect(agentA.connections.length, 1);
      expect(agentA.connections[0], agentB);

      expect(agentB.connections.length, 1);
      expect(agentB.connections[0], agentA);
    });

    test('AgentA transmit event, AgentB recieve event', () {});
  });
}
