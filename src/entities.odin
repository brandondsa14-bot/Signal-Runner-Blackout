package main

import rl "vendor:raylib"

MAX_ENTITIES :: 160

Entity_Kind :: enum {
    PLAYER,
    WALL,
    BLOCKER,

    // Surface / cemetery systems preserved from earlier checkpoints.
    TERMINAL,
    CEMETERY_DOOR,
    SIGNAL_BARRIER,
    GRAVE_CLUE,

    // Generic facility navigation.
    DOOR_TRIGGER,
    MONSTER_SPAWN,
    MONSTER_ENTRY,
    HIDE_SPOT,
    SEARCHABLE_CONTAINER,

    // Reception / power.
    FUSE_ITEM,
    POWER_PANEL,

    // Security control room.
    SECURITY_CONSOLE,
    SECURITY_CLUE,
    LASER_BARRIER,

    // Archive / investigation.
    ARCHIVE_RECORDS,
    ARCHIVE_HIDDEN_CLUE,

    // Laboratory frequency alignment.
    LAB_AUDIO_LOG,
    LAB_RECEIVER_A,
    LAB_RECEIVER_B,
    LAB_RECEIVER_C,

    // Detention block.
    DETENTION_CONSOLE,
    CELL_KEY_ITEM,
    MISSING_EFFECTS,

    // Maintenance.
    SCREWDRIVER_ITEM,
    MAINT_PANEL,
    NOISE_PIPE,

    // Containment.
    CONTAINMENT_NODE_A,
    CONTAINMENT_NODE_B,
    CONTAINMENT_NODE_C,
    EXPERIMENT_LOG,

    // Final investigation / optional lore.
    FINAL_TERMINAL,
    OPTIONAL_NOTE,
    OPTIONAL_PHOTO,

    // Legacy CP3/CP4 map kinds retained so earlier checkpoint data remains readable.
    LIBRARY_TRIGGER,
    SIDE_ROOM_TRIGGER,
    DUNGEON_DOOR,
    RETURN_TRIGGER,
    LIBRARY_KEY_ITEM,
    STAFF_LOCKER,
    WARDEN_DESK,
    ENDING_EXIT,
}

Entity :: struct {
    kind:              Entity_Kind,
    position:          rl.Vector2,
    size:              rl.Vector2,
    velocity:          rl.Vector2,
    active:            bool,
    target_room:       Room_ID,
    target_position:   rl.Vector2,
    requires_interact: bool,
    container_id:      Container_ID,
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
