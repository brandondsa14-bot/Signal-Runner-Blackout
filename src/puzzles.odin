package main

import rl "vendor:raylib"

distance_sq :: proc(a, b: rl.Vector2) -> f32 {
    dx := a[0] - b[0]
    dy := a[1] - b[1]
    return dx*dx + dy*dy
}

near_entity :: proc(game: ^Game, entity: ^Entity) -> bool {
    if game.player_index < 0 {
        return false
    }
    player := &game.entities[game.player_index]
    max_dist := game.tuning.interact_distance
    return distance_sq(player.position, entity.position) <= max_dist*max_dist
}

scanner_near_entity :: proc(game: ^Game, entity: ^Entity) -> bool {
    if game.player_index < 0 {
        return false
    }
    player := &game.entities[game.player_index]
    max_dist := game.tuning.scanner_range
    return distance_sq(player.position, entity.position) <= max_dist*max_dist
}

scanner_mode_name :: proc(mode: Scanner_Mode) -> cstring {
    switch mode {
    case .RED:    return "RED"
    case .BLUE:   return "BLUE"
    case .YELLOW: return "YELLOW"
    }
    return "RED"
}

evidence_count :: proc(game: ^Game) -> int {
    count := 0
    if game.archive_records { count += 1 }
    if game.has_personal_effects { count += 1 }
    if game.has_experiment_log { count += 1 }
    if game.optional_photo { count += 1 }
    return count
}

has_required_final_evidence :: proc(game: ^Game) -> bool {
    return game.archive_records && game.has_personal_effects && game.has_experiment_log
}

set_checkpoint :: proc(game: ^Game, room: Room_ID) {
    game.checkpoint_room = room
}

can_enter_room :: proc(game: ^Game, target: Room_ID) -> bool {
    switch target {
    case .ENTRANCE:
        return true
    case .RECEPTION:
        return game.hidden_stair_found
    case .STORAGE:
        return game.reception_power
    case .SECURITY:
        return game.reception_power && game.security_door_unlocked
    case .ARCHIVE:
        return game.security_unlocked && game.security_keycard && game.archive_door_unlocked
    case .LABORATORY:
        return game.security_unlocked && game.security_keycard
    case .DETENTION:
        return game.security_keycard && game.archive_code_known && game.lab_alignment_solved
    case .MAINTENANCE:
        return game.maintenance_badge
    case .CONTAINMENT:
        return game.security_unlocked && game.lab_alignment_solved && game.maintenance_online
    case .FINAL_AREA:
        return game.containment_solved && game.has_experiment_log
    }
    return false
}


entity_requires_item_selection :: proc(game: ^Game, entity: ^Entity) -> bool {
    if entity.kind != .DOOR_TRIGGER { return false }
    if entity.target_room == .SECURITY {
        return game.reception_power && !game.security_door_unlocked
    }
    if entity.target_room == .ARCHIVE {
        return game.security_unlocked && game.security_keycard && !game.archive_door_unlocked
    }
    return false
}

show_door_requirement :: proc(game: ^Game, target: Room_ID) {
    switch target {
    case .SECURITY:
        show_message(game, 51)
    case .ARCHIVE, .LABORATORY:
        show_message(game, 52)
    case .DETENTION:
        show_message(game, 53)
    case .MAINTENANCE:
        show_message(game, 54)
    case .CONTAINMENT:
        show_message(game, 55)
    case .FINAL_AREA:
        show_message(game, 56)
    case .STORAGE:
        show_message(game, 51)
    case .ENTRANCE, .RECEPTION:
        show_message(game, 56)
    }
}

security_expected_mode :: proc(step: int) -> Scanner_Mode {
    switch step {
    case 0: return .RED
    case 1: return .BLUE
    case 2: return .YELLOW
    case 3: return .BLUE
    }
    return .RED
}

