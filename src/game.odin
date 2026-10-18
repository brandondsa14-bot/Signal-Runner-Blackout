package main

import rl "vendor:raylib"

STORY_COUNT :: 7

Game :: struct {
    state: Game_State,
    room:  Room_ID,

    entities:     [MAX_ENTITIES]Entity,
    entity_count: int,
    player_index: int,

    resources: ^Resources,
    tuning:    Tuning,

    story_page: int,

    has_cemetery_key:  bool,
    cemetery_door_open: bool,
    red_signal_on:      bool,

    grave_dialogue_step: int,
    hidden_stair_found:  bool,

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
        has_cemetery_key = false,
        cemetery_door_open = false,
        red_signal_on = false,
        grave_dialogue_step = 0,
        hidden_stair_found = false,
        message_timer = 0,
        message_kind = 0,
    }

    load_level_file(&game, "data/levels/entrance.json", .ENTRANCE)
    return game
}

reset_story_and_world :: proc(game: ^Game) {
    game.has_cemetery_key = false
    game.cemetery_door_open = false
    game.red_signal_on = false
    game.grave_dialogue_step = 0
    game.hidden_stair_found = false
    game.message_timer = 0
    game.message_kind = 0
    load_level_file(game, "data/levels/entrance.json", .ENTRANCE)
}

update_game :: proc(game: ^Game, dt: f32) {
    switch game.state {
    case .TITLE:
        update_title(game)
    case .STORY:
        update_story(game)
    case .PLAYING:
        update_playing(game, dt)
    }
}

update_title :: proc(game: ^Game) {
    if rl.IsKeyPressed(.ENTER) {
        game.story_page = 0
        game.state = .STORY
    }
}

update_story :: proc(game: ^Game) {
    if rl.IsKeyPressed(.ENTER) {
        game.story_page += 1
        if game.story_page >= STORY_COUNT {
            reset_story_and_world(game)
            game.state = .PLAYING
        }
    }
}

show_message :: proc(game: ^Game, kind: int) {
    game.message_kind = kind
    game.message_timer = game.tuning.message_duration
}

near_entity :: proc(game: ^Game, entity: ^Entity) -> bool {
    if game.player_index < 0 {
        return false
    }
    player := &game.entities[game.player_index]
    max_dist := game.tuning.interact_distance
    return distance_sq(player.position, entity.position) < max_dist*max_dist
}

update_playing :: proc(game: ^Game, dt: f32) {
    if rl.IsKeyPressed(.ESCAPE) {
        game.state = .TITLE
        return
    }

    if game.message_timer > 0 {
        game.message_timer -= dt
    }

    if game.player_index < 0 {
        return
    }

    if rl.IsKeyPressed(.ONE) && game.room == .ENTRANCE {
        game.red_signal_on = !game.red_signal_on
        show_message(game, 3)
    }

    player := &game.entities[game.player_index]
    old_position := player.position

    // CP3: movement speed comes from data/tuning.json, not a code literal.
    speed := game.tuning.player_speed
    player.velocity = rl.Vector2{0, 0}

    if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    { player.velocity[1] -= speed }
    if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  { player.velocity[1] += speed }
    if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  { player.velocity[0] -= speed }
    if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) { player.velocity[0] += speed }

    player.position[0] += player.velocity[0] * dt
    player.position[1] += player.velocity[1] * dt

    player_rect := entity_rect(player)

    // Interactions and room transitions all use entities loaded from level data files.
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || entity.kind == .PLAYER {
            continue
        }

        if entity.kind == .TERMINAL && near_entity(game, entity) && rl.IsKeyPressed(.E) {
            if !game.has_cemetery_key {
                game.has_cemetery_key = true
                show_message(game, 1)
                rl.PlaySound(game.resources.pickup_sound)
            } else {
                show_message(game, 4)
            }
        }

        if entity.kind == .CEMETERY_DOOR && near_entity(game, entity) && rl.IsKeyPressed(.E) {
            if game.has_cemetery_key {
                game.cemetery_door_open = true
                show_message(game, 2)
                rl.PlaySound(game.resources.pickup_sound)
            } else {
                show_message(game, 5)
            }
        }

        if entity.kind == .GRAVE_CLUE && near_entity(game, entity) && rl.IsKeyPressed(.E) {
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
                load_level_file(game, "data/levels/underground_hall.json", .UNDERGROUND_HALL)
                return
            }
        }

        // Library and side room are seamless: touching their doorway changes room immediately.
        if entity.kind == .LIBRARY_TRIGGER && rl.CheckCollisionRecs(player_rect, entity_rect(entity)) {
            load_level_file(game, "data/levels/library.json", .LIBRARY)
            return
        }
        if entity.kind == .SIDE_ROOM_TRIGGER && rl.CheckCollisionRecs(player_rect, entity_rect(entity)) {
            load_level_file(game, "data/levels/side_room.json", .SIDE_ROOM)
            return
        }

        // Dungeon is deliberately the only underground doorway requiring E.
        if entity.kind == .DUNGEON_DOOR && near_entity(game, entity) && rl.IsKeyPressed(.E) {
            load_level_file(game, "data/levels/dungeon.json", .DUNGEON)
            return
        }

        if entity.kind == .RETURN_TRIGGER && rl.CheckCollisionRecs(player_rect, entity_rect(entity)) {
            load_level_file(game, "data/levels/underground_hall.json", .UNDERGROUND_HALL)
            return
        }
    }

    // Collision against solid entities.
    player_rect = entity_rect(player)
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || entity.kind == .PLAYER {
            continue
        }

        solid := entity.kind == .WALL
        if entity.kind == .SIGNAL_BARRIER {
            solid = !game.red_signal_on
        }
        if entity.kind == .CEMETERY_DOOR {
            solid = !game.cemetery_door_open
        }

        if solid && rl.CheckCollisionRecs(player_rect, entity_rect(entity)) {
            player.position = old_position
            break
        }
    }
}

