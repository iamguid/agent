/// An event handler is responsible for reacting to an incoming [Event]
typedef EventHandler<Event extends AgentBaseEvent> = void Function(String topic, Event event);

/// An event that can be emitted by [BaseAgent].
typedef AgentStreamEvent = (String topic, AgentBaseEvent event);

/// An object that provides [emit] method
abstract class CanEmit {
  /// The [emit] method used for emitting [event].
  void emit<E extends AgentBaseEvent>(String topic, E event);
}

/// An object that provides [onEvent] and [on] handler
abstract class CanHandleEvents {
  /// Events handler short syntax.
  void on<E extends AgentBaseEvent>(String topic, EventHandler<E> handler);

  /// Events handler.
  void onEvent(AgentStreamEvent event);
}

/// An object that provides access to a stream of events.
abstract class HasEventsStream {
  /// The current [Stream] of events.
  Stream<AgentStreamEvent> get eventsStream;
}

/// An object that provides methods for add and remove event listeners
abstract class CanStoreListeners<Target extends BaseAgent> {
  /// Method for adding new listener.
  void addEventListener(Target target);

  /// Method for removing listener.
  void removeEventListener(Target target);
}

/// An object that provides [connect] and [disconnect] methods.
abstract class CanConnect<Target extends BaseAgent> {
  /// Async [connect] method.
  /// Used for subscribe to each other
  void connect(Target target);

  /// Async [disconnect] method.
  /// Used for unsubscribe from each other
  void disconnect(Target target);
}

/// An object that provides access to a stream of states over time.
abstract class HasStatesStream<State extends Object?> {
  /// The current [Stream] of states.
  Stream<State> get stateStream;
}

/// An object that provides synchronous access to the current [state].
abstract class HasState<State extends Object?> {
  /// The current [state].
  State get state;
}

/// An object that implements [HasStatesStream] and [HasState] that provides
/// [nextState] method.
abstract class Stateful<State extends Object?>
    implements HasStatesStream<State>, HasState<State> {
  /// The [nextState] method.
  /// Needed for set new value to [HasState.state] and pass that state
  /// to [HasStatesStream.stateStream].
  void nextState(State state);
}

/// An object that provides [dispose] method.
abstract class Disposable {
  /// The [dispose] method.
  Future<void> dispose();
}

/// An object that implements [CanStoreListeners], [CanEmit], [CanHandleEvents],
/// [HasEventsStream], [Disposable], [CanConnect].
/// [BaseAgent] is a base class for all agents.
abstract class BaseAgent
    implements
        CanStoreListeners<BaseAgent>,
        CanEmit,
        CanHandleEvents,
        HasEventsStream,
        Disposable,
        CanConnect {}

/// An event that can be emitted by [BaseAgent].
abstract class AgentBaseEvent {}

/// A system event that can be emitted by [Agent].
abstract class AgentEvent extends AgentBaseEvent {}

/// A system event that can be emitted when [Agent] is connected to another [Agent].
class AgentConnected<BaseAgentA, BaseAgentB> extends AgentBaseEvent {
  final BaseAgentA agentA;
  final BaseAgentB agentB;

  AgentConnected({
    required this.agentA,
    required this.agentB,
  });
}

/// A system event that can be emitted when [Agent] is disconnected from another [Agent].
class AgentDisconnected<BaseAgentA, BaseAgentB> extends AgentBaseEvent {
  final BaseAgentA agentA;
  final BaseAgentB agentB;

  AgentDisconnected({
    required this.agentA,
    required this.agentB,
  });
}

/// A system event that can be emitted when [BaseAgent] state is changed.
class AgentStateChanged<State> extends AgentBaseEvent {
  final State state;
  final BaseAgent source;

  AgentStateChanged({
    required this.state,
    required this.source,
  });
}
