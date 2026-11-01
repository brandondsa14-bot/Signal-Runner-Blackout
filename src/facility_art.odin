package main

import rl "vendor:raylib"

// ---------- Shared environment helpers ----------

draw_concrete_floor :: proc(x, y, w, h: i32, base: rl.Color) {
    rl.DrawRectangle(x, y, w, h, base)
    for yy: i32 = y; yy < y + h; yy += 38 {
        rl.DrawLine(x, yy, x + w, yy, rl.Color{70, 72, 72, 65})
    }
    for xx: i32 = x; xx < x + w; xx += 76 {
        rl.DrawLine(xx, y, xx, y + h, rl.Color{60, 62, 62, 45})
    }
}

draw_tile_floor :: proc(x, y, w, h: i32, base: rl.Color) {
    rl.DrawRectangle(x, y, w, h, base)
    for yy: i32 = y; yy < y + h; yy += 42 {
        rl.DrawLine(x, yy, x + w, yy, rl.Color{85, 90, 92, 80})
    }
    for xx: i32 = x; xx < x + w; xx += 42 {
        rl.DrawLine(xx, y, xx, y + h, rl.Color{85, 90, 92, 60})
    }
}

draw_wood_floor :: proc(x, y, w, h: i32) {
    rl.DrawRectangle(x, y, w, h, rl.Color{76, 48, 30, 255})
    for yy: i32 = y; yy < y + h; yy += 24 {
        rl.DrawLine(x, yy, x + w, yy, rl.Color{47, 30, 20, 190})
    }
    for xx: i32 = x; xx < x + w; xx += 105 {
        rl.DrawLine(xx, y, xx, y + h, rl.Color{98, 61, 35, 150})
    }
}

draw_wall_shell :: proc() {
    rl.DrawRectangle(50, 85, 1000, 25, rl.Color{30, 32, 34, 255})
    rl.DrawRectangle(50, 540, 1000, 25, rl.Color{30, 32, 34, 255})
    rl.DrawRectangle(50, 110, 25, 430, rl.Color{30, 32, 34, 255})
    rl.DrawRectangle(1025, 110, 25, 430, rl.Color{30, 32, 34, 255})
}

draw_monitor :: proc(x, y, w, h: i32, active: bool) {
    rl.DrawRectangle(x, y, w, h, rl.Color{28, 31, 34, 255})
    screen := rl.Color{22, 55, 46, 255}
    if active { screen = rl.Color{22, 92, 67, 255} }
    rl.DrawRectangle(x + 6, y + 6, w - 12, h - 18, screen)
    rl.DrawLine(x + 10, y + 17, x + w - 11, y + 17, rl.Color{110, 200, 160, 120})
    rl.DrawRectangle(x + w/2 - 10, y + h - 9, 20, 5, rl.DARKGRAY)
}

draw_cabinet :: proc(x, y, w, h: i32, color: rl.Color) {
    rl.DrawRectangle(x, y, w, h, color)
    rl.DrawRectangleLines(x, y, w, h, rl.DARKGRAY)
    rl.DrawLine(x + w/2, y, x + w/2, y + h, rl.DARKGRAY)
    rl.DrawCircle(x + w/2 - 6, y + h/2, 2, rl.GOLD)
    rl.DrawCircle(x + w/2 + 6, y + h/2, 2, rl.GOLD)
}

draw_shelf :: proc(x, y, w, h: i32, books: bool) {
    rl.DrawRectangle(x, y, w, h, rl.Color{62, 48, 37, 255})
    rl.DrawRectangleLines(x, y, w, h, rl.Color{25, 22, 20, 255})
    for yy: i32 = y + 28; yy < y + h; yy += 36 {
        rl.DrawLine(x + 4, yy, x + w - 4, yy, rl.Color{25, 22, 20, 255})
    }
    if books {
        for xx: i32 = x + 8; xx < x + w - 10; xx += 14 {
            c := rl.Color{72, 91, 86, 255}
            if (xx/14)%3 == 1 { c = rl.Color{105, 66, 61, 255} }
            if (xx/14)%3 == 2 { c = rl.Color{93, 82, 48, 255} }
            rl.DrawRectangle(xx, y + 8, 9, 18, c)
        }
    }
}

