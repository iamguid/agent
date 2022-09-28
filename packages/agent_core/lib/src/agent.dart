import 'dart:async';

import 'abstract.dart';

abstract class Agent<Event>
    implements BaseAgent<Event>, CanStoreListeners<BaseAgent> {
  final Set<BaseAgent> _listenersSet = {};
  final List<StreamSubscription> _subscriptions = [];
  final Set<CanStoreListeners> _connectionsSet = {};
  final Set<Event> _dispatchTickEvents = {};
  final StreamController<Event> _eventsStreamController =
      StreamController.broadcast(sync: true);

  @override
  late Stream<Event> eventsStream;

  Agent() {
    eventsStream = _eventsStreamController.stream;
  }

  @override
  void dispatch<E extends Event>(E event) {
    if (_dispatchTickEvents.contains(event)) {
      return;
    }

    _dispatchTickEvents.add(event);

    for (var listener in _listenersSet) {
      listener.dispatch(event);
    }

    onEvent(event);

    _dispatchTickEvents.clear();
  }

  @override
  void addEventListener(BaseAgent target) {
    assert(
      !_listenersSet.contains(target),
      'Agent already listen the target',
    );

    _listenersSet.add(target);
  }

  @override
  void removeEventListener(BaseAgent target) {
    assert(
      _listenersSet.contains(target),
      'Agent is not connected to the target',
    );

    _listenersSet.remove(target);
  }

  @override
  void connect(CanStoreListeners target) {
    assert(
      !_connectionsSet.contains(target),
      'Agent already connected to the target',
    );

    assert(
      target != this,
      'You cannot connect agent with self',
    );

    target.addEventListener(this);
    _connectionsSet.add(target);
  }

  @override
  void disconnect(CanStoreListeners target) {
    assert(
      _connectionsSet.contains(target),
      'Agent is not connected to the target',
    );

    target.removeEventListener(this);
    _connectionsSet.remove(target);
  }

  @override
  void on<E extends Object?>(EventHandler<E> handler) {
    final subscription =
        eventsStream.where((event) => event is E).cast<E>().listen(handler);

    _subscriptions.add(subscription);
  }

  @override
  void onEvent(dynamic event) {
    _eventsStreamController.add(event);
  }

  @override
  Future<void> dispose() async {
    disconnectAll();

    for (var subscription in _subscriptions) {
      await subscription.cancel();
    }

    _subscriptions.clear();
  }

  void disconnectAll() {
    for (var connection in _connectionsSet) {
      disconnect(connection);
    }
  }

  List<CanStoreListeners> get connections {
    return _connectionsSet.toList();
  }

  List<BaseAgent> get listeners {
    return _listenersSet.toList();
  }
}
