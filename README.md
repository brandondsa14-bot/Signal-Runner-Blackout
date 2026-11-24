# Signal Runner: Blackout

A top-down survival-horror investigation and puzzle adventure built with **Odin + Raylib**.

The player is a Marshall, Nebraska police officer investigating four disappearances. The investigation begins at an abandoned cemetery and descends into a hidden research facility containing security systems, records, laboratories, detention cells, maintenance infrastructure, containment chambers, environmental evidence, and the mystery of **Project Resonance**.

## Current Build

The current project preserves the earlier checkpoint architecture while expanding the game into a connected survival-horror investigation:

- **CP1 / CP2** — GDD, entity-as-data architecture, explicit game states, update/render split.
- **CP3** — shared resources loaded once at boot, external tuning values, external level/spawn data, attribution.
- **CP4** — explicit Clay Stalker finite-state machine, deliberate AI movement and movement-method justification.
- **Expanded systems** — interconnected facility progression, scanner puzzles, searchable containers, stable-ID inventory, contextual item use, evidence progression, cross-room pursuit, hiding/distraction, three lives, checkpoints, jumpscare, Game Over, objective tracker, Investigation Log, minimap, progressive hints, persistent Reception lighting, procedural walking animation and a definite ending.

## Build and Run

From the repository root:

```bash
odin check src
odin run src
```

Run from the project root so `assets/` and `data/` resolve correctly.

## Controls

### Normal gameplay

- `WASD` / Arrow Keys — move; officer faces the movement direction.
- `E` — interact / examine / search / confirm / submit the current scanner frequency where applicable.
- `1` / `2` / `3` — select RED / BLUE / YELLOW scanner frequency underground.
- `F` — emit scanner pulse.
- `Tab` — open or close the Field Inventory.
- `I` — open or close the Investigation Log during normal play.
- `H` — open step-by-step assistance once the progressive hint system offers it.
- `K` — toggle automatic progressive hints on/off.
- `V` — toggle reduced horror effects.
- `Esc` — close the active modal; otherwise return toward the title/menu flow where supported.

At the cemetery surface, `1` retains the earlier Red-signal barrier mechanic.

### Search / inventory / contextual item menus

- Mouse wheel — move through available objects or inventory entries.
- Arrow Keys / `WASD` — keyboard menu navigation.
- Left click — select the highlighted entry where mouse selection is supported.
- `E` / Enter — inspect, pick up, equip, or confirm the selected action.
- `I` — exit a searchable-container or contextual item-use interface.
- `Esc` — exit the current modal interface.
- `Tab` — closes the Field Inventory when it is open.

Only one modal interface is intended to be active at a time. Normal movement and hint timing pause while the relevant modal UI is open.

## Searchable Containers

Environmental searching is part of the investigation rather than an automatic pickup system.

- Approach a searchable drawer/cabinet/container and press `E`.
- A dark Investigation Search interface opens and normal gameplay pauses.
- Scroll through individual objects.
- Each object can have its own description and action state: **Pick Up**, **Inspect**, or **Leave**.
- Collectable objects are added to persistent inventory state.
- Inspect-only objects remain environmental evidence/flavour.
- Collected objects disappear from that container and cannot be duplicated by leaving/re-entering the room.
- `I` or `Esc` leaves the search interface.

Examples currently include Reception, Archive, Maintenance and Storage interactions.

## Field Inventory

Press `Tab` during gameplay to open the Field Inventory.

Inventory entries use stable item identifiers rather than display-name comparisons. Each item can provide:

- name;
- procedural icon / slot presentation;
- description;
- gameplay use;
- item class (consumable, reusable, evidence or tool);
- persistent collected state.

The selected inventory item is highlighted and can also be represented on the main HUD.

### Item behaviour

- **Consumables** — removed only after a successful compatible use (for example the 20A Reception fuse).
- **Reusable items** — remain after use (for example badges, keys or tools where appropriate).
- **Evidence** — remains available for inspection/progression.
- **Incorrect item choices** — never consume the item and do not unlock the target.

## Contextual Item Use

