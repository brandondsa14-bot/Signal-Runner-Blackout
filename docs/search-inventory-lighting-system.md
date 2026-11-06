# Interactive Search, Inventory, Item Use, Walking Animation and Reception Lighting

## Searchable containers

`SEARCHABLE_CONTAINER` is a reusable entity kind loaded from the same external JSON level pipeline as the rest of the facility. A container carries a stable `Container_ID`; its contents are defined as stable `Search_Object_ID` values rather than display-name comparisons.

Current examples:

- Reception desk drawer — employee badge, Records Archive key, torn employee photograph, empty ammunition box.
- Reception electrical cabinet — 20A ceramic fuse, electrical memo, dead flashlight.
- Archive filing cabinet — environmental records and evidence-routing material.
- Maintenance tool locker — damaged facility tools and utility clues.
- Storage personal-effects locker — optional environmental evidence.

Collectable objects are marked in the persistent `search_object_taken` table. Inspect-only objects remain in the container. Reopening the room does not recreate collected contents because level loading does not reset this table.

## Inventory

`Item_ID` is the stable gameplay identifier. Display names are never used as keys.

Item classes:

- `CONSUMABLE` — removed only after a successful compatible use.
- `REUSABLE` — remains after use.
- `EVIDENCE` — remains available for case inspection.
- `TOOL` — reusable physical puzzle tool.

The inventory UI supports keyboard and mouse-wheel navigation and left-click selection. `E`/Enter equips the highlighted item. The selected item is also shown on the normal HUD.

## Contextual item use

Item-driven interactions open a dedicated selector rather than silently choosing an item.

Implemented examples:

1. Underground Reception power panel → requires `REPLACEMENT_FUSE`; fuse is consumed on success only.
2. Security Control access → requires reusable `EMPLOYEE_BADGE` after Reception power is restored.
3. Records Archive physical lock → requires reusable `ARCHIVE_KEY` after Security authorization is online.
4. Maintenance Relay Panel 3 cover → requires reusable `SCREWDRIVER`.

Any incorrect item leaves the target locked and the item untouched.

## Reception lighting

Before power:

- stronger world-only darkness overlay;
- smaller readable light radius around the officer;
- dim red emergency fixtures;
- power panel and searchable furniture remain visible enough to solve the puzzle.

After a correct fuse is installed:

- `reception_power` is set persistently;
- original synthesized `power_restore.wav` is played;
- a short controlled flicker occurs;
- `reception_power_transition` gradually reduces the blackout overlay;
- ceiling fixtures brighten;
- Reception uses a larger visibility radius;
- objective completion derives automatically from `reception_power`.

HUD, menus and dialogue are drawn after the room lighting pass and therefore remain readable.

## Player walk animation

The existing officer art is a single 32×40 texture. Rather than replacing the officer's visual identity, the game overlays a subtle procedural two-boot cycle based on movement and facing direction. The cycle:

- works for up/down/left/right;
- advances only while moving;
- stops immediately at idle;
- runs slightly faster during an active monster chase;
- does not alter the player's collision rectangle.

## Controls

- `E` — interact / confirm search or item use.
- `Tab` — open/close field inventory.
- `I` — Investigation Log.
- Mouse wheel / arrows / WASD — navigate applicable modal lists.
- Left click — select inventory/item-use entries.
- `Esc` — close active modal.
