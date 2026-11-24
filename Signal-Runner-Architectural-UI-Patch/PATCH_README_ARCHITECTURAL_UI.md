# Architectural UI / Responsive Window Patch

Merge this patch into the existing GitHub-linked `Signal-Runner-Blackout` project.

## Key changes

- monitor-aware resizable physical window;
- fixed virtual canvas with uniform letterboxed scaling;
- dedicated Top HUD / Gameplay / Bottom Controls hierarchy;
- physical-to-virtual mouse hit testing;
- room set-dressing re-layout based on functional architectural zones;
- no level JSON/collision/progression changes.

## Required local verification

```bash
odin check src
odin run src
```

Then resize the window and complete the relevant checks in `docs/REGRESSION_TEST_PLAN.md`.
