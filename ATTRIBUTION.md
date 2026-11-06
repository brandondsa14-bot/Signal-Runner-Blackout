# ATTRIBUTION

## AI Use

ChatGPT / OpenAI was used as a development assistant throughout the project for:

- GDD drafting and scope organization;
- Odin/Raylib setup and debugging guidance;
- CP2 entity/state/update-render architecture;
- CP3 resource loading, external tuning/level data, and checkpoint documentation;
- CP4 enemy finite-state-machine design and movement justification;
- the later cohesive facility redesign, puzzle dependency design, inventory/survival systems, cross-room pursuit, code organization, source review, and documentation;
- assistance drafting original programmer-art concepts and the dedicated monster close-up asset.

The project author remains responsible for reviewing, running, understanding, and demonstrating the submitted code.

## Existing / User-Provided Assets

### `assets/player_police.png`
- Original project asset created specifically for Signal Runner: Blackout with AI-assisted pixel-art drafting.
- No third-party character sprite sheet was copied.

### `assets/player_portrait.png`
- Original project asset created specifically for Signal Runner: Blackout with AI-assisted pixel-art drafting.
- Used for officer dialogue.

### `assets/ambience.mp3`
- User-provided file derived from the Danganronpa soundtrack.
- Used as temporary looping ambience at the user's request.
- Third-party copyright/licensing rights were not independently verified.
- Replace with original or appropriately licensed music before public distribution if permission is unavailable.

### `assets/pickup.mp3`
- User-provided Puppet Combo item-pickup sound file.
- Used for pickups and item discovery at the user's request.
- Third-party copyright/licensing rights were not independently verified.
- Replace with original or appropriately licensed audio before public distribution if permission is unavailable.

## Original Project Audio Added in Later Builds

### `assets/monster_chase.wav`
- Original synthesized chase loop created specifically for this project.
- Loaded once at boot and played during monster ALERT/CHASE states.

### `assets/scanner_success.wav`
- Original synthesized scanner-success cue created specifically for this project.

### `assets/scanner_fail.wav`
- Original synthesized scanner-failure cue created specifically for this project.

### `assets/monster_jumpscare.wav`
- Original synthesized horror impact/noise cue created specifically for the capture sequence.
- Designed to create impact without relying on excessively loud audio.

### `assets/distant_metal.wav`
- Original synthesized metallic ambience cue created specifically for this project.

## Original Visual Assets / Programmer Art

### `assets/monster_jumpscare.png`
- Original 640×640 close-up image created specifically for the Clay Stalker capture sequence.
- It is separate from the small gameplay monster and is not a scaled copy of the gameplay sprite.

### Facility / Clay Stalker Environment Art
- Cemetery, reception, security room, archive, laboratory, detention block, maintenance areas, containment wing, final investigation area, storage, furniture, cells, monitors, bloodstains, pipes, scanner nodes, and the gameplay Clay Stalker are original programmer art rendered with Raylib primitives.
- The uploaded Ao Oni screenshots were used only as a visual benchmark for room density, readability, and exploration depth; layouts and assets were not copied.

# CP4 AI / Movement Justification

## State machine

The Clay Stalker uses these explicit states in `src/states.odin` and `src/ai.odin`:

- `DORMANT` — absent from the immediate room, waiting for a possible appearance.
- `PATROL` — moves between authored navigation/spawn markers.
- `ALERT` — short reaction window after detection, giving the player fair warning.
- `CHASE` — actively pursues the officer.
- `SEARCH` — investigates the last known location after line-of-sight is broken.
- `DISENGAGE` — leaves the immediate search area before becoming dormant again.

Important transitions include:

- `DORMANT -> PATROL` after a randomized appearance delay.
- `PATROL -> ALERT` when line-of-sight detection succeeds.
- `ALERT -> CHASE` after the short reaction window.
- `CHASE -> SEARCH` after the player remains unseen long enough.
- `SEARCH -> ALERT` if the officer is rediscovered.
- `SEARCH -> DISENGAGE` when the search expires.
- `DISENGAGE -> DORMANT` after the monster withdraws.
- Active pursuit can carry across a room transition into another unsafe room after a short door-entry delay.

## Movement choice

The game deliberately uses **authored waypoint navigation + steering**, not full A*.

The facility consists of small handcrafted horror rooms with known furniture/corridor shapes. Data-driven `MONSTER_SPAWN` markers are placed at useful navigation points and corridor turns. When the target has a clear path, the Clay Stalker uses seek steering directly toward it. When furniture or walls block the direct line, the AI selects a visible authored marker that moves it closer to the target. Axis-separated collision movement prevents it from simply passing through walls.

This approach was chosen because:

1. It is easier to tune for a handcrafted horror map than a general grid search.
2. It lets level design control where the monster can create pressure.
3. It remains explainable during the checkpoint demo.
4. Full A* would add complexity that the current authored rooms do not require.
5. Cross-room pursuit is handled at the room-transition layer, where the monster enters through a `MONSTER_ENTRY` marker corresponding to the doorway the player actually used, after a short delay.

The monster also interacts with systems already built in earlier checkpoints: room data, collision, audio resources, scanner/noise events, player state, checkpoints, and game-state transitions.

## Search / Inventory / Lighting Expansion

ChatGPT / OpenAI assisted with the reusable stable-ID inventory/container architecture, modal interaction UI integration, contextual item-use flow, procedural walking-leg animation, Reception lighting transition, and related documentation. The feature set was integrated into the existing Odin + Raylib project structure rather than replacing prior checkpoint systems.

### `assets/power_restore.wav`
- Original synthesized electrical relay / rising-power cue created specifically for Signal Runner: Blackout during this implementation pass.
- Used when the correct 20A fuse is successfully installed in Underground Reception.
- Loaded once at startup through the existing shared resource pipeline.


## Progressive Hint / Puzzle-Clarity Expansion

ChatGPT / OpenAI assisted with the reusable context-aware hint-state architecture, Security Control onboarding/feedback pass, objective Next Step integration, modal exit-control improvements, and related verification/documentation. No new third-party visual or audio assets were added for this pass.