Some locked/powered interactions require the player to deliberately choose an inventory item.

Typical flow:

1. Approach the target and press `E`.
2. The officer examines the object.
3. A contextual item selector opens when an item is required.
4. Navigate the inventory and choose an item.
5. A wrong item produces feedback and remains in inventory.
6. A correct item updates the persistent puzzle/door/power state.

Implemented examples include Reception power restoration, badge/key access and Maintenance tool use. Ordinary interactions that do not need an item continue to use `E` normally.

## Underground Reception Power / Fuse Puzzle

Reception begins under dim emergency lighting but remains navigable.

1. Investigate Reception and nearby searchable objects.
2. Find the visible **20A Ceramic Fuse** world pickup.
3. Collect it into the Field Inventory.
4. Approach the Reception power panel and press `E`.
5. Select the 20A fuse from the contextual item selector.
6. Successful installation consumes the fuse, plays the electrical activation cue, flickers the room lights and raises the room brightness.
7. Reception power remains restored after leaving/re-entering and the objective stays completed.

The world-darkness pass is rendered separately from HUD/dialogue/modal UI so menus remain readable.

## Police Officer Walking Animation

The existing one-frame police sprite is preserved. Movement adds a subtle procedural four-direction leg/boot cycle so the character no longer appears completely static while walking. The animation stops when movement stops and can cycle faster during pursuit without changing the player's collision dimensions.

## Frequency Scanner

The scanner is a recurring investigation/puzzle tool rather than a one-room switch.

- **RED** — high-energy relay / containment calibration.
- **BLUE** — hidden evidence detection and encrypted evidence decryption.
- **YELLOW** — security confirmation and electronic lock bypass.

Select a frequency with `1`, `2`, or `3`. Use `F` for a scanner pulse where the puzzle expects scanning. Some devices, such as the Security Frequency Router, accept the currently selected frequency with `E` while the officer is positioned at the device.

Scanner actions can generate noise and puzzle failures can create risk.

## Security Control Puzzle

Security Control is intentionally a puzzle, but its controls and feedback are made explicit.

- Read the **Shift Note** for the actual clue.
- Inspect the Frequency Router once to learn how its input works.
- Select RED / BLUE / YELLOW with `1` / `2` / `3`.
- Press `E` at the router to submit the selected frequency.
- Correct entries report accepted progress.
- A wrong frequency clearly reports that the sequence reset.
- Completing the sequence visibly shuts down the security laser barrier and advances the objective.

The router screen does not simply display the full solution before the clue is investigated.

## Progressive Hint System

The hint system tracks **time without meaningful forward puzzle progress**, not total room time.

- The first automatic hint appears after roughly 60 seconds without progress.
- Additional stages become progressively more specific.
- The fourth stage offers `H` step-by-step assistance.
- `K` toggles automatic hints for players who prefer no assistance.
- Hint timers pause during dialogue, Inventory, Search, contextual item selection, Investigation Log, hint overlay, and Clay Stalker ALERT / CHASE / SEARCH states.
- Meaningful puzzle progress resets the stuck timer.
- Hint stage is stored per puzzle context, so leaving and re-entering a room does not erase the accumulated assistance state.
- Context-aware text is derived from actual puzzle/inventory state so the game should not tell the player to repeat an already completed step.

Security step-by-step assistance obtains the implemented frequency solution from the puzzle logic rather than storing a second, potentially inconsistent answer.

## Objective Tracker / Investigation Log

- A compact **Current Objective** panel remains visible during normal gameplay.
- The HUD also displays a contextual **Next Step** derived from current puzzle state.
- `I` opens the dark, aged Investigation Log during normal gameplay.
- Completed objectives use clear completion markers; locked/undiscovered leads use `?` styling.
- Objective completion derives from persistent game progression rather than a separate manually maintained quest list.

When a searchable-container or contextual item-use modal is open, `I` exits that interaction instead of opening the Investigation Log.

## Minimap

The top-right minimap:

- renders basic current-room geometry from the existing entity data;
- shows the officer position;
- records exploration/visited-room state;
- intentionally does **not** show the Clay Stalker so it does not become enemy radar.

