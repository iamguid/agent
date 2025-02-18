import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'state_agent_builder.dart';
import 'state_agent_listener.dart';

/// [StateAgentConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [StateAgentConsumer] is analogous to a nested `StateAgentListener`
/// and `StateAgentBuilder` but reduces the amount of boilerplate needed.
/// [StateAgentConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [agent].
///
/// [StateAgentConsumer] takes a required `StateAgentWidgetBuilder`
/// and `StateAgentWidgetListener` and an optional [agent],
/// `StateAgentBuilderCondition`, and `StateAgentListenerCondition`.
///
/// If the [agent] parameter is omitted, [StateAgentConsumer] will automatically
/// perform a lookup using `AgentProvider` and the current `BuildContext`.
///
/// ```dart
/// StateAgentConsumer<StateAgentA, StateAgentAState>(
///   listener: (context, state) {
///     // do stuff here based on StateAgentA's state
///   },
///   builder: (context, state) {
///     // return widget here based on StateAgentA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [agent] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [agent] when
/// the [StateAgentConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// StateAgentConsumer<StateAgentA, StateAgentAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on StateAgentA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on StateAgentA's state
///   }
/// )
/// ```
class StateAgentConsumer<A extends Stateful<S>, S> extends StatefulWidget {
  const StateAgentConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.agent,
    this.buildWhen,
    this.listenWhen,
  });

  /// The [agent] that the [StateAgentConsumer] will interact with.
  /// If omitted, [StateAgentConsumer] will automatically perform a lookup using
  /// `AgentProvider` and the current `BuildContext`.
  final A? agent;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final StateAgentWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [agent] `state`
  /// and is responsible for executing in response to `state` changes.
  final StateAgentWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final StateAgentBuilderCondition<S>? buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [StateAgentConsumer] with the current `state`.
  final StateAgentListenerCondition<S>? listenWhen;

  @override
  State<StateAgentConsumer<A, S>> createState() =>
      _StateAgentConsumerState<A, S>();
}

class _StateAgentConsumerState<A extends Stateful<S>, S>
    extends State<StateAgentConsumer<A, S>> {
  late A _agent;

  @override
  void initState() {
    super.initState();
    _agent = widget.agent ?? context.read<A>();
  }

  @override
  void didUpdateWidget(StateAgentConsumer<A, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldAgent = oldWidget.agent ?? context.read<A>();
    final currentAgent = widget.agent ?? oldAgent;
    if (oldAgent != currentAgent) _agent = currentAgent;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final agent = widget.agent ?? context.read<A>();
    if (_agent != agent) _agent = agent;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.agent == null) {
      // Trigger a rebuild if the agent reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<A, bool>((agent) => identical(_agent, agent));
    }
    return StateAgentBuilder<A, S>(
      agent: _agent,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}
