# CP4 — AI Checkpoint Demo Guide

## Requirement 1 — State Machine

Open `src/states.odin` and show `Enemy_State`:

- DORMANT
- PATROL
- ALERT
- CHASE
- SEARCH
- DISENGAGE

Then open `src/ai.odin` and show `update_enemy_ai()`.

Live demo target:

`PATROL -> ALERT -> CHASE -> SEARCH -> DISENGAGE`

The HUD displays the current enemy state in monster-enabled rooms so the transitions are easy to demonstrate.

## Requirement 2 — Enemy Movement

Open `src/ai.odin` and show:

- `enemy_can_see_player()` — line-of-sight/distance detection.
- `choose_navigation_marker()` — chooses authored room markers when direct pursuit is obstructed.
- `enemy_velocity_to_target()` — direct steering when clear, waypoint steering when blocked.
- `enemy_move_with_collision()` — collision-aware movement.
- `enemy_on_room_change()` — preserves an active chase across connected unsafe rooms.

## Requirement 3 — Justification

The formal movement justification is in `ATTRIBUTION.md` under **CP4 AI / Movement Justification**.

Short explanation to say to the TA:

> I use authored waypoint navigation plus steering. My rooms are small handcrafted horror spaces, so markers give reliable routes around furniture while seek steering keeps chases responsive. I did not add A* because a full grid pathfinder is unnecessary for these authored layouts. Cross-room pursuit is handled by the transition system, where the monster follows through a nearby entry marker after a short fair delay.

## Existing systems preserved

The build still preserves:

- entity data stored in collections;
- explicit game states and update/render split;
- load-once resource management;
- tuning/level data in external JSON;
- the cemetery key/red-signal/hidden-grave sequence;
- attribution and AI disclosure.