## Facility Progression

1. **Cemetery Visitor Gate** — obtain the cemetery key and discover the hidden grave staircase.
2. **Underground Reception** — investigate the room, collect the visible fuse and restore facility power.
3. **Security Control** — read the Shift Note, learn the router controls, solve the scanner-frequency sequence and obtain security access.
4. **Records Archive** — recover missing-person evidence and use BLUE scanning to reveal the archive code.
5. **Medical Laboratory** — use recorded evidence to calibrate receivers.
6. **Detention Block** — combine prior evidence, lock logic and item progression to recover additional case material.
7. **Maintenance** — use the correct tool and scanner alignment to restore the next facility system.
8. **Containment** — complete high-pressure scanner calibration while the Clay Stalker threat increases.
9. **Final Investigation** — combine mandatory evidence, decrypt the final record and transmit the completed case.

Optional storage/exploration areas contain additional environmental evidence.

## Clay Stalker AI

The Clay Stalker uses an explicit finite-state machine:

```text
DORMANT -> PATROL -> ALERT -> CHASE -> SEARCH -> DISENGAGE -> DORMANT
                    ^          |        |
                    |          |        +-- reacquire player
                    +----------+-- line-of-sight / sound
```

Movement uses authored navigation markers plus steering:

- authored markers for readable patrol and obstacle routing;
- line-of-sight checks for detection;
- steering/seek movement for pursuit;
- collision-aware movement around room geometry;
- cross-room pursuit into connected unsafe rooms;
- safe rooms that intentionally break pursuit and create puzzle-solving breathing space.

See `ATTRIBUTION.md` for the CP4 movement-method justification and inspiration disclosure.

## Survival System

- Exactly **3 lives**.
- Capture enters a dedicated jumpscare state.
- One life is deducted after the jumpscare sequence.
- Puzzle/evidence/inventory progress is preserved after capture.
- Respawn uses the most recent safe checkpoint with temporary protection.
- Third capture produces Game Over.
- `V` reduces the intense horror treatment.

## Configuration / Tuning

Gameplay tuning lives in `data/tuning.json`, including:

- player speed and interaction distance;
- message duration and ambience volume;
- scanner range / pulse timing;
- Clay Stalker patrol/chase speeds, detection/hearing ranges and state timings;
- cross-room pursuit delay;
- chase volume;
- respawn protection and jumpscare timing;
- ambient-event timing;
- `hint_interval_seconds` (default `60.0`);
- `hint_notification_seconds` (default `8.0`).

For rapid hint testing only, `hint_interval_seconds` can be temporarily reduced and then restored before submission.

## Data / Resource Structure

```text
src/
  ai.odin              Clay Stalker finite-state machine and navigation
  data.odin            JSON/tuning/level loading
  entities.odin        entity data model
  facility_art.odin    room/environment programmer art
  game.odin            game state/update flow and survival integration
  hints.odin           context-aware progressive hints and step-by-step assistance
  interaction_ui.odin  inventory/search/contextual-item UI
  items.odin           stable item IDs, inventory/container state and item-use logic
  main.odin            boot, shared resources and update/render seam
  objectives.odin      objective states and contextual objective information
  puzzles.odin         scanner and puzzle progression
  resources.odin       load-once shared textures/audio
  states.odin          explicit game/room/scanner/enemy enums
  ui.odin              HUD, dialogue, minimap, logs, jumpscare, Game Over, ending

data/
  tuning.json
  levels/*.json

assets/
docs/
```

## Attribution / Documentation

See:

- `ATTRIBUTION.md` — external assets, original project work, inspirations, AI-assistance disclosure and CP4 movement justification.
- `docs/implementation-summary.md` — feature-to-file implementation map.
- `docs/testing-summary.md` — static checks and required runtime verification.
- `docs/progressive-hint-system.md` — hint architecture and Security puzzle guidance.
- `docs/search-inventory-lighting-system.md` — container/inventory/power architecture.
- `docs/objective-minimap-system.md` — objectives and minimap implementation.

