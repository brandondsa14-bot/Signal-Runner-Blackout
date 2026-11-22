# CP5 — 2–3 Minute TA Demo Script

## 0:00–0:30 — Show that tuning is external

Open:

- `data/tuning_before.json`
- `data/tuning_after.json`
- `data/tuning_active.json`

Say:

> “My CP3 data pipeline is still intact. CP5 does not tune hardcoded Odin constants. I preserved the exact pre-CP5 values as BEFORE and created a separate AFTER profile.”

Point out chase speed, detection radius, alert delay, and the five difficulty-stage multipliers.

## 0:30–1:10 — Explain the curve

Say:

> “The original tuning was flat: the same monster pressure applied throughout the facility. The AFTER profile deliberately ramps from Introduction to Investigation to Rising Danger, peaks in Containment, and eases slightly during the Resolution.”

Show:

- Intro `0.75`
- Investigation `0.88`
- Rising `1.00`
- Peak `1.12`
- Resolution `1.06`

Then say:

> “The player speed stays 155. The effective chase speed rises from about 121 in Investigation to about 155 in Containment, so late-game pursuit approaches player speed without making early encounters immediately punishing.”

## 1:10–1:45 — Demonstrate no recompilation

In Terminal:

```bash
cp data/tuning_before.json data/tuning_active.json
```

Press `F5` in the running game.

Show the HUD/profile label.

Then:

```bash
cp data/tuning_after.json data/tuning_active.json
```

Press `F5` again.

Say:

> “Both profiles load from external JSON. I can retune or switch the entire balance profile without recompiling.”

## 1:45–2:25 — Show evidence

Open a real CSV generated with `F9`.

Say:

> “I added telemetry that records objective/room time, wrong puzzle attempts, hints, monster encounters, escapes, captures, chase duration and checkpoint retries. It does not change game behaviour.”

Show BEFORE and AFTER results from the same scenario.

Explain one actual measured difference from your completed playtest.

## 2:25–2:50 — Close with justification

Say:

> “I didn’t just make the game easier. The goal was a readable curve: teach safely, increase pursuit pressure as the player gains mastery, peak during Containment, then let the final investigation focus on resolution. All of those values remain external and can still be retuned.”

