# ATTRIBUTION

This file records external assets, original project work, inspirations, and AI-assisted development used in **Signal Runner: Blackout**. Existing credits are preserved and later feature passes are documented below so the project can be reviewed honestly as a university game-development submission.

## AI Use

ChatGPT / OpenAI was used as a development assistant throughout the project for:

- GDD drafting and scope organization;
- Odin/Raylib setup and debugging guidance;
- CP2 entity/state/update-render architecture;
- CP3 resource loading, external tuning/level data, and checkpoint documentation;
- CP4 enemy finite-state-machine design and movement justification;
- the later cohesive facility redesign, puzzle dependency design, inventory/survival systems, cross-room pursuit, code organization, source review, and documentation;
- assistance drafting original programmer-art concepts and the dedicated monster close-up asset;
- the objective tracker, Investigation Log and minimap implementation;
- reusable searchable-container and stable-ID inventory systems;
- contextual item-use logic, item persistence/consumption rules, and modal interaction UI;
- procedural officer walking-leg animation and Reception power/lighting transition;
- the reusable progressive hint system, Security Control onboarding/feedback, contextual Next Step guidance, and debugging of Odin compiler issues.

AI assistance included code generation, refactoring suggestions, debugging, design iteration, documentation drafting, and creation/assistance with some original project-only assets. No claim is made that third-party games supplied code or assets. The project author remains responsible for reviewing, running, understanding, and demonstrating the submitted code.

---

## External / User-Provided Assets

The following files were provided by the project author and are not claimed as original project-owned audio.

### `assets/ambience.mp3`
- User-provided file derived from the **Danganronpa** soundtrack.
- Used as temporary looping ambience at the user's request.
- Creator / rights holder: requires confirmation by the project author.
- Source URL: not provided in the project materials and therefore not invented here.
- Licence / permission: not independently verified.
- Submission note: replace with original or appropriately licensed music before public distribution if course-use permission is not confirmed.

### `assets/pickup.mp3`
- User-provided file identified by the project author as **“Puppet Combo item pickup sound effect (HQ)”**.
- Used for pickups and item-discovery feedback.
- Creator / rights holder: attributed by filename/request to Puppet Combo; exact original creator/rights information requires confirmation.
- Source URL: not provided in the project materials and therefore not invented here.
- Licence / permission: not independently verified.
- Submission note: replace with an original or appropriately licensed sound before public distribution if permission is not confirmed.

---

## Original / Project-Specific Visual Assets

### `assets/player_police.png`
- Original project asset created specifically for Signal Runner: Blackout with AI-assisted pixel-art drafting.
- No third-party character sprite sheet was copied.
- The later walking animation keeps this asset and adds procedural leg/boot motion in code rather than importing a third-party animation sheet.

### `assets/player_portrait.png`
- Original project asset created specifically for Signal Runner: Blackout with AI-assisted pixel-art drafting.
- Used for officer dialogue.

### `assets/monster_jumpscare.png`
- Original 640×640 close-up image created specifically for the Clay Stalker capture sequence with AI-assisted asset development.
- It is separate from the small gameplay monster and is not a scaled copy of another game's monster or gameplay sprite.

### Facility / Clay Stalker Programmer Art
- Cemetery, Underground Reception, Security Control, Records Archive, Medical Laboratory, Detention Block, Maintenance, Containment, Final Investigation, Storage, furniture, cells, monitors, bloodstains, pipes, scanner nodes, searchable-object markers, and the gameplay Clay Stalker are original project programmer art rendered primarily with Raylib primitives.
- The uploaded Ao Oni screenshots were used only as a **visual benchmark for room density, readability, exploration depth, and survival-horror pacing**. Their layouts, sprites, code, and artwork were not copied into the project.

---

## Original / Project-Specific Audio Added in Later Builds

The following sounds were created specifically for this project during AI-assisted development and are not credited to an external commercial game or sound library.

### `assets/monster_chase.wav`
- Original synthesized chase loop created specifically for this project.
- Loaded once at boot and played during monster ALERT/CHASE behaviour.

### `assets/scanner_success.wav`
- Original synthesized scanner-success cue created specifically for this project.

### `assets/scanner_fail.wav`
- Original synthesized scanner-failure cue created specifically for this project.

### `assets/monster_jumpscare.wav`
- Original synthesized horror impact/noise cue created specifically for the capture sequence.
- Designed to create impact without relying on excessively loud audio.

### `assets/distant_metal.wav`
- Original synthesized metallic ambience cue created specifically for this project.

### `assets/power_restore.wav`
- Original synthesized electrical relay / rising-power cue created specifically for Signal Runner: Blackout.
- Used when the correct 20A fuse is successfully installed in Underground Reception.
- Loaded once at startup through the existing shared resource pipeline.

---

# CP4 AI / Movement Justification

## Original implementation

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

The monster also interacts with systems built in earlier checkpoints: room data, collision, shared audio resources, scanner/noise events, player state, checkpoints, and game-state transitions.

## Inspiration