draw_blood_stain :: proc(x, y: i32) {
    rl.DrawCircle(x, y, 9, rl.Color{76, 12, 16, 150})
    rl.DrawCircle(x + 12, y + 4, 5, rl.Color{68, 8, 13, 125})
    rl.DrawLine(x - 8, y + 7, x - 25, y + 20, rl.Color{70, 10, 14, 95})
}

draw_pipe_bundle :: proc(x, y, w: i32) {
    rl.DrawLine(x, y, x + w, y, rl.Color{100, 105, 105, 255})
    rl.DrawLine(x, y + 8, x + w, y + 8, rl.Color{66, 70, 70, 255})
    for xx: i32 = x + 25; xx < x + w; xx += 90 {
        rl.DrawCircle(xx, y + 4, 6, rl.Color{85, 89, 90, 255})
    }
}

// ---------- Surface / cemetery preserved ----------

draw_entrance_background :: proc(game: ^Game) {
    rl.DrawRectangle(70, 110, 650, 438, rl.Color{42, 44, 50, 255})
    for x: i32 = 98; x < 692; x += 46 {
        rl.DrawLine(x, 138, x, 520, rl.Color{62, 64, 70, 255})
    }
    for y: i32 = 138; y < 520; y += 46 {
        rl.DrawLine(98, y, 692, y, rl.Color{62, 64, 70, 255})
    }

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
    x := i32(position[0]); y := i32(position[1])
    rl.DrawRectangle(x, y, 70, 52, rl.Color{38, 48, 45, 255})
    rl.DrawRectangle(x + 8, y + 8, 54, 23, rl.Color{20, 80, 55, 255})
    rl.DrawRectangle(x + 17, y + 38, 36, 7, rl.DARKGRAY)
    rl.DrawText("VISITOR", x + 5, y - 20, 12, rl.LIGHTGRAY)
}

draw_grave :: proc(x, y: i32, clue: bool) {
    color := rl.Color{76, 79, 82, 255}
    if clue { color = rl.Color{91, 95, 100, 255} }
    rl.DrawRectangle(x, y + 10, 38, 36, color)
    rl.DrawCircle(x + 19, y + 10, 19, color)
    rl.DrawRectangle(x + 17, y + 14, 4, 20, rl.DARKGRAY)
    rl.DrawRectangle(x + 11, y + 21, 16, 4, rl.DARKGRAY)
}

draw_cemetery :: proc(game: ^Game) {
    rl.DrawLine(735, 140, 1040, 140, rl.DARKGRAY)
    for x: i32 = 745; x < 1040; x += 36 { rl.DrawLine(x, 120, x, 158, rl.GRAY) }
    draw_grave(770, 205, false); draw_grave(875, 185, false); draw_grave(965, 235, true)
    draw_grave(810, 365, false); draw_grave(930, 395, false)

    rl.DrawRectangle(995, 320, 12, 95, rl.DARKBROWN)
    rl.DrawLine(1001, 335, 970, 300, rl.DARKBROWN)
    rl.DrawLine(1002, 350, 1030, 315, rl.DARKBROWN)
    rl.DrawLine(1000, 370, 972, 350, rl.DARKBROWN)

    rl.DrawCircle(820, 290, 8, rl.BEIGE)
    rl.DrawLine(828, 296, 860, 312, rl.BEIGE)
    rl.DrawLine(842, 304, 832, 325, rl.BEIGE)
    rl.DrawLine(842, 304, 855, 326, rl.BEIGE)
    rl.DrawLine(857, 311, 872, 301, rl.BEIGE)
    rl.DrawLine(857, 311, 873, 322, rl.BEIGE)

    if game.hidden_stair_found {
        rl.DrawRectangle(954, 280, 64, 64, rl.Color{12, 12, 14, 255})
        for y: i32 = 287; y < 338; y += 9 { rl.DrawLine(960, y, 1012, y, rl.GRAY) }
        rl.DrawText("STAIRS", 961, 348, 12, rl.LIGHTGRAY)
    }
}

// ---------- Redesigned facility rooms ----------

