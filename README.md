# Signal Runner: Blackout

A top-down survival-horror puzzle adventure built with **Odin + Raylib**.

The player is a Marshall, Nebraska police officer investigating four disappearances. The investigation begins at an abandoned cemetery and descends into a hidden research facility containing security systems, records, medical laboratories, detention cells, maintenance infrastructure, containment chambers, and evidence connected to **Project Resonance**.

## Current Build

This build preserves the CP1–CP4 foundations and expands the game into a connected survival-horror progression:

- CP1/CP2: GDD, entity architecture, explicit game states, update/render split.
- CP3: resources loaded once at boot, external tuning values, external level/spawn data, attribution.
- CP4: explicit monster finite-state machine and deliberate AI movement.
- Expanded build: scanner puzzles, inventory, evidence progression, interconnected facility rooms, cross-room pursuit, hiding/distraction, three lives, checkpoints, jumpscare, Game Over, and a definite ending.

## Build and Run

From the repository root:

```bash
odin run src
```

Run from the project root so `assets/` and `data/` resolve correctly.

## Controls

- `WASD` / Arrow Keys — move; officer faces the movement direction.
- `E` — interact / open doors / calibrate a selected frequency.
- `1` / `2` / `3` — select RED / BLUE / YELLOW scanner frequency underground.
- `F` — emit scanner pulse.
- `I` — open/close field inventory and evidence descriptions.
- `V` — toggle reduced horror effects.
- `Esc` — return to title during gameplay.
- `R` — restart investigation from Game Over.
- `Enter` — advance story/ending or return to menu from Game Over.

At the cemetery surface, `1` retains the earlier Red-signal barrier mechanic.

## Facility Progression

1. **Cemetery Visitor Gate** — obtain the cemetery key and discover the hidden grave staircase.
2. **Underground Reception** — find a spare fuse and restore partial power.
3. **Security Control** — solve the `RED → BLUE → YELLOW → BLUE` frequency-router sequence and obtain the security keycard.
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
  main.odin            boot, resources, update/render seam
  puzzles.odin         scanner, inventory and puzzle progression
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
