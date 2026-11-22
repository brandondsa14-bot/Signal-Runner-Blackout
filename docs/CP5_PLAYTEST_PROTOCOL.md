# CP5 Playtest / Evidence Protocol

## Purpose

Gather real evidence for CP5 without changing game rules between runs.

## Scenario

Use the same route for every run:

**Security Control → Laboratory → Detention → Maintenance → Containment**

Start each run from the same fresh save/session state.

## BEFORE run

From the project root:

```bash
cp data/tuning_before.json data/tuning_active.json
```

Start the game, or press `F5` if already running.

Complete the scenario normally.

Press `F9` at the end.

Copy:

`telemetry/latest_before.csv`

to a uniquely named file, for example:

`telemetry/brandon_before_run1.csv`

Repeat at least once.

## AFTER run

```bash
cp data/tuning_after.json data/tuning_active.json
```

Press `F5` or restart.

Repeat the exact same scenario.

Press `F9` and preserve the result as:

`telemetry/brandon_after_run1.csv`

Repeat at least once.

## Record observations

For each run, record:

- total segment time;
- Security objective time;
- Laboratory objective time;
- Detention/Maintenance time;
- Containment time;
- wrong puzzle submissions;
- hints shown;
- monster encounters;
- captures;
- successful escapes;
- total chase duration;
- checkpoint retries.

Also record one short qualitative observation, such as:

- “I was captured before I understood the Security room.”
- “Containment felt tense but I still had enough reaction time.”
- “The monster disappeared too quickly after losing line of sight.”

Do not alter tuning values between runs within the same profile.

## Evidence table

| Run | Profile | Time | Wrong inputs | Hints | Encounters | Escapes | Captures | Chase time | Retries | Observation |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | BEFORE | | | | | | | | | |
| 2 | BEFORE | | | | | | | | | |
| 3 | AFTER | | | | | | | | | |
| 4 | AFTER | | | | | | | | | |

## Evidence integrity

Only put actual measured values in the table. Configuration-derived ratios in `CP5_BALANCING_REPORT.md` are engineering evidence, not human playtest results.

## Run metadata

Before each run, confirm the active JSON contains labels that describe the test:

```json
"telemetry_scenario": "security_to_containment",
"telemetry_conditions": "manual_keyboard_mac"
```

Change these strings if you test another route or input/platform condition. The CSV also records the CP5 build identifier automatically.
