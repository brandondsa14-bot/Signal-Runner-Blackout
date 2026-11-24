# Signal Runner: Blackout — Quality-Pass Baseline Assessment

## Build / architecture inspected

- Language/library: Odin + raylib.
- Entry/build model: package in `src/`, launched with `odin run src` on the project Mac.
- Explicit update/render split is retained from CP2.
- Entities/room spawns are data-driven through JSON level files.
- Resources are loaded once through `src/resources.odin`.
- Persistent progression lives on the `Game` struct rather than room-local globals.
- CP5 balancing is loaded from `data/tuning_active.json`, with preserved BEFORE/AFTER profiles and telemetry.

## Systems already working before this pass

- cemetery terminal/key/red-signal/hidden-stair opening;
- connected underground facility progression;
- three scanner frequencies and scanner-based puzzles;
- searchable containers, inventory and contextual item use;
- Reception fuse/power/lighting puzzle;
- objective HUD, Investigation Log, minimap and progressive hints;
- three lives, checkpoints, jumpscare and Game Over;
- Clay Stalker patrol/chase/search/disengage foundation and cross-room entry markers;
- CP5 external tuning reload and telemetry infrastructure;
- existing environmental programmer art and Project Resonance narrative.

## Concrete problems identified from source + user/friend testing

1. **E interaction reliability:** proximity used an entity point rather than the nearest point on the object's bounds, making large interactables angle-sensitive.
2. **Movement/collision:** full sprite collision and no overlap recovery could produce corner snagging; animation reflected requested input even when collision cancelled displacement.
3. **Security onboarding:** the implementation had a valid puzzle, but assumed a new player already understood that scanner colour must be selected before E submission.
4. **AI readability/fairness:** pursuit had good foundations but needed an explicit suspicion/investigation bridge and safer navigation collision.
5. **Environmental density:** rooms had clear identities but some visual areas were sparse and optional interactions were inconsistent.
6. **Case structure:** evidence existed, but the four missing-person cases needed more independent corroboration and a clearer detective-log structure.
7. **Optional investigation:** existing main progression was strong enough to support one carefully scoped side area without adding incompatible movement physics.

## Change strategy

The pass fixes shared systems first, then layers content onto them. Existing rooms, item dependencies, scanner rules, lives, checkpoints and CP5 profiles are preserved. New content is optional unless explicitly integrated into an existing mandatory step. No new third-party dependency is required.

## Runtime limitation of this assessment

The packaging environment can inspect and validate source/data but does not contain the Odin compiler/raylib runtime. Runtime defects must be checked on the project Mac. See `docs/REGRESSION_TEST_PLAN.md`.
