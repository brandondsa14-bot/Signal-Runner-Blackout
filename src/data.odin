package main

import "core:encoding/json"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Tuning :: struct {
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
}

Level_Data :: struct {
    spawns: []Spawn_Data,
}

load_tuning :: proc(path: string) -> Tuning {
    tuning := Tuning{
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
    }

    data, read_err := os.read_entire_file(path, context.allocator)
    if read_err != nil {
        fmt.eprintfln("Could not read tuning file %s: %v", path, read_err)
        return tuning
    }
    defer delete(data)

    unmarshal_err := json.unmarshal(data, &tuning)
    if unmarshal_err != nil {
        fmt.eprintfln("Could not parse tuning file %s", path)
    }

    return tuning
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

room_id_from_string :: proc(name: string) -> (Room_ID, bool) {
    switch name {
    case "ENTRANCE":       return .ENTRANCE, true
    case "RECEPTION":      return .RECEPTION, true
    case "SECURITY":       return .SECURITY, true
    case "ARCHIVE":        return .ARCHIVE, true
    case "LABORATORY":     return .LABORATORY, true
    case "DETENTION":      return .DETENTION, true
    case "MAINTENANCE":    return .MAINTENANCE, true
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
        }
        delete(level.spawns)
    }

    game.entity_count = 0
    game.player_index = -1
    game.room = room

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

        index := add_entity(game, Entity{
            kind = kind,
            position = rl.Vector2{spawn.x, spawn.y},
            size = rl.Vector2{spawn.w, spawn.h},
            velocity = rl.Vector2{0, 0},
            active = true,
            target_room = target_room,
            target_position = rl.Vector2{spawn.target_x, spawn.target_y},
            requires_interact = spawn.interact,
        })

        if kind == .PLAYER {
            game.player_index = index
        }
    }

    return game.player_index >= 0
}
