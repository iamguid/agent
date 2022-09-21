import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'state_agent_listener.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef StateAgentWidgetBuilder<S> = Widget Function(
    BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [StateAgentBuilder] with the current `state`.
typedef StateAgentBuilderCondition<S> = bool Function(S previous, S current);

/// [StateAgentBuilder] handles building a widget in response to new `states`.
/// [StateAgentBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as agent-specific
/// performance improvements.

/// Please refer to [StateAgentListener] if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [agent] parameter is omitted, [StateAgentBuilder] will automatically
/// perform a lookup using [AgentProvider] and the current [BuildContext].
///
/// ```dart
/// StateAgentBuilder<StateAgentA, StateAgentAState>(
///   builder: (context, state) {
///   // return widget here based on StateAgentA's state
///   }
/// )
/// ```
///
/// Only specify the [agent] if you wish to provide a [agent] that is otherwise
/// not accessible via [AgentProvider] and the current [BuildContext].
///
/// ```dart
/// StateAgentBuilder<StateAgentA, StateAgentAState>(
///   agent: agentA,
///   builder: (context, state) {
///   // return widget here based on StateAgentA's state
///   }
/// )
/// ```
///
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [StateAgentBuilder] rebuilds.
/// [buildWhen] should only be used for performance optimizations as it
/// provides no security about the state passed to the [builder] function.
/// [buildWhen] will be invoked on each [agent] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [agent] when
/// the [StateAgentBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// StateAgentBuilder<StateAgentA, StateAgentAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on StateAgentA's state
///   }
/// )
/// ```
class StateAgentBuilder<A extends Stateful<S>, S>
    extends StateAgentBuilderBase<A, S> {
  const StateAgentBuilder({
    Key? key,
    required this.builder,
    A? agent,
    StateAgentBuilderCondition<S>? buildWhen,
  }) : super(key: key, agent: agent, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final StateAgentWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// Base class for widgets that build themselves based on interaction with
/// a specified [agent].
///
/// A [StateAgentBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
abstract class StateAgentBuilderBase<B extends Stateful<S>, S>
    extends StatefulWidget {
  const StateAgentBuilderBase({Key? key, this.agent, this.buildWhen})
      : super(key: key);

  /// The [agent] that the [StateAgentBuilderBase] will interact with.
  /// If omitted, [StateAgentBuilderBase] will automatically perform a lookup using
  /// [AgentProvider] and the current `BuildContext`.
  final B? agent;

  final StateAgentBuilderCondition<S>? buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<StateAgentBuilderBase<B, S>> createState() =>
      _StateAgentBuilderBaseState<B, S>();
}

class _StateAgentBuilderBaseState<A extends Stateful<S>, S>
    extends State<StateAgentBuilderBase<A, S>> {
  late A _agent;
  late S _state;

  @override
  void initState() {
    super.initState();
    _agent = widget.agent ?? context.read<A>();
    _state = _agent.state;
  }

  @override
  void didUpdateWidget(StateAgentBuilderBase<A, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldAgent = oldWidget.agent ?? context.read<A>();
    final currentAgent = widget.agent ?? oldAgent;
    if (oldAgent != currentAgent) {
      _agent = currentAgent;
      _state = _agent.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final agent = widget.agent ?? context.read<A>();
    if (_agent != agent) {
      _agent = agent;
      _state = _agent.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.agent == null) {
      // Trigger a rebuild if the agent reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<A, bool>((agent) => identical(_agent, agent));
    }
    return StateAgentListener<A, S>(
      agent: _agent,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }
}
