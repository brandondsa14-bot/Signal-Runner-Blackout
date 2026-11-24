package main

import rl "vendor:raylib"

Enemy_AI :: struct {
    state:              Enemy_State,
    active:             bool,
    room:               Room_ID,
    position:           rl.Vector2,
    velocity:           rl.Vector2,
    patrol_target:      rl.Vector2,
    last_seen:          rl.Vector2,
    state_timer:        f32,
    respawn_timer:      f32,
    lose_timer:         f32,
    cross_room_pending: bool,
    cross_room_timer:   f32,
    cross_room_entry:   rl.Vector2,
    forced_event:       bool,
}

room_allows_monster :: proc(room: Room_ID) -> bool {
    // Reception/archive/storage are deliberate breathing rooms for puzzle solving.
    return room == .SECURITY || room == .LABORATORY || room == .DETENTION ||
           room == .MAINTENANCE || room == .PROCESSING || room == .CONTAINMENT
}

random_respawn_delay :: proc(game: ^Game) -> f32 {
    lo := i32(monster_respawn_min_for_room(game) * 10)
    hi := i32(monster_respawn_max_for_room(game) * 10)
    if hi < lo {
        hi = lo
    }
    return f32(rl.GetRandomValue(lo, hi)) / 10.0
}

enemy_set_state :: proc(game: ^Game, state: Enemy_State) {
    if game.enemy.state == state {
        return
    }

    old_state := game.enemy.state
    telemetry_record_enemy_transition(game, old_state, state)
    game.enemy.state = state
    game.enemy.state_timer = 0
    game.enemy.lose_timer = 0

    if state == .ALERT || state == .CHASE {
        if !rl.IsMusicStreamPlaying(game.resources.chase_music) {
            rl.PlayMusicStream(game.resources.chase_music)
        }
        chase_volume := game.tuning.chase_volume
        if game.reduced_fx {
            chase_volume *= 0.35
        }
        rl.SetMusicVolume(game.resources.chase_music, chase_volume)
        rl.SetMusicVolume(game.resources.ambience_music, game.tuning.ambient_volume * 0.28)
    } else {
        if rl.IsMusicStreamPlaying(game.resources.chase_music) {
            rl.StopMusicStream(game.resources.chase_music)
        }
        rl.SetMusicVolume(game.resources.ambience_music, game.tuning.ambient_volume)
    }
}

stop_enemy_audio :: proc(game: ^Game) {
    if rl.IsMusicStreamPlaying(game.resources.chase_music) {
        rl.StopMusicStream(game.resources.chase_music)
    }
    rl.SetMusicVolume(game.resources.ambience_music, game.tuning.ambient_volume)
}

monster_marker_count :: proc(game: ^Game, kind: Entity_Kind) -> int {
    count := 0
    for i := 0; i < game.entity_count; i += 1 {
        if game.entities[i].kind == kind {
            count += 1
        }
    }
    return count
}

choose_random_marker :: proc(game: ^Game, kind: Entity_Kind, prefer_near_player: bool) -> rl.Vector2 {
    if game.player_index < 0 {
        return rl.Vector2{520, 300}
    }

    player := &game.entities[game.player_index]
    candidate_count := 0

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if entity.kind != kind {
            continue
        }
        d2 := distance_sq(player.position, entity.position)
        valid := true
        if prefer_near_player {
            valid = d2 >= 180*180 && d2 <= 500*500
        }
        if valid {
            candidate_count += 1
        }
    }

    if candidate_count > 0 {
        chosen := int(rl.GetRandomValue(0, i32(candidate_count - 1)))
        seen := 0
        for i := 0; i < game.entity_count; i += 1 {
            entity := &game.entities[i]
            if entity.kind != kind {
                continue
            }
            d2 := distance_sq(player.position, entity.position)
            valid := true
            if prefer_near_player {
                valid = d2 >= 180*180 && d2 <= 500*500
            }
            if valid {
                if seen == chosen {
                    return entity.position
                }
                seen += 1
            }
        }
    }

    total := monster_marker_count(game, kind)
    if total > 0 {
        chosen := int(rl.GetRandomValue(0, i32(total - 1)))
        seen := 0
        for i := 0; i < game.entity_count; i += 1 {
            if game.entities[i].kind == kind {
                if seen == chosen {
                    return game.entities[i].position
                }
                seen += 1
            }
        }
    }

    return rl.Vector2{player.position[0] + 250, player.position[1]}
}