distance_sq :: proc(a, b: rl.Vector2) -> f32 {
    dx := a[0] - b[0]
    dy := a[1] - b[1]
    return dx*dx + dy*dy
}

render_game :: proc(game: ^Game) {
    switch game.state {
    case .TITLE:
        render_title()
    case .STORY:
        render_story(game)
    case .PLAYING:
        render_playing(game)
    }
}

render_title :: proc() {
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("SIGNAL RUNNER", 330, 185, 54, rl.RAYWHITE)
    rl.DrawText("BLACKOUT", 420, 245, 42, rl.RED)
    rl.DrawText("A top-down murder-mystery horror adventure", 285, 320, 20, rl.GRAY)
    rl.DrawText("PRESS ENTER", 430, 430, 24, rl.LIGHTGRAY)
}

render_story :: proc(game: ^Game) {
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("MARSHALL, NEBRASKA", 60, 55, 22, rl.GRAY)

    switch game.story_page {
    case 0: draw_story_chunk("Four people vanished in thirteen days.", false)
    case 1: draw_story_chunk("No bodies. No witnesses. No answers.", false)
    case 2: draw_story_chunk("Their cars waited near cemetery road.", false)
    case 3: draw_story_chunk("At 2:14 AM, your radio crackled.", false)
    case 4: draw_story_chunk("\"Officer... if you want them back...\"", false)
    case 5: draw_story_chunk("COME TO THE VISITOR GATE.", true)
    case 6: draw_story_chunk("AND DO NOT LET IT SEE YOU.", true)
    }

    rl.DrawText("ENTER", 500, 555, 18, rl.DARKGRAY)
}

draw_story_chunk :: proc(text: cstring, danger: bool) {
    if danger {
        rl.DrawText(text, 105, 285, 34, rl.RED)
    } else {
        rl.DrawText(text, 105, 285, 30, rl.RAYWHITE)
    }
}

