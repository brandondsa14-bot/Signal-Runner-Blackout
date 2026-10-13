package main

import rl "vendor:raylib"

MAX_ENTITIES :: 48

Entity_Kind :: enum {
    PLAYER,
    WALL,
    TERMINAL,
    CEMETERY_DOOR,
    SIGNAL_BARRIER,
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
    game.entities[index] = entity
    game.entity_count += 1
    return index
}