- **Ao Oni** influenced the high-level idea of a threatening roaming/chasing creature, room-to-room survival pressure, and puzzle-horror pacing.
- The Clay Stalker, its state machine, appearance logic, collision/navigation code, audio behaviour, room-transition logic, and visual design are original Signal Runner: Blackout implementations rather than copied Ao Oni code/assets.

---

# CP4+ Facility / Survival-Horror Expansion

## Original implementation

The later CP4-era redesign added or expanded:

- an interconnected underground-facility progression;
- scanner-driven RED / BLUE / YELLOW puzzle logic;
- environmental evidence and multi-room puzzle dependencies;
- three persistent lives, checkpoints, capture/jumpscare flow, respawn protection and Game Over;
- cross-room Clay Stalker pursuit and safe-room disengagement;
- hiding/noise/distraction interactions;
- persistent objective tracking, Investigation Log and a room minimap;
- an explicit ending based on transmitting the completed investigation.

## Inspirations

- **Ao Oni** — survival-horror exploration, room-based pursuit pressure and puzzle pacing.
- Earlier GDD references such as **INSIDE**, **Mark of the Ninja**, and **Portal** informed atmosphere/readability, stealth-state clarity, and the idea of teaching a mechanic before combining it with later puzzles.
- These titles are design references only; no code, maps, sprites, sounds, or other game assets from them are included in this project.

## AI assistance

ChatGPT / OpenAI assisted with implementation planning, Odin code generation/debugging, room/puzzle dependency design, state-machine reasoning, survival-system integration, documentation, and source-level review.

---

# Objective Tracker / Investigation Log / Minimap Expansion

## Original implementation

- `src/objectives.odin` defines story objectives and derives `LOCKED`, `ACTIVE`, and `COMPLETED` states from actual persistent game progress.
- The persistent HUD shows the current objective and contextual Next Step.
- `I` opens the full Investigation Log during normal play.
- The minimap renders current-room structure and officer position from the existing room/entity data while deliberately hiding the monster.
- Explored-room state persists through ordinary transitions/checkpoint respawns.

## Inspiration

The dark, aged, rectangular investigation-log presentation was based on user-supplied UI reference imagery and general survival-horror/quest-log presentation. No reference UI asset was copied directly into the game.

## AI assistance

ChatGPT / OpenAI assisted with objective-state architecture, HUD/log/minimap rendering logic, control integration, and documentation.

---

# Search / Inventory / Contextual Item-Use Expansion

## Original implementation

The project now uses reusable, stable-ID systems instead of one-off room-specific pickup text:

- `src/items.odin` — item definitions, stable `Item_ID` values, persistent inventory state, container contents, item classes and contextual item checks.
- `src/interaction_ui.odin` — dark inventory/search/item-use interfaces, navigation, selection, procedural item icons and modal exit reminders.
- searchable drawers/cabinets/containers can contain multiple inspectable or collectable objects;
- collected objects disappear from the source container and cannot be duplicated by re-entering the room;
- incorrect item choices never consume the item;
- consumables are removed only after successful use;
- reusable keys/badges/tools remain in inventory;
- evidence remains inspectable;
- unlocked/powered states persist through room transitions.

Examples include the Reception desk search, contextual power-panel fuse selection, employee-badge access, Archive key use and Maintenance screwdriver interaction.

## AI assistance

ChatGPT / OpenAI assisted with stable-ID architecture, reusable container definitions, modal UI code, inventory persistence, item-consumption rules, contextual item checks, and debugging/integration with the existing scanner/objective systems.

---

# Police Officer Walking Animation

## Original implementation

The existing one-frame police sprite is preserved. Because the current asset does not contain a complete four-direction walk sheet, the project adds a subtle procedural directional boot/leg cycle in code while the officer is moving. The cycle stops when movement stops and can speed up during pursuit. Player collision dimensions remain unchanged.

## External assets

No new third-party walking sprite sheet was introduced for this feature.

## AI assistance

ChatGPT / OpenAI assisted with the procedural animation approach and integration.

---

# Underground Reception Power / Lighting Expansion

## Original implementation

- Reception starts under dim emergency lighting rather than complete darkness.
- The 20A fuse is a visible world pickup.
- The player must explicitly select/use the fuse at the Reception power panel.
- The fuse is consumed only after successful installation.
- `assets/power_restore.wav` plays during activation.
- The room briefly flickers and then brightens.
- The persistent Reception-power state drives the lighting, objective completion and later access logic, so leaving/re-entering does not reset the puzzle.
- HUD/modal UI is rendered separately so the darkness treatment does not make menus unreadable.

## AI assistance

ChatGPT / OpenAI assisted with the persistent power-state design, lighting-transition implementation, fuse/item integration and documentation.

---

# Progressive Hint / Puzzle-Clarity Expansion

## Original implementation

