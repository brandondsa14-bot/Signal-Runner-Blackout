# Signal Runner: Blackout — Game Design Document

## 1. High Concept
**Signal Runner: Blackout** is a short 2D stealth-puzzle game built in **Odin + Raylib**.  
The player is trapped in a research facility during a blackout and must use a handheld signal transmitter to alter the environment, reveal hidden paths, disable hazards, and avoid enemies.

The central idea is that **every useful signal has a cost**: the same action that helps the player can also make them easier to detect or create a new hazard.

---

## 2. Design Pillars
1. **Every advantage creates a new risk.**
2. **Darkness is a gameplay mechanic, not just a visual effect.**
3. **The player solves problems through signal choice rather than combat.**
4. **Information should be valuable and sometimes dangerous to obtain.**
5. **Levels should be short, readable, and built around one clear decision.**

---

## 3. Core Loop
**Observe the room → choose a signal → reveal or change the environment → deal with the consequence → move toward the exit → repeat.**

---

## 4. Mechanics

### Primary Mechanic — Tune
The player switches between signal frequencies to change how the level behaves.

### Secondary Mechanics
- **Move** through the level.
- **Illuminate** nearby space in darkness.
- **Hide** by reducing visibility and signal output.
- **Interact** with doors, terminals, and switches.

### Tertiary Mechanics
- Restart the current room quickly after failure.
- Use simple environmental clues to remember hidden paths.
- Time movement around enemy patrols and hazards.

---

## 5. Goal, Opposition, Decisions, and Rules

### Goal
Reach the transmission terminal at the end of each sector and ultimately restore the facility's emergency transmitter.

### Opposition
- Darkness limits what the player can see.
- Security enemies patrol important areas.
- Lasers and powered hazards block paths.
- Some useful signals also reveal the player's position.

### Decisions
The player must decide:
- Which signal to use.
- When to reveal hidden paths.
- When it is safer to stay dark.
- Whether disabling one hazard is worth activating another risk.
- When to move past an enemy patrol.

### Rules
- Only **one signal frequency** may be active at a time.
- The player can always move, but visibility is limited in darkness.
- Signal effects are consistent throughout the game.
- Enemy detection depends on light, distance, and/or active signal.
- Contact with an enemy or lethal hazard restarts the current room.
- Reaching the room exit completes the room.

---

## 6. Signal System

### Red — Reveal
**Benefit**
- Reveals hidden platforms and environmental markings.

**Cost**
- Makes the player easier for Watcher enemies to detect.

### Blue — Disable
**Benefit**
- Temporarily disables lasers and powered barriers.

**Cost**
- Temporarily reduces the player's personal light radius.

### Yellow — Jam
**Benefit**
- Disrupts Signal Hunter enemies and slows their detection.

**Cost**
- Hidden navigation markers disappear while Yellow is active.

> For the 2–3 week build, the game will use **three signals only**. A fourth signal is outside the initial scope.

---

## 7. Darkness System
- Most rooms begin in low visibility.
- The player has a small personal light radius.
- Red temporarily reveals hidden geometry and clues.
- Blue reduces the light radius while active.
- Enemies can react differently to visible light and active signals.
- Darkness should create uncertainty without making the level unreadable.

---

## 8. Enemies

### Watcher
A simple patrol enemy.

States:
- Patrol
- Notice
- Chase
- Return

Watcher detects the player more easily while **Red** is active.

### Signal Hunter
A second enemy type used in later rooms.

States:
- Patrol
- Detect Signal
- Investigate
- Return

**Yellow** disrupts or slows its detection.

---

## 9. Player Experience
The intended experience is:
- **Tension** — the player is safer in darkness but knows less.
- **Discovery** — signals reveal how each room works.
- **Problem solving** — progress comes from choosing the right signal at the right time.
- **Mastery** — later rooms combine previously learned rules.

Primary pleasure targets:
- **Challenge**
- **Discovery**

---