render_playing :: proc(game: ^Game) {
    rl.ClearBackground(rl.BLACK)

    switch game.room {
    case .ENTRANCE:         draw_entrance_background(game)
    case .UNDERGROUND_HALL: draw_underground_hall()
    case .LIBRARY:          draw_library()
    case .SIDE_ROOM:        draw_side_room()
    case .DUNGEON:          draw_dungeon()
    }

    // Entities were loaded from data/levels/*.json.
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active {
            continue
        }

        switch entity.kind {
        case .PLAYER:
            draw_player_texture(game, entity.position)
        case .WALL:
            // Walls are mostly visually represented by each room's art; subtle collider edge helps readability.
            rect := entity_rect(entity)
            rl.DrawRectangleLinesEx(rect, 1, rl.Color{70, 72, 78, 80})
        case .TERMINAL:
            draw_terminal(entity.position)
        case .SIGNAL_BARRIER:
            if !game.red_signal_on {
                rect := entity_rect(entity)
                rl.DrawRectangleRec(rect, rl.Color{65, 8, 12, 255})
                rl.DrawRectangleLinesEx(rect, 2, rl.RED)
            }
        case .CEMETERY_DOOR:
            if !game.cemetery_door_open {
                rect := entity_rect(entity)
                rl.DrawRectangleRec(rect, rl.Color{72, 58, 45, 255})
                rl.DrawRectangleLinesEx(rect, 2, rl.BROWN)
            }
        case .GRAVE_CLUE:
            // The grave itself is drawn in the cemetery art.
        case .LIBRARY_TRIGGER:
            // Invisible seamless transition zone.
        case .SIDE_ROOM_TRIGGER:
            // Invisible seamless transition zone.
        case .RETURN_TRIGGER:
            // Invisible seamless transition zone.
        case .DUNGEON_DOOR:
            draw_dungeon_door(entity.position, entity.size)
        }
    }

    draw_interaction_prompt(game)

    if game.message_timer > 0 {
        draw_message(game)
    }

    rl.DrawText("WASD/ARROWS: MOVE", 20, 20, 18, rl.RAYWHITE)
    rl.DrawText("E: INTERACT", 245, 20, 18, rl.RAYWHITE)
    if game.room == .ENTRANCE {
        rl.DrawText("1: RED SIGNAL", 390, 20, 18, rl.RAYWHITE)
    }
    rl.DrawText("ESC: TITLE", 560, 20, 18, rl.RAYWHITE)
}

// ---------- Entrance / cemetery ----------

draw_entrance_background :: proc(game: ^Game) {
    rl.DrawRectangle(70, 110, 650, 438, rl.Color{42, 44, 50, 255})
    for x: i32 = 98; x < 692; x += 46 {
        rl.DrawLine(x, 138, x, 520, rl.Color{62, 64, 70, 255})
    }
    for y: i32 = 138; y < 520; y += 46 {
        rl.DrawLine(98, y, 692, y, rl.Color{62, 64, 70, 255})
    }

    // Visible structure around the visitor entrance.
    rl.DrawRectangle(70, 110, 650, 28, rl.Color{28, 30, 35, 255})
    rl.DrawRectangle(70, 520, 650, 28, rl.Color{28, 30, 35, 255})
    rl.DrawRectangle(70, 138, 28, 382, rl.Color{28, 30, 35, 255})
    rl.DrawRectangle(692, 138, 28, 128, rl.Color{28, 30, 35, 255})
    rl.DrawRectangle(360, 138, 24, 250, rl.Color{28, 30, 35, 255})

    rl.DrawRectangle(720, 110, 340, 438, rl.Color{18, 25, 20, 255})
    draw_cemetery(game)

    if game.red_signal_on {
        rl.DrawRectangle(70, 110, 650, 438, rl.Color{100, 0, 15, 45})
        rl.DrawText("RED SIGNAL ACTIVE", 815, 25, 20, rl.RED)
    } else {
        rl.DrawText("RED SIGNAL OFF", 835, 25, 20, rl.GRAY)
    }
}

draw_terminal :: proc(position: rl.Vector2) {
    x := i32(position[0])
    y := i32(position[1])
    rl.DrawRectangle(x, y, 70, 52, rl.Color{38, 48, 45, 255})
    rl.DrawRectangle(x + 8, y + 8, 54, 23, rl.Color{20, 80, 55, 255})
    rl.DrawRectangle(x + 17, y + 38, 36, 7, rl.DARKGRAY)
    rl.DrawText("VISITOR", x + 5, y - 20, 12, rl.LIGHTGRAY)
}