choose_entry_marker :: proc(game: ^Game) -> rl.Vector2 {
    found := false
    best := rl.Vector2{520, 300}
    best_d2: f32 = 99999999

    // Cross-room pursuit remembers the destination position of the doorway the
    // player actually used. Choose the MONSTER_ENTRY nearest that doorway so the
    // Stalker follows through the same route rather than appearing elsewhere.
    hint := game.enemy.cross_room_entry
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if entity.kind != .MONSTER_ENTRY {
            continue
        }
        d2 := distance_sq(hint, entity.position)
        if d2 < best_d2 {
            best_d2 = d2
            best = entity.position
            found = true
        }
    }

    if found {
        return best
    }
    return choose_random_marker(game, .MONSTER_SPAWN, true)
}

enemy_on_room_change :: proc(game: ^Game, pursuit_carried: bool, entry_hint: rl.Vector2) {
    game.enemy.room = game.room
    game.enemy.velocity = rl.Vector2{0, 0}
    game.enemy.lose_timer = 0
    game.enemy.active = false
    game.enemy.cross_room_pending = false
    game.enemy.cross_room_entry = entry_hint
    game.enemy.forced_event = false

    if !room_allows_monster(game.room) {
        game.enemy.state = .DORMANT
        game.enemy.respawn_timer = 9999
        stop_enemy_audio(game)
        return
    }

    if pursuit_carried {
        // Cross-room chase: the player gets a short fair head start before the monster enters.
        game.enemy.state = .ALERT
        game.enemy.cross_room_pending = true
        game.enemy.cross_room_timer = monster_cross_room_delay_for_room(game)
        return
    }

    game.enemy.state = .DORMANT
    game.enemy.respawn_timer = random_respawn_delay(game)
    stop_enemy_audio(game)
}

spawn_enemy_patrol :: proc(game: ^Game) {
    game.enemy.position = choose_random_marker(game, .MONSTER_SPAWN, true)
    game.enemy.patrol_target = choose_random_marker(game, .MONSTER_SPAWN, false)
    game.enemy.last_seen = game.enemy.position
    game.enemy.active = true
    game.enemy.room = game.room
    game.enemy.forced_event = false
    _ = resolve_enemy_overlap(game)
    enemy_set_state(game, .PATROL)
}

spawn_enemy_from_door :: proc(game: ^Game) {
    game.enemy.position = choose_entry_marker(game)
    // The monster remembers the doorway/entry point the player used, not the
    // player's current exact position. It must reacquire visually after entering.
    game.enemy.last_seen = game.enemy.cross_room_entry
    game.enemy.active = true
    game.enemy.room = game.room
    game.enemy.cross_room_pending = false
    _ = resolve_enemy_overlap(game)
    enemy_set_state(game, .INVESTIGATE)
    game.enemy.state_timer = monster_investigate_seconds_for_room(game)
}

enemy_rect :: proc(game: ^Game) -> rl.Rectangle {
    return rl.Rectangle{x=game.enemy.position[0], y=game.enemy.position[1], width=42, height=54}
}

entity_solid_for_enemy :: proc(game: ^Game, entity: ^Entity) -> bool {
    #partial switch entity.kind {
    case .WALL, .BLOCKER, .HIDE_SPOT, .DOOR_TRIGGER, .SEARCHABLE_CONTAINER:
        return true
    case .PROCESSING_BRIDGE_LOCK:
        return !game.processing_bridge_extended
    case .SIGNAL_BARRIER:
        return !game.red_signal_on
    case .CEMETERY_DOOR:
        return !game.cemetery_door_open
    case .LASER_BARRIER:
        return !game.security_unlocked
    case:
        return false
    }
}

