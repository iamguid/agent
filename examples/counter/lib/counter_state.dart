class CounterState {
  final num counter;

  CounterState({
    required this.counter,
  });

  factory CounterState.empty() {
    return CounterState(counter: 0);
  }
}