calibrate_security_sequence :: proc(game: ^Game, entity: ^Entity) {
    if game.security_unlocked {
        show_message(game, 26)
        return
    }

    expected := security_expected_mode(game.security_sequence_step)
    if game.scanner_mode == expected {
        game.security_sequence_step += 1
        rl.PlaySound(game.resources.scanner_success)
        if game.security_sequence_step >= 4 {
            game.security_unlocked = true
            game.security_keycard = true
            game.security_laser_shutdown = 1.25
            add_item_with_progress(game, .SECURITY_KEYCARD)
            show_message(game, 26)
            rl.PlaySound(game.resources.scanner_success)
        } else {
            show_message(game, 24)
        }
    } else {
        game.security_sequence_step = 0
        show_message(game, 25)
        rl.PlaySound(game.resources.scanner_fail)
        enemy_attract_to(game, entity.position, true)
    }
}

calibrate_lab_receiver :: proc(game: ^Game, kind: Entity_Kind) {
    expected: Scanner_Mode = .RED
    already := false

    #partial switch kind {
    case .LAB_RECEIVER_A:
        expected = .BLUE
        already = game.lab_receiver_a
    case .LAB_RECEIVER_B:
        expected = .RED
        already = game.lab_receiver_b
    case .LAB_RECEIVER_C:
        expected = .YELLOW
        already = game.lab_receiver_c
    case:
        return
    }

    if already {
        show_message(game, 31)
        return
    }

    if game.scanner_mode == expected {
        #partial switch kind {
        case .LAB_RECEIVER_A: game.lab_receiver_a = true
        case .LAB_RECEIVER_B: game.lab_receiver_b = true
        case .LAB_RECEIVER_C: game.lab_receiver_c = true
        case: {}
        }
        rl.PlaySound(game.resources.scanner_success)
        show_message(game, 31)
    } else {
        rl.PlaySound(game.resources.scanner_fail)
        show_message(game, 32)
        enemy_attract_to(game, game.entities[game.player_index].position, false)
    }

    if game.lab_receiver_a && game.lab_receiver_b && game.lab_receiver_c && !game.lab_alignment_solved {
        game.lab_alignment_solved = true
        show_message(game, 33)
        rl.PlaySound(game.resources.pickup_sound)
    }
}

calibrate_containment_node :: proc(game: ^Game, kind: Entity_Kind) {
    expected: Scanner_Mode = .RED
    solved := false

    #partial switch kind {
    case .CONTAINMENT_NODE_A:
        expected = .YELLOW
        solved = game.containment_node_a
    case .CONTAINMENT_NODE_B:
        expected = .BLUE
        solved = game.containment_node_b
    case .CONTAINMENT_NODE_C:
        expected = .RED
        solved = game.containment_node_c
    case:
        return
    }

    if solved {
        show_message(game, 42)
        return
    }

    if game.scanner_mode == expected {
        #partial switch kind {
        case .CONTAINMENT_NODE_A: game.containment_node_a = true
        case .CONTAINMENT_NODE_B: game.containment_node_b = true
        case .CONTAINMENT_NODE_C: game.containment_node_c = true
        case: {}
        }
        show_message(game, 42)
        rl.PlaySound(game.resources.scanner_success)
        enemy_force_containment_event(game)
        enemy_attract_to(game, game.entities[game.player_index].position, true)
    } else {
        show_message(game, 43)
        rl.PlaySound(game.resources.scanner_fail)
        enemy_attract_to(game, game.entities[game.player_index].position, true)
    }

    if game.containment_node_a && game.containment_node_b && game.containment_node_c && !game.containment_solved {
        game.containment_solved = true
        show_message(game, 44)
        rl.PlaySound(game.resources.pickup_sound)
    }
}