draw_reception :: proc(game: ^Game) {
    draw_tile_floor(50, 85, 1000, 480, rl.Color{47, 51, 52, 255})
    draw_wall_shell()
    rl.DrawText("SUBLEVEL R-1 / RECEPTION", 72, 120, 18, rl.Color{158, 166, 158, 255})
    rl.DrawRectangle(330, 245, 430, 82, rl.Color{64, 52, 45, 255})
    rl.DrawRectangle(345, 257, 400, 13, rl.Color{100, 80, 61, 255})
    draw_monitor(490, 275, 90, 45, game.reception_power)
    rl.DrawText("VISITOR PROCESSING", 455, 210, 16, rl.GRAY)

    rl.DrawRectangle(160, 390, 150, 58, rl.Color{55, 60, 62, 255})
    rl.DrawRectangle(790, 375, 120, 70, rl.Color{55, 60, 62, 255})
    draw_cabinet(930, 160, 62, 120, rl.Color{70, 72, 69, 255})
    rl.DrawText("PROJECT RESONANCE", 780, 135, 14, rl.Color{95, 120, 111, 255})

    if !game.reception_power {
        rl.DrawRectangle(50, 85, 1000, 480, rl.Color{0, 0, 0, 75})
        rl.DrawText("EMERGENCY POWER ONLY", 430, 470, 18, rl.RED)
    } else {
        rl.DrawRectangle(88, 134, 115, 7, rl.Color{130, 148, 116, 180})
        rl.DrawRectangle(895, 134, 115, 7, rl.Color{130, 148, 116, 180})
    }
}

draw_security :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{38, 43, 46, 255})
    draw_wall_shell()
    rl.DrawText("SECURITY CONTROL / CAMERA NETWORK", 72, 120, 17, rl.LIGHTGRAY)

    for x: i32 = 150; x <= 780; x += 270 {
        draw_monitor(x, 155, 170, 75, game.security_unlocked)
    }
    rl.DrawRectangle(455, 310, 190, 70, rl.Color{42, 48, 52, 255})
    rl.DrawRectangle(470, 324, 160, 28, rl.Color{20, 60, 55, 255})
    rl.DrawText("FREQUENCY ROUTER", 470, 286, 15, rl.SKYBLUE)
    rl.DrawText("R  B  Y  B", 496, 331, 20, rl.Color{135, 198, 180, 255})

    rl.DrawRectangle(170, 285, 54, 36, rl.Color{110, 104, 82, 255})
    rl.DrawText("SHIFT NOTE", 152, 327, 12, rl.BEIGE)
    draw_cabinet(780, 390, 70, 125, rl.Color{65, 72, 76, 255})

    if !game.security_unlocked {
        for y: i32 = 230; y < 350; y += 18 {
            rl.DrawLine(930, y, 1020, y, rl.RED)
        }
    }
}

draw_archive :: proc(game: ^Game) {
    draw_wood_floor(50, 85, 1000, 480)
    draw_wall_shell()
    rl.DrawText("RECORDS ARCHIVE / PERSONNEL & INTAKE", 72, 120, 17, rl.BEIGE)
    draw_shelf(180, 155, 115, 250, true); draw_shelf(340, 155, 115, 250, true)
    draw_shelf(690, 155, 115, 250, true); draw_shelf(850, 155, 115, 250, true)
    rl.DrawRectangle(475, 340, 175, 75, rl.Color{83, 57, 38, 255})
    rl.DrawText("INTAKE INDEX", 500, 365, 14, rl.LIGHTGRAY)
    draw_cabinet(970, 410, 48, 115, rl.Color{61, 61, 63, 255})
    rl.DrawText("MISSING PERSONS", 478, 445, 15, rl.Color{150, 119, 87, 255})

    if game.archive_code_known {
        rl.DrawText("SCANNER TRACE: 7 - 3 - 1", 760, 128, 15, rl.SKYBLUE)
    } else {
        rl.DrawText("...faint coating on east shelf...", 745, 128, 13, rl.DARKGRAY)
    }
}

