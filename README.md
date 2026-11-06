# Signal Runner: Blackout

A top-down survival-horror puzzle adventure built with **Odin + Raylib**.

The player is a Marshall, Nebraska police officer investigating four disappearances. The investigation begins at an abandoned cemetery and descends into a hidden research facility containing security systems, records, medical laboratories, detention cells, maintenance infrastructure, containment chambers, and evidence connected to **Project Resonance**.

## Current Build

This build preserves the CP1–CP4 foundations and expands the game into a connected survival-horror progression:

- CP1/CP2: GDD, entity architecture, explicit game states, update/render split.
- CP3: resources loaded once at boot, external tuning values, external level/spawn data, attribution.
- CP4: explicit monster finite-state machine and deliberate AI movement.
- Expanded build: scanner puzzles, inventory, evidence progression, interconnected facility rooms, cross-room pursuit, hiding/distraction, three lives, checkpoints, jumpscare, Game Over, a definite ending, a live objective tracker, Investigation Log, and a room minimap.

## Build and Run

From the repository root:

```bash
odin run src
```

Run from the project root so `assets/` and `data/` resolve correctly.

## Controls

- `WASD` / Arrow Keys — move; officer faces the movement direction.
- `E` — interact / search / confirm pickup or contextual item use / calibrate a selected frequency.
- `1` / `2` / `3` — select RED / BLUE / YELLOW scanner frequency underground.
- `F` — emit scanner pulse.
- `I` — open/close the Investigation Log during normal play; while a search/item-use modal is open, `I` exits that interaction.
- `Tab` — open/close field inventory; equip the highlighted item with `E` or click.
- `H` — open step-by-step assistance once the progressive hint system offers it.
- `K` — toggle automatic progressive hints on/off.
- `V` — toggle reduced horror effects.
- Mouse wheel / Arrow keys / `WASD` — navigate active search/inventory/item-selection menus.
- Left click — select an inventory or contextual item-use entry.
- `Esc` — close an active modal; otherwise return to title during gameplay.
- `R` — restart investigation from Game Over.
- `Enter` — advance story/ending or return to menu from Game Over.

At the cemetery surface, `1` retains the earlier Red-signal barrier mechanic.

## Facility Progression

1. **Cemetery Visitor Gate** — obtain the cemetery key and discover the hidden grave staircase.
2. **Underground Reception** — search the room, pick up the visible floor fuse, and restore partial power.
3. **Security Control** — read the Shift Note, learn the router controls, solve its scanner-frequency sequence, and obtain the security keycard.
4. **Records Archive** — collect missing-person intake records and use BLUE scanning to reveal code `7-3-1`.
5. **Medical Laboratory** — use a damaged audio log to calibrate three receivers `BLUE / RED / YELLOW`.
6. **Detention Block D** — use YELLOW scanning plus prior evidence to bypass cell locks; recover a cell key and Cell 04 belongings/maintenance badge.
7. **Maintenance** — find a screwdriver, open Relay Panel 3, then use RED scanning to synchronize the third facility signal.
8. **Containment Wing C** — calibrate three containment nodes while the Clay Stalker becomes aggressive; recover the C-17 experiment log.
9. **Final Investigation** — combine the three mandatory evidence exhibits, use BLUE to decrypt the evidence mirror, and upload the case to Marshall PD.

An optional **Supply Storage** room contains additional environmental evidence and a damaged photograph.

## Frequency Scanner

The scanner is central to the whole underground experience rather than being a one-room switch.

- **RED** — high-energy relay/containment calibration.
- **BLUE** — hidden evidence detection and encrypted evidence decryption.
- **YELLOW** — security confirmation and electronic lock bypass.

Scanner use can generate noise. Bad puzzle inputs can attract the monster.

## Investigation Log and Minimap

- A compact **Current Objective** panel remains visible during gameplay.
- `I` opens a full dark/aged Investigation Log with active, completed and undiscovered objectives.
- Completed entries use checkmarks; locked leads remain obscured with `?` markers until discovered.
- `Tab` now opens the field inventory so the Investigation Log can own the `I` key.
- The top-right minimap renders current-room collision structure and the officer position while intentionally hiding the monster.
- Room exploration marks persist through normal room changes and checkpoint respawns.

## Clay Stalker AI

The Clay Stalker uses an explicit finite-state machine:

```text
DORMANT -> PATROL -> ALERT -> CHASE -> SEARCH -> DISENGAGE -> DORMANT
                    ^          |        |
                    |          |        +-- reacquire player
                    +----------+-- line-of-sight / sound
```

Movement uses a deliberate hybrid:

- authored navigation markers for readable patrol and obstacle routing;
- line-of-sight checks for detection;
- steering/seek movement for pursuit;
- collision-aware movement around walls and large furniture;
- cross-room pursuit when the player changes into another unsafe room;
- safe rooms break pursuit to preserve puzzle-solving breathing room.

## Survival System

- Exactly **3 lives**.
- Capture enters a dedicated jumpscare state.
- One life is deducted after the jumpscare.
- Puzzle progress/evidence is preserved after capture.
- Player respawns at the most recent safe checkpoint with temporary protection.
- Third capture produces Game Over.
- `V` reduces chase volume, removes jumpscare shake, and suppresses intense jumpscare/ambient sound.

## Data / Resource Structure

```text
src/
  ai.odin              monster finite-state machine and navigation
  data.odin            JSON/tuning/level loading
  entities.odin        entity data model
  facility_art.odin    room/environment programmer art
  game.odin            game state/update flow and survival system
  hints.odin           context-aware progressive hint timers and step-by-step assistance
  main.odin            boot, resources, update/render seam
  puzzles.odin         scanner and puzzle progression
  items.odin           stable item IDs, inventory state, searchable containers and item-use logic
  interaction_ui.odin  inventory/search/contextual-item UI and procedural item icons
  resources.odin       load-once shared textures/audio
  states.odin          explicit enums for game/room/scanner/enemy states
  ui.odin              HUD, dialogue, inventory, jumpscare, Game Over, ending

data/
  tuning.json
  levels/*.json
assets/
docs/
```

See `docs/level-progression.md`, `docs/puzzle-dependency-map.md`, and `docs/testing-summary.md` for the detailed design and verification notes.

## Interactive Search, Inventory and Power Update

The investigation layer now uses stable item/container identifiers instead of treating pickups as room-specific text events.

- `E` near a searchable drawer/cabinet opens a modal investigation search interface.
- Mouse wheel or `W/S` / arrow keys move through the contents; `E` inspects or collects the highlighted object; `I` or `Esc` leaves. A visible top-right exit reminder is shown on modal interactions.
- Collected objects disappear from that container and remain collected after room transitions/checkpoint respawns.
- `Tab` opens a slot-based field inventory with procedural item icons, selection highlighting, descriptions, item class, and an equipped-item HUD indicator.
- Locked item-driven interactions open a contextual item selector. Wrong items remain in inventory.
- The Reception 20A fuse is a visible world pickup on the floor and is consumed only after successful installation; staff badges, keys and tools are reusable; evidence remains inspectable.
- Underground Reception begins under emergency lighting. Successful fuse installation plays an electrical activation cue, flickers the lighting bus, then brightens the room. The powered state persists.
- The one-frame officer sprite now receives a subtle procedural four-direction boot/leg cycle while moving; the cycle stops when movement stops.

The reusable implementation is split across `src/items.odin` (item/container definitions, persistent state helpers and modal input logic) and `src/interaction_ui.odin` (inventory/search/item-use presentation).


## Progressive Puzzle Hints

The game now tracks time spent without meaningful puzzle progress rather than raw room time.

- Automatic hints begin after roughly 60 seconds without forward progress and become more specific in four stages.
- Hint timers pause during dialogue, inventory/search/item-use menus, Investigation Log, hint assistance, and Clay Stalker ALERT/CHASE/SEARCH states.
- Progress such as reading the Security Shift Note, inspecting the Frequency Router, entering accepted frequencies, solving a receiver, or advancing a major item puzzle resets the stuck timer.
- Hint progress is stored per facility context, so leaving and re-entering a room does not erase the accumulated hint stage.
- At the fourth stage, `H` opens step-by-step help. In Security Control, the displayed sequence is read from the implemented `security_expected_mode()` puzzle logic.
- `K` toggles automatic hints for players who prefer no assistance.
- The Current Objective HUD now includes a contextual **Next Step** line derived from actual puzzle state.

Security Control specifically records whether the Shift Note was read, whether the router instructions were inspected, how many inputs were accepted, and whether the lock is disabled. Wrong frequencies clearly reset the router to `0/4`; accepted frequencies report progress; the laser grid animates down on completion.
