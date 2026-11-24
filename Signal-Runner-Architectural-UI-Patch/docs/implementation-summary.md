# Cohesive Redesign — Implementation Map

This file maps the major redesign requirements to the project files that implement them.

## Story and environmental investigation

- `src/ui.odin` — story intro, evidence/dialogue text, room objectives, definite ending.
- `src/facility_art.odin` — reception, security, archive, laboratory, detention, maintenance, containment, final-investigation, storage and cemetery programmer art.
- `data/levels/*.json` — physical room layouts, collision, doors, evidence objects, hiding spots and monster navigation markers.
- `docs/level-progression.md` — room purpose and narrative progression.

## Frequency scanner

- `src/states.odin` — `Scanner_Mode` (`RED`, `BLUE`, `YELLOW`).
- `src/puzzles.odin` — security sequence, archive hidden trace, detention bypass, maintenance relay scan, final decryption and scanner pulse logic.
- `src/ui.odin` — scanner HUD, mode feedback and scan prompts.
- `assets/scanner_success.wav`, `assets/scanner_fail.wav` — scanner feedback.

## Item puzzles / inventory

- `src/game.odin` — persistent inventory/evidence state.
- `src/puzzles.odin` — fuse, keycard, cell key, personal effects, maintenance badge, screwdriver and evidence dependencies.
- `src/ui.odin` — field inventory overlay and item descriptions.
- `docs/puzzle-dependency-map.md` — complete dependency chain.

## Clay Stalker AI

- `src/states.odin` — `Enemy_State` enum.
- `src/ai.odin` — detection, line of sight, hearing/noise attraction, patrol, alert, chase, search, disengagement, authored navigation markers, collision, random appearances and cross-room pursuit.
- `data/levels/*.json` — `MONSTER_SPAWN` and `MONSTER_ENTRY` route markers.
- `ATTRIBUTION.md` — CP4 movement-method justification.

## Cross-room pursuit

- `src/game.odin` — carries active pursuit through `change_room()`.
- `src/ai.odin` — remembers the doorway destination used by the player, delays entry for fairness, then selects the corresponding `MONSTER_ENTRY` marker in the next unsafe room.
- Reception, Archive, Storage and Final Investigation are deliberate breathing/safe rooms.

## Three-life survival system

- `src/game.odin` — lives, checkpoints, respawn protection, capture resolution and Game Over transition.
- `src/ui.odin` — three-life HUD and Game Over screen.
- Puzzle/inventory booleans remain in `Game`, so completed progression survives checkpoint respawns.

## Jumpscare

- `src/game.odin` — dedicated `JUMPSCARE` state/timer and life deduction after the sequence.
- `src/ui.odin` — gameplay freeze presentation, dedicated close-up texture, shake/distortion, fade/cut to black.
- `assets/monster_jumpscare.png` — separate close-up asset, not an enlarged gameplay sprite.
- `assets/monster_jumpscare.wav` — dedicated capture sound.
- `V` toggles reduced horror effects.

## Horror atmosphere

- `src/facility_art.odin` — darkness, damaged environments, bloodstains, cells, monitors, equipment, pipes and room-specific visual identity.
- `src/game.odin` — randomized ambient-event timing.
- `assets/distant_metal.wav` — intermittent environmental sound.
- `assets/monster_chase.wav` — chase-state music.
- `src/ai.odin` — ambience volume drops when a chase begins.

## Previous checkpoint preservation

- `src/main.odin` still uses the explicit update/render seam from CP2.
- `src/entities.odin` retains entity-as-data architecture and legacy checkpoint entity kinds.
- `src/resources.odin` keeps CP3 resources loaded once at boot and shared.
- `src/data.odin` / `data/tuning.json` keep tuning and level/spawn data external.
- The original cemetery terminal/key/red-signal/grave/stair sequence remains the surface opening.
- Existing CP3/early-CP4 JSON level files remain in the repository for checkpoint history/compatibility, while the redesigned facility uses the new active room set.

## Verification

See `docs/testing-summary.md` for static checks already completed and the exact runtime checklist to perform with `odin run src` on macOS before committing this build.


## Investigation/objective tracking

- `src/objectives.odin` defines fourteen story objectives and derives `LOCKED`, `ACTIVE`, or `COMPLETED` from real progression flags.
- `src/ui.odin` renders the persistent Current Objective panel, aged Investigation Log, objective markers, and top-right minimap.
- `src/data.odin` records explored rooms whenever a level is loaded.
- The minimap reuses current entity geometry and does not reveal Clay Stalker position.
- `I` opens the log; `Tab` preserves access to the pre-existing field inventory.

## Search / Inventory / Lighting Expansion

Added `src/items.odin` and `src/interaction_ui.odin` as reusable systems. Searchable containers are data-driven entities and persistent object state is stored on `Game`, so room reloads do not duplicate pickups. Contextual item-use targets compare stable `Item_ID` values rather than strings. Reception power is a persistent puzzle state and its lighting transition is rendered in the world pass before HUD/UI. The officer's one-frame sprite is preserved and enhanced with a procedural directional boot cycle.


## Progressive Hint / Interaction Clarity Pass

