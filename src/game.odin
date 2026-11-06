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
    security_intro_seen:     bool,
    security_clue_read:      bool,
    security_router_seen:    bool,
    security_laser_shutdown: f32,
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


    // Reusable inventory / searchable-container systems.
    inventory:          [ITEM_COUNT]bool,
    equipped_item:      Item_ID,
    inventory_cursor:   int,
    search_open:        bool,
    active_container:   Container_ID,
    search_cursor:      int,
    search_feedback:    int,
    search_object_taken:[SEARCH_OBJECT_COUNT]bool,
    item_use_open:      bool,
    item_use_target_index: int,
    item_use_cursor:    int,
    item_use_feedback:  int,
    security_door_unlocked: bool,
    archive_door_unlocked:  bool,

    // Player animation and persistent Reception power-transition presentation.
    player_moving:      bool,
    player_walk_phase:  f32,
    reception_power_transition: f32,
    reception_power_flicker:    f32,

    // Reusable progressive hint system. State is kept per puzzle context so
    // leaving/re-entering a room does not erase accumulated hint progress.
    hints_enabled:             bool,
    hint_elapsed:              [HINT_CONTEXT_COUNT]f32,
    hint_stage:                [HINT_CONTEXT_COUNT]int,
    hint_progress_token:       [HINT_CONTEXT_COUNT]int,
    hint_notification_timer:   f32,
    hint_notification_context: Hint_Context,
    hint_notification_stage:   int,
    hint_solution_open:        bool,

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
    game.security_intro_seen = false
    game.security_clue_read = false
    game.security_router_seen = false
    game.security_laser_shutdown = 0
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

    for i := 0; i < ITEM_COUNT; i += 1 { game.inventory[i] = false }
    for i := 0; i < SEARCH_OBJECT_COUNT; i += 1 { game.search_object_taken[i] = false }
    game.equipped_item = .NONE
    game.inventory_cursor = 0
    game.search_open = false
    game.active_container = .NONE
    game.search_cursor = 0
    game.search_feedback = 0
    game.item_use_open = false
    game.item_use_target_index = -1
    game.item_use_cursor = 0
    game.item_use_feedback = 0
    game.security_door_unlocked = false
    game.archive_door_unlocked = false
    game.player_moving = false
    game.player_walk_phase = 0
    game.reception_power_transition = 0
    game.reception_power_flicker = 0

    game.hints_enabled = true
    for i := 0; i < HINT_CONTEXT_COUNT; i += 1 {
        game.hint_elapsed[i] = 0
        game.hint_stage[i] = 0
        game.hint_progress_token[i] = -1
    }
    game.hint_notification_timer = 0
    game.hint_notification_context = .NONE
    game.hint_notification_stage = 0
    game.hint_solution_open = false

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
        if target == .SECURITY && !game.security_intro_seen {
            game.security_intro_seen = true
            show_message(game, 85)
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
    case .WALL, .BLOCKER, .HIDE_SPOT, .DOOR_TRIGGER, .SEARCHABLE_CONTAINER:
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

    game.player_moving = player.velocity[0] != 0 || player.velocity[1] != 0
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
    // Only one modal interface may be active at a time. All modal screens pause world simulation.
    if game.hint_solution_open {
        if rl.IsKeyPressed(.H) || rl.IsKeyPressed(.I) || rl.IsKeyPressed(.ESCAPE) {
            game.hint_solution_open = false
        }
        return
    }
    if game.search_open {
        update_search_interface(game)
        return
    }
    if game.item_use_open {
        update_item_selector(game)
        return
    }
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
        update_inventory_interface(game)
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

    if rl.IsKeyPressed(.K) {
        game.hints_enabled = !game.hints_enabled
        game.hint_notification_timer = 0
    }

    if game.message_timer > 0 { game.message_timer -= dt }
    if game.scanner_pulse_timer > 0 { game.scanner_pulse_timer -= dt }
    if game.respawn_protection > 0 { game.respawn_protection -= dt }
    if game.reception_power_flicker > 0 { game.reception_power_flicker -= dt }
    if game.security_laser_shutdown > 0 { game.security_laser_shutdown -= dt }
    if game.hint_notification_timer > 0 { game.hint_notification_timer -= dt }
    if game.reception_power && game.reception_power_transition < 1.0 {
        game.reception_power_transition += dt * 0.72
        if game.reception_power_transition > 1.0 { game.reception_power_transition = 1.0 }
    }

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
    if game.player_moving {
        cycle_speed := game.tuning.player_speed / 18.0
        if game.enemy.state == .CHASE { cycle_speed *= 1.35 }
        game.player_walk_phase += dt * cycle_speed
        if game.player_walk_phase > 1000 { game.player_walk_phase = 0 }
    }

    if rl.IsKeyPressed(.E) {
        old_room := game.room
        for i := 0; i < game.entity_count; i += 1 {
            entity := &game.entities[i]
            if !entity.active || entity.kind == .PLAYER || !near_entity(game, entity) {
                continue
            }
            if entity.kind == .SEARCHABLE_CONTAINER {
                open_search_container(game, entity.container_id)
            } else if entity.kind == .POWER_PANEL && !game.reception_power {
                open_item_selector(game, i)
            } else if entity.kind == .MAINT_PANEL && !game.maintenance_panel_open {
                open_item_selector(game, i)
            } else if entity.kind == .DOOR_TRIGGER && entity_requires_item_selection(game, entity) {
                open_item_selector(game, i)
            } else {
                handle_entity_interaction(game, entity)
            }
            if game.room != old_room {
                return
            }
            break
        }
    }

    update_enemy_ai(game, dt)
    update_hint_system(game, dt)
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