point_inside_rect :: proc(point: rl.Vector2, rect: rl.Rectangle) -> bool {
    return point[0] >= rect.x && point[0] <= rect.x + rect.width &&
           point[1] >= rect.y && point[1] <= rect.y + rect.height
}

segment_clear :: proc(game: ^Game, from, to: rl.Vector2) -> bool {
    // Lightweight authored-room line-of-sight. Sampling is stable for the compact rooms
    // and avoids adding a heavyweight pathfinding dependency.
    for step := 1; step < 16; step += 1 {
        t := f32(step) / 16.0
        point := rl.Vector2{
            from[0] + (to[0] - from[0]) * t,
            from[1] + (to[1] - from[1]) * t,
        }
        for i := 0; i < game.entity_count; i += 1 {
            entity := &game.entities[i]
            if !entity.active || !entity_solid_for_enemy(game, entity) {
                continue
            }
            if point_inside_rect(point, entity_rect(entity)) {
                return false
            }
        }
    }
    return true
}

enemy_can_see_player :: proc(game: ^Game) -> bool {
    if game.player_index < 0 || game.player_hidden {
        return false
    }
    player := &game.entities[game.player_index]
    max_d := monster_detection_range_for_room(game)
    if distance_sq(game.enemy.position, player.position) > max_d*max_d {
        return false
    }
    return segment_clear(game, game.enemy.position, player.position)
}

seek_velocity :: proc(from, to: rl.Vector2, speed: f32) -> rl.Vector2 {
    delta := rl.Vector2{to[0] - from[0], to[1] - from[1]}
    if delta[0]*delta[0] + delta[1]*delta[1] <= 0.001 {
        return rl.Vector2{0, 0}
    }
    direction := rl.Vector2Normalize(delta)
    return rl.Vector2{direction[0] * speed, direction[1] * speed}
}

enemy_world_rect_at :: proc(position: rl.Vector2) -> rl.Rectangle {
    // Use the Stalker's lower body for navigation collisions. Its full 42x54
    // sprite remains available for capture/contact checks, but shoulders/head no
    // longer snag on furniture corners or narrow door geometry.
    return rl.Rectangle{x=position[0] + 5, y=position[1] + 12, width=32, height=40}
}

enemy_world_collides_at :: proc(game: ^Game, position: rl.Vector2) -> bool {
    rect := enemy_world_rect_at(position)
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || !entity_solid_for_enemy(game, entity) {
            continue
        }
        if rl.CheckCollisionRecs(rect, entity_rect(entity)) {
            return true
        }
    }
    return false
}

resolve_enemy_overlap :: proc(game: ^Game) -> bool {
    if !enemy_world_collides_at(game, game.enemy.position) { return true }

    origin := game.enemy.position
    for radius: i32 = 1; radius <= 24; radius += 1 {
        r := f32(radius)
        candidates := [8]rl.Vector2{
            rl.Vector2{origin[0] + r, origin[1]}, rl.Vector2{origin[0] - r, origin[1]},
            rl.Vector2{origin[0], origin[1] + r}, rl.Vector2{origin[0], origin[1] - r},
            rl.Vector2{origin[0] + r, origin[1] + r}, rl.Vector2{origin[0] - r, origin[1] + r},
            rl.Vector2{origin[0] + r, origin[1] - r}, rl.Vector2{origin[0] - r, origin[1] - r},
        }
        for candidate in candidates {
            if !enemy_world_collides_at(game, candidate) {
                game.enemy.position = candidate
                return true
            }
        }
    }
    game.enemy.position = origin
    return false
}

enemy_move_with_collision :: proc(game: ^Game, velocity: rl.Vector2, dt: f32) {
    // Axis-separated movement gives natural wall sliding. A small overlap
    // recovery protects authored spawn/door markers from rounding or edge-touch
    // softlocks without teleporting the enemy toward the player.
    _ = resolve_enemy_overlap(game)

    next_x := rl.Vector2{game.enemy.position[0] + velocity[0] * dt, game.enemy.position[1]}
    if !enemy_world_collides_at(game, next_x) {
        game.enemy.position = next_x
    }

    next_y := rl.Vector2{game.enemy.position[0], game.enemy.position[1] + velocity[1] * dt}
    if !enemy_world_collides_at(game, next_y) {
        game.enemy.position = next_y
    }
}

