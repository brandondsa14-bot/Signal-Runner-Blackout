# Testing and Verification Summary

## Scope of verification

This redesign was checked as thoroughly as the available build environment allows. The working environment used to prepare this package does **not** contain the Odin compiler or a graphical Raylib runtime, so a real `odin run src` execution could not be performed here. Runtime success is therefore **not claimed** in this document.

The final mandatory runtime verification must be performed on the project author's existing macOS Odin/Raylib setup.

## Source/data checks completed

### 1. Level JSON validation — PASS

All active and retained legacy level files parse as valid JSON:

- `entrance.json`
- `reception.json`
- `security.json`
- `archive.json`
- `laboratory.json`
- `detention.json`
- `maintenance.json`
- `containment.json`
- `final_area.json`
- `storage.json`
- retained CP3/CP4 `library.json`, `side_room.json`, `dungeon.json`, `underground_hall.json`

Every level contains exactly one `PLAYER` spawn.

### 2. Transition target validation — PASS

Every redesigned `DOOR_TRIGGER` target resolves to a valid `Room_ID` and an existing level file.

Static rectangle checks were run against destination coordinates. No room destination point placed the 32×40 player rectangle inside a `WALL`, `BLOCKER`, or `HIDE_SPOT` collision rectangle.

Monster `MONSTER_SPAWN` and `MONSTER_ENTRY` markers in all active danger rooms were also checked using the Clay Stalker's 42×54 collision rectangle. Marker positions were adjusted where necessary so the monster does not initialize inside a wall, large blocker, hiding locker, or door trigger.

### 3. Entity/data mapping — PASS

Every entity kind used by the JSON level files has a corresponding `Entity_Kind` and string mapping in `src/data.odin`.

Legacy CP3/CP4 entity names remain mapped so earlier checkpoint level data remains readable even though the redesigned facility no longer relies on those rooms.

### 4. Asset reference validation — PASS

All asset paths referenced by the Odin source exist in `assets/`, including:

- player sprite and portrait;
- ambience and pickup audio retained from earlier checkpoints;
- chase music;
- scanner success/failure cues;
- distant metallic ambience;
- dedicated monster jumpscare image;
- dedicated jumpscare audio.

### 5. CP3 load-once resource pipeline — PASS by source inspection

All calls to `LoadTexture`, `LoadSound`, and `LoadMusicStream` are located in `src/resources.odin`.

No texture, sound, or music load call is present inside the update/render loops or per-entity code.

### 6. Source structure — PASS by static inspection

All `.odin` files were checked for balanced parentheses, brackets, and braces. Internal bare procedure calls were cross-checked against declared project procedures; no unresolved project-local procedure name was found.

All `game.<field>` and `game.enemy.<field>` references were cross-checked against their corresponding structs; no unknown field reference was found.

### 7. Message/dialogue mapping — PASS

Every message ID used through `show_message(game, ...)` has a rendering case in `src/ui.odin`.

### 8. Progression dependency review — PASS by source inspection

The required progression has a complete dependency chain:

1. Cemetery Key -> hidden staircase.
2. Reception fuse -> facility power.
3. Security sequence -> Security Keycard + signal 1.
4. Archive intake records + BLUE trace -> mandatory evidence + code 7-3-1.
5. Laboratory receiver alignment -> signal 2.
6. Detention YELLOW bypass + code/keycard -> Cell Key -> Cell 04 personal effects + Maintenance Badge.
7. Maintenance screwdriver -> panel -> RED alignment -> signal 3.
8. Containment three-node calibration -> C-17 experiment log.
9. Final area requires all three mandatory evidence exhibits -> BLUE decrypt -> upload -> ending.

Mandatory item state lives in the persistent `Game` struct and is not reset during normal room transitions or checkpoint respawns.

### 9. Survival-system review — PASS by source inspection

- New investigations begin with exactly 3 lives.
- `begin_jumpscare()` changes to the dedicated `JUMPSCARE` state.
- Life deduction happens once in `resolve_player_capture()` after the jumpscare timer completes.
- If lives remain, `respawn_at_checkpoint()` reloads the checkpoint room without resetting inventory/puzzle booleans.
- Respawn protection uses `respawn_protection_seconds`.
- Zero lives enters `GAME_OVER`.

### 10. Monster state-machine review — PASS by source inspection

The Clay Stalker defines and handles:

`DORMANT -> PATROL -> ALERT -> CHASE -> SEARCH -> DISENGAGE`

Reacquisition can return `SEARCH`/`DISENGAGE` to `ALERT`. Cross-room pursuit is carried by `change_room()` and `enemy_on_room_change()` when the player leaves an unsafe room during an active pursuit; the destination doorway position is remembered so the monster re-enters through the corresponding route after its reaction delay. Safe rooms intentionally break pursuit to create puzzle-solving breathing space.

## Runtime tests that still MUST be performed on the Mac

Run from the repository root:

```bash
odin run src
```

Then verify these in order:

1. Title -> story -> cemetery gameplay launches.
2. Surface terminal/key/red barrier/grave/stair sequence still works.
3. Reception, Security, Archive, Laboratory, Detention, Maintenance, Containment, Storage and Final Investigation can be entered in intended directions.
4. Wall/furniture collision feels correct in every room.
5. Security sequence accepts RED -> BLUE -> YELLOW -> BLUE and resets on a wrong input.
6. Archive BLUE pulse reveals code 7-3-1.
7. Laboratory receivers accept BLUE / RED / YELLOW respectively.
8. Detention YELLOW bypass requires the earlier code/keycard state.
9. Cell key and personal-effects progression works and grants Maintenance Badge.
10. Maintenance panel requires the screwdriver and RED scan.
11. Containment nodes accept YELLOW / BLUE / RED and unlock the C-17 log.
12. Final BLUE decrypt requires all three mandatory evidence exhibits and reaches the ending.
13. Investigation Log (`I`) opens/closes, tracks active/completed/locked objectives, and the field inventory (`Tab`) still preserves collected items after room transitions.
14. The Clay Stalker spawns only in intended danger rooms, detects the player, enters ALERT/CHASE, loses line of sight, SEARCHes, then disengages.
15. During an active chase, leaving for another unsafe connected room causes delayed cross-room pursuit.
16. Hiding suppresses detection when entered with enough separation; the noise pipe attracts/investigates.
17. Monster collision triggers the dedicated close-up jumpscare and audio.
18. Exactly one life is removed per capture.
19. Respawn returns to the latest checkpoint with puzzle/evidence state preserved and short protection active.
20. Third capture reaches Game Over; `R` starts a new investigation and Enter returns to the title screen.
21. `V` reduces the intense jumpscare shake/audio treatment.
22. Top-right minimap shows current-room structure/player position, updates visited-room marks, and never reveals the monster.
23. Full mandatory progression is completable from cemetery to the definite ending.

## Known limitation of this package review

Because Odin/Raylib could not be executed in the packaging environment, compiler-specific type errors or runtime behaviours that only appear on macOS cannot be ruled out. If `odin run src` reports an error, use the exact compiler output to patch the relevant file before committing this version to GitHub.


## Objective/minimap static review — PASS by source inspection

- Objective completion is derived directly from persistent puzzle/evidence state rather than duplicated manual quest flags.
- Fourteen main objectives have explicit active/completed/locked states.
- `I` and `Tab` are mutually exclusive modal menus and both pause normal gameplay while open.
- `load_level_file()` marks each loaded room as explored; exploration history is only reset by a new investigation.
- Minimap geometry is generated from the current room's entity collection and deliberately omits enemy data.
- The final objective is marked complete only when the final evidence transmission is actually triggered.
