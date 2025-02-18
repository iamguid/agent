import 'dart:async';

import 'abstract.dart';

/// An agent that listen to events from other agents.
abstract class Agent implements BaseAgent {
  final Set<String> _topics = {};
  final Set<BaseAgent> _listenersSet = {};
  final List<StreamSubscription<AgentStreamEvent>> _subscriptions = [];
  final Set<BaseAgent> _connectionsSet = {};
  final StreamController<AgentStreamEvent> _eventsStreamController =
      StreamController.broadcast(sync: true);
  final Set<AgentBaseEvent> _emitEventsStack = {};

  @override
  late Stream<AgentStreamEvent> eventsStream;

  Agent() {
    eventsStream = _eventsStreamController.stream;
  }

  /// Emit event to all listeners around that have the same topic.
  @override
  void emit<E extends AgentBaseEvent>(String topic, E event) {
    if (_emitEventsStack.contains(event)) {
      return;
    }

    if (!_topics.contains('*') && !_topics.contains(topic)) {
      return;
    }

    _emitEventsStack.add(event);

    for (var listener in listeners) {
      listener.emit(topic, event);
    }

    onEvent((topic, event));

    _emitEventsStack.remove(event);
  }

  void _listenTopic(String topic) {
    _topics.add(topic);
  }

  @override
  void addEventListener(BaseAgent target) {
    assert(
      !_listenersSet.contains(target),
      'Agent is already listen the target',
    );

    assert(
      !_connectionsSet.contains(target),
      'Agent is already connected to the target',
    );

    _connectionsSet.add(target);
    _listenersSet.add(target);
  }

  @override
  void removeEventListener(BaseAgent target) {
    assert(
      _listenersSet.contains(target),
      'Agent is not listen the target',
    );

    assert(
      _connectionsSet.contains(target),
      'Agent is not connected to the target',
    );

    _connectionsSet.remove(target);
    _listenersSet.remove(target);
  }

  @override
  void connect(BaseAgent target) {
    assert(
      target != this,
      'You cannot connect agent with self',
    );

    target.addEventListener(this);
    addEventListener(target);

    emit('agent', AgentConnected(agentA: this, agentB: target));
  }

  @override
  void disconnect(BaseAgent target) {
    emit('agent', AgentDisconnected(agentA: this, agentB: target));

    target.removeEventListener(this);
    removeEventListener(target);
  }

  @override
  void on<E extends AgentBaseEvent>(String topic, EventHandler<E> handler) {
    _listenTopic(topic);

    final subscription = eventsStream
        .where((event) =>
            (topic == event.$1 || topic == '*') && event.$2 is E)
        .listen((event) => handler(event.$1, event.$2 as E));

    _subscriptions.add(subscription);
  }

  @override
  void onEvent(AgentStreamEvent event) {
    if (!_eventsStreamController.isClosed) {
      _eventsStreamController.add(event);
    }
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
