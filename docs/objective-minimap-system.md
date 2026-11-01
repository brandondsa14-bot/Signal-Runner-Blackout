# Investigation Log and Minimap System

## Purpose

The objective system is designed as an in-world police investigation log rather than a generic RPG quest menu. It reads the same persistent puzzle/evidence flags used by gameplay, so objective state cannot drift away from actual progression.

## Controls

- `I` — open/close the Investigation Log.
- `Tab` — open/close the field inventory.
- `Esc` — close whichever modal menu is open.
- While either menu is open, normal movement and enemy simulation pause so reading cannot cause an unavoidable capture.

## Objective states

Every main objective is rendered in one of three states:

- **Active** — red case marker, brighter aged-gold border.
- **Completed** — hand-drawn checkmark and muted green treatment.
- **Locked / undiscovered** — `?` marker with the objective title withheld until the previous investigation lead is complete.

The log currently tracks fourteen main investigation steps from the visitor terminal through transmitting the final case file.

## Current Objective HUD

A compact aged-case panel appears at the upper-left during gameplay. It shows the active main objective and the short room-specific instruction, so the player has immediate direction without opening the full log.

## Minimap

The top-right minimap renders a scaled-down structural view of the current room using existing entity data. Walls, blockers, doors/barriers and the officer are shown; the Clay Stalker is deliberately never shown. Ten small exploration marks indicate which main rooms have already been visited, with the current room highlighted.

This keeps navigation readable without turning the minimap into a monster-radar system or revealing unexplored room interiors.

## Implementation files

- `src/objectives.odin` — objective IDs, titles/descriptions, completion/lock/active rules, progress counts.
- `src/game.odin` — modal state, exploration history and final transmission state.
- `src/data.odin` — marks a room explored whenever its level data is loaded.
- `src/ui.odin` — minimap, current-objective panel, full Investigation Log, visual states.
- `src/puzzles.odin` — sets the final transmitted-case state when the ending is triggered.
