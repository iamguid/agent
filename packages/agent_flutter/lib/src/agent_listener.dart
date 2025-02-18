import 'dart:async';

import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// A function that listens for an [Agent] event.
typedef AgentWidgetListener<E extends AgentStreamEvent> = void Function(
    BuildContext context, E event);

/// A widget that listens for an [Agent] event.
///
/// This widget is used to listen for an [Agent] event.
/// It will listen for an [Agent] event and call the [listener] function.
class AgentListener<A extends Agent> extends SingleChildStatefulWidget {
  AgentListener({
    super.key,
    required this.listener,
    this.agent,
    this.child,
  }) : super(child: child);

  final Widget? child;

  final A? agent;

  final AgentWidgetListener listener;

  @override
  createState() => _AgentListenerState<A>();
}

class _AgentListenerState<A extends Agent>
    extends SingleChildState<AgentListener<A>> {
  late StreamSubscription<dynamic>? _subscription;
  late A _agent;

  @override
  void initState() {
    super.initState();
    _agent = widget.agent ?? context.read<A>();
    _subscribe();
  }

  @override
  void didUpdateWidget(AgentListener<A> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldAgent = oldWidget.agent ?? context.read<A>();
    final currentAgent = widget.agent ?? oldAgent;

    if (oldAgent != currentAgent) {
      if (_subscription != null) {
        _unsubscribe();
        _agent = currentAgent;
      }

      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final agent = widget.agent ?? context.read<A>();

    if (_agent != agent) {
      if (_subscription != null) {
        _unsubscribe();
        _agent = agent;
      }

      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '''${widget.runtimeType} used outside of MultiAgentListener must specify a child''',
    );

    if (widget.agent == null) {
      // Trigger a rebuild if the agent reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<A, bool>((agent) => identical(_agent, agent));
    }

    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _agent.eventsStream.listen((event) {
      widget.listener(context, event);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
