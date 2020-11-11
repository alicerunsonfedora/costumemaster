# Working with Artificial Intelligence

Players and developers interested in working with artificial intelligence can run demonstrations of different artificial intelligence 
agents in the game that attempt to solve the puzzles for each provided level. This document will guide you through the theory
behind the AI agent work in the game, how to run examples with existing agents, and how to implement your own into the game.

- Important: Artificial intelligence features require a Mac running macOS 10.15 Catalina or greater, and The Costumemaster v1.1.0
or greater.

## How The Costumemaster Handles AI Gameplay

The Costumemasters works with GameplayKit, a framework provided by Apple Inc. that adds extra tools and utilities for game
developers to use, to provide the basis for AI agent testing.

Levels that agents can test work with a subclass of the game scene class, `AIGameScene`. This subclass provides the necessary
methods and properties to let an AI agent play the level in a safe manner, keeping track of updates such as costume changes,
time to complete the level, and others.

When the game scene finishes setting up the level, a strategist (`AIGameStrategist`) is created based on user parameters with a
given _strategy_ (`GKStrategist`). The strategy includes a method, `bestMoveForActivePlayer`, that gets called in the AI scene
that will determine the best move for the current player based on the current state of the game world, abstracted away to the struct
`AIAbstractGameState`.

The strategist is given the initial state of the world with `AIGameScene.getState` and will begin creating a set of moves using
`AIGameScene.strategize(with:)`. The logic for creating a set of moves is as follows:

- Assess the current state of the world.
- If the state is a winning state, don't make any more moves.
- Otherwise, generate a move using `AIGameStrategist.nextAction()`, which internally calls `bestMoveForActivePlayer`.
- Add the move to the set of moves, apply the update, and set the state of the agent to that of updated state.

Depending on what conditions the user supplies, the agent can make a different amount of moves at a given time. Once the agent
creates a set of moves, the moves are passed to the scene to apply the update to the real game world and will wait until a new
batch is generated, unless the level is complete.

## Supplied Game Strategists

GameplayKit does not provide strategists that work with solving puzzles due to the turn-based, competitive nature of the agents. 
However, The Costumemaster ships with a few agents designed for solving puzzles. These strategists conform to the 
`GKStrategist` protocol to ensure compatibility with GameplayKit.

### `AIRandomMoveStrategist`

The `AIRandomMoveStrategist` is a strategist designed to pick a move randomly. The strategist does not assess the state to
determine a random move.

### `AIRandomWeightedStrategist`

The `AIRandomWeightedStrategist` functionally performs similarly to the `AIRandomMoveStrategist` in that it picks a random
move to perform without assessing any states. However, this strategist will generate a list of all possible actions and assign a
random value to them. The strategist will pick the action with the highest value.

### `AIPredeterminedTreeStrategist`

The `AIPredeterminedTreeStrategist` is a strategist that determines an actions based on an assesement of the current game
state. The strategist answers a set of questions that get fed into a decision tree (implemented with `GKDecisionTree`) to determine
an optimal move:

- `"canEscape?"` - Whether the agent has completed the puzzle and can leave the level.
- `"nearExit"?` - Whether the agent is near the exit door.
- `"nearInput?"` - Whether the agent is near an input.
- `"inputRelevant?"` - Whether the input closest to the agent links to the exit door.
- `"inputActive?"` - Whether the input closes to the agent is active.

- Note: For this strategist, the tree is pre-determined and that questions listed above are already sorted in the tree in such a way
that some questions take priority over others (see: `AIPredeterminedTreeStrategist.makeDecisionTree()`).

In some cases, the action returned in the tree will pertain to moving closer to a device or an exit. The strategist will perform extra
checks to determine the directional move that will move the agent closer to a specified target using taxicab/Manhattan distance:

`$\lvert x_1 - x_2 \rvert + \lvert y_1 - y_2 \rvert$`

The logic is as follows:

```
Set the current action to stop.
Set the current minimum distance to infinity.
For all possible movement actions:
    Create a new state and apply the movement action.
    Set the new distance to the taxicab distance between the exit and the player in the new state.
    If the new distance is less than the current minimum distance:
        Set the current minimum distance to the new distance.
        Set the current action to the movement action that caused the distance change.
Finally, return the current action.
```

### `AITealConverseStrategist`