draw_laboratory :: proc(game: ^Game) {
    draw_tile_floor(50, 85, 1000, 480, rl.Color{183, 186, 180, 255})
    draw_wall_shell()
    rl.DrawText("MEDICAL LAB / RESONANCE TESTING", 72, 120, 17, rl.Color{55, 63, 64, 255})

    for x: i32 = 180; x <= 730; x += 275 {
        rl.DrawRectangle(x, 300, 180, 80, rl.Color{90, 101, 102, 255})
        rl.DrawRectangle(x + 10, 310, 160, 40, rl.Color{155, 163, 160, 255})
        rl.DrawRectangle(x + 18, 360, 18, 17, rl.DARKGRAY)
        rl.DrawRectangle(x + 145, 360, 18, 17, rl.DARKGRAY)
    }
    draw_blood_stain(410, 410)
    draw_blood_stain(935, 265)
    draw_cabinet(930, 405, 70, 125, rl.Color{94, 101, 100, 255})

    rl.DrawText("A", 318, 148, 18, rl.DARKGRAY); rl.DrawText("B", 543, 148, 18, rl.DARKGRAY); rl.DrawText("C", 768, 148, 18, rl.DARKGRAY)
    draw_receiver_status(300, 165, game.lab_receiver_a, .BLUE)
    draw_receiver_status(525, 165, game.lab_receiver_b, .RED)
    draw_receiver_status(750, 165, game.lab_receiver_c, .YELLOW)
}

draw_receiver_status :: proc(x, y: i32, solved: bool, mode: Scanner_Mode) {
    color := rl.DARKGRAY
    if solved {
        switch mode {
        case .RED: color = rl.RED
        case .BLUE: color = rl.SKYBLUE
        case .YELLOW: color = rl.GOLD
        }
    }
    rl.DrawCircle(x + 27, y + 27, 24, rl.Color{35, 38, 40, 255})
    rl.DrawCircleLines(x + 27, y + 27, 22, color)
    rl.DrawCircle(x + 27, y + 27, 5, color)
}

draw_detention :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{43, 43, 42, 255})
    draw_wall_shell()
    rl.DrawText("DETENTION BLOCK D / INTERROGATION", 72, 120, 17, rl.LIGHTGRAY)

    draw_cell_block(145, 145, "01", "L. PARK")
    draw_cell_block(300, 145, "02", "M. RUIZ")
    draw_cell_block(680, 145, "03", "E. COLE")
    draw_cell_block(835, 145, "04", "L. MORRISON")

    rl.DrawRectangle(680, 355, 280, 115, rl.Color{57, 52, 49, 255})
    rl.DrawText("INTERROGATION", 735, 370, 14, rl.GRAY)
    rl.DrawRectangle(730, 398, 150, 38, rl.Color{82, 66, 51, 255})
    rl.DrawRectangle(695, 408, 25, 25, rl.DARKGRAY)
    rl.DrawRectangle(890, 408, 25, 25, rl.DARKGRAY)
    draw_blood_stain(620, 420)

    rl.DrawRectangle(175, 430, 125, 65, rl.Color{37, 43, 46, 255})
    rl.DrawText("CELL LOCK BUS", 182, 450, 12, rl.SKYBLUE)
    if game.detention_locks_bypassed { rl.DrawText("BYPASS", 196, 471, 13, rl.GREEN) }
}

draw_cell_block :: proc(x, y: i32, number, name: cstring) {
    rl.DrawRectangle(x, y, 120, 135, rl.Color{35, 37, 37, 255})
    for xx: i32 = x + 8; xx < x + 115; xx += 15 { rl.DrawLine(xx, y + 10, xx, y + 105, rl.GRAY) }
    rl.DrawText(number, x + 8, y + 112, 14, rl.LIGHTGRAY)
    rl.DrawText(name, x + 40, y + 112, 11, rl.GRAY)
}

draw_maintenance :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{45, 47, 44, 255})
    draw_wall_shell()
    rl.DrawText("MAINTENANCE / POWER DISTRIBUTION", 72, 120, 17, rl.Color{178, 166, 115, 255})
    draw_pipe_bundle(100, 145, 850)
    draw_pipe_bundle(110, 515, 800)

    rl.DrawRectangle(150, 160, 160, 95, rl.Color{62, 62, 58, 255})
    rl.DrawText("TOOL BENCH", 178, 178, 13, rl.GRAY)
    draw_cabinet(360, 155, 140, 100, rl.Color{63, 67, 64, 255})
    rl.DrawRectangle(715, 145, 220, 105, rl.Color{48, 54, 52, 255})
    rl.DrawText("RELAY 3 / CONTAINMENT", 730, 162, 13, rl.SKYBLUE)
    if game.maintenance_online { rl.DrawText("ONLINE", 785, 205, 18, rl.GREEN) } else { rl.DrawText("OFFLINE", 780, 205, 18, rl.RED) }

    rl.DrawRectangle(530, 430, 58, 70, rl.Color{83, 86, 86, 255})
    rl.DrawCircle(559, 447, 13, rl.DARKGRAY)
    rl.DrawText("STEAM", 537, 506, 11, rl.GRAY)
    draw_cabinet(900, 390, 70, 125, rl.Color{61, 63, 62, 255})
}

