package main

import rl "vendor:raylib"

STORY_COUNT  :: 7
ENDING_COUNT :: 5

Game :: struct {
    state: Game_State,
    room:  Room_ID,

    entities:     [MAX_ENTITIES]Entity,
    entity_count: int,
    player_index: int,

    resources: ^Resources,
    tuning:    Tuning,

    story_page:  int,
    ending_page: int,

    // Surface sequence preserved from CP2/CP3.
    has_cemetery_key:    bool,
    cemetery_door_open:  bool,
    red_signal_on:       bool,
    grave_dialogue_step: int,
    hidden_stair_found:  bool,

    // Scanner and investigation systems.
    scanner_mode:        Scanner_Mode,
    scanner_pulse_timer: f32,

    // Facility progression / inventory.
    has_spare_fuse:          bool,
    reception_power:         bool,
    security_sequence_step:  int,
    security_unlocked:       bool,
    security_keycard:        bool,
    archive_records:         bool,
    archive_code_known:      bool,
    lab_audio_log:           bool,
    lab_receiver_a:          bool,
    lab_receiver_b:          bool,
    lab_receiver_c:          bool,
    lab_alignment_solved:    bool,
    detention_locks_bypassed: bool,
    has_cell_key:            bool,
    has_personal_effects:    bool,
    maintenance_badge:       bool,
    has_screwdriver:         bool,
    maintenance_panel_open:  bool,
    maintenance_online:      bool,
    containment_node_a:      bool,
    containment_node_b:      bool,
    containment_node_c:      bool,
    containment_solved:      bool,
    containment_event_started: bool,
    has_experiment_log:      bool,
    final_decrypted:         bool,
    optional_photo:          bool,

    // Player presentation / survival.
    player_facing:       Facing_Direction,
    player_hidden:       bool,
    inventory_open:      bool,
    objectives_open:     bool,
    explored_rooms:      [ROOM_COUNT]bool,
    case_transmitted:    bool,
    lives:               int,
    checkpoint_room:     Room_ID,
    respawn_protection:  f32,
    reduced_fx:          bool,

    // Jumpscare / atmosphere.
    jumpscare_timer:     f32,
    world_time:          f32,
    ambient_event_timer: f32,

    // Enemy AI.
    enemy: Enemy_AI,

    // Shared dialogue/message system.
    message_timer: f32,
    message_kind:  int,
}

new_game :: proc(resources: ^Resources, tuning: Tuning) -> Game {
    game := Game{
        state = .TITLE,
        room = .ENTRANCE,
        entity_count = 0,
        player_index = -1,
        resources = resources,
        tuning = tuning,
        story_page = 0,
        ending_page = 0,
        scanner_mode = .RED,
        player_facing = .DOWN,
        lives = 3,
        checkpoint_room = .ENTRANCE,
        enemy = Enemy_AI{state=.DORMANT, active=false, room=.ENTRANCE},
    }

    reset_progress(&game)
    game.state = .TITLE
    return game
}

reset_progress :: proc(game: ^Game) {
    game.has_cemetery_key = false
    game.cemetery_door_open = false
    game.red_signal_on = false
    game.grave_dialogue_step = 0
    game.hidden_stair_found = false

    game.scanner_mode = .RED
    game.scanner_pulse_timer = 0

    game.has_spare_fuse = false
    game.reception_power = false
    game.security_sequence_step = 0
    game.security_unlocked = false
    game.security_keycard = false
    game.archive_records = false
    game.archive_code_known = false
    game.lab_audio_log = false
    game.lab_receiver_a = false
    game.lab_receiver_b = false
    game.lab_receiver_c = false
    game.lab_alignment_solved = false
    game.detention_locks_bypassed = false
    game.has_cell_key = false
    game.has_personal_effects = false
    game.maintenance_badge = false
    game.has_screwdriver = false
    game.maintenance_panel_open = false
    game.maintenance_online = false
    game.containment_node_a = false
    game.containment_node_b = false
    game.containment_node_c = false
    game.containment_solved = false
    game.containment_event_started = false
    game.has_experiment_log = false
    game.final_decrypted = false
    game.optional_photo = false

    game.player_facing = .DOWN
    game.player_hidden = false
    game.inventory_open = false
    game.objectives_open = false
    game.case_transmitted = false
    for i := 0; i < ROOM_COUNT; i += 1 {
        game.explored_rooms[i] = false
    }
    game.lives = 3
    game.checkpoint_room = .ENTRANCE
    game.respawn_protection = 0

    game.jumpscare_timer = 0
    game.world_time = 0
    game.message_timer = 0
    game.message_kind = 0
    game.ambient_event_timer = random_ambient_delay(game)

    load_level_file(game, room_path(.ENTRANCE), .ENTRANCE)
    game.enemy = Enemy_AI{state=.DORMANT, active=false, room=.ENTRANCE}
    enemy_on_room_change(game, false, rl.Vector2{0, 0})
}

