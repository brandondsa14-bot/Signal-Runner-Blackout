package main

import rl "vendor:raylib"

STORY_COUNT :: 7

Game :: struct {
    state:           Game_State,
    entities:        [MAX_ENTITIES]Entity,
    entity_count:    int,
    player_index:    int,

    story_page:      int,
    has_cemetery_key: bool,
    cemetery_door_open: bool,
    red_signal_on:   bool,

    message_timer:   f32,
    message_kind:    int,
}

new_game :: proc() -> Game {
    game := Game{
        state = .TITLE,
        entity_count = 0,
        player_index = -1,
        story_page = 0,
        has_cemetery_key = false,
        cemetery_door_open = false,
        red_signal_on = false,
        message_timer = 0,
        message_kind = 0,
    }

    setup_world(&game)
    return game
}

setup_world :: proc(game: ^Game) {
    game.entity_count = 0
    game.has_cemetery_key = false
    game.cemetery_door_open = false
    game.red_signal_on = false
    game.message_timer = 0
    game.message_kind = 0

    game.player_index = add_entity(game, Entity{
        kind = .PLAYER,
        position = rl.Vector2{150, 430},
        size = rl.Vector2{28, 36},
        velocity = rl.Vector2{0, 0},
        active = true,
    })

    // Outer visitor building
    _ = add_entity(game, Entity{kind=.WALL, position=rl.Vector2{70, 110}, size=rl.Vector2{650, 28}, active=true})
    _ = add_entity(game, Entity{kind=.WALL, position=rl.Vector2{70, 520}, size=rl.Vector2{650, 28}, active=true})
    _ = add_entity(game, Entity{kind=.WALL, position=rl.Vector2{70, 138}, size=rl.Vector2{28, 382}, active=true})

    // Top/right visitor wall segments, leaving a door gap
    _ = add_entity(game, Entity{kind=.WALL, position=rl.Vector2{692, 138}, size=rl.Vector2{28, 128}, active=true})
    _ = add_entity(game, Entity{kind=.WALL, position=rl.Vector2{692, 366}, size=rl.Vector2{28, 154}, active=true})

    // Interior wall - extends farther downward
_ = add_entity(game, Entity{
    kind = .WALL,
    position = rl.Vector2{360, 138},
    size = rl.Vector2{24, 250},
    active = true,
})

    // Terminal
    _ = add_entity(game, Entity{
        kind = .TERMINAL,
        position = rl.Vector2{250, 185},
        size = rl.Vector2{70, 52},
        active = true,
    })

   // Signal barrier - the ONLY passage through this wall
_ = add_entity(game, Entity{
    kind = .SIGNAL_BARRIER,
    position = rl.Vector2{360, 388},
    size = rl.Vector2{24, 132},
    active = true,
})

    // Cemetery door in right-side wall gap
    _ = add_entity(game, Entity{
    kind = .CEMETERY_DOOR,
    position = rl.Vector2{692, 266},
    size = rl.Vector2{28, 254},
    active = true,
})
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
            setup_world(game)
            game.state = .PLAYING
        }
    }
}

update_playing :: proc(game: ^Game, dt: f32) {
    if rl.IsKeyPressed(.ESCAPE) {
        game.state = .TITLE
        return
    }

    if rl.IsKeyPressed(.ONE) {
        game.red_signal_on = !game.red_signal_on
        game.message_kind = 3
        game.message_timer = 1.8
    }

    if game.message_timer > 0 {
        game.message_timer -= dt
    }

    player := &game.entities[game.player_index]
    old_position := player.position

    speed: f32 = 155
    player.velocity = rl.Vector2{0, 0}

    if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    { player.velocity[1] -= speed }
    if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  { player.velocity[1] += speed }
    if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  { player.velocity[0] -= speed }
    if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) { player.velocity[0] += speed }

    player.position[0] += player.velocity[0] * dt
    player.position[1] += player.velocity[1] * dt

    // Interactions use the same entity collection.
    if rl.IsKeyPressed(.E) {
        for i := 0; i < game.entity_count; i += 1 {
            entity := &game.entities[i]
            if !entity.active { continue }

            if entity.kind == .TERMINAL {
                if distance_sq(player.position, entity.position) < 130*130 {
                    if !game.has_cemetery_key {
                        game.has_cemetery_key = true
                        game.message_kind = 1
                        game.message_timer = 3.0
                    } else {
                        game.message_kind = 4
                        game.message_timer = 2.0
                    }
                }
            }

            if entity.kind == .CEMETERY_DOOR {
                if distance_sq(player.position, entity.position) < 140*140 {
                    if game.has_cemetery_key {
                        game.cemetery_door_open = true
                        game.message_kind = 2
                        game.message_timer = 2.0
                    } else {
                        game.message_kind = 5
                        game.message_timer = 2.0
                    }
                }
            }
        }
    }

    // Collision against the entity collection.
    player_rect := entity_rect(player)

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
    rl.DrawText("A top-down signal-horror adventure", 330, 320, 20, rl.GRAY)
    rl.DrawText("PRESS ENTER", 430, 430, 24, rl.LIGHTGRAY)
}

