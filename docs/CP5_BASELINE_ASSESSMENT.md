# CP5 Baseline Technical Assessment

## Baseline used

This assessment is based on the latest pre-CP5 Signal Runner: Blackout build reconstructed from the full Hint / Exit / Fuse build plus the later documentation/reserved-keyword patch.

An untouched copy of that reconstructed project is retained as `baseline-pre-cp5` in the working package used to create this CP5 update. The distributable project itself does not contain a duplicate source tree.

## Existing architecture

- **Language / rendering:** Odin + raylib.
- **Main loop:** `src/main.odin` performs resource loading once, then an update pass and render pass every frame.
- **Persistent game state:** `Game` in `src/game.odin`.
- **Room data:** external JSON files in `data/levels/`.
- **Gameplay tuning:** external JSON in `data/tuning.json`.
- **Resources:** loaded once through `src/resources.odin`.
- **Enemy AI:** finite-state machine in `src/ai.odin`.
- **Puzzles / progression:** `src/puzzles.odin`.
- **Objectives:** `src/objectives.odin`.
- **Progressive hints:** `src/hints.odin`.
- **Inventory/search:** `src/items.odin` and `src/interaction_ui.odin`.
- **World/UI art:** `src/facility_art.odin` and `src/ui.odin`.

## Systems confirmed present before CP5

The baseline already contains:

- Cemetery gate, cemetery key, grave interaction, and hidden stairway.
- Underground Reception fuse/power sequence.
- Searchable containers and a persistent inventory.
- Red / Blue / Yellow scanner frequencies.
- Security sequence, Archive scan, Laboratory receiver puzzle, Detention bypass, Maintenance relay, Containment nodes, and final evidence mirror.
- Objective HUD, investigation log, minimap, and progressive hint system.
- Three lives, checkpoint respawn, hiding, jumpscare, and reduced-horror mode.
- Clay Stalker FSM with Dormant, Patrol, Alert, Chase, Search, and Disengage states.
- Cross-room pursuit and authored navigation markers.
- External tuning and external room/spawn data.

## CP5 balancing problem identified

The baseline already used external values, but its monster pressure was globally flat:

- Patrol speed: `72`
- Chase speed: `142`
- Detection radius: `250`
- Alert delay: `0.62 s`
- Lost-player delay: `1.35 s`
- Search duration: `4.2 s`
- Cross-room delay: `0.85 s`

Those values were applied the same way in every monster-enabled room. The content became more complicated as the player progressed, but the numeric monster pressure did not form an explicit room-by-room curve.

This creates a balancing problem for CP5: the project is data-driven, but the difficulty shape cannot be described from the tuning data itself.

## Changes justified for CP5

1. Preserve the exact pre-CP5 values as a **BEFORE** profile.
2. Create an **AFTER** profile with a deliberate five-stage curve.
3. Apply stage scaling through centralized helper functions rather than room-specific literals.
4. Add safe configuration validation.
5. Add live external-profile reload with `F5`.
6. Add observational telemetry so balancing evidence can be gathered without changing gameplay.
7. Keep all gameplay content and puzzle rules identical between BEFORE and AFTER.

## Verification status

This document records source inspection and configuration analysis. Human balancing observations must be gathered through the included telemetry/playtest procedure; none are invented here.
