package main

import "core:encoding/json"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Tuning :: struct {
    // CP5 profile metadata. 0 = BEFORE (pre-CP5 numeric snapshot), 1 = AFTER.
    profile_id:           i32,
    telemetry_enabled:    bool,
    telemetry_scenario:   string,
    telemetry_conditions: string,

    player_speed:      f32,
    interact_distance: f32,
    message_duration:  f32,
    ambient_volume:    f32,

    scanner_range:         f32,
    scanner_pulse_seconds: f32,

    monster_patrol_speed:       f32,
    monster_chase_speed:        f32,
    monster_detection_range:    f32,
    monster_hearing_range:      f32,
    monster_alert_seconds:      f32,
    monster_investigate_seconds:f32,
    monster_lost_seconds:       f32,
    monster_search_seconds:     f32,
    monster_respawn_min:        f32,
    monster_respawn_max:        f32,
    monster_cross_room_delay:   f32,
    monster_disengage_seconds:  f32,
    chase_volume:               f32,

    respawn_protection_seconds: f32,
    jumpscare_duration:         f32,
    ambient_event_min:          f32,
    ambient_event_max:          f32,

    hint_interval_seconds:      f32,
    hint_notification_seconds:  f32,

    // CP5 authored difficulty curve. These multipliers are applied to monster
    // pressure by room stage while the base mechanics/content remain identical.
    difficulty_intro_scale:         f32,
    difficulty_investigation_scale: f32,
    difficulty_rising_scale:        f32,
    difficulty_peak_scale:          f32,
    difficulty_resolution_scale:    f32,
}

tuning_profile_name :: proc(profile_id: i32) -> cstring {
    if profile_id == 0 { return "BEFORE" }
    if profile_id == 1 { return "AFTER" }
    return "CUSTOM"
}

tuning_profile_name_string :: proc(profile_id: i32) -> string {
    if profile_id == 0 { return "BEFORE" }
    if profile_id == 1 { return "AFTER" }
    return "CUSTOM"
}

clamp_tuning_value :: proc(value, lo, hi: f32) -> f32 {
    if value < lo { return lo }
    if value > hi { return hi }
    return value
}

sanitize_tuning :: proc(tuning: ^Tuning) {
    // Invalid/malformed numeric values are clamped to conservative gameplay
    // ranges so an external edit cannot create an unusable build.
    tuning.player_speed = clamp_tuning_value(tuning.player_speed, 80, 260)
    tuning.interact_distance = clamp_tuning_value(tuning.interact_distance, 50, 220)
    tuning.message_duration = clamp_tuning_value(tuning.message_duration, 0.5, 8)
    tuning.ambient_volume = clamp_tuning_value(tuning.ambient_volume, 0, 1)

    tuning.scanner_range = clamp_tuning_value(tuning.scanner_range, 80, 320)
    tuning.scanner_pulse_seconds = clamp_tuning_value(tuning.scanner_pulse_seconds, 0.1, 2)

    tuning.monster_patrol_speed = clamp_tuning_value(tuning.monster_patrol_speed, 20, 240)
    tuning.monster_chase_speed = clamp_tuning_value(tuning.monster_chase_speed, 40, 280)
    tuning.monster_detection_range = clamp_tuning_value(tuning.monster_detection_range, 60, 520)
    tuning.monster_hearing_range = clamp_tuning_value(tuning.monster_hearing_range, 80, 720)
    tuning.monster_alert_seconds = clamp_tuning_value(tuning.monster_alert_seconds, 0.15, 3)
    tuning.monster_investigate_seconds = clamp_tuning_value(tuning.monster_investigate_seconds, 0.5, 12)
    tuning.monster_lost_seconds = clamp_tuning_value(tuning.monster_lost_seconds, 0.4, 8)
    tuning.monster_search_seconds = clamp_tuning_value(tuning.monster_search_seconds, 1, 18)
    tuning.monster_respawn_min = clamp_tuning_value(tuning.monster_respawn_min, 1, 40)
    tuning.monster_respawn_max = clamp_tuning_value(tuning.monster_respawn_max, tuning.monster_respawn_min, 60)
    tuning.monster_cross_room_delay = clamp_tuning_value(tuning.monster_cross_room_delay, 0.2, 5)
    tuning.monster_disengage_seconds = clamp_tuning_value(tuning.monster_disengage_seconds, 0.5, 10)
    tuning.chase_volume = clamp_tuning_value(tuning.chase_volume, 0, 1)

    tuning.respawn_protection_seconds = clamp_tuning_value(tuning.respawn_protection_seconds, 0, 8)
    tuning.jumpscare_duration = clamp_tuning_value(tuning.jumpscare_duration, 0.5, 4)
    tuning.ambient_event_min = clamp_tuning_value(tuning.ambient_event_min, 2, 120)
    tuning.ambient_event_max = clamp_tuning_value(tuning.ambient_event_max, tuning.ambient_event_min, 180)

    tuning.hint_interval_seconds = clamp_tuning_value(tuning.hint_interval_seconds, 10, 300)
    tuning.hint_notification_seconds = clamp_tuning_value(tuning.hint_notification_seconds, 2, 30)

    tuning.difficulty_intro_scale = clamp_tuning_value(tuning.difficulty_intro_scale, 0.5, 1.5)
    tuning.difficulty_investigation_scale = clamp_tuning_value(tuning.difficulty_investigation_scale, 0.5, 1.5)
    tuning.difficulty_rising_scale = clamp_tuning_value(tuning.difficulty_rising_scale, 0.5, 1.5)
    tuning.difficulty_peak_scale = clamp_tuning_value(tuning.difficulty_peak_scale, 0.5, 1.5)
    tuning.difficulty_resolution_scale = clamp_tuning_value(tuning.difficulty_resolution_scale, 0.5, 1.5)

    if tuning.profile_id < 0 || tuning.profile_id > 1 {
        tuning.profile_id = 2
    }
}

