import 'dart:async';

part 'agent_abstract.dart';

abstract class Agent<Event extends Object?> extends Connectable<Event, Agent>
    implements Dispatchable<Event>, Eventable<Event> {
  final Set<Agent> _connections = {};
  final Map<EventStreamable, StreamSubscription> _subscriptions = {};
  late StreamController<Event> _eventsStreamController;

  @override
  late Stream<Event> eventsStream;

  Agent() {
    _eventsStreamController = StreamController.broadcast(sync: true);
    eventsStream = _eventsStreamController.stream;
  }

  @override
  void subscribeTo(EventStreamable target) {
    if (_subscriptions.containsKey(target)) {
      throw Exception('Target is already subscribed');
    }

    final subscription = target.eventsStream.listen(onEvent);
    _subscriptions[target] = subscription;
  }

  @override
  void unsubscribeFrom(EventStreamable target) {
    if (!_subscriptions.containsKey(target)) {
      throw Exception('Target is not subscribed');
    }

    final subscription = _subscriptions[target]!;
    subscription.cancel();

    _subscriptions.remove(target);
  }

  @override
  void connectWith(Agent target) {
    if (_connections.contains(target)) {
      throw Exception('Agent is already conected');
    }

    subscribeTo(target);
    target.subscribeTo(this);
    _connections.add(target);
  }

  @override
  void disconnectWith(Agent target) {
    if (!_connections.contains(target)) {
      throw Exception('Agent is not conected');
    }

    unsubscribeFrom(target);
    target.unsubscribeFrom(this);
    _connections.remove(target);
  }

  @override
  void dispatch(Event event) {
    _eventsStreamController.add(event);
  }

  @override
  void onEvent(dynamic event);

  void disconnectFromAll() {
    for (var connection in _connections) {
      disconnectWith(connection);
      _subscriptions.remove(connection);
    }
  }

  List<Agent> get connections {
    return _connections.toList();
  }
}