draw_cemetery :: proc(game: ^Game) {
    rl.DrawLine(735, 140, 1040, 140, rl.DARKGRAY)
    for x: i32 = 745; x < 1040; x += 36 {
        rl.DrawLine(x, 120, x, 158, rl.GRAY)
    }

    draw_grave(770, 205, false)
    draw_grave(875, 185, false)
    draw_grave(965, 235, true)
    draw_grave(810, 365, false)
    draw_grave(930, 395, false)

    rl.DrawRectangle(995, 320, 12, 95, rl.DARKBROWN)
    rl.DrawLine(1001, 335, 970, 300, rl.DARKBROWN)
    rl.DrawLine(1002, 350, 1030, 315, rl.DARKBROWN)
    rl.DrawLine(1000, 370, 972, 350, rl.DARKBROWN)

    // Decorative skeleton remains; non-solid so the player can walk over them.
    rl.DrawCircle(820, 290, 8, rl.BEIGE)
    rl.DrawLine(828, 296, 860, 312, rl.BEIGE)
    rl.DrawLine(842, 304, 832, 325, rl.BEIGE)
    rl.DrawLine(842, 304, 855, 326, rl.BEIGE)
    rl.DrawLine(857, 311, 872, 301, rl.BEIGE)
    rl.DrawLine(857, 311, 873, 322, rl.BEIGE)

    rl.DrawCircle(910, 300, 45, rl.Color{150, 155, 160, 18})
    rl.DrawCircle(790, 440, 55, rl.Color{150, 155, 160, 14})

    if game.hidden_stair_found {
        // Hidden staircase revealed behind the far-right grave.
        rl.DrawRectangle(954, 280, 64, 64, rl.Color{12, 12, 14, 255})
        for y: i32 = 287; y < 338; y += 9 {
            rl.DrawLine(960, y, 1012, y, rl.GRAY)
        }
        rl.DrawText("STAIRS", 961, 348, 12, rl.LIGHTGRAY)
    }
}

draw_grave :: proc(x, y: i32, clue: bool) {
    color := rl.Color{76, 79, 82, 255}
    if clue {
        color = rl.Color{86, 90, 95, 255}
    }
    rl.DrawRectangle(x, y + 10, 38, 36, color)
    rl.DrawCircle(x + 19, y + 10, 19, color)
    rl.DrawRectangle(x + 17, y + 14, 4, 20, rl.DARKGRAY)
    rl.DrawRectangle(x + 11, y + 21, 16, 4, rl.DARKGRAY)
}

// ---------- Underground ----------

draw_wood_floor :: proc(x0, y0, w, h: i32) {
    rl.DrawRectangle(x0, y0, w, h, rl.Color{70, 46, 31, 255})
    for y: i32 = y0; y < y0 + h; y += 28 {
        rl.DrawLine(x0, y, x0 + w, y, rl.Color{42, 28, 20, 255})
    }
    for x: i32 = x0; x < x0 + w; x += 110 {
        rl.DrawLine(x, y0, x, y0 + h, rl.Color{88, 58, 38, 255})
    }
}

draw_underground_hall :: proc() {
    draw_wood_floor(70, 90, 960, 478)
    rl.DrawRectangle(70, 90, 960, 28, rl.Color{24, 22, 24, 255})
    rl.DrawRectangle(70, 540, 960, 28, rl.Color{24, 22, 24, 255})
    rl.DrawRectangle(70, 118, 28, 422, rl.Color{24, 22, 24, 255})
    rl.DrawRectangle(1002, 118, 28, 422, rl.Color{24, 22, 24, 255})

    rl.DrawRectangle(180, 90, 150, 34, rl.Color{13, 13, 16, 255})
    rl.DrawText("LIBRARY", 211, 96, 18, rl.GOLD)
    rl.DrawRectangle(720, 90, 150, 34, rl.Color{13, 13, 16, 255})
    rl.DrawText("ROOM", 763, 96, 18, rl.LIGHTGRAY)
    rl.DrawText("A long passage runs beneath the cemetery.", 330, 145, 18, rl.Color{185, 175, 160, 255})
}

