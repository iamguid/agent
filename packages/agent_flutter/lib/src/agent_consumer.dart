import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// and is responsible for returning a widget which is to be rendered.
typedef AgentWidgetBuilder<A> = Widget Function(BuildContext context, A agent);

class AgentConsumer<A extends Agent> extends StatefulWidget {
  const AgentConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final AgentWidgetBuilder<A> builder;

  @override
  createState() => _AgentConsumerState<A>();
}

class _AgentConsumerState<A extends Agent> extends State<AgentConsumer<A>> {
  late A _agent;

  @override
  void initState() {
    super.initState();
    _agent = context.read<A>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final agent = context.read<A>();
    if (_agent != agent) _agent = agent;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _agent);
  }
}
