import 'package:agent_core/agent_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiAgentProvider` to infer the types
/// of multiple [AgentProvider]s.
mixin AgentProviderSingleChildWidget on SingleChildWidget {}

/// Takes a [Create] function that is responsible for
/// creating the [Agent] or [StateAgent] and a [child] which will have access
/// to the instance via `AgentProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [Agent] or [StateAgent] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// AgentProvider(
///   create: (BuildContext context) => AgentA(),
///   child: ChildA(),
/// );
/// ```
///
/// It automatically handles closing the instance when used with [Create].
/// By default, [Create] is called only when the instance is accessed.
/// To override this behavior, set [lazy] to `false`.
///
/// ```dart
/// AgentProvider(
///   lazy: false,
///   create: (BuildContext context) => AgentA(),
///   child: ChildA(),
/// );
/// ```
///
class AgentProvider<T extends BaseAgent> extends SingleChildStatelessWidget
    with AgentProviderSingleChildWidget {
  const AgentProvider({
    Key? key,
    required Create<T> create,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);

  const AgentProvider.value({
    Key? key,
    required T value,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(key: key, child: child);

  /// Widget which will have access to the [Agent] or [StateAgent].
  final Widget? child;

  /// Whether the [Agent] should be created lazily.
  /// Defaults to `true`.
  final bool lazy;

  final Create<T>? _create;

  final T? _value;

  /// Method that allows widgets to access a [Agent] or [StateAgent] instance
  /// as long as their `BuildContext` contains a [AgentProvider] instance.
  ///
  /// If we want to access an instance of `AgentA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// AgentProvider.of<AgentA>(context);
  /// ```
  static T of<T>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        AgentProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to AgentProvider.of<$T>().
        This can happen if the context you used comes from a widget above the AgentProvider.
        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '$runtimeType used outside of MultiAgentProvider must specify a child',
    );
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, agent) => agent.dispose(),
            startListening: _startListening,
            child: child,
            lazy: lazy,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<BaseAgent?> e,
    BaseAgent value,
  ) {
    final subscription = value.eventsStream.listen(
      (_) => e.markNeedsNotifyDependents(),
    );

    return subscription.cancel;
  }
}
