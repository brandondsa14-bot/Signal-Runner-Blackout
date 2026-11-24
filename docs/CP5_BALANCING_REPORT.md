# CP5 Balancing Report

## 1. CP5 target

The course checkpoint requires a deliberate difficulty shape, before/after tuning values, evidence behind the change, and continued data-driven retuning without recompilation.

This implementation keeps the same rooms, objectives, puzzles, inventory rules, and enemy state machine in both profiles. Only external tuning values differ.

## 2. Original balancing problem

The pre-CP5 build used external tuning correctly, but monster pressure was numerically flat. A chase used `142` speed, `250` detection radius, `0.62 s` alert time, and `4.2 s` search time wherever the monster was active.

The player speed was `155`, so the baseline monster chase speed was **91.6% of player walking speed in every stage**. That gives no explicit numeric escalation between the first threat room and Containment.

That is the primary CP5 problem being fixed.

## 3. Before-and-after profiles

Files:

- `data/tuning_before.json` — exact pre-CP5 numeric values.
- `data/tuning_after.json` — deliberately shaped candidate balance.
- `data/tuning_active.json` — profile currently loaded by the game.
- `data/tuning.json` — retained as the legacy CP3 tuning snapshot.

Important base-value changes:

| Parameter | BEFORE | AFTER | Reason |
|---|---:|---:|---|
| Monster patrol speed | 72 | 70 | Slightly lowers base roaming pressure; stage scaling now supplies the escalation. |
| Monster chase speed | 142 | 138 | Creates headroom for a curve instead of using one nearly-player-speed value everywhere. |
| Detection radius | 250 | 235 | Reduces early accidental detection; later stage scaling restores/exceeds baseline pressure. |
| Hearing radius | 360 | 340 | Makes incidental scanner/noise attraction less global in earlier rooms. |
| Alert delay | 0.62 | 0.78 | Adds a clearer reaction window before the player has learned the pursuit rules. |
| Lost-player delay | 1.35 | 1.75 | Lets later pursuits retain the player's last known position more convincingly. |
| Search duration | 4.2 | 4.8 | Supports stronger late-game search without forcing the same duration in early rooms. |
| Respawn minimum | 5.0 | 6.5 | Reduces encounter clustering in early/mid rooms; stage scaling shortens it toward the peak. |
| Respawn maximum | 10.0 | 11.5 | Creates more breathing room before the curve ramps. |
| Cross-room pursuit delay | 0.85 | 1.05 | Provides a fairer head start early; stage scaling shortens it in high-pressure rooms. |
| Disengage duration | 2.2 | 2.5 | Makes successful escapes readable instead of instantly despawning the threat. |
| Respawn protection | 2.6 | 3.2 | Reduces repeated capture immediately after checkpoint recovery. |
| Hint interval | 60.0 | 55.0 | Slightly earlier assistance for multi-step investigation puzzles while keeping four-stage escalation. |

Values not listed above were intentionally left unchanged unless needed by the new stage curve.

## 4. Candidate five-stage difficulty curve

No separate class-drawn curve file was present in the supplied project, so this is clearly treated as the **candidate CP5 curve** to compare against the curve drawn in class. The AFTER profile applies one external stage multiplier to monster pressure. The multiplier is selected from the current room by centralized code in `src/balance.odin`.

| Stage | Rooms | Scale | Effective chase speed | Effective detection radius | Effective alert delay | Effective search | Cross-room delay |
|---|---|---:|---:|---:|---:|---:|---:|
| Stage 1 — Introduction | Entrance + Reception | 0.75 | 103.5 | 176.2 | 1.04s | 3.60s | 1.40s |
| Stage 2 — Investigation | Security + Archive + Laboratory | 0.88 | 121.4 | 206.8 | 0.89s | 4.22s | 1.19s |
| Stage 3 — Rising Danger | Detention + Maintenance + Storage | 1.00 | 138.0 | 235.0 | 0.78s | 4.80s | 1.05s |
| Stage 4 — Peak Tension | Containment | 1.12 | 154.6 | 263.2 | 0.70s | 5.38s | 0.94s |
| Stage 5 — Resolution | Final Investigation | 1.06 | 146.3 | 249.1 | 0.74s | 5.09s | 0.99s |

### Shape

**Introduction → Investigation → Rising Danger → Peak Tension → Resolution**

The curve rises gradually, peaks in Containment, then eases slightly for the final evidence-resolution room instead of creating a second arbitrary spike.

The monster is deliberately disabled in designated breathing rooms such as Reception/Archive/Storage; those safe spaces are part of the pacing curve rather than an absence of balancing.

## 5. Quantitative configuration evidence

These observations come directly from the actual tuning values and are not human playtest claims:

- BEFORE chase/player speed ratio: `142 / 155 = 0.916` in every threat stage.
- AFTER ratio:
  - Introduction scale: `103.5 / 155 = 0.668`
  - Investigation: `121.44 / 155 = 0.783`
  - Rising Danger: `138 / 155 = 0.890`
  - Peak Tension: `154.56 / 155 = 0.997`
  - Resolution: `146.28 / 155 = 0.944`