load_tuning :: proc(path: string) -> Tuning {
    // Defaults intentionally match the pre-CP5 build, so a missing or malformed
    // external file falls back to a known-playable baseline rather than zeroes.
    tuning := Tuning{
        profile_id = 0,
        telemetry_enabled = true,
        telemetry_scenario = "security_to_containment",
        telemetry_conditions = "manual_keyboard_mac",
        player_speed = 155,
        interact_distance = 118,
        message_duration = 2.7,
        ambient_volume = 0.30,
        scanner_range = 155,
        scanner_pulse_seconds = 0.35,
        monster_patrol_speed = 72,
        monster_chase_speed = 142,
        monster_detection_range = 250,
        monster_hearing_range = 360,
        monster_alert_seconds = 0.62,
        monster_investigate_seconds = 2.6,
        monster_lost_seconds = 1.35,
        monster_search_seconds = 4.2,
        monster_respawn_min = 5.0,
        monster_respawn_max = 10.0,
        monster_cross_room_delay = 0.85,
        monster_disengage_seconds = 2.2,
        chase_volume = 0.62,
        respawn_protection_seconds = 2.6,
        jumpscare_duration = 1.65,
        ambient_event_min = 9.0,
        ambient_event_max = 18.0,
        hint_interval_seconds = 60.0,
        hint_notification_seconds = 8.0,
        difficulty_intro_scale = 1.0,
        difficulty_investigation_scale = 1.0,
        difficulty_rising_scale = 1.0,
        difficulty_peak_scale = 1.0,
        difficulty_resolution_scale = 1.0,
    }

    data, read_err := os.read_entire_file(path, context.allocator)
    if read_err != nil {
        fmt.eprintfln("Could not read tuning file %s: %v", path, read_err)
        sanitize_tuning(&tuning)
        return tuning
    }
    defer delete(data)

    unmarshal_err := json.unmarshal(data, &tuning)
    if unmarshal_err != nil {
        fmt.eprintfln("Could not parse tuning file %s; using safe defaults where needed.", path)
    }

    sanitize_tuning(&tuning)
    fmt.printfln("[CP5] Loaded balance profile %s from %s", tuning_profile_name_string(tuning.profile_id), path)
    return tuning
}

Spawn_Data :: struct {
    kind:       string,
    x:          f32,
    y:          f32,
    w:          f32,
    h:          f32,
    target:     string,
    target_x:   f32,
    target_y:   f32,
    interact:   bool,
    container:  string,
    prop:       string,
}

Level_Data :: struct {
    spawns: []Spawn_Data,
}

