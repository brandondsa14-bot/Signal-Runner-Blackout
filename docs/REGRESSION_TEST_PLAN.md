# Signal Runner: Blackout — Regression Test Plan

Use this checklist on the macOS Odin/raylib development machine after applying the quality-pass patch.

## Build gate

- [ ] `odin check src` exits with no diagnostics.
- [ ] `odin run src` launches the game.
- [ ] Title → story → cemetery → underground can be completed without a crash.

## Interaction reliability

Test at least one note/prop/container/terminal/door from different sides.

- [ ] Reception desk works from left, right and below when visually adjacent.
- [ ] Security desk opens without a pixel-perfect angle.
- [ ] Environmental prop prompt appears only when E will work.
- [ ] When two targets are close, `Q` changes the selected target.
- [ ] One E press triggers only the selected interaction.
- [ ] Empty / previously collected interactions give explicit feedback where intended.
- [ ] Visible Reception fuse can be collected once.
- [ ] After installation/consumption, the Reception fuse does **not** respawn when the room is revisited.

## Movement and collision

- [ ] Walk up/down/left/right across open Reception floor.
- [ ] Hold diagonally; movement speed does not visibly exceed cardinal speed.
- [ ] Slide along long walls while holding into the wall + along it.
- [ ] Walk around desk/cabinet corners without unexplained sticking.
- [ ] Player walking animation stops when collision fully blocks movement.
- [ ] Enter every room transition and verify the spawn is not inside a wall.
- [ ] Toggle `F8` and inspect player lower-body collider / selected interaction target.

## Security puzzle usability

- [ ] First-time player can discover router instructions inside Security Desk.
- [ ] Instructions explain `1/2/3` selection and `E` submission without revealing answer.
- [ ] Separate handover card supplies the four-colour clue.
- [ ] Scanner selection feedback clearly shows current carrier.
- [ ] Correct submissions update accepted count.
- [ ] Wrong submission states that progress reset.
- [ ] Hints correctly distinguish instructions/clue/router/partial sequence state.
- [ ] Laser grid shuts down after success and objective advances.

## Inventory / search / objective / hint regression

- [ ] `Tab` opens Field Inventory.
- [ ] `I` opens Investigation Log in normal play.
- [ ] `I` exits search/item-use modal when that modal is active.
- [ ] Search objects persist after room changes.
- [ ] Wrong contextual item is not consumed.
- [ ] Reusable badge/key/tool remains after successful use.
- [ ] `K` toggles automatic hints.
- [ ] `H` opens detailed help only when available.
- [ ] Current Objective / Next Step changes after meaningful progress.

## Monster AI

- [ ] Patrol does not walk through solid furniture/walls.
- [ ] Detection passes through `SUSPICIOUS` before chase when appropriate.
- [ ] Sound interactions attract/investigate without revealing the player's exact current position.
- [ ] Breaking line of sight moves the monster toward last-known position.
- [ ] SEARCH eventually leads to DISENGAGE if player is not reacquired.
- [ ] Hiding can succeed but does not instantly erase the search.
- [ ] During a chase, moving through a connected unsafe doorway can carry pursuit.
- [ ] Monster enters from the corresponding doorway after the configured delay rather than spawning on the player.
- [ ] No immediate capture occurs during unavoidable room transition/loading time.
- [ ] Capture still triggers jumpscare → one life lost → checkpoint respawn/protection.

## Room / story / evidence progression

- [ ] Reception power puzzle remains completable.
- [ ] Archive mandatory records remain obtainable.
- [ ] Laboratory recording and receiver puzzle remain completable.
- [ ] Detention key/effects sequence remains completable.
- [ ] Maintenance Relay 3 remains completable.
- [ ] Optional Waste Processing hatch opens only after Maintenance is online.
- [ ] Processing BLUE → YELLOW bridge sequence works.
- [ ] Optional Relay 3 incident report can be recovered.
- [ ] Processing evidence appears in Investigation Log.
- [ ] Containment nodes and C-17 log remain completable.
- [ ] Final mirror can be decrypted and case upload can trigger ending.
- [ ] Mandatory path reaches ending even if optional evidence is skipped.
- [ ] Ending text reflects evidence completeness without blocking resolution.

## CP5 preservation

- [ ] `data/tuning_before.json`, `tuning_after.json`, `tuning_active.json` still parse.
- [ ] Copy BEFORE → ACTIVE; press `F5`; HUD reports BEFORE.
- [ ] Copy AFTER → ACTIVE; press `F5`; HUD reports AFTER.
- [ ] No source recompilation is needed between profiles.
- [ ] `F9` writes telemetry and includes `PROCESSING` room time.
- [ ] The new `monster_investigate_seconds` value is externally loaded.

## Known verification boundary

This checklist intentionally remains unchecked in the packaged source. Static source/data validation does **not** prove runtime behaviour. Mark items only after executing them on the actual Odin/raylib build.

# UI / HUD / Environment Polish Regression Addendum — 2026-11-23

## Text readability

- [ ] Open Security Officer Desk and inspect all three entries; no description crosses the right edge of the detail panel.
- [ ] Test at least one long inventory description and one contextual item-use description.
- [ ] Trigger a long custom environmental message and confirm both lines wrap inside the dialogue area.
- [ ] Open step-by-step hint help and confirm long guidance stays inside its panel.
- [ ] Confirm Current Objective and Next Step remain readable when their text is long.

## Dedicated HUD band

- [ ] Window opens with a top investigation band and the original gameplay viewport below it.
- [ ] Current Objective / Next Step remains visible at top-left but never covers the player/world.
- [ ] Facility Map remains visible at top-right but never covers the player/world.
- [ ] Walk to the top-left and top-right playable corners in multiple rooms; player and nearby clues remain visible.
- [ ] Room geometry is not stretched and collision/transition locations feel unchanged.
- [ ] Search/inventory/item-use mouse clicks still select the intended row/item after the viewport shift.

## Environment / navigation

- [ ] Visit Entrance, Reception, Security, Archive, Laboratory, Detention, Maintenance, Processing, Containment, Final Investigation, and Storage.
- [ ] Room-specific visual details are present and visually distinct.
- [ ] No new decoration blocks corridors, doors, puzzle consoles, items, hiding spots, or room-transition triggers.
- [ ] Existing interactables remain visually distinguishable from decorative programmer art.
- [ ] Clay Stalker navigation and player movement are unchanged by the render-only decoration pass.

