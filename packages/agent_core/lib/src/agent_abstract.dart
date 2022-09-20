part of 'agent.dart';

/// An object that provides [dispatch] method
abstract class Dispatchable<Event extends Object?>
    extends EventStreamable<Event> {
  /// The [dispatch] method used for dispatching [dispatch.event]
  /// to [EventStreamable] target.
  void dispatch(Event event);
}

/// An object that provides access to a stream of events over time.
abstract class EventStreamable<Event extends Object?> {
  /// The current [Stream] of events.
  Stream<Event> get eventsStream;
}

/// An object that provides [onEvent] handler.
abstract class Eventable<Event extends Object?> extends EventStreamable<Event> {
  /// Events handler.
  void onEvent(Event event);
}

/// An object that provides access to a stream of states over time.
abstract class StateStreamable<State extends Object?> {
  /// The current [Stream] of states.
  Stream<State> get statesStream;
}

/// A [StateStreamable] that provides synchronous access to the current [state].
abstract class Stateable<State extends Object?> extends StateStreamable<State> {
  /// The current [state].
  State get state;
}

/// A [Stateable] that provides [nextState] method.
abstract class Stateful<State> extends Stateable<State> {
  /// The [nextState] method.
  /// Needed for set new value to [Stateable.state] and pass that state
  /// to [StateStreamable].
  void nextState(State state);
}

/// An [Stateable] that provides [subscribeTo] and [unsubscribeFrom] methods.
abstract class Listenable<Event extends Object?, Target extends EventStreamable>
    extends EventStreamable<Event> {
  /// Async [subscribeTo] method for subscribe to target.
  void subscribeTo(Target target);

  /// Async [unsubscribeFrom] method for unsubscribe from target.
  void unsubscribeFrom(Target target);
}

/// An [Listenable] that provides [connectWith] and [disconnectWith] methods.
abstract class Connectable<Event extends Object?, Target extends Listenable>
    extends Listenable<Event, Target> {
  /// Async [connectWith] method.
  /// Used for subscribe to each other
  void connectWith(Target target);

  /// Async [disconnectWith] method.
  /// Used for unsubscribe from each other
  void disconnectWith(Target target);
}

abstract class BaseEvent<T> {
  final T _payload;

  BaseEvent(this._payload);

  T get payload {
    return _payload;
  }
}