render_story :: proc(game: ^Game) {
    rl.ClearBackground(rl.BLACK)

    rl.DrawText("MARSHALL, NEBRASKA", 60, 55, 22, rl.GRAY)

    switch game.story_page {
    case 0:
        draw_story_chunk("Four people vanished in thirteen days.", false)
    case 1:
        draw_story_chunk("No bodies. No witnesses. No answers.", false)
    case 2:
        draw_story_chunk("Their cars waited near cemetery road.", false)
    case 3:
        draw_story_chunk("At 2:14 AM, your radio crackled.", false)
    case 4:
        draw_story_chunk("\"Officer... if you want them back...\"", false)
    case 5:
        draw_story_chunk("COME TO THE VISITOR GATE.", true)
    case 6:
        draw_story_chunk("AND DO NOT LET IT SEE YOU.", true)
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

    // Visitor checkpoint floor.
    rl.DrawRectangle(70, 110, 650, 438, rl.Color{42, 44, 50, 255})

    // Tile lines.
    for x: i32 = 98; x < 692; x += 46 {
        rl.DrawLine(x, 138, x, 520, rl.Color{62, 64, 70, 255})
    }
    for y: i32 = 138; y < 520; y += 46 {
        rl.DrawLine(98, y, 692, y, rl.Color{62, 64, 70, 255})
    }

    // Cemetery area to the right.
    rl.DrawRectangle(720, 110, 340, 438, rl.Color{18, 25, 20, 255})
    draw_cemetery()

    // RED signal changes the scene.
    if game.red_signal_on {
        rl.DrawRectangle(70, 110, 650, 438, rl.Color{100, 0, 15, 45})
        rl.DrawText("RED SIGNAL ACTIVE", 815, 25, 20, rl.RED)
    } else {
        rl.DrawText("RED SIGNAL OFF", 835, 25, 20, rl.GRAY)
    }

    // Draw all actual structured entities.
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active { continue }

        switch entity.kind {
        case .PLAYER:
            draw_player(entity.position)

        case .WALL:
            rect := entity_rect(entity)
            rl.DrawRectangleRec(rect, rl.Color{28, 30, 35, 255})
            rl.DrawRectangleLinesEx(rect, 2, rl.Color{78, 82, 90, 255})

        case .TERMINAL:
            draw_terminal(entity.position)

        case .SIGNAL_BARRIER:
            if !game.red_signal_on {
                rect := entity_rect(entity)
                rl.DrawRectangleRec(rect, rl.Color{65, 8, 12, 255})
                rl.DrawRectangleLinesEx(rect, 2, rl.RED)
            } else {
                rl.DrawRectangle(
                    i32(entity.position[0]),
                    i32(entity.position[1]),
                    i32(entity.size[0]),
                    i32(entity.size[1]),
                    rl.Color{115, 15, 25, 35},
                )
            }

        case .CEMETERY_DOOR:
            if !game.cemetery_door_open {
                rect := entity_rect(entity)
                rl.DrawRectangleRec(rect, rl.Color{72, 58, 45, 255})
                rl.DrawRectangleLinesEx(rect, 2, rl.BROWN)
            }
        }
    }

    // Prompts
    player := &game.entities[game.player_index]

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if entity.kind == .TERMINAL && distance_sq(player.position, entity.position) < 130*130 {
            rl.DrawText("E: ACCESS TERMINAL", 135, 565, 18, rl.RAYWHITE)
        }
        if entity.kind == .CEMETERY_DOOR && distance_sq(player.position, entity.position) < 140*140 && !game.cemetery_door_open {
            rl.DrawText("E: USE CEMETERY DOOR", 135, 590, 18, rl.RAYWHITE)
        }
    }

    if game.message_timer > 0 {
        draw_message(game.message_kind)
    }

    rl.DrawText("WASD/ARROWS: MOVE", 20, 20, 18, rl.RAYWHITE)
    rl.DrawText("E: INTERACT", 245, 20, 18, rl.RAYWHITE)
    rl.DrawText("1: RED SIGNAL", 390, 20, 18, rl.RAYWHITE)
    rl.DrawText("ESC: TITLE", 560, 20, 18, rl.RAYWHITE)
}

