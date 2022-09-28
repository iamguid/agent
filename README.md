# Agent
Agent is not yet another state management library.
It is completely new way to manage your state and events.

Agent is:
  * Simple - Core just 200 line of code.
  * Flexible - You can make what you want.
  * High Preformance - Because Agent is simple.
  * Scalable - You can scale complexity of your state and event stream.
  * Easy To Use - Because Agent is simple.

## Core Concept
Agent provides primitives for manage your application state and events:
`Agent` and `StateAgent`.
* `Agent` is like event dispatcher, that can connect with other `Agent`s,
  and you can describe your `Agent` behavior base on events.
* `StateAgent` extends `Agent`, but have some fields and methods for
  state management. You can listen incoming events in your widgets
  and change current `StateAgent` state.

Agent is modular system, that means, using Agent you can isolate your modules
from other and nothing broke. You can test your moduls and easily mock each
`Agent` or `StateAgent` on which you depend.

Think like Agent is a tree of dispatchers and when you emit some event in one Agent,
then each other can react on your event. But we have no centralized dispatcher,
because all agents are dispatchers. It is important thing because you can connect and disconnect from one agent and connect to other, in some meaning it is like
'decentrolized' dispatchers.  Agents just distribute your event to all
connected Agents using simple algorithm it is synchronus process,
maybe in future it will be asynchronous.

## How It Works
The first example will be ofcourse counter :) It is simple app for demonstrate how
state management works. But future examples will be more complicated.
What we have in counter ? A button that will be count up a counter when
we will press on it. Counter will be start from 0. Let's make it.

For that simple example we need only one StateAgent let's name it CounterStateAgent.
Also we need some events and counter state class.


`counter_events.dart`
```dart
abstract class CounterEvent {}
class CounterIncrementedEvent extends CounterEvent {}
class CounterDecrementedEvent extends CounterEvent {}
```

`counter_state.dart`
```dart
class CounterState {
  final num counter;

  CounterState({
    required this.counter,
  });

  // Special factory for emty state
  factory CounterState.empty() { 
    return CounterState(counter: 0);
  }
}
```

`counter_state_agent.dart`
```dart
class CounterStateAgent extends StateAgent<CounterState, CounterEvent> {
  CounterStateAgent() : super(CounterState.empty());

  // Importand method that we should define, events can be
  // not only CounterEvent, it can be some event from other
  // agents, thats why event has Object? type, and there 
  // we can handle events from other agents.
  @override
  void onEvent(Object? event) {
    if (event is CounterIncrementedEvent) {
      nextState(CounterState(counter: state.counter + 1));
    }

    if (event is CounterDecrementedEvent) {
      nextState(CounterState(counter: state.counter - 1));
    }
  }
}
```

`main.dart`
```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CounterStateAgent _counterStateAgent;

  @override
  void initState() {
    _counterStateAgent = CounterStateAgent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, _) =>
        // Subscribe to state changes
          StateAgentBuilder<CounterStateAgent, CounterState>(
        agent: _counterStateAgent,
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Agent counter app'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  // Get counter from state
                  '${state.counter}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // Dispatch increment event
            onPressed: () =>
                _counterStateAgent.dispatch(CounterIncrementedEvent()),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
```

Full work example you can find  [here](https://github.com) 