import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

abstract class TestEvent extends AgentBaseEvent {}

class TestEventA extends TestEvent {}

class TestEventAA extends TestEventA {}

class TestEventB extends TestEvent {}

class TestEventBA extends TestEventB {}

typedef OnEvent<E extends AgentBaseEvent> = EventHandler<E>;

void defaultOnEvent<E extends AgentBaseEvent>(String topic, E event) {}

class TestAgent extends Agent {
  final OnEvent<TestEvent>? onTestEvent;
  final OnEvent<TestEventA>? onTestEventA;
  final OnEvent<TestEventAA>? onTestEventAA;
  final OnEvent<TestEventB>? onTestEventB;
  final OnEvent<TestEventBA>? onTestEventBA;

  TestAgent({
    this.onTestEvent,
    this.onTestEventA,
    this.onTestEventB,
    this.onTestEventAA,
    this.onTestEventBA,
  }) {
    on('test', onTestEventA ?? defaultOnEvent);
    on('test', onTestEventB ?? defaultOnEvent);
    on('test', onTestEventAA ?? defaultOnEvent);
    on('test', onTestEventBA ?? defaultOnEvent);
    on('test', onTestEvent ?? defaultOnEvent);
  }
}

class DuplicateHandlerAgent extends Agent {
  DuplicateHandlerAgent() {
    on('test', defaultOnEvent);
    on('test', defaultOnEvent);
  }
}

void main() {
  group('on<E>', () {
    test('invokes all on<T> where E is T', () {
      var onEventCallCount = 0;
      var onACallCount = 0;
      var onBCallCount = 0;
      var onAACallCount = 0;
      var onBACallCount = 0;

      final agent = TestAgent(
        onTestEvent: (_, __) => onEventCallCount++,
        onTestEventA: (_, __) => onACallCount++,
        onTestEventB: (_, __) => onBCallCount++,
        onTestEventAA: (_, __) => onAACallCount++,
        onTestEventBA: (_, __) => onBACallCount++,
      );

      agent.onEvent(('test', TestEventA()));

      expect(onEventCallCount, equals(1));
      expect(onACallCount, equals(1));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(0));
      expect(onBACallCount, equals(0));

      agent.onEvent(('test', TestEventAA()));

      expect(onEventCallCount, equals(2));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      agent.onEvent(('test', TestEventB()));

      expect(onEventCallCount, equals(3));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(1));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      agent.onEvent(('test', TestEventBA()));

      expect(onEventCallCount, equals(4));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(2));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(1));
    });
  });
}
