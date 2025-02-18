import 'dart:async';

import 'package:agent_core/agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiAgentListener` to infer the types
/// of multiple [StateAgentListener]s.
mixin StateAgentListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef StateAgentWidgetListener<S> = void Function(
    BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [StateAgentWidgetListener] of [StateAgentListener]
/// with the current `state`.
typedef StateAgentListenerCondition<S> = bool Function(S previous, S current);

/// Takes a [StateAgentWidgetListener] and an optional [agent] and invokes
/// the [listener] in response to `state` changes in the [agent].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `StateAgentBuilder`.
///
/// If the [agent] parameter is omitted, [StateAgentListener] will automatically
/// perform a lookup using [AgentProvider] and the current `BuildContext`.
///
/// ```dart
/// StateAgentListener<StateAgentA, StateAgentAState>(
///   listener: (context, state) {
///     // do stuff here based on StateAgentA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [agent] if you wish to provide a [agent] that is otherwise
/// not accessible via [AgentProvider] and the current `BuildContext`.
///
/// ```dart
/// StateAgentListener<StateAgentA, StateAgentAState>(
///   value: agentA,
///   listener: (context, state) {
///     // do stuff here based on StateAgentA's state
///   },
///   child: Container(),
/// )
/// ```
///
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [agent] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [agent]
/// when the [StateAgentListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// StateAgentListener<StateAgentA, StateAgentAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on StateAgentA's state
///   }
///   child: Container(),
/// )
/// ```
class StateAgentListener<A extends Stateful<S>, S>
    extends StateAgentListenerBase<A, S>
    with StateAgentListenerSingleChildWidget {
  const StateAgentListener({
    super.key,
    required super.listener,
    super.agent,
    super.listenWhen,
    super.child,
  });
}

/// Base class for widgets that listen to state changes in a specified [agent].
///
/// A [StateAgentListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
abstract class StateAgentListenerBase<A extends Stateful<S>, S>
    extends SingleChildStatefulWidget {
  const StateAgentListenerBase({
    super.key,
    required this.listener,
    this.agent,
    this.child,
    this.listenWhen,
  }) : super(child: child);

  /// The widget which will be rendered as a descendant of the
  /// [StateAgentListenerBase].
  final Widget? child;

  /// The [agent] whose `state` will be listened to.
  /// Whenever the [agent]'s `state` changes, [listener] will be invoked.
  final A? agent;

  /// The [StateAgentWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final StateAgentWidgetListener<S> listener;

  final StateAgentListenerCondition<S>? listenWhen;

  @override
  SingleChildState<StateAgentListenerBase<A, S>> createState() =>
      _StateAgentListenerBaseState<A, S>();
}

class _StateAgentListenerBaseState<A extends Stateful<S>, S>
    extends SingleChildState<StateAgentListenerBase<A, S>> {
  StreamSubscription<S>? _subscription;
  late A _agent;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _agent = widget.agent ?? context.read<A>();
    _previousState = _agent.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(StateAgentListenerBase<A, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldAgent = oldWidget.agent ?? context.read<A>();
    final currentAgent = widget.agent ?? oldAgent;
    if (oldAgent != currentAgent) {
      if (_subscription != null) {
        _unsubscribe();
        _agent = currentAgent;
        _previousState = _agent.state;
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
        _previousState = _agent.state;
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
    _subscription = _agent.stateStream.listen((state) {
      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