## Verification Status

Documentation distinguishes source/static review from real runtime verification.

The latest integrated build should be checked from the repository root with:

```bash
odin check src
odin run src
```

Do not treat a source-level inspection as proof of runtime behaviour. Complete the manual checklist in `docs/testing-summary.md` before final submission, especially after applying a new patch.

## CP5 — Data-Driven Balancing

The CP5 build preserves the CP3 external-data pipeline and adds explicit before/after balance profiles:

- `data/tuning_before.json` — exact pre-CP5 numeric baseline.
- `data/tuning_after.json` — deliberately shaped CP5 candidate balance.
- `data/tuning_active.json` — profile currently loaded by the game.
- `data/tuning.json` — retained as the earlier CP3 tuning snapshot/reference.

The game now maps rooms to five balance stages:

1. **Introduction** — Entrance / Reception.
2. **Investigation** — Security / Archive / Laboratory.
3. **Rising Danger** — Detention / Maintenance / Storage.
4. **Peak Tension** — Containment.
5. **Resolution** — Final Investigation.

The active AFTER curve is `0.75 -> 0.88 -> 1.00 -> 1.12 -> 1.06`. Monster speed, detection/hearing pressure, reaction timing, search duration, cross-room pursuit delay, and respawn pacing are derived through `src/balance.odin` rather than room-specific hardcoded constants.

### CP5 runtime controls

- `F5` — reload `data/tuning_active.json` without recompiling.
- `F9` — write a CP5 telemetry snapshot to `telemetry/`.

To switch profiles from the repository root:

```bash
cp data/tuning_before.json data/tuning_active.json
```

or:

```bash
cp data/tuning_after.json data/tuning_active.json
```

Then press `F5` in a running build (or restart the game). The HUD displays the active profile and current balance stage.

### CP5 evidence collection

Telemetry is observational and does not alter game rules. It records:

- active gameplay time;
- room/objective time;
- wrong puzzle submissions;
- hints shown;
- monster encounters and escapes;
- captures;
- total chase duration;
- checkpoint retries.

Use the reproducible procedure in `docs/CP5_PLAYTEST_PROTOCOL.md`. Actual playtest measurements must be gathered by running the game; the repository does not fabricate human results.

See:

- `docs/CP5_BASELINE_ASSESSMENT.md`
- `docs/CP5_BALANCING_REPORT.md`
- `docs/CP5_DEMO_SCRIPT.md`
- `docs/CP5_PLAYTEST_PROTOCOL.md`
- `telemetry/README.md`

## Narrative Integration — Project Resonance

The current narrative is documented in `docs/NARRATIVE_BIBLE.md`. The underground annex began as a concealed civil-defence communications site beneath St. Mercy Cemetery before being repurposed by Dr. Adrian Vale for Project Resonance. The four missing civilians are Lena Park, Mateo Ruiz, Evan Cole, and Leah Morrison. The Clay Stalker is Subject C-17, former security officer Elias Voss. The scanner is tied directly to the facility's tri-band maintenance/containment infrastructure rather than existing only as an abstract puzzle tool.

Environmental evidence is distributed through Reception, Archive, Laboratory, Detention, Maintenance, Storage, Containment, and Final Investigation so the final reveal is foreshadowed by earlier discoveries.

CP5 telemetry metadata can be labelled externally with `telemetry_scenario` and `telemetry_conditions` in the active tuning JSON; these labels are written into every F9 CSV snapshot alongside the build ID and profile.

---

# 2026-11-20 Reliability / Investigation Quality Pass

This section is the authoritative control and feature summary for the latest integrated source.

## Current controls

