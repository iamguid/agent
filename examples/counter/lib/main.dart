import 'package:agent_flutter/agent_flutter.dart';
import 'package:counter/counter_events.dart';
import 'package:counter/counter_state.dart';
import 'package:counter/counter_state_agent.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
                  '${state.counter}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _counterStateAgent.emit('counter', CounterIncrementedEvent()),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