The `AITealConverseStrategist` is a strategy that uses a decision tree generated from CoreML and/or Create ML to make
decisions. The agent asks the same questions as the `AIPredeterminedTreeStrategist`, but uses the capabilities of CoreML to
answer those questions with an ML model.

Details on how the model is generated can be found on the [Teal Converse repository][#tealconverse].

## Testing the Included Agents

### Via the Simulator Tool

- Important: The simulator tool is included in v1.2.0 of The Costumemaster or greater.

To test the agents in a sample level for AI, open The Costumemaster and go to **Game &rsaquo; Run AI Simulation...**
or press ⌘R on your keyboard to open the AI Simulator tool. The AI simulator tool allows you to select an agent type, move
generation rate, and level for the simulator.

![AI Simulator Tool](https://github.com/alicerunsonfedora/CS400/raw/root/.readme/aisimtool.png)

Apply the settings you wish to use and then click "Start Simulation" to run the simulation.

### Via the Terminal
To test the agents in a sample level for AI, you will need to run The Costumemaster through the Terminal. In a terminal application,
point to the Costumemaster app and run the following:

```
./Contents/MacOS/The\ Costumemaster --agent-testing-mode true
```

There are extra commands you can supply to the game to control the overall output of the game:

| Command | Value type | Description |
| ------------ | ------------ | ------------- |
| `--start-level` | String | The name of the level to run the AI simulation in*. |
| `--agent-type` | String | The type of agent to use (`random`, `randomWeight`, `predTree`). |
| `--agent-move-rate` | Integer | The maximum number of moves the agent can make at a given time in a batch. |

- Note: *Due to limited testing, there is only one level available for testing, Entry. Additional AI levels may be added in the future.

If `--agent-type` and `--agent-move-rate` are not provided, the game will automatically chose the random move strategist and
a move rate of one (1) move per batch.

### Message Logging

The Costumemaster comes with an AI simulator console that will log any messages throughout the duration of the AI simulation.

![AI Simulator Console](https://github.com/alicerunsonfedora/CS400/raw/root/.readme/aisimconsole.png)

Messages sent to the console are also reflected in the command line if launched from the Terminal, with the exception of debug
messages. If the console is closed, the console can be re-opened by going to **Game &rsaquo; AI Simulator Console** in the 
menu bar or press ⌥⌘C on your keyboard.

#### Now Mode

Now Mode allows you to view the console messages as a stack, with the most recent message at the top. Click the Now Mode
button in the console toolbar to toggle Now Mode on/off.

## Creating a Custom Agent

To add a custom agent to the game, you will need to make sure you have cloned the game's source code from GitHub and ensured
that you have the required software to build the project.

1. Create a class that subclasses from `AIGameStrategy`. Be sure to override and implement the  `bestMoveForActivePlayer` 
method and return an action of type `AIGameDecision`.
2. Add an entry in the `CommandLineArguments.AgentTestingType` enumeration that will represent your custom agent.
3. Modify the method `AIGameScene.getStrategy(with:)` and include a case that instantiates your strategy.
4. Add a symbol from SF Symbols that best represents your agent, then update `AISimulatorAgentImage` to include backgrounds
and the symbol image for your agent accordingly.
5. Add a dictionary entry in AgentTypes.plist with a title and description for your agent.
6. Build and run The Costumemaster.

### Important Notes:

- Agent efficiency matters. Try to reduce the number of times you make state updates or you make a calculation to ensure that the
simulation will properly run and allow the game window to appear correctly.
- When reading the game state, ensure that you are checking the game state by casting it to the `AIAbstractGameState`
struct. Without this cast, you may be unable to determine key components such as positions and whether certain inputs are active.
- If your agent requires training, ensure that you have some means of communicating to the user that your agent is in training. This
can be easily achieved by printing a message like `"[INFO] Training the agent..."` or by using the 
`AIGameScene.console.debug` method to use the AI Simulator Console.
- Try to restrict what extra information you need from the user to do any decision-making. The `AIGameScene.getStrategy(with:)`
method [opaquely returns a type][#opaque] of `AIGameStrategist` and will not provide details on what kind of strategy was used.

[#opaque]: https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html
[#rnd]: https://1n.pm/df0Ui
[#tealconverse]: https://github.com/alicerunsonfedora/CS400-ml-playground