## 10. Target Player
Primary Bartle type:
- **Explorer** — learns how signals change the environment and discovers safe routes.

Secondary:
- **Achiever** — completes rooms efficiently and masters the signal rules.

The game is not designed around multiplayer Socializer or Killer motivations.

---

## 11. Inspirations

### Game Inspirations
- **INSIDE** — atmosphere, readable environmental hazards, minimal UI.
- **Mark of the Ninja** — readable stealth states and clear enemy awareness.
- **Portal** — introducing one rule at a time, then combining rules later.

These are references for structure and readability, not games to copy.

### Non-Game Inspirations
- Radio frequency scanning.
- Emergency lighting during a power outage.
- Sonar/radar systems where gaining information can also reveal your position.

---

## 12. Genre, Platform, and Tools
- **Genre:** 2D stealth-puzzle / action-puzzle
- **Platform:** macOS desktop
- **Language:** Odin
- **Library:** Raylib
- **Version Control:** Git + GitHub
- **Target Controls:** Keyboard

Suggested controls:
- `WASD` / Arrow Keys — movement
- `1` — Red signal
- `2` — Blue signal
- `3` — Yellow signal
- `F` — light toggle, if retained after prototype testing
- `R` — restart room
- `Esc` — pause

---

## 13. Progression

### Room 1 — Darkness
Learn movement, personal light radius, and exit condition.

### Room 2 — Red
Learn that Red reveals hidden platforms.

### Room 3 — Blue
Learn to disable a laser barrier while dealing with reduced visibility.

### Room 4 — Watcher
Use Red carefully while avoiding an enemy patrol.

### Room 5 — Final Sector
Combine Red, Blue, Yellow, darkness, one or both enemy types, and hazards in a final multi-step room.

Target playtime: **8–12 minutes**.

---

## 14. Win / Lose Conditions

### Win
Complete the final sector and activate the emergency transmitter.

### Lose
- Touch an enemy.
- Touch a lethal hazard.
- Fall outside the playable area.

Failure restarts the current room quickly.

---

## 15. Scope

### MUST-HAVE — required for the finished game
1. Player movement and collision.
2. Darkness / limited visibility.
3. Red, Blue, and Yellow signal switching.
4. At least one clear environmental effect for each signal.
5. Five short rooms.
6. Watcher enemy with a simple state machine.
7. Hazards such as lasers.
8. Room restart.
9. Title screen.
10. Win screen / final objective.
11. Basic sound effects.
12. README and attribution documentation.

### SHOULD-HAVE — add after all must-haves are stable
1. Signal Hunter enemy.
2. Pause screen.
3. Simple particles / signal pulse effects.
4. Room transition effects.
5. External tuning data for speeds, detection ranges, and signal durations.

---

## CUT LINE
Everything below this line is optional and will be removed first if time is limited.

### NICE-TO-HAVE
1. Fourth signal frequency.
2. Battery / signal energy meter.
3. Multiple paths through rooms.
4. Animated background machinery.
5. Additional enemy types.
6. Ranking / time score system.
7. Controller support.

---

## 16. Technical Breakdown

### Game States
- Title
- Playing
- Paused
- Win

### Core Data
- Player
- Enemies
- Hazards
- Doors / barriers
- Room data
- Active signal
- Game state

### Main Systems
- Input
- Update
- Rendering
- Collision
- Signal effects
- Enemy AI
- Room loading
- UI / game state

---

## 17. 2–3 Week Build Plan

### Week 1 — Core
- Project structure
- Window and game loop
- Player movement
- Collision
- Darkness rendering
- Signal switching
- First two rooms

### Week 2 — Gameplay
- Red / Blue / Yellow effects
- Watcher AI
- Hazards
- Remaining rooms
- Win / lose logic

### Week 3 — Finish and Polish
- Signal Hunter if time allows
- Sound
- UI
- Balance
- Bug fixes
- Playtesting
- README / attribution updates
- Final build verification