entity_kind_from_string :: proc(kind: string) -> (Entity_Kind, bool) {
    switch kind {
    case "PLAYER":                 return .PLAYER, true
    case "WALL":                   return .WALL, true
    case "BLOCKER":                return .BLOCKER, true
    case "TERMINAL":               return .TERMINAL, true
    case "CEMETERY_DOOR":          return .CEMETERY_DOOR, true
    case "SIGNAL_BARRIER":         return .SIGNAL_BARRIER, true
    case "GRAVE_CLUE":             return .GRAVE_CLUE, true
    case "DOOR_TRIGGER":           return .DOOR_TRIGGER, true
    case "MONSTER_SPAWN":          return .MONSTER_SPAWN, true
    case "MONSTER_ENTRY":          return .MONSTER_ENTRY, true
    case "HIDE_SPOT":              return .HIDE_SPOT, true
    case "SEARCHABLE_CONTAINER":   return .SEARCHABLE_CONTAINER, true
    case "INSPECTABLE_PROP":       return .INSPECTABLE_PROP, true
    case "FUSE_ITEM":              return .FUSE_ITEM, true
    case "POWER_PANEL":            return .POWER_PANEL, true
    case "SECURITY_CONSOLE":       return .SECURITY_CONSOLE, true
    case "SECURITY_CLUE":          return .SECURITY_CLUE, true
    case "LASER_BARRIER":          return .LASER_BARRIER, true
    case "ARCHIVE_RECORDS":        return .ARCHIVE_RECORDS, true
    case "ARCHIVE_HIDDEN_CLUE":    return .ARCHIVE_HIDDEN_CLUE, true
    case "LAB_AUDIO_LOG":          return .LAB_AUDIO_LOG, true
    case "LAB_RECEIVER_A":         return .LAB_RECEIVER_A, true
    case "LAB_RECEIVER_B":         return .LAB_RECEIVER_B, true
    case "LAB_RECEIVER_C":         return .LAB_RECEIVER_C, true
    case "DETENTION_CONSOLE":      return .DETENTION_CONSOLE, true
    case "CELL_KEY_ITEM":          return .CELL_KEY_ITEM, true
    case "MISSING_EFFECTS":        return .MISSING_EFFECTS, true
    case "SCREWDRIVER_ITEM":       return .SCREWDRIVER_ITEM, true
    case "MAINT_PANEL":            return .MAINT_PANEL, true
    case "NOISE_PIPE":             return .NOISE_PIPE, true
    case "PROCESSING_CONSOLE":     return .PROCESSING_CONSOLE, true
    case "PROCESSING_BRIDGE_LOCK": return .PROCESSING_BRIDGE_LOCK, true
    case "PROCESSING_EVIDENCE":    return .PROCESSING_EVIDENCE, true
    case "CONTAINMENT_NODE_A":     return .CONTAINMENT_NODE_A, true
    case "CONTAINMENT_NODE_B":     return .CONTAINMENT_NODE_B, true
    case "CONTAINMENT_NODE_C":     return .CONTAINMENT_NODE_C, true
    case "EXPERIMENT_LOG":         return .EXPERIMENT_LOG, true
    case "FINAL_TERMINAL":         return .FINAL_TERMINAL, true
    case "OPTIONAL_NOTE":          return .OPTIONAL_NOTE, true
    case "OPTIONAL_PHOTO":         return .OPTIONAL_PHOTO, true
    case "LIBRARY_TRIGGER":        return .LIBRARY_TRIGGER, true
    case "SIDE_ROOM_TRIGGER":      return .SIDE_ROOM_TRIGGER, true
    case "DUNGEON_DOOR":           return .DUNGEON_DOOR, true
    case "RETURN_TRIGGER":         return .RETURN_TRIGGER, true
    case "LIBRARY_KEY_ITEM":       return .LIBRARY_KEY_ITEM, true
    case "STAFF_LOCKER":           return .STAFF_LOCKER, true
    case "WARDEN_DESK":            return .WARDEN_DESK, true
    case "ENDING_EXIT":            return .ENDING_EXIT, true
    }
    return .WALL, false
}


container_id_from_string :: proc(name: string) -> (Container_ID, bool) {
    switch name {
    case "RECEPTION_DESK":          return .RECEPTION_DESK, true
    case "RECEPTION_SUPPLY":        return .RECEPTION_SUPPLY, true
    case "SECURITY_DESK":           return .SECURITY_DESK, true
    case "ARCHIVE_FILE_CABINET":    return .ARCHIVE_FILE_CABINET, true
    case "MAINTENANCE_LOCKER":      return .MAINTENANCE_LOCKER, true
    case "STORAGE_PERSONAL_LOCKER": return .STORAGE_PERSONAL_LOCKER, true
    }
    return .NONE, false
}