draw_containment :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{31, 33, 34, 255})
    draw_wall_shell()
    rl.DrawText("CONTAINMENT WING C / AUTHORIZED STAFF ONLY", 72, 120, 16, rl.RED)

    // Reinforced central chamber.
    rl.DrawRectangle(390, 220, 320, 170, rl.Color{19, 21, 22, 255})
    rl.DrawRectangleLines(390, 220, 320, 170, rl.Color{120, 126, 128, 255})
    for x: i32 = 410; x < 700; x += 24 { rl.DrawLine(x, 220, x, 390, rl.Color{65, 69, 70, 255}) }
    rl.DrawText("C-17", 532, 290, 25, rl.Color{105, 20, 24, 255})
    rl.DrawText("RESONANCE SUBJECT", 455, 325, 14, rl.GRAY)

    draw_containment_node(180, 320, game.containment_node_a, .YELLOW, "A")
    draw_containment_node(520, 430, game.containment_node_b, .BLUE, "B")
    draw_containment_node(860, 320, game.containment_node_c, .RED, "C")
    draw_blood_stain(750, 430)
    draw_cabinet(930, 400, 70, 125, rl.Color{58, 61, 61, 255})
}

draw_containment_node :: proc(x, y: i32, solved: bool, mode: Scanner_Mode, label: cstring) {
    rl.DrawRectangle(x, y, 58, 58, rl.Color{42, 44, 46, 255})
    color := rl.GRAY
    if solved {
        switch mode {
        case .RED: color = rl.RED
        case .BLUE: color = rl.SKYBLUE
        case .YELLOW: color = rl.GOLD
        }
    }
    rl.DrawCircleLines(x + 29, y + 29, 18, color)
    rl.DrawText(label, x + 25, y + 21, 14, color)
}

draw_final_area :: proc(game: ^Game) {
    draw_tile_floor(50, 85, 1000, 480, rl.Color{35, 39, 42, 255})
    draw_wall_shell()
    rl.DrawText("FINAL INVESTIGATION / EVIDENCE MIRROR", 72, 120, 17, rl.SKYBLUE)

    for y: i32 = 170; y < 410; y += 62 {
        draw_monitor(155, y, 180, 48, game.final_decrypted)
        draw_monitor(765, y, 180, 48, game.final_decrypted)
    }
    rl.DrawRectangle(410, 275, 280, 100, rl.Color{40, 48, 52, 255})
    rl.DrawRectangle(430, 292, 240, 54, rl.Color{12, 48, 47, 255})
    if game.final_decrypted {
        rl.DrawText("UPLOAD CHANNEL OPEN", 462, 311, 17, rl.GREEN)
    } else {
        rl.DrawText("ENCRYPTED ARCHIVE", 478, 311, 17, rl.SKYBLUE)
    }
    rl.DrawText("MARSHALL PD MIRROR NODE", 430, 390, 14, rl.GRAY)
}

draw_storage :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{57, 55, 49, 255})
    draw_wall_shell()
    rl.DrawText("SUPPLY STORAGE / DECOMMISSIONED", 72, 120, 17, rl.BEIGE)
    draw_shelf(150, 150, 170, 120, false); draw_shelf(150, 330, 170, 120, false)
    draw_shelf(410, 150, 170, 120, false); draw_shelf(410, 330, 170, 120, false)
    rl.DrawRectangle(675, 160, 150, 95, rl.Color{78, 64, 48, 255})
    rl.DrawText("PERSONAL EFFECTS", 675, 270, 13, rl.GRAY)
    rl.DrawText("SAFE ROOM", 850, 500, 13, rl.Color{105, 130, 105, 255})
}

// ---------- Data-driven entities ----------

