# Scanner HUD Compatibility Fix

This patch replaces only `src/ui.odin`.

It is built against the existing 160px top-HUD version of Signal Runner and does not require the unmerged architectural virtual-canvas constants (`VIRTUAL_WIDTH` or `BOTTOM_CONTROLS_HEIGHT`).

Signal controls are moved into the top center HUD:
- Surface: `1 RED SIGNAL`
- Underground: `1 R`, `2 B`, `3 Y`
- `F PULSE`
- Security sequence progress or facility-link progress

After merging, run:

```bash
odin check src
odin run src
```
