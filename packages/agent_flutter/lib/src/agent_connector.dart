import 'package:agent_flutter/agent_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'agent_consumer.dart';

typedef CreateAgent<A extends Agent> = A Function(BuildContext context);

class AgentConnector<A extends Agent> extends StatefulWidget {
  final CreateAgent createChildAgent;
  final AgentWidgetBuilder build;

  AgentConnector({
    required this.createChildAgent,
    required this.build,
  });

  @override
  createState() => _AgentConnectorState<A>();
}

class _AgentConnectorState<A extends Agent> extends State<AgentConnector> {
  late A _parentAgent;
  late Agent _childAgent;

  @override
  void initState() {
    super.initState();

    _parentAgent = context.read<A>();
    _childAgent = widget.createChildAgent(context);

    _parentAgent.connect(_childAgent);
  }

  @override
  void dispose() {
    _parentAgent.disconnect(_childAgent);
    _childAgent.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final parentAgent = context.read<A>();

    if (_parentAgent != parentAgent) {
      _parentAgent.disconnect(_childAgent);
      _parentAgent = parentAgent;
      _parentAgent.connect(_childAgent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AgentProvider.value(
      value: _childAgent,
      child: widget.build(context, _childAgent),
    );
  }
}