draw_door_trigger :: proc(game: ^Game, entity: ^Entity) {
    rect := entity_rect(entity)
    unlocked := can_enter_room(game, entity.target_room)
    color := rl.Color{38, 38, 42, 255}
    trim := rl.Color{105, 105, 110, 255}
    if !unlocked { trim = rl.Color{125, 45, 48, 255} }
    rl.DrawRectangleRec(rect, color)
    rl.DrawRectangleLinesEx(rect, 2, trim)
    if entity.size[0] > entity.size[1] {
        rl.DrawCircle(i32(entity.position[0] + entity.size[0] - 16), i32(entity.position[1] + entity.size[1]/2), 3, trim)
    } else {
        rl.DrawCircle(i32(entity.position[0] + entity.size[0]/2), i32(entity.position[1] + entity.size[1] - 16), 3, trim)
    }
}

draw_laser_barrier :: proc(entity: ^Entity, disabled: bool) {
    x := i32(entity.position[0]); y := i32(entity.position[1])
    w := i32(entity.size[0]); h := i32(entity.size[1])
    if disabled {
        rl.DrawText("GRID OFF", x - 20, y + h/2, 13, rl.SKYBLUE)
        return
    }
    for yy: i32 = y + 4; yy < y + h; yy += 15 {
        rl.DrawLine(x, yy, x + w, yy, rl.RED)
    }
}

draw_simple_item :: proc(entity: ^Entity, color: rl.Color, label: cstring) {
    x := i32(entity.position[0]); y := i32(entity.position[1])
    rl.DrawRectangle(x, y, i32(entity.size[0]), i32(entity.size[1]), color)
    rl.DrawRectangleLines(x, y, i32(entity.size[0]), i32(entity.size[1]), rl.LIGHTGRAY)
    rl.DrawText(label, x - 3, y - 16, 11, rl.LIGHTGRAY)
}

draw_hide_spot :: proc(entity: ^Entity) {
    x := i32(entity.position[0]); y := i32(entity.position[1])
    w := i32(entity.size[0]); h := i32(entity.size[1])
    draw_cabinet(x, y, w, h, rl.Color{54, 61, 62, 255})
    rl.DrawText("HIDE", x + 12, y + h - 20, 11, rl.DARKGRAY)
}

