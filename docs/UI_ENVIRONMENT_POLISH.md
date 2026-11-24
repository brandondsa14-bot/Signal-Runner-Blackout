# UI Readability, HUD Separation, and Environmental Cohesion Pass

## Goal

This pass addresses three usability/polish priorities without changing the authored gameplay rules:

1. Long instructions and dialogue must stay inside their UI containers.
2. Current Objective / Next Step and Facility Map must remain visible without covering the playable world.
3. Rooms should communicate purpose and story through intentional visual detail rather than random clutter.

## UI text wrapping

A shared helper in `src/text_ui.odin` measures candidate text with Raylib and wraps at whitespace before the configured panel width. Explicit newlines are respected. The helper is reused instead of maintaining hand-split text for each individual note.

Integrated surfaces include:

- searchable-container introductions and detail descriptions;
- Field Inventory descriptions and use notes;
- contextual item-use panels;
- Current Objective and contextual Next Step;
- Investigation Log current-objective description;
- progressive hint notifications and step-by-step help;
- custom environmental/investigation dialogue;
- long puzzle/system feedback where overflow was likely.

The Security Officer Desk is the primary regression example because its Frequency Router instructions, Night-shift handover card, and sticky-note text previously ran through the right edge of the detail panel.

## HUD / gameplay viewport separation

The original room coordinate system remains `1100×640`. A `160 px` top HUD band is added to the application window, making the PLAYING window `1100×800`.

During PLAYING:

- screen-space objective/map UI renders first in the dedicated top band;
- the original 1100×640 game is rendered below it through a `Camera2D` offset;
- world entities, collisions, AI navigation points, room transitions, and puzzle locations keep their previous coordinates;
- inventory/search/item-use mouse positions are translated back by the HUD offset before hit-testing.

This avoids both undesirable alternatives: covering the playfield with persistent panels or rescaling every authored level.

## Environmental design principles

All additions in this pass are render-only programmer art. They do not create collision or interaction. Existing data-driven interactables remain the only gameplay-significant objects. This ensures visual polish cannot block a corridor, cover a trigger, or change puzzle logic.

### Cemetery / Visitor Gate

- faded visitor notice;
- abandoned maintenance/trash detail;
- restrained floor scuffing around the work area.

Purpose: establish that the public-facing entrance once functioned as a controlled service checkpoint rather than an empty room beside a graveyard.

### Underground Reception

- abandoned personal bag;
- evacuation/facility notice treatment;
- reception refuse/vent details;
- subtle wear/scuffs around traffic paths.

Purpose: sell a visitor-processing lobby that was evacuated abruptly while keeping the fuse, power panel, desk, and Security route visually readable.

### Security Control

- wall/network cable runs;
- access/operations notice;
- operator-area refuse/wear.

Purpose: distinguish the room as a staffed control station and support the router/security puzzle fiction without placing clutter around the console or laser route.

### Records Archive

- labelled record boxes;
- reading/storage furniture;
- ladder/records-access cues;
- restrained floor wear.

Purpose: communicate active archival work and recent document movement rather than using generic office furniture.

### Medical Laboratory

- medical cart;
- biohazard/storage treatment;
- ventilation hardware;
- clinical wear.

Purpose: reinforce experimentation/medical use while leaving receivers and evidence surfaces prominent.

### Detention Block

- worn cell mattresses;
- exposed pipe infrastructure;
- institutional ventilation;
- corridor wear.

Purpose: make the cells feel used and neglected without adding new solid geometry inside escape/navigation paths.

### Maintenance Tunnels

- tool pegboard;
- spare electrical/fuse boxes;
- cable runs;
- maintenance-floor wear.

Purpose: make Relay 3 feel like part of a credible service area and visually support the screwdriver/panel puzzle.

### Hazardous Waste Processing

- hazard barrels;
- decontamination signage;
- industrial ventilation.

Purpose: communicate chemical/runoff handling and support the optional BLUE→YELLOW bridge puzzle.

### Containment

- broken-glass shards;
- bio-lock warning signage;
- damaged cable infrastructure.

Purpose: communicate the aftermath of a containment failure while preserving node visibility and chase lanes.

### Final Investigation

- evidence/archive boxes;
- case-material clutter;
- cable infrastructure.

Purpose: visually converge the investigation threads without replacing the final evidence mirror/board interactions.

### Supply Storage

- sealed/lot-labelled boxes;
- abandoned bag;
- ventilation and floor wear.

Purpose: distinguish storage as an evidence/property overflow space instead of another generic room.

## Preserved systems

This pass does not intentionally change:

- CP5 BEFORE/AFTER tuning values or difficulty stages;
- scanner frequencies/puzzle solutions;
- inventory persistence or item consumption;
- evidence/objective progression;
- Clay Stalker states/detection/path logic;
- lives, jumpscare, respawn, or checkpoints;
- room connectivity;
- collision geometry;
- level JSON content.

## Verification boundary

Static validation checks JSON parsing, Odin source delimiter balance, duplicate procedure declarations, known `#partial` entity switches, referenced assets, and package integrity. The packaged environment does not contain the Odin compiler, so final compile/runtime verification must be performed on the project author's Odin/raylib Mac build with `odin check src` and `odin run src`.
