import 'package:agent_flutter/agent_flutter.dart';
import 'package:agent_flutter/src/agent_connector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class TestParentWidget<AParent extends Agent, AChild extends Agent>
    extends StatelessWidget {
  final AParent parentAgent;
  final CreateAgent<AChild> childAgentCreator;

  TestParentWidget({
    required this.parentAgent,
    required this.childAgentCreator,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (_, __) => AgentProvider.value(
        value: parentAgent,
        child: TestChildWidget<AParent, AChild>(
          childAgentCreator: childAgentCreator,
        ),
      ),
    );
  }
}

class TestChildWidget<AParent extends Agent, AChild extends Agent>
    extends StatelessWidget {
  final CreateAgent<AChild> childAgentCreator;

  TestChildWidget({
    required this.childAgentCreator,
  });

  @override
  Widget build(BuildContext context) {
    return AgentConnector<AParent>(
      createChildAgent: childAgentCreator,
      build: (context, agent) => Text(agent.toString()),
    );
  }
}

void main() {
  final parentAgent = TestAgent();

  TestStateAgent childAgentCreator(BuildContext context) {
    return TestStateAgent(TestState(0));
  }

  testWidgets('Should pump widget', (tester) async {
    final widget = TestParentWidget(
      parentAgent: parentAgent,
      childAgentCreator: childAgentCreator,
    );

    await tester.pumpWidget(widget);
  });
}