draw_level_entities :: proc(game: ^Game) {
    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active { continue }

        switch entity.kind {
        case .PLAYER:
            if !game.player_hidden { draw_player_texture(game, entity.position) }
        case .WALL:
            // Boundary art is drawn by the room; keep only a subtle collision seam.
            rl.DrawRectangleLinesEx(entity_rect(entity), 1, rl.Color{80, 82, 84, 45})
        case .BLOCKER, .MONSTER_SPAWN, .MONSTER_ENTRY:
            // Invisible collision/navigation metadata; decorative art is room-specific.
        case .DOOR_TRIGGER:
            draw_door_trigger(game, entity)
        case .TERMINAL:
            draw_terminal(entity.position)
        case .SIGNAL_BARRIER:
            if !game.red_signal_on {
                rl.DrawRectangleRec(entity_rect(entity), rl.Color{75, 8, 13, 255})
                rl.DrawRectangleLinesEx(entity_rect(entity), 2, rl.RED)
            }
        case .CEMETERY_DOOR:
            if !game.cemetery_door_open {
                rl.DrawRectangleRec(entity_rect(entity), rl.Color{72, 58, 45, 255})
                rl.DrawRectangleLinesEx(entity_rect(entity), 2, rl.BROWN)
            }
        case .GRAVE_CLUE:
            // Already rendered in cemetery art.
        case .HIDE_SPOT:
            draw_hide_spot(entity)
        case .FUSE_ITEM:
            if !game.has_spare_fuse { draw_simple_item(entity, rl.Color{160, 125, 52, 255}, "FUSE") }
        case .POWER_PANEL:
            draw_simple_item(entity, rl.Color{55, 68, 66, 255}, "POWER")
        case .SECURITY_CONSOLE:
            // Main console drawn in room art.
        case .SECURITY_CLUE:
            // Note drawn in room art.
        case .LASER_BARRIER:
            draw_laser_barrier(entity, game.security_unlocked)
        case .ARCHIVE_RECORDS:
            if !game.archive_records { draw_simple_item(entity, rl.Color{145, 116, 72, 255}, "FILES") }
        case .ARCHIVE_HIDDEN_CLUE:
            if game.archive_code_known { draw_simple_item(entity, rl.SKYBLUE, "TRACE") }
        case .LAB_AUDIO_LOG:
            draw_simple_item(entity, rl.Color{60, 70, 76, 255}, "AUDIO")
        case .LAB_RECEIVER_A, .LAB_RECEIVER_B, .LAB_RECEIVER_C:
            // Receiver art is room-specific.
        case .DETENTION_CONSOLE:
            // Drawn in room art.
        case .CELL_KEY_ITEM:
            if game.detention_locks_bypassed && !game.has_cell_key { draw_simple_item(entity, rl.GOLD, "CELL KEY") }
        case .MISSING_EFFECTS:
            if game.detention_locks_bypassed && !game.has_personal_effects { draw_simple_item(entity, rl.Color{105, 82, 66, 255}, "BAG") }
        case .SCREWDRIVER_ITEM:
            if !game.has_screwdriver { draw_simple_item(entity, rl.GRAY, "DRIVER") }
        case .MAINT_PANEL:
            // Relay art is room-specific.
        case .NOISE_PIPE:
            // Pipe art is room-specific.
        case .CONTAINMENT_NODE_A, .CONTAINMENT_NODE_B, .CONTAINMENT_NODE_C:
            // Node art is room-specific.
        case .EXPERIMENT_LOG:
            if game.containment_solved && !game.has_experiment_log { draw_simple_item(entity, rl.Color{133, 92, 70, 255}, "C-17 LOG") }
        case .FINAL_TERMINAL:
            // Central terminal drawn in room art.
        case .OPTIONAL_NOTE:
            draw_simple_item(entity, rl.Color{165, 154, 118, 255}, "NOTE")
        case .OPTIONAL_PHOTO:
            if !game.optional_photo { draw_simple_item(entity, rl.Color{120, 112, 100, 255}, "PHOTO") }
        case .LIBRARY_TRIGGER, .SIDE_ROOM_TRIGGER, .DUNGEON_DOOR, .RETURN_TRIGGER,
             .LIBRARY_KEY_ITEM, .STAFF_LOCKER, .WARDEN_DESK, .ENDING_EXIT:
            // Legacy checkpoint entities are retained for compatibility but are not used by the redesigned facility.
        }
    }
}

// ---------- Player / monster ----------

draw_player_texture :: proc(game: ^Game, position: rl.Vector2) {
    source := rl.Rectangle{x=0, y=0, width=32, height=40}
    if game.player_facing == .LEFT {
        source.width = -32
    }
    dest := rl.Rectangle{x=position[0], y=position[1], width=32, height=40}
    rl.DrawTexturePro(game.resources.player_texture, source, dest, rl.Vector2{0, 0}, 0, rl.WHITE)

    x := i32(position[0]); y := i32(position[1])
    switch game.player_facing {
    case .UP:
        rl.DrawRectangle(x + 7, y + 2, 18, 10, rl.Color{40, 27, 23, 255})
        rl.DrawRectangle(x + 14, y - 5, 4, 8, rl.SKYBLUE)
    case .DOWN:
        rl.DrawCircle(x + 11, y + 10, 2, rl.BLACK); rl.DrawCircle(x + 21, y + 10, 2, rl.BLACK)
        rl.DrawRectangle(x + 14, y + 39, 4, 6, rl.SKYBLUE)
    case .LEFT:
        rl.DrawRectangle(x - 6, y + 20, 8, 4, rl.SKYBLUE); rl.DrawCircle(x + 8, y + 10, 2, rl.BLACK)
    case .RIGHT:
        rl.DrawRectangle(x + 30, y + 20, 8, 4, rl.SKYBLUE); rl.DrawCircle(x + 23, y + 10, 2, rl.BLACK)
    }

    if game.respawn_protection > 0 {
        rl.DrawCircleLines(x + 16, y + 20, 25, rl.SKYBLUE)
    }
}

