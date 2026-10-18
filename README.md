# Signal Runner: Blackout

A short top-down murder-mystery / horror adventure built with **Odin + Raylib**.

## Current Status
This repository contains the **CP3 Assets checkpoint build**.

## Build and Run
From the repository root:

```bash
odin run src
```

Run the command from the project root so the game can find `assets/` and `data/`.

## Controls
- `Enter` — advance title/story
- `WASD` / Arrow Keys — move
- `E` — interact
- `1` — toggle Red signal in the visitor entrance
- `Esc` — return to title

## CP3 Resource Pipeline
Resources are loaded once at startup in `src/resources.odin` and shared through the game:
- player texture
- dialogue portrait
- looping ambience music
- pickup/interact sound

Gameplay tuning is read from:

```text
data/tuning.json
```

Level/spawn data is read from:

```text
data/levels/entrance.json
data/levels/underground_hall.json
data/levels/library.json
data/levels/side_room.json
data/levels/dungeon.json
```

## CP3 Live Demo
Open `data/tuning.json` and change:

```json
"player_speed": 155.0
```

to, for example:

```json
"player_speed": 250.0
```

Save the file and run `odin run src` again. The player will move faster without any source-code edit.

## Repository Structure

```text
src/       game source
assets/    runtime textures and audio
data/      tuning and level/spawn data
docs/      GDD, postmortem starter, checkpoint notes
```