handle_scanner_pulse :: proc(game: ^Game) {
    if game.player_index < 0 || game.room == .ENTRANCE {
        return
    }

    game.scanner_pulse_timer = game.tuning.scanner_pulse_seconds
    handled := false

    // Scanner noise is useful but dangerous: active monsters can investigate the pulse.
    enemy_attract_to(game, game.entities[game.player_index].position, false)

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || !scanner_near_entity(game, entity) {
            continue
        }

        #partial switch entity.kind {
        case .ARCHIVE_HIDDEN_CLUE:
            handled = true
            if game.scanner_mode == .BLUE {
                if !game.archive_code_known {
                    game.archive_code_known = true
                    show_message(game, 28)
                    rl.PlaySound(game.resources.scanner_success)
                } else {
                    show_message(game, 58)
                }
            } else {
                show_message(game, 29)
                rl.PlaySound(game.resources.scanner_fail)
            }

        case .DETENTION_CONSOLE:
            handled = true
            if game.scanner_mode == .YELLOW && game.archive_code_known && game.security_keycard {
                game.detention_locks_bypassed = true
                show_message(game, 34)
                rl.PlaySound(game.resources.scanner_success)
            } else {
                show_message(game, 35)
                rl.PlaySound(game.resources.scanner_fail)
            }

        case .MAINT_PANEL:
            handled = true
            if !game.maintenance_panel_open {
                show_message(game, 39)
                rl.PlaySound(game.resources.scanner_fail)
            } else if game.scanner_mode == .RED {
                if !game.maintenance_online {
                    game.maintenance_online = true
                    show_message(game, 41)
                    rl.PlaySound(game.resources.scanner_success)
                } else {
                    show_message(game, 59)
                }
            } else {
                show_message(game, 43)
                rl.PlaySound(game.resources.scanner_fail)
            }

        case .FINAL_TERMINAL:
            handled = true
            if !has_required_final_evidence(game) {
                show_message(game, 46)
                rl.PlaySound(game.resources.scanner_fail)
            } else if game.scanner_mode != .BLUE {
                show_message(game, 47)
                rl.PlaySound(game.resources.scanner_fail)
            } else {
                game.final_decrypted = true
                show_message(game, 48)
                rl.PlaySound(game.resources.scanner_success)
            }

        case:
            // Other objects are either E interactions or environmental props.
        }
    }

    if !handled {
        show_message(game, 60)
    }
}

handle_hide_spot :: proc(game: ^Game, entity: ^Entity) {
    if game.player_hidden {
        game.player_hidden = false
        show_message(game, 62)
        return
    }

    if game.enemy.active && distance_sq(game.enemy.position, game.entities[game.player_index].position) < 135*135 {
        show_message(game, 61)
        return
    }

    game.player_hidden = true
    show_message(game, 62)
}

