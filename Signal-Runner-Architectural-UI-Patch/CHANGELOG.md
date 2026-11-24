# Changelog

## 2026-11-23 — UI Readability / HUD / Environmental Cohesion Pass

### Fixed

- Added reusable width-aware text wrapping for long notes, drawer/search descriptions, inventory/item-use details, objectives, hints, and custom dialogue.
- Moved Current Objective / Next Step and Facility Map into a dedicated non-playfield top HUD band so they no longer hide room corners or the player.
- Adjusted mouse hit-testing for search/inventory/item-use menus after the gameplay viewport was shifted below the new HUD band.

### Improved

- Preserved the original 1100×640 world coordinate space rather than stretching/cropping levels.
- Added room-specific visual-only environmental storytelling to every major facility room while preserving movement lanes, puzzle targets, doors, and collisions.
- Security drawer text from the router instructions/handover card now wraps inside the right-side investigation panel.

### Added

- `src/text_ui.odin` shared UI text/viewport helper.
- `docs/UI_ENVIRONMENT_POLISH.md` implementation breakdown and room-by-room art rationale.
- Additional regression checks for wrapped text, HUD separation, mouse alignment, and corner visibility.

## 2026-11-20 — Investigation / Reliability Quality Pass

### Fixed

- Reworked E-interaction distance to use the nearest point on an object's bounds rather than requiring proximity to one entity coordinate.
- Added deterministic nearest-target selection and `Q` cycling for overlapping interactables.
- Prevented consumed one-time Reception fuse from reappearing after installation.
- Reworked player collision to a lower-body collider with wall sliding, diagonal normalization and small-overlap recovery.
- Walking animation now reflects actual displacement rather than requested input.
- Added lower-body Clay Stalker navigation collision, wall sliding and overlap recovery.

### Improved

- Security scanner procedure is discoverable inside the security desk; sequence clue remains a separate investigation discovery.
- Scanner input feedback and progressive hints now track the player's actual Security puzzle step.
- Clay Stalker gains explicit SUSPICIOUS and INVESTIGATE phases and fairer last-known-position / cross-room behaviour.
- Major rooms receive additional room-specific procedural pixel-art detail and meaningful inspectable props.
- Investigation Log gains structured evidence support and four missing-person case corroboration.

### Added

- Data-driven environmental inspectables throughout major rooms.
- Optional Hazardous Waste Processing chamber off Maintenance.
- BLUE → YELLOW scanner bridge puzzle over conductive runoff.
- Optional Relay 3 incident report confirming Mateo Ruiz's fate.
- `F8` collision/interaction diagnostics.
- New original synthesized `assets/plumbing.wav` and `assets/monitor_flicker.wav` effects.
- Quality-pass implementation and regression-test documentation.

### CP5 preservation

- BEFORE / AFTER / ACTIVE profiles retained.
- `monster_investigate_seconds` externalized with the same value in preserved BEFORE/AFTER profiles.
- Waste Processing uses the existing Rising Danger stage.
- Telemetry now includes Processing room time.

## 2026-11-23 — Architectural Layout & Responsive Window Pass

### UI / window
- Added a fixed virtual canvas rendered through a Raylib render texture.
- Physical window now sizes itself from the current monitor with conservative desktop margins.
- Enabled safe window resizing with aspect-ratio-preserving letterboxing.
- Added a dedicated bottom controls strip outside the gameplay viewport.
- Preserved the dedicated top objective/map HUD outside the gameplay viewport.
- Updated mouse-coordinate conversion so modal UI remains accurate after scaling/resizing.
- Kept the original 1100×640 gameplay coordinate system unchanged.

### Environment
- Re-zoned Reception into a west waiting bay, central processing counter and east records/emergency-services area.
- Reorganized Security into camera, operator, router and access zones; removed loose desk clutter from the hiding/access side.
- Moved Archive record boxes to perimeter storage positions and preserved the central reading/index lane.
- Rebalanced Laboratory support equipment around medical/research work zones.
- Consolidated Maintenance tools/spares into a dedicated work bay and kept the Relay 3 aisle open.
- Moved Storage personal-property dressing beside the property intake zone instead of the main shelving aisle.
- Reviewed Processing, Containment, Final Investigation and Entrance groupings; retained functional clustering where it supported room purpose.

### Preservation
- No level JSON, puzzle solution, objective condition, item progression, AI state, CP5 tuning value or collision rectangle was intentionally changed by this pass.
