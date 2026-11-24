# Signal Runner: Blackout — Scanner HUD Visibility Fix

This patch fixes the regression where the signal/frequency controls disappeared below the visible game window after the responsive architectural UI pass.

## What changed
- Surface/Cemetery: `1 RED SIGNAL` is now visible in the persistent top HUD.
- Underground: `1 R`, `2 B`, and `3 Y` selectors now live in the persistent top HUD.
- `F PULSE` is shown directly below the underground selectors.
- Security shows compact four-step sequence progress beside the controls.
- Other underground rooms show the three facility-link indicators.
- The old gameplay-bottom scanner strip is no longer required for visibility.

## Modified file
- `src/ui.odin`

After merging, run:

```bash
odin check src
odin run src
```