room_id_from_string :: proc(name: string) -> (Room_ID, bool) {
    switch name {
    case "ENTRANCE":       return .ENTRANCE, true
    case "RECEPTION":      return .RECEPTION, true
    case "SECURITY":       return .SECURITY, true
    case "ARCHIVE":        return .ARCHIVE, true
    case "LABORATORY":     return .LABORATORY, true
    case "DETENTION":      return .DETENTION, true
    case "MAINTENANCE":    return .MAINTENANCE, true
    case "PROCESSING":     return .PROCESSING, true
    case "CONTAINMENT":    return .CONTAINMENT, true
    case "FINAL_AREA":     return .FINAL_AREA, true
    case "STORAGE":        return .STORAGE, true
    }
    return .ENTRANCE, false
}

room_path :: proc(room: Room_ID) -> string {
    switch room {
    case .ENTRANCE:      return "data/levels/entrance.json"
    case .RECEPTION:     return "data/levels/reception.json"
    case .SECURITY:      return "data/levels/security.json"
    case .ARCHIVE:       return "data/levels/archive.json"
    case .LABORATORY:    return "data/levels/laboratory.json"
    case .DETENTION:     return "data/levels/detention.json"
    case .MAINTENANCE:   return "data/levels/maintenance.json"
    case .PROCESSING:    return "data/levels/processing.json"
    case .CONTAINMENT:   return "data/levels/containment.json"
    case .FINAL_AREA:    return "data/levels/final_area.json"
    case .STORAGE:       return "data/levels/storage.json"
    }
    return "data/levels/entrance.json"
}

load_level_file :: proc(game: ^Game, path: string, room: Room_ID) -> bool {
    data, read_err := os.read_entire_file(path, context.allocator)
    if read_err != nil {
        fmt.eprintfln("Could not read level file %s: %v", path, read_err)
        return false
    }
    defer delete(data)

    level: Level_Data
    unmarshal_err := json.unmarshal(data, &level)
    if unmarshal_err != nil {
        fmt.eprintfln("Could not parse level file %s", path)
        return false
    }
    defer {
        for spawn in level.spawns {
            delete(spawn.kind)
            if len(spawn.target) > 0 {
                delete(spawn.target)
            }
            if len(spawn.container) > 0 {
                delete(spawn.container)
            }
            if len(spawn.prop) > 0 {
                delete(spawn.prop)
            }
        }
        delete(level.spawns)
    }

    game.entity_count = 0
    game.player_index = -1
    game.interaction_target_index = -1
    game.interaction_candidate_count = 0
    game.interaction_cycle = 0
    game.room = room
    room_index := int(room)
    if room_index >= 0 && room_index < ROOM_COUNT {
        game.explored_rooms[room_index] = true
    }

    for spawn in level.spawns {
        kind, ok := entity_kind_from_string(spawn.kind)
        if !ok {
            fmt.eprintfln("Unknown entity kind in %s: %s", path, spawn.kind)
            continue
        }

        target_room: Room_ID = .ENTRANCE
        if len(spawn.target) > 0 {
            parsed_room, room_ok := room_id_from_string(spawn.target)
            if room_ok {
                target_room = parsed_room
            }
        }

        container_id: Container_ID = .NONE
        if len(spawn.container) > 0 {
            parsed_container, container_ok := container_id_from_string(spawn.container)
            if container_ok { container_id = parsed_container }
        }

        prop_id: Prop_ID = .NONE
        if len(spawn.prop) > 0 {
            parsed_prop, prop_ok := prop_id_from_string(spawn.prop)
            if prop_ok { prop_id = parsed_prop }
        }

        index := add_entity(game, Entity{
            kind = kind,
            position = rl.Vector2{spawn.x, spawn.y},
            size = rl.Vector2{spawn.w, spawn.h},
            velocity = rl.Vector2{0, 0},
            active = true,
            target_room = target_room,
            target_position = rl.Vector2{spawn.target_x, spawn.target_y},
            requires_interact = spawn.interact,
            container_id = container_id,
            prop_id = prop_id,
        })

        if kind == .PLAYER {
            game.player_index = index
        }
    }

    return game.player_index >= 0
}
