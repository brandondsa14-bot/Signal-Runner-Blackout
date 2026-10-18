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
}

Spawn_Data :: struct {
    kind: string,
    x:    f32,
    y:    f32,
    w:    f32,
    h:    f32,
}

Level_Data :: struct {
    spawns: []Spawn_Data,
}

load_tuning :: proc(path: string) -> Tuning {
    tuning := Tuning{
        player_speed = 155,
        interact_distance = 130,
        message_duration = 2.5,
        ambient_volume = 0.35,
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
    case "PLAYER":             return .PLAYER, true
    case "WALL":               return .WALL, true
    case "TERMINAL":           return .TERMINAL, true
    case "CEMETERY_DOOR":      return .CEMETERY_DOOR, true
    case "SIGNAL_BARRIER":     return .SIGNAL_BARRIER, true
    case "GRAVE_CLUE":         return .GRAVE_CLUE, true
    case "LIBRARY_TRIGGER":    return .LIBRARY_TRIGGER, true
    case "SIDE_ROOM_TRIGGER":  return .SIDE_ROOM_TRIGGER, true
    case "DUNGEON_DOOR":       return .DUNGEON_DOOR, true
    case "RETURN_TRIGGER":     return .RETURN_TRIGGER, true
    }
    return .WALL, false
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

        index := add_entity(game, Entity{
            kind = kind,
            position = rl.Vector2{spawn.x, spawn.y},
            size = rl.Vector2{spawn.w, spawn.h},
            velocity = rl.Vector2{0, 0},
            active = true,
        })

        if kind == .PLAYER {
            game.player_index = index
        }
    }

    return game.player_index >= 0
}
