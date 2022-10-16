import 'package:agent_core/agent_core.dart';
import 'package:test/test.dart';

abstract class TestEvent extends AgentBaseEvent {}

class TestEventA extends TestEvent {}

class TestEventAA extends TestEventA {}

class TestEventB extends TestEvent {}

class TestEventBA extends TestEventB {}

typedef OnEvent<E> = void Function(E event);

void defaultOnEvent<E>(E event) {}

class TestAgent extends Agent<TestEvent> {
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
  }) : super() {
    on<TestEventA>(onTestEventA ?? defaultOnEvent);
    on<TestEventB>(onTestEventB ?? defaultOnEvent);
    on<TestEventAA>(onTestEventAA ?? defaultOnEvent);
    on<TestEventBA>(onTestEventBA ?? defaultOnEvent);
    on<TestEvent>(onTestEvent ?? defaultOnEvent);
  }
}

class DuplicateHandlerAgent extends Agent<TestEvent> {
  DuplicateHandlerAgent() : super() {
    on<TestEvent>(defaultOnEvent);
    on<TestEvent>(defaultOnEvent);
  }
}

void main() {
  group('on<Event>', () {
    test('invokes all on<T> when event E is added where E is T', () {
      var onEventCallCount = 0;
      var onACallCount = 0;
      var onBCallCount = 0;
      var onAACallCount = 0;
      var onBACallCount = 0;

      final agent = TestAgent(
        onTestEvent: (_) => onEventCallCount++,
        onTestEventA: (_) => onACallCount++,
        onTestEventB: (_) => onBCallCount++,
        onTestEventAA: (_) => onAACallCount++,
        onTestEventBA: (_) => onBACallCount++,
      );

      agent.onEvent(TestEventA());

      expect(onEventCallCount, equals(1));
      expect(onACallCount, equals(1));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(0));
      expect(onBACallCount, equals(0));

      agent.onEvent(TestEventAA());

      expect(onEventCallCount, equals(2));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      agent.onEvent(TestEventB());

      expect(onEventCallCount, equals(3));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(1));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      agent.onEvent(TestEventBA());

      expect(onEventCallCount, equals(4));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(2));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(1));
    });
  });
}