draw_terminal :: proc(position: rl.Vector2) {
    x := i32(position[0])
    y := i32(position[1])

    rl.DrawRectangle(x, y, 70, 52, rl.Color{38, 48, 45, 255})
    rl.DrawRectangle(x + 8, y + 8, 54, 23, rl.Color{20, 80, 55, 255})
    rl.DrawRectangle(x + 17, y + 38, 36, 7, rl.DARKGRAY)
    rl.DrawText("VISITOR", x + 5, y - 20, 12, rl.LIGHTGRAY)
}

draw_cemetery :: proc() {
    // Fence line.
    rl.DrawLine(735, 140, 1040, 140, rl.DARKGRAY)
    for x: i32 = 745; x < 1040; x += 36 {
        rl.DrawLine(x, 120, x, 158, rl.GRAY)
    }

    // Gravestones.
    draw_grave(770, 205)
    draw_grave(875, 185)
    draw_grave(965, 235)
    draw_grave(810, 365)
    draw_grave(930, 395)

    // Dead tree.
    rl.DrawRectangle(995, 320, 12, 95, rl.DARKBROWN)
    rl.DrawLine(1001, 335, 970, 300, rl.DARKBROWN)
    rl.DrawLine(1002, 350, 1030, 315, rl.DARKBROWN)
    rl.DrawLine(1000, 370, 972, 350, rl.DARKBROWN)

    // Skeleton remains: decorative and walk-over.
    rl.DrawCircle(820, 290, 8, rl.BEIGE)
    rl.DrawLine(828, 296, 860, 312, rl.BEIGE)
    rl.DrawLine(842, 304, 832, 325, rl.BEIGE)
    rl.DrawLine(842, 304, 855, 326, rl.BEIGE)
    rl.DrawLine(857, 311, 872, 301, rl.BEIGE)
    rl.DrawLine(857, 311, 873, 322, rl.BEIGE)

    // Mist patches.
    rl.DrawCircle(910, 300, 45, rl.Color{150, 155, 160, 18})
    rl.DrawCircle(790, 440, 55, rl.Color{150, 155, 160, 14})
}

draw_grave :: proc(x, y: i32) {
    rl.DrawRectangle(x, y + 10, 38, 36, rl.Color{76, 79, 82, 255})
    rl.DrawCircle(x + 19, y + 10, 19, rl.Color{76, 79, 82, 255})
    rl.DrawRectangle(x + 17, y + 14, 4, 20, rl.DARKGRAY)
    rl.DrawRectangle(x + 11, y + 21, 16, 4, rl.DARKGRAY)
}

draw_message :: proc(kind: int) {
    rl.DrawRectangle(230, 475, 640, 70, rl.Color{0, 0, 0, 215})
    rl.DrawRectangleLines(230, 475, 640, 70, rl.GRAY)

    switch kind {
    case 1:
        rl.DrawText("YOU OBTAINED: CEMETERY KEY", 315, 498, 24, rl.GOLD)
    case 2:
        rl.DrawText("THE CEMETERY DOOR UNLOCKS.", 330, 498, 23, rl.LIGHTGRAY)
    case 3:
        rl.DrawText("THE RED FREQUENCY SHIFTS THE ROOM.", 275, 498, 21, rl.RED)
    case 4:
        rl.DrawText("THE TERMINAL HAS NOTHING ELSE.", 320, 498, 21, rl.LIGHTGRAY)
    case 5:
        rl.DrawText("LOCKED. A KEY SLOT IS VISIBLE.", 325, 498, 21, rl.LIGHTGRAY)
    }
}

draw_player :: proc(position: rl.Vector2) {
    x := i32(position[0])
    y := i32(position[1])

    // Shadow
    rl.DrawEllipse(x + 14, y + 34, 13, 5, rl.Color{0, 0, 0, 100})

    // Legs
    rl.DrawRectangle(x + 6, y + 26, 6, 9, rl.DARKBLUE)
    rl.DrawRectangle(x + 17, y + 26, 6, 9, rl.DARKBLUE)

    // Police-style jacket
    rl.DrawRectangle(x + 4, y + 13, 20, 15, rl.BLUE)
    rl.DrawRectangle(x + 1, y + 15, 5, 12, rl.DARKBLUE)
    rl.DrawRectangle(x + 23, y + 15, 5, 12, rl.DARKBLUE)
    rl.DrawRectangle(x + 12, y + 17, 4, 4, rl.GOLD)

    // Head and hair
    rl.DrawRectangle(x + 7, y + 3, 15, 12, rl.BEIGE)
    rl.DrawRectangle(x + 6, y, 17, 6, rl.DARKBROWN)
    rl.DrawRectangle(x + 6, y + 4, 4, 6, rl.DARKBROWN)

    // Signal transmitter
    rl.DrawRectangle(x + 25, y + 20, 4, 8, rl.GRAY)
    rl.DrawRectangle(x + 26, y + 17, 2, 4, rl.RED)
}
