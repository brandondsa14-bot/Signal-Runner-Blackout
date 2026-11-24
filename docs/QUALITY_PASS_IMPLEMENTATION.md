# Signal Runner: Blackout — Gameplay Quality Pass Implementation

Date: 2026-11-20

This document records the integrated quality pass performed after the CP5 balancing work. The goal was to correct concrete playtest problems without recreating the project or discarding earlier checkpoint systems.

## Baseline preserved

The pass builds on the existing Odin + raylib architecture and preserves:

- cemetery / hidden-stair opening;
- all existing facility rooms and connections;
- player sprite, directional facing and walk-cycle presentation;
- RED / BLUE / YELLOW scanner;
- searchable-container and inventory systems;
- objective tracker, minimap and Investigation Log;
- progressive hints;
- three lives, checkpoints, jumpscare and Game Over;
- Clay Stalker FSM and cross-room pursuit foundation;
- CP3 load-once resources and external data;
- CP5 BEFORE / AFTER / ACTIVE tuning profiles and telemetry.

## Phase 1 — Interaction reliability

### Root cause

Earlier interaction checks compared the player against an entity position/top-left point. Large drawers, notes, terminals and props could therefore be visually adjacent while the measured point was still outside the interaction radius. When several objects overlapped, the code also lacked one shared nearest-target decision.

### Fix

- Interaction distance is measured from the player's interaction point to the **nearest point on the target rectangle**.
- The same range test drives both the prompt and the E action.
- Nearby E targets are sorted by distance.
- `Q` cycles valid overlapping targets.
- Only the selected target consumes an E press.
- Object-specific prompts are generated from the selected target.
- Already-consumed one-time pickups are excluded from targeting.
- The Reception fuse now has a separate `reception_fuse_collected` world-state flag, preventing the world pickup from reappearing after the fuse is consumed at the power panel.

Key files: `src/puzzles.odin`, `src/game.odin`, `src/ui.odin`.

## Phase 1 — Movement and collision reliability

### Root cause

The full visible sprite dimensions were being used too aggressively against authored obstacle rectangles, so shoulders/head could snag at corners. Animation was based on requested velocity rather than confirmed displacement. A player that began slightly overlapped with geometry had no recovery path.

### Fix

- Player collision uses a lower-body rectangle while preserving the sprite dimensions.
- Movement resolves X and Y independently for wall sliding.
- Diagonal input is normalized to the configured speed.
- Small overlap recovery searches nearby legal positions rather than leaving the officer trapped.
- Walking animation advances only when the player actually moves.
- Room entry calls the same overlap recovery.
- `F8` toggles a collision/interaction diagnostic overlay for repeatable QA.

The Clay Stalker now uses the same principle: a lower-body navigation collider, axis-separated wall sliding and small depenetration recovery. The full monster rectangle remains available for capture/contact checks.

Key files: `src/game.odin`, `src/ai.odin`, `src/ui.odin`.

## Phase 2 — Scanner puzzle teaching

The Security Control puzzle still uses the original four-frequency rule, but the procedure is taught through investigation:

1. Search the Security Officer Desk.
2. Read the Frequency Router instructions: `1=RED`, `2=BLUE`, `3=YELLOW`; approach router; press `E` to transmit.
3. Find/read the separate night-shift handover card for the actual sequence clue.
4. Submit one frequency at a time.
5. Correct entries visibly increment accepted progress.
6. A mismatch reports the reset instead of silently failing.
7. Progressive hints distinguish missing instructions, missing sequence clue, unseen router and partial sequence progress.

The router display never reveals future colours before the player discovers the clue.

Key files: `src/items.odin`, `src/puzzles.odin`, `src/hints.odin`, `src/objectives.odin`, `src/ui.odin`, `data/levels/security.json`.

## Phase 3 — Clay Stalker behaviour

The existing finite-state system was extended rather than replaced:

`DORMANT → PATROL → SUSPICIOUS → INVESTIGATE → ALERT → CHASE → INVESTIGATE/SEARCH → DISENGAGE → PATROL`

Important behaviour:

