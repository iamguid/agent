/// Support for doing something awesome.
///
/// More dartdocs go here.
library agent_flutter;

export 'package:agent_core/agent_core.dart'
    show
        Agent,
        StateAgent,
        AgentBaseEvent,
        AgentEvent,
        AgentConnected,
        AgentDisconnected;
export 'src/agent_provider.dart';
export 'src/agent_consumer.dart';
export 'src/agent_connector.dart';
export 'src/agent_listener.dart';
export 'src/multi_agent_provider.dart';
export 'src/state_agent_builder.dart';
export 'src/state_agent_consumer.dart';
export 'src/state_agent_listener.dart';