handle_entity_interaction :: proc(game: ^Game, entity: ^Entity) {
    switch entity.kind {
    case .TERMINAL:
        if !game.has_cemetery_key {
            game.has_cemetery_key = true
            add_item_with_progress(game, .CEMETERY_KEY)
            show_message(game, 1)
            rl.PlaySound(game.resources.pickup_sound)
        } else {
            show_message(game, 4)
        }

    case .CEMETERY_DOOR:
        if game.has_cemetery_key {
            game.cemetery_door_open = true
            show_message(game, 2)
            rl.PlaySound(game.resources.pickup_sound)
        } else {
            show_message(game, 5)
        }

    case .GRAVE_CLUE:
        switch game.grave_dialogue_step {
        case 0:
            show_message(game, 6)
            game.grave_dialogue_step = 1
        case 1:
            show_message(game, 7)
            game.grave_dialogue_step = 2
        case 2:
            show_message(game, 8)
            game.grave_dialogue_step = 3
            game.hidden_stair_found = true
            rl.PlaySound(game.resources.pickup_sound)
        case 3:
            change_room(game, .RECEPTION, rl.Vector2{505, 465})
        }

    case .DOOR_TRIGGER:
        if can_enter_room(game, entity.target_room) {
            change_room(game, entity.target_room, entity.target_position)
        } else {
            show_door_requirement(game, entity.target_room)
        }

    case .FUSE_ITEM:
        if !game.has_spare_fuse {
            game.has_spare_fuse = true
            add_item_with_progress(game, .REPLACEMENT_FUSE)
            show_message(game, 20)
            rl.PlaySound(game.resources.pickup_sound)
        }

    case .POWER_PANEL:
        if game.reception_power { show_message(game, 63) }
        else { show_message(game, 22) }

    case .SECURITY_CLUE:
        game.security_clue_read = true
        show_message(game, 23)

    case .SECURITY_CONSOLE:
        if !game.security_router_seen {
            game.security_router_seen = true
            show_message(game, 86)
        } else {
            calibrate_security_sequence(game, entity)
        }

    case .ARCHIVE_RECORDS:
        if !game.archive_records {
            game.archive_records = true
            add_item_with_progress(game, .ARCHIVE_RECORDS)
            show_message(game, 27)
            rl.PlaySound(game.resources.pickup_sound)
            set_checkpoint(game, .ARCHIVE)
        } else {
            show_message(game, 64)
        }

    case .LAB_AUDIO_LOG:
        game.lab_audio_log = true
        show_message(game, 30)

    case .LAB_RECEIVER_A, .LAB_RECEIVER_B, .LAB_RECEIVER_C:
        calibrate_lab_receiver(game, entity.kind)

    case .CELL_KEY_ITEM:
        if !game.detention_locks_bypassed {
            show_message(game, 65)
        } else if !game.has_cell_key {
            game.has_cell_key = true
            add_item_with_progress(game, .CELL_KEY)
            show_message(game, 36)
            rl.PlaySound(game.resources.pickup_sound)
        }

    case .MISSING_EFFECTS:
        if !game.detention_locks_bypassed {
            show_message(game, 65)
        } else if !game.has_cell_key {
            show_message(game, 66)
        } else if !game.has_personal_effects {
            game.has_personal_effects = true
            game.maintenance_badge = true
            add_item_with_progress(game, .PERSONAL_EFFECTS)
            add_item_with_progress(game, .MAINTENANCE_BADGE)
            show_message(game, 37)
            rl.PlaySound(game.resources.pickup_sound)
        } else {
            show_message(game, 67)
        }

    case .SCREWDRIVER_ITEM:
        if !game.has_screwdriver {
            game.has_screwdriver = true
            add_item_with_progress(game, .SCREWDRIVER)
            show_message(game, 38)
            rl.PlaySound(game.resources.pickup_sound)
        }

    case .MAINT_PANEL:
        if game.maintenance_panel_open { show_message(game, 68) }
        else { show_message(game, 39) }

    case .NOISE_PIPE:
        show_message(game, 69)
        rl.PlaySound(game.resources.distant_metal)
        enemy_attract_to(game, entity.position, true)

    case .CONTAINMENT_NODE_A, .CONTAINMENT_NODE_B, .CONTAINMENT_NODE_C:
        calibrate_containment_node(game, entity.kind)

    case .EXPERIMENT_LOG:
        if !game.containment_solved {
            show_message(game, 70)
        } else if !game.has_experiment_log {
            game.has_experiment_log = true
            add_item_with_progress(game, .EXPERIMENT_LOG)
            show_message(game, 45)
            rl.PlaySound(game.resources.pickup_sound)
        } else {
            show_message(game, 71)
        }

    case .FINAL_TERMINAL:
        if game.final_decrypted && has_required_final_evidence(game) {
            game.case_transmitted = true
            game.ending_page = 0
            game.state = .ENDING
            stop_enemy_audio(game)
        } else if !has_required_final_evidence(game) {
            show_message(game, 46)
        } else {
            show_message(game, 47)
        }

    case .OPTIONAL_NOTE:
        switch game.room {
        case .RECEPTION:   show_message(game, 74)
        case .ARCHIVE:     show_message(game, 75)
        case .LABORATORY:  show_message(game, 76)
        case .DETENTION:   show_message(game, 77)
        case .MAINTENANCE: show_message(game, 78)
        case .STORAGE:     show_message(game, 79)
        case .FINAL_AREA:  show_message(game, 80)
        case .ENTRANCE, .SECURITY, .CONTAINMENT: show_message(game, 49)
        }

    case .OPTIONAL_PHOTO:
        if !game.optional_photo {
            game.optional_photo = true
            add_item_with_progress(game, .GROUP_PHOTO)
            show_message(game, 72)
            rl.PlaySound(game.resources.pickup_sound)
        } else {
            show_message(game, 73)
        }

    case .HIDE_SPOT:
        handle_hide_spot(game, entity)

    case .PLAYER, .WALL, .BLOCKER, .SIGNAL_BARRIER, .MONSTER_SPAWN, .MONSTER_ENTRY, .SEARCHABLE_CONTAINER,
         .LASER_BARRIER, .DETENTION_CONSOLE, .ARCHIVE_HIDDEN_CLUE,
         .LIBRARY_TRIGGER, .SIDE_ROOM_TRIGGER, .DUNGEON_DOOR, .RETURN_TRIGGER,
         .LIBRARY_KEY_ITEM, .STAFF_LOCKER, .WARDEN_DESK, .ENDING_EXIT:
        // These use movement, rendering, or scanner-pulse logic instead of E.
    }
}
