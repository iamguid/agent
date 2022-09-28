/// An object that provides [dispatch] method
abstract class CanDispatch<Event extends Object?> {
  /// The [dispatch] method used for dispatching [dispatch.event].
  void dispatch<E extends Event>(E event);
}

/// An event handler is responsible for reacting to an incoming [Event]
typedef EventHandler<Event extends Object?> = void Function(Event event);

/// An object that provides [onEvent] and [on] handler
abstract class CanHandleEvents {
  /// Events handler short syntax.
  void on<E extends Object?>(EventHandler<E> handler);

  /// Events handler.
  void onEvent(dynamic event);
}

/// An object that provides access to a stream of events.
abstract class HasEventsStream<Event extends Object?> {
  /// The current [Stream] of events.
  Stream<Event> get eventsStream;
}

/// An object that provides methods for add and remove event listeners
abstract class CanStoreListeners<Target extends CanHandleEvents> {
  /// Method for adding new listener.
  void addEventListener(Target target);

  /// Method for removing listener.
  void removeEventListener(Target target);
}

/// An object that provides [connect] and [disconnect] methods.
abstract class CanConnect<Target extends CanStoreListeners> {
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
abstract class Stateful<State>
    implements HasStatesStream<State>, HasState<State> {
  /// The [nextState] method.
  /// Needed for set new value to [HasState.state] and pass that state
  /// to [HasStatesStream.stateStream].
  void nextState(State state);
}

abstract class Disposable {
  Future<void> dispose();
}

abstract class BaseAgent<Event extends Object?>
    implements
        CanDispatch<Event>,
        CanHandleEvents,
        HasEventsStream<Event>,
        CanStoreListeners<BaseAgent>,
        Disposable,
        CanConnect {}