- line-of-sight and distance remain meaningful;
- audible interactions provide a sound source, not omniscient player tracking;
- the monster stores a last-known location;
- losing sight transitions through investigation/search rather than immediately forgetting or cheating;
- cross-room pursuit enters from the doorway corresponding to the player's transition after the externally tuned delay;
- cross-room entry remembers the doorway, not the player's new exact position;
- navigation continues to use authored room markers + steering rather than unnecessary A*;
- search/investigation durations remain external tuning values;
- hiding breaks direct visibility but does not instantly erase monster memory;
- respawn protection, lives and jumpscare behaviour are preserved.

Key files: `src/ai.odin`, `src/states.odin`, `src/balance.odin`, `src/data.odin`.

## Phase 4 — Environmental detail and interaction

Every major facility area now has room-specific procedural pixel-art detail plus a small set of purposeful data-driven inspectable props. Examples include:

- Reception: waiting chairs, visitor paperwork, damaged phone/register, wall clock and abandoned processing clutter.
- Security: officer workstation, cameras, monitor wiring, binders and personal clutter.
- Archive: sealed boxes, paper stacks, filing shelves, typewriter/bookcase investigation.
- Laboratory: examination equipment, sample rack, IV hardware and research stations.
- Detention: cells, shower/plumbing strip, surveillance camera, scratches and fixtures.
- Maintenance: gauges, warning striping, tool bench and relay equipment.
- Waste Processing: filter tanks, conductive runoff, PPE storage and scanner bridge controls.
- Containment: observation lamps, restraint equipment, reinforced C-17 chamber and cameras.
- Storage: labelled lots, personal-effects crates and safe-room furniture.
- Final Investigation: physical case board, evidence terminals and radio/case interactions.

Decorative art does not create new collision geometry unless the level data explicitly contains a blocker. This keeps routes stable.

Key files: `src/facility_art.odin`, `src/environment.odin`, `data/levels/*.json`.

## Phase 5 — Detective evidence progression

The Investigation Log now supports structured evidence IDs with title, case association, discovery location, summary and mandatory/optional status.

The four linked cases are independently corroborated:

- **Lena Park** — reporter who traced Project Resonance and was isolated in the archive/service-shaft network.
- **Mateo Ruiz** — electrical contractor forced to work Relay 3; optional Waste Processing evidence confirms the fatal arc-flash while he attempted to cut Resonance power.
- **Evan Cole** — groundskeeper who discovered reopened cemetery tunnels; laboratory evidence confirms an unauthorized fatal calibration.
- **Leah Morrison** — EMT detained with the group; survived long enough to reach a maintenance radio and make the 2:14 AM call.

The mandatory path still guarantees a completable ending. Optional evidence improves corroboration but never creates a permanent softlock.

Key files: `src/evidence.odin`, `src/items.odin`, `src/puzzles.odin`, `src/ui.odin`, `docs/NARRATIVE_BIBLE.md`.

## Phase 6 — Optional Hazardous Waste Processing puzzle

A new optional Maintenance side chamber was chosen instead of adding incompatible platforming/jump physics.

- The chamber contains conductive industrial runoff and a retracted service bridge.
- BLUE vents the pressure system.
- YELLOW engages the bridge drive.
- Correct steps persist; an incorrect carrier does not erase already valid progress.
- The far side contains an optional Relay 3 incident report that strengthens Mateo Ruiz's case.
- The room supports monster navigation, cross-room pursuit, minimap discovery, hints and CP5 telemetry.
- The room is **not** required for the main ending.

Key files: `data/levels/processing.json`, `src/puzzles.odin`, `src/facility_art.odin`, `src/hints.odin`, `src/data.odin`.

## CP5 integrity

The original CP5 profiles remain preserved. The new `monster_investigate_seconds` parameter exists in BEFORE, AFTER and ACTIVE data and is identical (`2.6`) in the preserved comparison profiles, so the historical before/after comparison is not silently rewritten.

Waste Processing is mapped to the existing `RISING_DANGER` stage and therefore inherits profile-driven pressure instead of using hard-coded monster difficulty.

## Runtime verification status

Static validation was completed in the packaging environment, but that environment does not contain the Odin compiler or a graphical raylib runtime. Final compile/runtime acceptance must therefore be performed on the project Mac with:

```bash
odin check src
odin run src
```

See `docs/REGRESSION_TEST_PLAN.md` for the manual test matrix. Do not report unchecked items as passed.
