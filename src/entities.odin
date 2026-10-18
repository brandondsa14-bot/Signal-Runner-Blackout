package main

import rl "vendor:raylib"

MAX_ENTITIES :: 64

Entity_Kind :: enum {
    PLAYER,
    WALL,
    TERMINAL,
    CEMETERY_DOOR,
    SIGNAL_BARRIER,
    GRAVE_CLUE,
    LIBRARY_TRIGGER,
    SIDE_ROOM_TRIGGER,
    DUNGEON_DOOR,
    RETURN_TRIGGER,
}

Entity :: struct {
    kind:     Entity_Kind,
    position: rl.Vector2,
    size:     rl.Vector2,
    velocity: rl.Vector2,
    active:   bool,
}

entity_rect :: proc(entity: ^Entity) -> rl.Rectangle {
    return rl.Rectangle{
        x = entity.position[0],
        y = entity.position[1],
        width = entity.size[0],
        height = entity.size[1],
    }
}

add_entity :: proc(game: ^Game, entity: Entity) -> int {
    index := game.entity_count
    if index >= MAX_ENTITIES {
        return -1
    }
    game.entities[index] = entity
    game.entity_count += 1
    return index
}