- `src/hints.odin` — reusable per-context stuck timers, context-aware hint text, progressive four-stage assistance, step-by-step overlay, and contextual Next Step derivation.
- `src/game.odin` — persistent hint state, Security clue/router state, hint pause/toggle integration, and Security first-entry onboarding.
- `src/puzzles.odin` — Security read/inspect state, clearer accepted/reset feedback, and laser shutdown timer.
- `src/ui.odin` — Current Objective Next Step, hint status/help availability, hint notification/solution rendering, and improved Security result messages.
- `src/interaction_ui.odin` / `src/items.odin` — visible `I — EXIT` modal control and `I` exit handling.
- `src/facility_art.odin` — router screen no longer exposes the answer and laser grid animates down after success.
- `data/levels/reception.json` — restores the 20A fuse as a visible world pickup.
- `data/tuning.json` — external 60-second hint interval and notification duration.

## Documentation / Attribution Integrity Pass

The final documentation pass aligns the project records with the current CP4-era feature set:

- `ATTRIBUTION.md` now separates external/user-provided assets, original project assets, design inspirations, AI-assisted development, and the CP4 movement justification.
- Unverified third-party audio is explicitly marked as requiring creator/source/licence confirmation rather than assigning invented URLs or permissions.
- `README.md` now documents the actual current controls and interaction priority for normal gameplay, Search UI, contextual item use, Inventory, Investigation Log, progressive hints, scanner controls and reduced-horror mode.
- Configuration fields in `data/tuning.json`, including the hint timing fields, are documented.
- `docs/final-project-integrity-summary.md` provides a concise deliverables/testing summary for final review.

No gameplay architecture was replaced during this documentation pass.

# CP5 implementation addendum

## New source systems

- `src/balance.odin` — maps rooms into the five-stage CP5 difficulty curve and derives effective monster pressure from external stage multipliers.
- `src/telemetry.odin` — observational balancing telemetry and CSV snapshots.

## New external data

- `data/tuning_before.json` — preserved pre-CP5 numeric baseline.
- `data/tuning_after.json` — candidate deliberately shaped balance.
- `data/tuning_active.json` — runtime-loaded profile.

The earlier `data/tuning.json` is retained as a CP3 history/reference file.

## Existing files integrated with CP5

- `src/data.odin` — tuning metadata, validation/clamping, active-profile logging.
- `src/main.odin` — loads `tuning_active.json`.
- `src/ai.odin` — uses stage-aware balance helpers and telemetry transitions.
- `src/game.odin` — telemetry state, F5 profile reload, F9 snapshot, capture/survival instrumentation.
- `src/hints.odin` — hint telemetry.
- `src/puzzles.odin` — wrong-submission telemetry and final snapshot.
- `src/ui.odin` — CP5 profile/stage display and expanded ending.

## Narrative integration

`docs/NARRATIVE_BIBLE.md` consolidates the existing mystery around St. Mercy Cemetery, Project Resonance, the four missing civilians, C-17/Elias Voss, Adrian Vale, and Leah Morrison's 2:14 AM call. Existing rooms are used for environmental storytelling rather than adding a disconnected narrative subsystem.

## 2026-11-20 reliability / investigation quality pass

See `docs/QUALITY_PASS_IMPLEMENTATION.md` for the full engineering rationale. In summary:

- interaction targeting is now bounds-aware and nearest-target deterministic;
- `Q` cycles overlapping E targets;
- player and monster navigation use lower-body collision with wall sliding / overlap recovery;
- Security teaching is moved into an investigable desk and no longer assumes the player already understands scanner submission;
- environmental props are data-driven and use the same corrected interaction system;
- evidence has stable IDs and separate missing-person case associations;
- Clay Stalker now has explicit SUSPICIOUS / INVESTIGATE phases;
- optional Waste Processing extends Maintenance with a scanner-operated bridge and non-mandatory Mateo evidence;
- CP5 tuning profiles are preserved and Processing is included in telemetry.

## 2026-11-23 UI / HUD / Environment polish

- Added `src/text_ui.odin` for reusable width-aware text wrapping and PLAYING mouse-coordinate conversion.
- Expanded the PLAYING window with a 160 px dedicated HUD band while preserving the original 1100×640 world coordinate space.
- Moved Current Objective / Next Step and Facility Map into the dedicated band.
- Integrated wrapping across search, inventory, item use, objectives, hints, and custom investigation messages.
- Added visual-only room-specific programmer art throughout the facility; no new collision or level-data blockers were introduced.
- Added regression coverage for text overflow, HUD obstruction, viewport-adjusted mouse input, and room navigation.


## Architectural UI / Responsive Window pass

- Added monitor-aware, resizable virtual-canvas presentation in `src/main.odin`.
- Added physical-to-virtual mouse mapping through `src/text_ui.odin`.
- Added an external bottom controls strip and removed keyboard help from the in-world bottom bar in `src/ui.odin`.
- Updated `render_game` so PLAYING uses Top HUD → Gameplay → Bottom Controls, while non-playing screens remain centered in their original 1100×640 composition.
- Reworked procedural set-dressing coordinates in `src/facility_art.odin` around functional architectural zones without changing level JSON or collision data.