choose_navigation_marker :: proc(game: ^Game, target: rl.Vector2) -> rl.Vector2 {
    found := false
    best := target
    best_score: f32 = 99999999

    for i := 0; i < game.entity_count; i += 1 {
        marker := &game.entities[i]
        if marker.kind != .MONSTER_SPAWN {
            continue
        }
        if !segment_clear(game, game.enemy.position, marker.position) {
            continue
        }
        score := distance_sq(marker.position, target)
        if score < best_score {
            best_score = score
            best = marker.position
            found = true
        }
    }

    if found {
        return best
    }
    return target
}

enemy_velocity_to_target :: proc(game: ^Game, target: rl.Vector2, speed: f32) -> rl.Vector2 {
    if segment_clear(game, game.enemy.position, target) {
        return seek_velocity(game.enemy.position, target, speed)
    }
    waypoint := choose_navigation_marker(game, target)
    return seek_velocity(game.enemy.position, waypoint, speed)
}

enemy_attract_to :: proc(game: ^Game, position: rl.Vector2, strong: bool) {
    if !room_allows_monster(game.room) || game.player_index < 0 {
        return
    }

    // Sound is information, not omniscience: the Stalker only receives the
    // source position when the event falls inside its externally tuned hearing
    // radius. Strong scripted noises may awaken a dormant monster nearby.
    if game.enemy.active {
        hearing := monster_hearing_range_for_room(game)
        if distance_sq(game.enemy.position, position) > hearing*hearing {
            return
        }
    }

    if !game.enemy.active {
        if strong {
            game.enemy.position = choose_random_marker(game, .MONSTER_SPAWN, true)
            game.enemy.active = true
            game.enemy.room = game.room
            game.enemy.last_seen = position
            game.enemy.forced_event = true
            enemy_set_state(game, .SUSPICIOUS)
            game.enemy.state_timer = monster_alert_seconds_for_room(game) * 1.15
        }
        return
    }

    if game.enemy.state != .CHASE {
        game.enemy.last_seen = position
        enemy_set_state(game, .INVESTIGATE)
        game.enemy.state_timer = monster_investigate_seconds_for_room(game)
    }
}

enemy_force_containment_event :: proc(game: ^Game) {
    if game.room != .CONTAINMENT || game.containment_event_started {
        return
    }
    game.containment_event_started = true
    game.enemy.respawn_timer = 1.8
    game.enemy.forced_event = true
}

