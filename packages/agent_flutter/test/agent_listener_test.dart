import 'package:agent_core/agent_core.dart';
import 'package:agent_flutter/agent_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class TestParentWidget<AParent extends Agent> extends StatelessWidget {
  final AParent parentAgent;
  final childKey = GlobalKey<TestChildWidgetState>();

  TestParentWidget({
    Key? key,
    required this.parentAgent,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (_, __) => AgentProvider.value(
        value: parentAgent,
        child: TestChildWidget<AParent>(key: childKey),
      ),
    );
  }
}

class TestChildWidget<AParent extends Agent> extends StatefulWidget {
  TestChildWidget({
    super.key,
  });

  @override
  createState() => TestChildWidgetState<AParent>();
}

class TestChildWidgetState<AParent extends Agent>
    extends State<TestChildWidget> {
  final List<AgentStreamEvent> recordedEvents = [];

  void onEvent(BuildContext context, AgentStreamEvent event) {
    recordedEvents.add(event);
  }

  @override
  Widget build(BuildContext context) {
    return AgentListener<AParent>(
      listener: onEvent,
      child: Container(),
    );
  }
}

void main() {
  testWidgets('Should pump widget', (tester) async {
    final parentAgent = TestAgent();
    final widget = TestParentWidget(parentAgent: parentAgent);
    await tester.pumpWidget(widget);
  });

  testWidgets('Should record events', (tester) async {
    final parentAgent = TestAgent();
    final widget = TestParentWidget(parentAgent: parentAgent);

    await tester.pumpWidget(widget);
    final widgetRecordedEvents = widget.childKey.currentState!.recordedEvents;

    expect(widgetRecordedEvents.length, 0);

    final event1 = TestEvent(1);
    final event2 = TestEvent(2);

    parentAgent.emit('event1', event1);
    parentAgent.emit('event2', event2);

    expect(widgetRecordedEvents.length, 2);
    expect(widgetRecordedEvents[0].$2, event1);
    expect(widgetRecordedEvents[1].$2, event2);
  });
}
