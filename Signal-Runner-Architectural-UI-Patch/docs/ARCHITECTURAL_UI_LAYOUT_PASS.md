# Architectural UI / Window / Environment Pass

## Goals

This pass addresses two observed problems from the latest screenshots:

1. environmental set dressing looked clustered or visually unplanned in some rooms;
2. the enlarged HUD/window layout could push the bottom command instructions below the usable desktop area.

The pass deliberately avoids changing puzzle rules, progression, collision data or level coordinates.

## Screen hierarchy

The playing screen is now composed on a fixed virtual canvas with three zones:

- **Top HUD:** Current Objective / Next Step, Field Status and Facility Map.
- **Gameplay:** the existing 1100×640 coordinate space.
- **Bottom Controls:** two compact keyboard-help lines outside the gameplay viewport.

The complete virtual canvas is rendered to a Raylib `RenderTexture2D` and uniformly scaled into the physical OS window. This allows the window to fit smaller desktops without cropping and allows manual resizing without stretching the world.

### Startup sizing

After Raylib creates the window, the game queries the current monitor, reserves conservative horizontal/vertical margins, and chooses the largest scale up to 1.0 that fits the full virtual canvas. The window is positioned near the top of the monitor to leave additional room for bottom docks/taskbars.

### Mouse input

Search, Inventory and contextual item-use interfaces operate in virtual coordinates. Physical mouse coordinates are transformed back through the same letterbox scale and offset before the gameplay HUD offset is applied.

## Room layout principles

Visual-only decorations remain non-colliding. Interactive entities, blockers and door triggers continue to come from the level JSON.

### Reception
- west-wall waiting bay with vertically organized seating and an abandoned bag;
- central processing counter remains the visual hierarchy anchor;
- visitor paperwork stays on the counter rather than scattered across the floor;
- east wall holds records/emergency information and supporting furniture;
- center circulation path remains open.

### Security Control
- north wall remains the camera-monitor bank;
- west side remains the officer workstation and instruction source;
- Frequency Router remains central;
- east side is reserved for access control, laser route and hiding equipment;
- loose paper/trash was removed from the access/hide zone.

### Records Archive
- shelving stays in two clear banks;
- loose archive boxes were moved to perimeter staging positions;
- central index/reading area remains open and legible;
- east-side sealed evidence grouping remains visually distinct.

### Laboratory
- support cart / IV equipment stays with the medical work zone;
- samples and paperwork stay near the research/storage side;
- central receiver puzzle remains visually dominant and unobstructed.

### Detention
- cell mattresses remain inside their corresponding cells;
- plumbing/shower infrastructure remains grouped centrally;
- interrogation furniture remains a separate functional zone;
- the main cell-block circulation lane remains clear.

### Maintenance
- tools, pegboard and spare-parts boxes are consolidated into a west-side work bay;
- Relay 3 remains a distinct east-side electrical zone;
- central circulation between the two remains open.

### Waste Processing
- hazard barrels remain intentionally grouped near filtration infrastructure;
- decontamination and PPE elements remain associated with the access side;
- service-bridge route stays visually clear.

### Containment
- central reinforced chamber remains the hierarchy anchor;
- restraint/observation details stay around the chamber perimeter;
- node puzzle locations and escape routes remain unobstructed.

### Final Investigation
- case-board and evidence equipment remain deliberately grouped as an investigation workspace;
- monitor banks stay symmetrical to support the final digital-evidence objective.

### Storage
- abandoned personal-property bag moved beside the property intake/evidence zone;
- shelving aisles remain uncluttered and readable as navigation space.

## Preservation notes

This pass intentionally does not modify:

- level JSON entity positions;
- collision/blocker rectangles;
- doors or room connections;
- puzzle sequences;
- item/evidence requirements;
- Clay Stalker states or tuning;
- CP5 BEFORE/AFTER values;
- objective conditions;
- lives/checkpoint systems.