draw_library :: proc() {
    draw_wood_floor(90, 100, 820, 428)
    rl.DrawText("OLD ARCHIVE LIBRARY", 365, 135, 24, rl.GOLD)

    for x: i32 = 145; x <= 745; x += 200 {
        rl.DrawRectangle(x, 175, 120, 180, rl.Color{58, 38, 28, 255})
        for y: i32 = 195; y < 340; y += 35 {
            rl.DrawLine(x + 8, y, x + 112, y, rl.BROWN)
        }
        // Books, only decorative for now.
        rl.DrawRectangle(x + 14, 205, 15, 28, rl.MAROON)
        rl.DrawRectangle(x + 34, 201, 12, 32, rl.DARKBLUE)
        rl.DrawRectangle(x + 52, 208, 17, 25, rl.DARKGREEN)
        rl.DrawRectangle(x + 75, 198, 13, 35, rl.PURPLE)
    }

    rl.DrawRectangle(410, 385, 180, 58, rl.DARKBROWN)
    rl.DrawRectangle(485, 365, 32, 20, rl.GOLD)
    rl.DrawText("EXIT", 506, 482, 14, rl.GRAY)
}

draw_side_room :: proc() {
    draw_wood_floor(90, 100, 820, 428)
    rl.DrawText("ABANDONED STAFF ROOM", 365, 135, 24, rl.LIGHTGRAY)

    rl.DrawRectangle(145, 190, 210, 95, rl.Color{70, 64, 58, 255})
    rl.DrawRectangle(155, 198, 190, 32, rl.Color{120, 115, 105, 255})
    rl.DrawText("BED", 225, 245, 14, rl.DARKGRAY)

    rl.DrawRectangle(685, 185, 120, 160, rl.DARKBROWN)
    rl.DrawLine(745, 185, 745, 345, rl.BROWN)
    rl.DrawCircle(735, 270, 3, rl.GOLD)
    rl.DrawCircle(755, 270, 3, rl.GOLD)

    // Small grimy window.
    rl.DrawRectangle(450, 175, 140, 80, rl.Color{35, 47, 50, 255})
    rl.DrawRectangleLines(450, 175, 140, 80, rl.GRAY)
    rl.DrawLine(520, 175, 520, 255, rl.GRAY)
    rl.DrawLine(450, 215, 590, 215, rl.GRAY)
    rl.DrawText("EXIT", 506, 482, 14, rl.GRAY)
}

draw_dungeon_door :: proc(position, size: rl.Vector2) {
    x := i32(position[0])
    y := i32(position[1])
    w := i32(size[0])
    h := i32(size[1])
    rl.DrawRectangle(x, y, w, h, rl.Color{20, 20, 22, 255})
    rl.DrawRectangleLines(x, y, w, h, rl.GRAY)
    for bx: i32 = x + 12; bx < x + w - 8; bx += 18 {
        rl.DrawLine(bx, y, bx, y + h, rl.DARKGRAY)
    }
    rl.DrawText("DUNGEON", x + 33, y + 17, 18, rl.RED)
}

draw_dungeon :: proc() {
    rl.DrawRectangle(55, 80, 990, 498, rl.Color{37, 37, 40, 255})
    for y: i32 = 108; y < 550; y += 44 {
        rl.DrawLine(83, y, 1017, y, rl.Color{52, 52, 56, 255})
    }
    for x: i32 = 83; x < 1017; x += 58 {
        rl.DrawLine(x, 108, x, 550, rl.Color{47, 47, 50, 255})
    }

    rl.DrawText("DETENTION BLOCK", 430, 112, 24, rl.LIGHTGRAY)

    draw_cell(95, 165, "01")
    draw_cell(210, 165, "02")
    draw_cell(355, 165, "03")
    draw_cell(765, 165, "04")
    draw_cell(900, 165, "05")

    // Warden's office with a visible interior window.
    rl.DrawRectangle(515, 155, 205, 260, rl.Color{56, 46, 38, 255})
    rl.DrawRectangleLines(515, 155, 205, 260, rl.BROWN)
    rl.DrawText("WARDEN'S OFFICE", 535, 170, 16, rl.GOLD)
    rl.DrawRectangle(545, 205, 145, 78, rl.Color{20, 32, 36, 255})
    rl.DrawRectangleLines(545, 205, 145, 78, rl.GRAY)
    rl.DrawLine(617, 205, 617, 283, rl.GRAY)
    rl.DrawLine(545, 244, 690, 244, rl.GRAY)
    rl.DrawRectangle(555, 320, 115, 45, rl.DARKBROWN)
    rl.DrawRectangle(680, 305, 18, 72, rl.Color{90, 78, 65, 255})

    rl.DrawText("EXIT", 515, 532, 14, rl.GRAY)
}

