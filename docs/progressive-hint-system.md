# Progressive Hint System and Interaction Exit Update

## Interaction exit behavior

Searchable containers and contextual item-use menus now display a visible `I — EXIT` reminder in the upper-right corner.

- `E` / Enter / click: inspect, pick up, or try the selected item.
- `I` or `Esc`: leave the active search/item-use modal.
- Outside a modal, `I` retains its normal Investigation Log behavior.

This prevents the player from feeling trapped in a drawer/cabinet interaction while preserving deliberate item pickup.

## Reception fuse

The 20A ceramic fuse is once again a visible `FUSE_ITEM` world pickup in Underground Reception. It is no longer stored inside the searchable supply cabinet.

The supply cabinet still contains environmental investigation material. The world fuse is added to the inventory with `E`, and the power panel continues to use the contextual item selector. The fuse is consumed only after successful installation.

## Security Control clarity

The puzzle itself is preserved.

Implemented sequence logic remains defined by `security_expected_mode()` in `src/puzzles.odin`.

The room now tracks:

- `security_intro_seen`
- `security_clue_read`
- `security_router_seen`
- `security_sequence_step`
- `security_unlocked`

On first entry the officer comments that the active laser system appears to be controlled by the Frequency Router and that a nearby clue may explain it.

The Shift Note is the clue source. The router display no longer prints the complete answer directly.

First interaction with the router explains:

- scanner colours are RED / BLUE / YELLOW;
- `1 / 2 / 3` selects a colour;
- `E` at the router submits the selected frequency.

Subsequent router interactions submit the frequency.

Accepted inputs display `1/4`, `2/4`, or `3/4`. An incorrect frequency explicitly states that the router reset to `0/4`. Completion animates the laser grid shutting down and identifies the newly opened laboratory route.

## Progressive hints

`src/hints.odin` implements one reusable system for the facility.

Each room/puzzle context stores:

- elapsed time without forward progress;
- the highest meaningful progress token achieved;
- the current hint stage.

Automatic hints are paused during:

- dialogue;
- container search;
- item selection;
- inventory;
- Investigation Log;
- step-by-step assistance;
- Clay Stalker ALERT / CHASE / SEARCH states.

Forward progress resets the timer. Backward state, such as a failed Security sequence resetting from partial progress to zero, does not count as meaningful progress.

Hint stages:

1. subtle investigative thought after approximately 60 seconds;
2. more specific relationship between clue/mechanic after another interval;
3. direct control-level guidance after another interval;
4. persistent `H` step-by-step assistance availability.

`K` toggles automatic hints.

Security step-by-step help reads its colour sequence from the actual `security_expected_mode()` function rather than maintaining a second hardcoded solution.

## Objective integration

The persistent Current Objective HUD now includes **NEXT STEP**, derived from live puzzle state.

Examples include:

- read the Security Shift Note;
- inspect the Frequency Router;
- continue the accepted sequence;
- use the Reception fuse;
- scan the Archive coating;
- play the Laboratory recording;
- open Maintenance Relay Panel 3;
- collect missing final evidence.

This is intended to explain the next action without immediately revealing puzzle solutions.
