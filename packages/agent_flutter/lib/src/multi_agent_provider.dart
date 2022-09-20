import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetbook/src/agent/agent_provider.dart';

/// Merges multiple [AgentProvider] widgets into one widget tree.
///
/// [MultiAgentProvider] improves the readability and eliminates the need
/// to nest multiple [AgentProvider]s.
///
/// By using [MultiAgentProvider] we can go from:
///
/// ```dart
/// AgentProvider<AgentA>(
///   create: (BuildContext context) => AgentA(),
///   child: AgentProvider<AgentB>(
///     create: (BuildContext context) => AgentB(),
///     child: AgentProvider<AgentC>(
///       create: (BuildContext context) => AgentC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiAgentProvider(
///   providers: [
///     AgentProvider<AgentA>(
///       create: (BuildContext context) => AgentA(),
///     ),
///     AgentProvider<AgentB>(
///       create: (BuildContext context) => AgentB(),
///     ),
///     AgentProvider<AgentC>(
///       create: (BuildContext context) => AgentC(),
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiAgentProvider] converts the [AgentProvider] list into a tree of nested
/// [AgentProvider] widgets.
/// As a result, the only advantage of using [MultiAgentProvider] is improved
/// readability due to the reduction in nesting and boilerplate.
class MultiAgentProvider extends MultiProvider {
  MultiAgentProvider({
    Key? key,
    required List<AgentProviderSingleChildWidget> providers,
    required Widget child,
  }) : super(key: key, providers: providers, child: child);
}