update_enemy_ai :: proc(game: ^Game, dt: f32) {
    if game.state != .PLAYING || game.player_index < 0 || !room_allows_monster(game.room) {
        return
    }

    player := &game.entities[game.player_index]

    if game.enemy.cross_room_pending {
        game.enemy.cross_room_timer -= dt
        if game.enemy.cross_room_timer <= 0 {
            spawn_enemy_from_door(game)
        }
        return
    }

    switch game.enemy.state {
    case .DORMANT:
        game.enemy.respawn_timer -= dt
        if game.enemy.respawn_timer <= 0 {
            spawn_enemy_patrol(game)
        }

    case .PATROL:
        if !game.enemy.active {
            game.enemy.state = .DORMANT
            game.enemy.respawn_timer = random_respawn_delay(game)
            return
        }

        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            enemy_set_state(game, .SUSPICIOUS)
            game.enemy.state_timer = monster_alert_seconds_for_room(game)
            return
        }

        if distance_sq(game.enemy.position, game.enemy.patrol_target) < 30*30 {
            game.enemy.patrol_target = choose_random_marker(game, .MONSTER_SPAWN, false)
        }
        velocity := enemy_velocity_to_target(game, game.enemy.patrol_target, monster_patrol_speed_for_room(game))
        game.enemy.velocity = velocity
        enemy_move_with_collision(game, velocity, dt)

    case .SUSPICIOUS:
        // A brief confirmation window gives the player readable reaction time. If
        // line of sight breaks here, the monster investigates the last position
        // instead of magically knowing where the player went.
        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            game.enemy.state_timer -= dt
            if game.enemy.state_timer <= 0 {
                enemy_set_state(game, .ALERT)
                game.enemy.state_timer = monster_alert_seconds_for_room(game) * 0.40
            }
        } else {
            enemy_set_state(game, .INVESTIGATE)
            game.enemy.state_timer = monster_investigate_seconds_for_room(game)
        }

    case .INVESTIGATE:
        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            enemy_set_state(game, .SUSPICIOUS)
            game.enemy.state_timer = monster_alert_seconds_for_room(game) * 0.65
            return
        }

        game.enemy.state_timer -= dt
        velocity := enemy_velocity_to_target(game, game.enemy.last_seen, monster_patrol_speed_for_room(game) * 1.20)
        game.enemy.velocity = velocity
        enemy_move_with_collision(game, velocity, dt)

        reached := distance_sq(game.enemy.position, game.enemy.last_seen) < 34*34
        if reached || game.enemy.state_timer <= 0 {
            enemy_set_state(game, .SEARCH)
            game.enemy.state_timer = monster_search_seconds_for_room(game)
        }

    case .ALERT:
        if !game.enemy.active { return }
        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            game.enemy.state_timer -= dt
            if game.enemy.state_timer <= 0 {
                enemy_set_state(game, .CHASE)
            }
        } else {
            enemy_set_state(game, .INVESTIGATE)
            game.enemy.state_timer = monster_investigate_seconds_for_room(game)
        }

    case .CHASE:
        sees_player := enemy_can_see_player(game)
        if sees_player {
            game.enemy.last_seen = player.position
            game.enemy.lose_timer = 0
        } else {
            game.enemy.lose_timer += dt
        }

        velocity := enemy_velocity_to_target(game, game.enemy.last_seen, monster_chase_speed_for_room(game))
        game.enemy.velocity = velocity
        enemy_move_with_collision(game, velocity, dt)

        if game.enemy.lose_timer >= monster_lost_seconds_for_room(game) {
            enemy_set_state(game, .INVESTIGATE)
            game.enemy.state_timer = monster_investigate_seconds_for_room(game)
        }

    case .SEARCH:
        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            enemy_set_state(game, .SUSPICIOUS)
            game.enemy.state_timer = monster_alert_seconds_for_room(game) * 0.55
            return
        }

        game.enemy.state_timer -= dt
        velocity := enemy_velocity_to_target(game, game.enemy.last_seen, monster_patrol_speed_for_room(game) * 1.08)
        game.enemy.velocity = velocity
        enemy_move_with_collision(game, velocity, dt)

        if game.enemy.state_timer <= 0 {
            game.enemy.patrol_target = choose_random_marker(game, .MONSTER_SPAWN, false)
            enemy_set_state(game, .DISENGAGE)
            game.enemy.state_timer = monster_disengage_seconds_for_room(game)
        }

    case .DISENGAGE:
        if enemy_can_see_player(game) {
            game.enemy.last_seen = player.position
            enemy_set_state(game, .SUSPICIOUS)
            game.enemy.state_timer = monster_alert_seconds_for_room(game)
            return
        }

        game.enemy.state_timer -= dt
        velocity := enemy_velocity_to_target(game, game.enemy.patrol_target, monster_patrol_speed_for_room(game))
        game.enemy.velocity = velocity
        enemy_move_with_collision(game, velocity, dt)

        if game.enemy.state_timer <= 0 || distance_sq(game.enemy.position, game.enemy.patrol_target) < 26*26 {
            game.enemy.active = false
            game.enemy.state = .DORMANT
            game.enemy.respawn_timer = random_respawn_delay(game)
            stop_enemy_audio(game)
        }
    }

    if game.enemy.active && game.respawn_protection <= 0 && !game.player_hidden &&
       rl.CheckCollisionRecs(enemy_rect(game), entity_rect(player)) {
        begin_jumpscare(game)
    }
}

