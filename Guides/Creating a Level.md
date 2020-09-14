# Creating a Level

Levels in The Costumemaster can be easily made with the SpriteKit scene editor built in with Xcode. This guide will go through the
process on how to create a simple level for The Costumemaster using Xcode. This guide assumes that you have cloned The 
Costumemaster from GitHub and have opened it at least once in Xcode.

## Creating a new scene

In the **Scenes &rsaquo; Levels** group in the Xcode project, create a new file and select "SpriteKit Scene" as the file type. Name the file
the name of the level you are creating. The SpriteKit scene editor will open after creating the file.

You'll need to make a few adjustments to make the scene suitable for The Costumemaster:

1. Open the Attributes inspector and change the Size property to "Apple TV". Additionally, set the Name property to the name of the level.
2. Open the Custom Class inspector and change the Custom Class property to `GameScene`. This will allow the game to apply the right
    settings to the scene on runtime.
3. Add a Camera node (`SKCameraNode`) and Tile Map Node (`SKTilemapNode`) in the scene. Ensure that the name for the camera node
    is "Camera" and the name of the tile map node is "Tile Map Node" by editing the name in the Attributes inspector.
4. On the Tile Map Node, turn off "Enable automapping" in the Attributes inspector.
5. Double click on the Tile Map Node and draw out your level design. Ensure the map includes a player (Main) and an exit door.
    - Note: The locations of the exit door and inputs should be noted when designing your level. Start from the bottom left hand corner and
      count to the right for the column, then count then count up for the row.

## Adding user data

In the **User Data** section under the scene properties in the Attributes inspector, you'll need to add the following fields and set the types
of these fields:

| Field | Type | Value requirements |
| ----- | ---- | --------------- |
| availableCostumes | Int | 0 for USB-only, 1 to add the bird costume, 2 to add the sorceress costume, 3 for all costumes (including "none") |
| startingCostume | String | The costume to start with: Main, USB, Bird, or Sorceress |
| levelLink | String | The name of the scene to load when the player exits. Recommended: MainMenu |
| exitAt | String | The location of the exit door as a coordinate with column, then row. Example: 5,8 |

Additional fields can be defined as per the documentation in `LevelDataConfiguration`.

### Linking up inputs with outputs

To link an output to a set of inputs, you'll need to add additional fields to the user data that include these configurations ("requisites"). The 
type of a requisite is String. The typical requisite format is as follows:

`requisite_OUTCOL_OUTROW = TYPE;IN<X>COL,IN<X>ROW;`

Where the following are defined:

- `OUTCOL` is the column where the output is located.
- `OUTROW` is the row where the output is located.
- `TYPE` is either the word `AND` (all inputs are required) or `OR` (only one input is required). The type **must** end in a semicolon.
- `IN<X>COL,IN<X>ROW` is a coordinate for the column and row of an input. To add multiple inputs, use a semicolon after each coordinate
  and insert the next coordinate.


Example:

| Name | Type | Value |
| ----- | ---- | ----- |
| requisite_5_9 | String | AND;7,9;8,10; |
| requisite_6_8 | String | OR;7,9; |

## Creating challenge levels

Levels that incorporate challenges may need to make some additional modifications to the scene file.

- Levels should come with their own custom class that inherits from `ChallengeGameScene`. This new subclass should override
  the `ChallengeGameScene.willCalculateChallengeResults(...)` method to check for times, costume switches, etc. This
  method can be used to grant achievements or submit scores to leaderboards in Game Center based on criteria.
- The Custom Class field in the Custom Class inspector will need to be changed to another class name that subclasses from 
  `ChallengeGameScene`. This field _can_ contain ChallengeGameScene as its custom class, but no challenge functions will
  be performed other than the standard information being printed to the console.

## Testing and debugging levels

To test a level, you can run the game from the command line with the `--start-level` argument:

```
/path/to/Debug/The\ Costumemaster.app/Contents/MacOS/The\ Costumemaster --start-level NameOfLevel.sks
```