draw_cell :: proc(x, y: i32, number: cstring) {
    rl.DrawRectangle(x, y, 105, 245, rl.Color{24, 24, 27, 255})
    rl.DrawRectangleLines(x, y, 105, 245, rl.DARKGRAY)
    for bx: i32 = x + 10; bx < x + 100; bx += 18 {
        rl.DrawLine(bx, y, bx, y + 245, rl.GRAY)
    }
    rl.DrawText(number, x + 40, y + 12, 16, rl.RED)
    // Tiny interior window/art detail.
    rl.DrawRectangle(x + 24, y + 75, 55, 38, rl.Color{18, 29, 34, 255})
    rl.DrawRectangleLines(x + 24, y + 75, 55, 38, rl.DARKGRAY)
    rl.DrawRectangle(x + 38, y + 175, 32, 9, rl.Color{70, 65, 58, 255})
}

// ---------- Shared rendering / UI ----------

draw_player_texture :: proc(game: ^Game, position: rl.Vector2) {
    // The texture is shared from game.resources; it is never loaded here.
    rl.DrawTextureEx(game.resources.player_texture, position, 0, 1.0, rl.WHITE)
}

draw_interaction_prompt :: proc(game: ^Game) {
    if game.player_index < 0 {
        return
    }

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || !near_entity(game, entity) {
            continue
        }

        switch entity.kind {
        case .TERMINAL:
            draw_prompt("PRESS E TO ACCESS TERMINAL")
            return
        case .CEMETERY_DOOR:
            if !game.cemetery_door_open {
                draw_prompt("PRESS E TO USE CEMETERY DOOR")
                return
            }
        case .GRAVE_CLUE:
            if game.hidden_stair_found {
                draw_prompt("PRESS E TO DESCEND THE HIDDEN STAIRS")
            } else {
                draw_prompt("PRESS E TO INSPECT THE GRAVE")
            }
            return
        case .DUNGEON_DOOR:
            draw_prompt("PRESS E TO ENTER THE DUNGEON")
            return
        case .PLAYER, .WALL, .SIGNAL_BARRIER, .LIBRARY_TRIGGER, .SIDE_ROOM_TRIGGER, .RETURN_TRIGGER:
            // These entity kinds do not show an interaction prompt.
        }
    }
}

draw_prompt :: proc(text: cstring) {
    rl.DrawRectangle(300, 570, 500, 42, rl.Color{0, 0, 0, 220})
    rl.DrawRectangleLines(300, 570, 500, 42, rl.GRAY)
    rl.DrawText(text, 328, 582, 17, rl.RAYWHITE)
}

draw_message :: proc(game: ^Game) {
    rl.DrawRectangle(185, 456, 730, 100, rl.Color{0, 0, 0, 225})
    rl.DrawRectangleLines(185, 456, 730, 100, rl.GRAY)

    // Portrait texture is also loaded once and shared.
    if game.message_kind >= 6 && game.message_kind <= 8 {
        rl.DrawTextureEx(game.resources.player_portrait, rl.Vector2{198, 459}, 0, 0.88, rl.WHITE)
    }

    switch game.message_kind {
    case 1:
        rl.DrawText("YOU OBTAINED: CEMETERY KEY", 315, 492, 24, rl.GOLD)
    case 2:
        rl.DrawText("THE CEMETERY DOOR UNLOCKS.", 330, 492, 23, rl.LIGHTGRAY)
    case 3:
        rl.DrawText("THE RED FREQUENCY SHIFTS THE ROOM.", 275, 492, 21, rl.RED)
    case 4:
        rl.DrawText("THE TERMINAL HAS NOTHING ELSE.", 320, 492, 21, rl.LIGHTGRAY)
    case 5:
        rl.DrawText("LOCKED. A KEY SLOT IS VISIBLE.", 325, 492, 21, rl.LIGHTGRAY)
    case 6:
        rl.DrawText("There's light coming through...", 305, 480, 22, rl.RAYWHITE)
    case 7:
        rl.DrawText("Digging... digging...", 305, 480, 22, rl.RAYWHITE)
    case 8:
        rl.DrawText("There's a hidden stairway here...", 305, 476, 21, rl.RAYWHITE)
        rl.DrawText("Better take a look.", 305, 510, 21, rl.RAYWHITE)
    }
}
