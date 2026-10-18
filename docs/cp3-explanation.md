# CP3 — Assets / Data Pipeline — Signal Runner: Blackout

## What CP3 demonstrates

### 1. Resources loaded once and shared
`src/resources.odin` defines a `Resources` struct containing the player sprite, player portrait, ambience music, and pickup sound. `main.odin` calls `load_resources()` once before the game loop. Rendering and gameplay reuse those already-loaded handles; no texture or sound is loaded inside an entity update or render loop.

### 2. At least three tuning values in a data file
`data/tuning.json` contains:
- `player_speed`
- `interact_distance`
- `message_duration`
- `ambient_volume`

`src/data.odin` loads these values at startup. `game.odin` actually uses them for player movement, interaction range, and dialogue timing.

### 3. Level/spawn data outside source code
The current maps are stored under `data/levels/*.json`. Their player, walls, terminal, signal barrier, cemetery door, clue grave, transition zones, dungeon door, and dungeon collision walls are read from data files by `load_level_file()` rather than being created as a large list of position literals inside `setup_world()`.

### 4. Attribution complete
`ATTRIBUTION.md` lists current AI use, original project art, and both user-provided audio files. Licensing status for third-party audio is stated honestly rather than assumed.

## Live TA demonstration
1. Run the game once with `player_speed` set to `155.0`.
2. Exit the game.
3. Open `data/tuning.json` only — do not edit Odin source.
4. Change `player_speed` to `250.0`.
5. Run `odin run src` again.
6. Show that the officer visibly moves faster.
7. Open `src/resources.odin` and show that texture/audio loads happen in `load_resources()` once at startup.
8. Open `data/levels/entrance.json` and explain that spawn/layout data is external.
9. Open `ATTRIBUTION.md` and show the AI + assets sections.

## New atmospheric content in this build
- Far-right grave displays an interaction prompt.
- Repeated `E` interactions produce the clue dialogue:
  1. "There's light coming through..."
  2. "Digging... digging..."
  3. "There's a hidden stairway here... Better take a look."
- One more `E` descends to an underground wooden passage.
- Top-left doorway automatically enters the library.
- Top-right doorway automatically enters the abandoned room.
- The dungeon is the only underground destination requiring `E` to enter.
- The dungeon contains numbered prison cells and a visible Warden's Office area.