random_ambient_delay :: proc(game: ^Game) -> f32 {
    lo := i32(game.tuning.ambient_event_min * 10)
    hi := i32(game.tuning.ambient_event_max * 10)
    if hi < lo { hi = lo }
    return f32(rl.GetRandomValue(lo, hi)) / 10.0
}

show_message :: proc(game: ^Game, kind: int) {
    game.message_kind = kind
    game.message_timer = game.tuning.message_duration
}

change_room :: proc(game: ^Game, target: Room_ID, target_position: rl.Vector2) {
    pursuit_carried := game.enemy.active &&
        (game.enemy.state == .ALERT || game.enemy.state == .CHASE || game.enemy.state == .SEARCH)

    if load_level_file(game, room_path(target), target) {
        if game.player_index >= 0 && (target_position[0] != 0 || target_position[1] != 0) {
            game.entities[game.player_index].position = target_position
        }
        game.player_hidden = false
        enemy_on_room_change(game, pursuit_carried, target_position)

        if target == .RECEPTION && game.checkpoint_room == .ENTRANCE {
            set_checkpoint(game, .RECEPTION)
        }
        if target == .CONTAINMENT {
            enemy_force_containment_event(game)
        }
        if target == .FINAL_AREA {
            // Final Investigation is a deliberate safe room and becomes the latest checkpoint.
            set_checkpoint(game, .FINAL_AREA)
        }
    }
}

reload_room_without_enemy_pursuit :: proc(game: ^Game, room: Room_ID) {
    if load_level_file(game, room_path(room), room) {
        game.player_hidden = false
        enemy_on_room_change(game, false, rl.Vector2{0, 0})
    }
}

respawn_at_checkpoint :: proc(game: ^Game) {
    reload_room_without_enemy_pursuit(game, game.checkpoint_room)
    game.respawn_protection = game.tuning.respawn_protection_seconds
    game.state = .PLAYING
    show_message(game, 50)
}

begin_jumpscare :: proc(game: ^Game) {
    if game.state != .PLAYING || game.respawn_protection > 0 {
        return
    }

    game.state = .JUMPSCARE
    game.jumpscare_timer = 0
    stop_enemy_audio(game)
    if !game.reduced_fx {
        rl.PlaySound(game.resources.jumpscare_sound)
    }
}

resolve_player_capture :: proc(game: ^Game) {
    game.lives -= 1
    game.enemy.active = false
    game.enemy.state = .DORMANT
    game.enemy.cross_room_pending = false

    if game.lives <= 0 {
        game.lives = 0
        game.state = .GAME_OVER
        stop_enemy_audio(game)
        return
    }

    respawn_at_checkpoint(game)
}

update_game :: proc(game: ^Game, dt: f32) {
    game.world_time += dt

    switch game.state {
    case .TITLE:
        update_title(game)
    case .STORY:
        update_story(game)
    case .PLAYING:
        update_playing(game, dt)
    case .JUMPSCARE:
        update_jumpscare(game, dt)
    case .GAME_OVER:
        update_game_over(game)
    case .ENDING:
        update_ending(game)
    }
}

update_title :: proc(game: ^Game) {
    if rl.IsKeyPressed(.V) {
        game.reduced_fx = !game.reduced_fx
    }
    if rl.IsKeyPressed(.ENTER) {
        game.story_page = 0
        game.state = .STORY
    }
}

update_story :: proc(game: ^Game) {
    if rl.IsKeyPressed(.ENTER) {
        game.story_page += 1
        if game.story_page >= STORY_COUNT {
            reduced := game.reduced_fx
            reset_progress(game)
            game.reduced_fx = reduced
            game.state = .PLAYING
        }
    }
}

update_ending :: proc(game: ^Game) {
    if rl.IsKeyPressed(.ENTER) {
        game.ending_page += 1
        if game.ending_page >= ENDING_COUNT {
            reduced := game.reduced_fx
            reset_progress(game)
            game.reduced_fx = reduced
            game.state = .TITLE
        }
    }
}

update_game_over :: proc(game: ^Game) {
    if rl.IsKeyPressed(.R) {
        reduced := game.reduced_fx
        reset_progress(game)
        game.reduced_fx = reduced
        game.state = .PLAYING
    }
    if rl.IsKeyPressed(.ENTER) {
        reduced := game.reduced_fx
        reset_progress(game)
        game.reduced_fx = reduced
        game.state = .TITLE
    }
}

update_jumpscare :: proc(game: ^Game, dt: f32) {
    game.jumpscare_timer += dt
    if game.jumpscare_timer >= game.tuning.jumpscare_duration {
        resolve_player_capture(game)
    }
}

entity_solid_for_player :: proc(game: ^Game, entity: ^Entity) -> bool {
    #partial switch entity.kind {
    case .WALL, .BLOCKER, .HIDE_SPOT, .DOOR_TRIGGER:
        return true
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

player_collides_world :: proc(game: ^Game, player: ^Entity) -> bool {
    rect := entity_rect(player)
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || entity.kind == .PLAYER || !entity_solid_for_player(game, entity) {
            continue
        }
        if rl.CheckCollisionRecs(rect, entity_rect(entity)) {
            return true
        }
    }
    return false
}

