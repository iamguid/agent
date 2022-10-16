import 'dart:async';

import 'abstract.dart';

abstract class AgentEvent extends AgentBaseEvent {}

class AgentConnected<BaseAgentA, BaseAgentB> extends AgentBaseEvent {
  final BaseAgentA agentA;
  final BaseAgentB agentB;

  AgentConnected({
    required this.agentA,
    required this.agentB,
  });
}

class AgentDisconnected<BaseAgentA, BaseAgentB> extends AgentBaseEvent {
  final BaseAgentA agentA;
  final BaseAgentB agentB;

  AgentDisconnected({
    required this.agentA,
    required this.agentB,
  });
}

abstract class Agent<Event extends AgentBaseEvent>
    implements BaseAgent<Event>, CanStoreListeners<BaseAgent> {
  final Set<BaseAgent> _listenersSet = {};
  final List<StreamSubscription> _subscriptions = [];
  final Set<BaseAgent> _connectionsSet = {};
  final Set<dynamic> _dispatchTickEvents = {};
  final StreamController<dynamic> _eventsStreamController =
      StreamController.broadcast(sync: true);

  @override
  late Stream<dynamic> eventsStream;

  Agent() {
    eventsStream = _eventsStreamController.stream;
  }

  @override
  void dispatch(event) {
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

    dispatch(AgentConnected(agentA: this, agentB: target));
  }

  @override
  void disconnect(BaseAgent target) {
    dispatch(AgentDisconnected(agentA: this, agentB: target));

    target.removeEventListener(this);
    removeEventListener(target);
  }

  @override
  void on<E extends AgentBaseEvent>(EventHandler<E> handler) {
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
