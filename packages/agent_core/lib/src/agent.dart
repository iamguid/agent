import 'dart:async';

import 'abstract.dart';

abstract class Agent<Event> implements BaseAgent<Event>, Eventful<Event> {
  final Set<BaseAgent> _listenersSet = {};
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
  void dispatch(dynamic event) {
    if (_dispatchTickEvents.contains(event)) {
      return;
    }

    _dispatchTickEvents.add(event);

    for (var listener in _listenersSet) {
      listener.dispatch(event);
    }

    _eventsStreamController.add(event);
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
  Future<void> dispose() async {
    disconnectAll();
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