- `src/hints.odin` stores reusable hint contexts, per-context stuck timers, progress tokens, four-stage hint escalation, contextual text and step-by-step help.
- Hint timers measure time without meaningful forward progress rather than total room time.
- Timers pause during dialogue, inventory/search/item-use UI, Investigation Log, hint overlays, and Clay Stalker ALERT/CHASE/SEARCH behaviour.
- Meaningful progress resets the stuck timer; leaving/re-entering does not erase the context's hint stage.
- `K` toggles automatic hints.
- After the final hint stage, `H` opens step-by-step help.
- Security assistance reads the actual implemented puzzle sequence from `security_expected_mode()` instead of maintaining a separate invented solution.
- The objective HUD uses live puzzle state to show a contextual **Next Step**.

## Security Control clarity improvements

- The Shift Note and Frequency Router have separate persistent read/seen states.
- The router first explains the scanner controls rather than silently consuming input.
- Correct entries report accepted progress.
- Wrong inputs explicitly report that the sequence reset.
- Successful completion visibly shuts down the laser barrier and updates the next objective.
- The router display no longer exposes the full answer before the player investigates the clue.

## AI assistance

ChatGPT / OpenAI assisted with the reusable hint architecture, contextual progression logic, Security onboarding/feedback, modal exit-control improvements, Odin debugging, and documentation.

---

# Documentation / Project Integrity Notes

- Existing credits above are intentionally retained rather than replaced.
- No external source URL, licence, creator, or permission status is invented when it was not supplied or independently verified.
- `README.md`, `docs/implementation-summary.md`, and `docs/testing-summary.md` describe the current controls, architecture and verification status.
- A source-level/static review is not the same as a successful runtime test. The latest build should be verified with `odin check src` and `odin run src` on the project author's macOS Odin/Raylib setup before final submission.

# CP5 — Balancing, Narrative Integration, and Telemetry

## Original implementation for Signal Runner: Blackout

The following CP5 work was implemented specifically for this project and is not copied from another game's source code:

- External **BEFORE / AFTER / ACTIVE** balancing profiles in `data/tuning_before.json`, `data/tuning_after.json`, and `data/tuning_active.json`.
- Centralized tuning validation/clamping in `src/data.odin`.
- Five-stage room difficulty curve and effective monster-pressure helpers in `src/balance.odin`.
- Runtime external-profile reload (`F5`) without editing/recompiling Odin source.
- CP5 observational telemetry in `src/telemetry.odin`, including room/objective time, wrong puzzle attempts, hints, encounters, escapes, captures, chase duration, and checkpoint retries.
- Telemetry CSV snapshot export (`F9`) for reproducible BEFORE/AFTER evidence gathering.
- CP5 HUD status showing active balance profile and current difficulty stage.
- Updated Clay Stalker tuning integration so patrol/chase speed, detection/hearing radius, reaction timing, search timing, cross-room pursuit delay, and respawn pacing continue to come from external data.
- Narrative consolidation for Project Resonance, the four missing civilians, Subject C-17/Elias Voss, Dr. Adrian Vale, the 2:14 AM call, and the concealed communications annex beneath St. Mercy Cemetery.
- Expanded short environmental clues and final ending pages using the existing dialogue/rendering systems.
- CP5 baseline, balancing report, playtest protocol, telemetry documentation, demonstration script, and narrative bible.

No new third-party art, music, sound effects, fonts, or code libraries were introduced specifically for this CP5 balancing/narrative pass. Existing asset attribution entries elsewhere in this file remain applicable.

## Balancing inspiration / course concepts

The CP5 balancing work follows the course concepts of difficulty curves, pacing, external tuning tables, evidence-driven balancing, and retuning without recompilation. The resulting numeric curve and telemetry implementation are original to Signal Runner: Blackout.

Survival-horror games including *Ao Oni* remain high-level design references for pursuit tension, breathing-room pacing, and environmental investigation. They did **not** provide source code, level files, sprites, audio, tuning values, or other implementation assets used by this project.

## AI assistance disclosure — CP5

OpenAI ChatGPT assisted with:

- auditing the existing tuning/data architecture;
- proposing and implementing the CP5 before/after profile structure;
- generating/refining Odin code for centralized balance scaling, configuration validation, profile reload, and telemetry instrumentation;
- identifying a deliberately shaped five-stage candidate difficulty curve;
- calculating configuration-derived chase/player-speed ratios and effective per-stage tuning values;
- reorganizing Project Resonance narrative details into one consistent mystery and drafting short environmental-story text;
- drafting the CP5 baseline assessment, balancing report, demonstration script, playtest protocol, narrative bible, and documentation updates;
- static source review and debugging assistance.

AI assistance did **not** generate or fabricate human playtest results. Any CP5 human evidence must come from actual gameplay runs recorded by the project author/testers. Configuration-derived ratios are identified as engineering evidence rather than human playtest evidence.

## Verification / attribution integrity note

The CP5 code and documentation distinguish source/static verification from actual runtime or human-playtest verification. Do not cite empty telemetry templates as completed playtest evidence. Third-party asset authors, URLs, and licences remain exactly as documented in the pre-existing attribution sections; no unverified external attribution details were invented during this pass.