update_player_facing_and_velocity :: proc(game: ^Game, player: ^Entity) {
    player.velocity = rl.Vector2{0, 0}
    if game.player_hidden {
        return
    }

    speed := game.tuning.player_speed
    if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
        player.velocity[1] -= speed
        game.player_facing = .UP
    }
    if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
        player.velocity[1] += speed
        game.player_facing = .DOWN
    }
    if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
        player.velocity[0] -= speed
        game.player_facing = .LEFT
    }
    if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
        player.velocity[0] += speed
        game.player_facing = .RIGHT
    }
}

move_player_with_collision :: proc(game: ^Game, player: ^Entity, dt: f32) {
    old_x := player.position[0]
    player.position[0] += player.velocity[0] * dt
    if player_collides_world(game, player) {
        player.position[0] = old_x
    }

    old_y := player.position[1]
    player.position[1] += player.velocity[1] * dt
    if player_collides_world(game, player) {
        player.position[1] = old_y
    }
}

update_ambient_events :: proc(game: ^Game, dt: f32) {
    if game.room == .ENTRANCE || game.state != .PLAYING {
        return
    }
    if game.enemy.state == .ALERT || game.enemy.state == .CHASE {
        return
    }

    game.ambient_event_timer -= dt
    if game.ambient_event_timer <= 0 {
        if !game.reduced_fx {
            rl.PlaySound(game.resources.distant_metal)
        }
        game.ambient_event_timer = random_ambient_delay(game)
    }
}

update_playing :: proc(game: ^Game, dt: f32) {
    // Investigation log (I) and inventory (Tab) are modal and pause gameplay.
    if game.objectives_open {
        if rl.IsKeyPressed(.I) || rl.IsKeyPressed(.ESCAPE) {
            game.objectives_open = false
        } else if rl.IsKeyPressed(.TAB) {
            game.objectives_open = false
            game.inventory_open = true
        }
        return
    }

    if game.inventory_open {
        if rl.IsKeyPressed(.TAB) || rl.IsKeyPressed(.ESCAPE) {
            game.inventory_open = false
        } else if rl.IsKeyPressed(.I) {
            game.inventory_open = false
            game.objectives_open = true
        }
        return
    }

    if rl.IsKeyPressed(.I) {
        game.objectives_open = true
        game.inventory_open = false
        return
    }

    if rl.IsKeyPressed(.TAB) {
        game.inventory_open = true
        game.objectives_open = false
        return
    }

    if rl.IsKeyPressed(.ESCAPE) {
        stop_enemy_audio(game)
        game.state = .TITLE
        return
    }

    if rl.IsKeyPressed(.V) {
        game.reduced_fx = !game.reduced_fx
        if game.enemy.state == .ALERT || game.enemy.state == .CHASE {
            chase_volume := game.tuning.chase_volume
            if game.reduced_fx { chase_volume *= 0.35 }
            rl.SetMusicVolume(game.resources.chase_music, chase_volume)
        }
    }

    if game.message_timer > 0 { game.message_timer -= dt }
    if game.scanner_pulse_timer > 0 { game.scanner_pulse_timer -= dt }
    if game.respawn_protection > 0 { game.respawn_protection -= dt }

    update_ambient_events(game, dt)

    if game.inventory_open {
        return
    }

    if game.player_index < 0 {
        return
    }

    // Surface preserves the original red-signal gate. Underground uses three scanner frequencies.
    if game.room == .ENTRANCE {
        if rl.IsKeyPressed(.ONE) {
            game.red_signal_on = !game.red_signal_on
            show_message(game, 3)
        }
    } else {
        if rl.IsKeyPressed(.ONE) { game.scanner_mode = .RED }
        if rl.IsKeyPressed(.TWO) { game.scanner_mode = .BLUE }
        if rl.IsKeyPressed(.THREE) { game.scanner_mode = .YELLOW }
        if rl.IsKeyPressed(.F) { handle_scanner_pulse(game) }
    }

    player := &game.entities[game.player_index]
    update_player_facing_and_velocity(game, player)
    move_player_with_collision(game, player, dt)

    if rl.IsKeyPressed(.E) {
        old_room := game.room
        for i := 0; i < game.entity_count; i += 1 {
            entity := &game.entities[i]
            if !entity.active || entity.kind == .PLAYER || !near_entity(game, entity) {
                continue
            }
            handle_entity_interaction(game, entity)
            if game.room != old_room {
                return
            }
            break
        }
    }

    update_enemy_ai(game, dt)
}

render_game :: proc(game: ^Game) {
    switch game.state {
    case .TITLE:      render_title(game)
    case .STORY:      render_story(game)
    case .PLAYING:    render_playing(game)
    case .JUMPSCARE:  render_jumpscare(game)
    case .GAME_OVER:  render_game_over(game)
    case .ENDING:     render_ending(game)
    }
}