- BEFORE detection radius is `250` everywhere.
- AFTER effective detection rises from `176.25` to `263.2` at the peak.
- BEFORE alert time is `0.62 s` everywhere.
- AFTER effective alert time tightens from `1.04 s` in the intro curve to about `0.70 s` at peak tension.
- BEFORE cross-room delay is `0.85 s` everywhere.
- AFTER it changes from `1.40 s` early to `0.94 s` at peak tension.

This is evidence that the AFTER profile has an intentional mathematical shape rather than a single global difficulty change.

## 6. Runtime telemetry

`src/telemetry.odin` records observational metrics without changing game rules:

- total active gameplay time;
- time spent in every room;
- time spent on each active objective;
- wrong puzzle submissions;
- progressive hints shown;
- monster encounters;
- successful chase escapes;
- monster captures;
- total chase duration;
- checkpoint retries.

Press **F9** to save a snapshot.

Output:

- BEFORE → `telemetry/latest_before.csv`
- AFTER → `telemetry/latest_after.csv`

The CSV records the profile name and current balance stage.

### Important evidence integrity note

No human playtest results have been fabricated for this report.

The telemetry system is implemented so real BEFORE/AFTER runs can be gathered before the CP5 lab. The included `CP5_PLAYTEST_PROTOCOL.md` explains a reproducible comparison.

## 7. Retuning without recompilation

The game loads:

`data/tuning_active.json`

To demonstrate BEFORE:

```bash
cp data/tuning_before.json data/tuning_active.json
```

Then either restart the game or press **F5** while playing.

To demonstrate AFTER:

```bash
cp data/tuning_after.json data/tuning_active.json
```

Press **F5** again.

The HUD displays the loaded profile and current difficulty stage. The console also logs the profile name.

No Odin source file needs to be edited or recompiled to retune the game.

## 8. Configuration safety

`load_tuning` now:

- begins from known-safe pre-CP5 defaults;
- falls back safely if the JSON cannot be read;
- reports malformed JSON;
- clamps gameplay values to conservative ranges;
- enforces max/min relationships such as respawn maximum >= respawn minimum.

This prevents a typo such as a negative chase speed or extreme volume from silently producing an unusable build.

## 9. Evidence still required before the lab

For the strongest possible evidence marks, perform at least:

- 2 representative BEFORE runs;
- 2 representative AFTER runs;

using the same scenario and player.

Recommended scenario:

**Security Control → Laboratory → Detention → Maintenance → Containment**

Compare:

- completion time;
- captures;
- chase duration;
- wrong puzzle submissions;
- hints used;
- checkpoint retries.

Do not rewrite the report with invented numbers. Paste actual CSV observations into the evidence table after playing.

## 10. CP5 demonstration procedure

1. Show `data/tuning_before.json` and `data/tuning_after.json`.
2. Point out the same content/rules but different external values.
3. Show the five stage multipliers.
4. Copy BEFORE to `tuning_active.json`.
5. Press `F5`.
6. Point to `CP5 BALANCE: BEFORE` on the HUD.
7. Demonstrate a threat room.
8. Copy AFTER to `tuning_active.json`.
9. Press `F5`.
10. Point to the AFTER profile and explain the intended stage curve.
11. Show `telemetry/latest_before.csv` and `latest_after.csv` from real runs.
12. Explain one measured change and why the AFTER value addresses it.

## 11. Limitations

The AFTER profile is a deliberate candidate balance supported by configuration analysis. Final tuning should be updated with actual human telemetry before presentation. CP6 is still the appropriate point for broader multi-tester playtest conclusions.

## 12. Telemetry run metadata

Each CSV snapshot also records:

- build version (`cp5-2026-11-20`);
- active profile;
- current balance stage;
- external scenario label (`telemetry_scenario`);
- external test-condition label (`telemetry_conditions`).

The supplied BEFORE/AFTER profiles use `security_to_containment` and `manual_keyboard_mac` for the recommended CP5 comparison. These labels can be changed in the active JSON before a run without recompiling.

---

## Post-CP5 quality-pass compatibility note — Nov 20

The reliability/AI quality pass introduces one additional externally loaded timing parameter:

| Parameter | BEFORE | AFTER | Reason |
|---|---:|---:|---|
| `monster_investigate_seconds` | 2.6 s | 2.6 s | Supports the new SUSPICIOUS/INVESTIGATE behaviour without fabricating a new CP5 before/after difference. |

Because the value is identical in the preserved comparison profiles, it does not alter the historical BEFORE-vs-AFTER balance claim. Room-stage multipliers still shape effective pressure.

The optional Hazardous Waste Processing room is assigned to **Rising Danger** and uses the same external monster tuning helpers as other dangerous rooms. Telemetry now records Processing-room time, but optional evidence from that room is not required for the representative mandatory CP5 route.

No human-playtest result is added by this quality pass. Any later change to the new investigation timing or Processing pressure should be entered in this report only after actual observed evidence is collected.