| Input | Action |
|---|---|
| `WASD` / Arrow Keys | Move the officer |
| `E` | Use the currently selected nearby interactable / confirm interaction |
| `Q` | Cycle overlapping nearby E-interaction targets |
| `1` / `2` / `3` | Select RED / BLUE / YELLOW scanner frequency underground |
| `F` | Scanner pulse |
| `Tab` | Open Field Inventory |
| `I` | Open Investigation Log in normal gameplay; exit Search / Item-Use UI while those modals are active |
| `H` | Open step-by-step puzzle assistance when unlocked by the hint system |
| `K` | Toggle automatic progressive hints |
| `V` | Toggle reduced horror effects |
| `F5` | Reload `data/tuning_active.json` for CP5 balancing without recompilation |
| `F8` | Toggle collision / interaction diagnostics |
| `F9` | Write a CP5 telemetry CSV snapshot |
| `Esc` | Close the active modal, or return to title when no modal is active |

### Reliable interactions

The prompt and E action now use the same selected target. Range is calculated to the nearest point on an interactive object's bounds, so large drawers, notes and terminals no longer require the officer to stand near one specific coordinate. When multiple interactables overlap, `Q` cycles them.

### Collision reliability

The visible officer sprite is preserved, while navigation uses a lower-body collider. X/Y movement resolves independently for wall sliding, diagonal movement is normalized, and a small depenetration search protects room-entry/spawn positions from minor overlap softlocks. Walking animation advances only when actual displacement occurs.

## Security Control teaching flow

The Frequency Router does not reveal its answer automatically.

1. Search the **Security Officer Desk**.
2. Read **Frequency Router Instructions** to learn that `1=RED`, `2=BLUE`, `3=YELLOW`, then approach the router and press `E` to transmit one channel.
3. Read the separate night-shift handover card to infer the required four-channel sequence.
4. Correct inputs advance the visible accepted count; a mismatch explicitly reports a reset.
5. The objective tracker and progressive hints respond to the exact step already completed.

## Investigation / evidence

Press `I` and switch between Objectives and Evidence. Important evidence has a stable ID, case association, discovery location, summary and mandatory/optional role. The four linked missing-person cases are corroborated through different rooms rather than resolved by one document.

## Optional Hazardous Waste Processing area

Maintenance now has an optional side chamber once Relay 3 is online. This is a top-down scanner puzzle rather than a platforming/jump system:

- BLUE vents the hazardous service bridge system.
- YELLOW engages the bridge drive.
- Crossing the restored bridge leads to an optional Relay 3 incident report tied to Mateo Ruiz.
- The area participates in monster pursuit, hints, minimap exploration and CP5 telemetry.
- It is not required for the mandatory ending.

## Debug / QA

`F8` displays collision and interaction diagnostics. Use it to verify the lower-body collider, nearby target selection and authored collision geometry when investigating movement or E-interaction issues.

For the full manual regression matrix, see `docs/REGRESSION_TEST_PLAN.md`.

# 2026-11-23 — UI Readability / Unobstructed HUD / Environment Polish

## Dedicated non-playfield HUD

Normal gameplay keeps the original **1100×640 world coordinate space**, but the application window now includes a dedicated **160 px investigation HUD band above the gameplay viewport**. The Current Objective / Next Step panel and Facility Map render in this band, so they remain visible without covering the player, doors, clues, or room corners. Level coordinates, collision geometry, AI navigation markers, puzzle positions, and transitions are not rescaled.

Mouse-driven inventory/search/item-use interfaces automatically convert screen-space mouse coordinates back into the gameplay UI coordinate space after the viewport offset.

## Wrapped UI text

`src/text_ui.odin` provides a reusable width-aware text renderer based on Raylib text measurement. It is used by search/container details, inventory descriptions, contextual item use, objective/next-step text, hint assistance, and custom investigation messages. Long text now wraps inside its panel rather than continuing past the right edge.

## Environmental cohesion pass

`src/facility_art.odin` adds room-specific, visual-only set dressing. These additions intentionally do **not** participate in collision or interaction, protecting authored movement lanes and puzzle access. The pass differentiates Reception, Security, Archive, Laboratory, Detention, Maintenance, Waste Processing, Containment, Final Investigation, Storage, and the Cemetery/Visitor Gate through appropriate abandoned-facility details.

See `docs/UI_ENVIRONMENT_POLISH.md` and `docs/REGRESSION_TEST_PLAN.md` for the room-by-room breakdown and manual verification checklist.