draw_clay_stalker :: proc(game: ^Game) {
    x := i32(game.enemy.position[0]); y := i32(game.enemy.position[1])
    body := rl.Color{153, 143, 132, 255}; head := rl.Color{183, 171, 157, 255}
    if game.enemy.state == .CHASE || game.enemy.state == .ALERT {
        body = rl.Color{178, 141, 134, 255}; head = rl.Color{206, 169, 157, 255}
    }

    rl.DrawEllipse(x + 21, y + 52, 23, 8, rl.Color{0, 0, 0, 130})
    rl.DrawEllipse(x + 21, y + 35, 18, 24, body)
    rl.DrawCircle(x + 21, y + 15, 21, head)
    rl.DrawCircle(x + 10, y + 11, 6, rl.Color{18, 16, 18, 255})
    rl.DrawCircle(x + 30, y + 9, 9, rl.Color{10, 9, 10, 255})
    rl.DrawCircle(x + 31, y + 9, 2, rl.RED)
    rl.DrawLine(x + 9, y + 29, x + 33, y + 31, rl.Color{67, 38, 38, 255})
    rl.DrawLine(x + 12, y + 33, x + 29, y + 39, rl.Color{67, 38, 38, 255})
    rl.DrawLine(x + 4, y + 4, x + 12, y + 9, rl.DARKGRAY)
    rl.DrawLine(x + 12, y + 9, x + 7, y + 17, rl.DARKGRAY)
    rl.DrawLine(x + 36, y + 17, x + 29, y + 23, rl.DARKGRAY)
    rl.DrawLine(x + 5, y + 29, x - 13, y + 51, body)
    rl.DrawLine(x + 37, y + 29, x + 55, y + 56, body)
    rl.DrawCircle(x - 14, y + 52, 5, body); rl.DrawCircle(x + 56, y + 57, 5, body)

    if game.enemy.state == .ALERT {
        rl.DrawText("!", x + 13, y - 28, 31, rl.RED)
    }
    if game.enemy.state == .CHASE {
        rl.DrawCircleLines(x + 21, y + 24, 32, rl.Color{170, 0, 0, 150})
    }
}

// ---------- Room dispatcher / atmosphere ----------

draw_room_background :: proc(game: ^Game) {
    switch game.room {
    case .ENTRANCE:     draw_entrance_background(game)
    case .RECEPTION:    draw_reception(game)
    case .SECURITY:     draw_security(game)
    case .ARCHIVE:      draw_archive(game)
    case .LABORATORY:   draw_laboratory(game)
    case .DETENTION:    draw_detention(game)
    case .MAINTENANCE:  draw_maintenance(game)
    case .CONTAINMENT:  draw_containment(game)
    case .FINAL_AREA:   draw_final_area(game)
    case .STORAGE:      draw_storage(game)
    }
}

draw_atmosphere :: proc(game: ^Game) {
    if game.room == .ENTRANCE || game.room == .STORAGE || game.room == .FINAL_AREA {
        return
    }

    // Limited visibility: darken the edges while leaving a readable area around the officer.
    if game.player_index >= 0 {
        p := game.entities[game.player_index].position
        px := i32(p[0]); py := i32(p[1])
        radius: i32 = 185
        left_w := px - radius
        if left_w < 0 { left_w = 0 }
        right_x := px + radius
        if right_x < SCREEN_WIDTH {
            rl.DrawRectangle(right_x, 80, SCREEN_WIDTH - right_x, 480, rl.Color{0, 0, 0, 90})
        }
        if left_w > 0 { rl.DrawRectangle(0, 80, left_w, 480, rl.Color{0, 0, 0, 90}) }
        top_h := py - radius - 80
        if top_h > 0 { rl.DrawRectangle(left_w, 80, radius*2, top_h, rl.Color{0, 0, 0, 75}) }
        bottom_y := py + radius
        if bottom_y < 560 { rl.DrawRectangle(left_w, bottom_y, radius*2, 560 - bottom_y, rl.Color{0, 0, 0, 75}) }
    }

    // Damaged lighting flicker in the most unstable areas; no rapid full-screen flashing.
    phase := i32(game.world_time * 7.0) % 19
    if (game.room == .LABORATORY || game.room == .DETENTION || game.room == .CONTAINMENT) && phase == 0 {
        rl.DrawRectangle(50, 85, 1000, 480, rl.Color{0, 0, 0, 45})
    }
}
