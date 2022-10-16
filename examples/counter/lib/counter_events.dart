import 'package:agent_flutter/agent_flutter.dart';

abstract class CounterEvent extends AgentBaseEvent {}

class CounterIncrementedEvent extends CounterEvent {}

class CounterDecrementedEvent extends CounterEvent {}
