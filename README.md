# Agent
Agent is simple, high preformance, large scalable, easy to use events and state
management system for fast ui development.

## Core concept
Agent provides primitives for manage your application state and events.
Agent have only two main classes: `Agent` and `StateAgent`.
* `Agent` is like event dispatcher, that can connect with other `Agent`s,
  and you can describe your `Agent` behavior base on events.
* `StateAgent` extends `Agent`, but have some fields and methods for
  state management. You can listen incoming events and change current
  `StateAgent` state. You can listen your state changes and bind it
  with your widgets.

Agent is modular system, that means, using Agent you can isolate your modules
from other and nothing broke. You can test your moduls and easily mock each
`Agent` on which you depend.

Think like Agent is tree of dispatchers and when you emit some event in one Agent,
then each other can react on your event, and change state, for example.
