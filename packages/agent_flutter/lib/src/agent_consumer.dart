import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Signature for the `builder` function which takes the [BuildContext] and
/// the current [Agent] and is responsible for returning a widget which is to be rendered.
typedef AgentWidgetBuilder<A> = Widget Function(BuildContext context, A agent);

/// A widget that consumes an [Agent] and builds a widget based on the [Agent]'s state.
///
/// This widget is used to consume an [Agent] and build a widget based on the [Agent]'s state.
/// It will rebuild the widget when the [Agent]'s state changes.
/// It will also dispose of the [Agent] when the widget is disposed.
class AgentConsumer<A extends Agent> extends StatefulWidget {
  const AgentConsumer({
    super.key,
    required this.builder,
  });

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the [BuildContext] and current [Agent] and must return a widget.
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
