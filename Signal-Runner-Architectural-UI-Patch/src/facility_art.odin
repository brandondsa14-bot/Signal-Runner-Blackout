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

draw_chair :: proc(x, y: i32, color: rl.Color) {
    rl.DrawRectangle(x + 4, y, 28, 20, color)
    rl.DrawRectangle(x, y + 18, 36, 7, rl.Color{38, 37, 35, 255})
    rl.DrawRectangle(x + 5, y + 25, 5, 16, rl.DARKGRAY)
    rl.DrawRectangle(x + 26, y + 25, 5, 16, rl.DARKGRAY)
}

draw_paper_stack :: proc(x, y: i32) {
    rl.DrawRectangle(x, y + 4, 32, 18, rl.Color{178, 171, 146, 255})
    rl.DrawRectangle(x + 3, y, 32, 18, rl.Color{205, 196, 165, 255})
    rl.DrawLine(x + 7, y + 7, x + 27, y + 7, rl.Color{105, 99, 87, 255})
    rl.DrawLine(x + 7, y + 12, x + 23, y + 12, rl.Color{105, 99, 87, 255})
}

draw_security_camera :: proc(x, y: i32) {
    rl.DrawRectangle(x, y, 34, 16, rl.Color{86, 91, 91, 255})
    rl.DrawRectangle(x + 25, y + 4, 12, 8, rl.Color{28, 31, 32, 255})
    rl.DrawCircle(x + 31, y + 8, 3, rl.Color{70, 15, 18, 255})
    rl.DrawLine(x + 8, y + 16, x + 2, y + 29, rl.GRAY)
}

draw_warning_stripes :: proc(x, y, w: i32) {
    rl.DrawRectangle(x, y, w, 12, rl.Color{154, 129, 46, 255})
    for xx: i32 = x; xx < x + w; xx += 24 {
        rl.DrawLine(xx, y + 12, xx + 14, y, rl.Color{38, 36, 31, 255})
        rl.DrawLine(xx + 5, y + 12, xx + 19, y, rl.Color{38, 36, 31, 255})
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

// ---------- Visual-only set dressing helpers ----------
// These never add collision or interaction. They sit behind the data-driven
// gameplay layer so room polish cannot block paths, doors or puzzle targets.

draw_wall_vent :: proc(x, y, w, h: i32) {
    rl.DrawRectangle(x, y, w, h, rl.Color{50, 54, 55, 255})
    rl.DrawRectangleLines(x, y, w, h, rl.Color{90, 94, 94, 255})
    for yy: i32 = y + 5; yy < y + h - 3; yy += 6 {
        rl.DrawLine(x + 5, yy, x + w - 5, yy, rl.Color{105, 109, 108, 180})
    }
}

draw_archive_box :: proc(x, y: i32, label: cstring) {
    rl.DrawRectangle(x, y, 52, 34, rl.Color{116, 91, 59, 255})
    rl.DrawRectangleLines(x, y, 52, 34, rl.Color{57, 44, 31, 255})
    rl.DrawRectangle(x + 8, y + 8, 36, 10, rl.Color{177, 161, 126, 255})
    rl.DrawText(label, x + 12, y + 10, 7, rl.Color{61, 53, 43, 255})
}

draw_small_trash_bin :: proc(x, y: i32) {
    rl.DrawRectangle(x, y + 6, 24, 28, rl.Color{61, 64, 63, 255})
    rl.DrawLine(x - 2, y + 6, x + 26, y + 6, rl.Color{107, 109, 105, 255})
    rl.DrawLine(x + 4, y + 12, x + 7, y + 29, rl.DARKGRAY)
    rl.DrawLine(x + 18, y + 12, x + 15, y + 29, rl.DARKGRAY)
}

draw_abandoned_bag :: proc(x, y: i32) {
    rl.DrawRectangle(x, y + 8, 32, 22, rl.Color{70, 53, 42, 255})
    rl.DrawLine(x + 7, y + 8, x + 10, y, rl.Color{92, 73, 55, 255})
    rl.DrawLine(x + 10, y, x + 22, y, rl.Color{92, 73, 55, 255})
    rl.DrawLine(x + 22, y, x + 25, y + 8, rl.Color{92, 73, 55, 255})
}

draw_floor_scuffs :: proc(x, y: i32) {
    rl.DrawLine(x, y, x + 28, y - 7, rl.Color{28, 29, 29, 95})
    rl.DrawLine(x + 6, y + 9, x + 42, y + 2, rl.Color{28, 29, 29, 75})
    rl.DrawLine(x + 18, y + 17, x + 55, y + 13, rl.Color{28, 29, 29, 55})
}

draw_cable_run :: proc(x, y, w: i32, color: rl.Color) {
    rl.DrawLine(x, y, x + w, y, color)
    for xx: i32 = x + 20; xx < x + w; xx += 55 {
        rl.DrawRectangle(xx, y - 2, 5, 5, rl.Color{50, 51, 50, 255})
    }
}

draw_tool_pegboard :: proc(x, y: i32) {
    rl.DrawRectangle(x, y, 130, 56, rl.Color{71, 66, 54, 255})
    rl.DrawRectangleLines(x, y, 130, 56, rl.Color{111, 101, 76, 255})
    for xx: i32 = x + 10; xx < x + 125; xx += 18 {
        rl.DrawCircle(xx, y + 10, 1, rl.DARKGRAY)
        rl.DrawCircle(xx, y + 28, 1, rl.DARKGRAY)
        rl.DrawCircle(xx, y + 46, 1, rl.DARKGRAY)
    }
    rl.DrawLine(x + 24, y + 15, x + 24, y + 42, rl.GRAY)
    rl.DrawLine(x + 54, y + 19, x + 69, y + 36, rl.GRAY)
    rl.DrawRectangle(x + 92, y + 17, 5, 27, rl.Color{98, 76, 48, 255})
}

draw_medical_cart :: proc(x, y: i32) {
    rl.DrawRectangle(x, y, 74, 44, rl.Color{103, 111, 110, 255})
    rl.DrawRectangleLines(x, y, 74, 44, rl.Color{65, 71, 70, 255})
    rl.DrawLine(x + 6, y + 15, x + 68, y + 15, rl.Color{70, 76, 75, 255})
    rl.DrawCircle(x + 12, y + 48, 4, rl.DARKGRAY)
    rl.DrawCircle(x + 62, y + 48, 4, rl.DARKGRAY)
}

draw_cell_mattress :: proc(x, y: i32) {
    rl.DrawRectangle(x, y, 72, 25, rl.Color{82, 77, 69, 255})
    rl.DrawRectangleLines(x, y, 72, 25, rl.Color{43, 42, 39, 255})
    rl.DrawRectangle(x + 4, y + 4, 20, 12, rl.Color{118, 111, 96, 255})
}

draw_hazard_barrel :: proc(x, y: i32, stripe: rl.Color) {
    rl.DrawRectangle(x, y + 8, 34, 48, rl.Color{62, 69, 62, 255})
    rl.DrawCircle(x + 17, y + 8, 17, rl.Color{78, 85, 76, 255})
    rl.DrawCircle(x + 17, y + 56, 17, rl.Color{50, 56, 52, 255})
    rl.DrawRectangle(x, y + 28, 34, 8, stripe)
}

draw_glass_shards :: proc(x, y: i32) {
    rl.DrawTriangle(rl.Vector2{f32(x), f32(y)}, rl.Vector2{f32(x + 12), f32(y - 8)}, rl.Vector2{f32(x + 16), f32(y + 4)}, rl.Color{126, 154, 153, 130})
    rl.DrawTriangle(rl.Vector2{f32(x + 22), f32(y + 3)}, rl.Vector2{f32(x + 32), f32(y - 10)}, rl.Vector2{f32(x + 37), f32(y + 5)}, rl.Color{126, 154, 153, 110})
}

draw_notice_frame :: proc(x, y, w, h: i32, title: cstring, accent: rl.Color) {
    rl.DrawRectangle(x, y, w, h, rl.Color{51, 48, 42, 255})
    rl.DrawRectangleLines(x, y, w, h, accent)
    rl.DrawRectangle(x + 8, y + 10, w - 16, h - 20, rl.Color{159, 151, 127, 255})
    rl.DrawText(title, x + 13, y + 14, 8, rl.Color{54, 50, 43, 255})
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
    // Visitor-gate work area: faded notices and abandoned maintenance gear.
    draw_notice_frame(115, 155, 96, 62, "VISITOR", rl.Color{92, 101, 98, 255})
    draw_small_trash_bin(112, 462)
    draw_floor_scuffs(275, 472)
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

    // Architected reception zoning: a west-wall waiting bay, central processing
    // counter, and east-wall records/emergency-services zone. Decorative props
    // support those functions instead of competing with the interactive clues.
    rl.DrawText("WAITING", 100, 205, 9, rl.Color{98, 101, 96, 180})
    draw_chair(105, 235, rl.Color{68, 73, 72, 255})
    draw_chair(105, 295, rl.Color{68, 73, 72, 255})
    draw_abandoned_bag(112, 350)
    draw_chair(825, 475, rl.Color{68, 73, 72, 255})
    draw_paper_stack(365, 276)
    draw_paper_stack(690, 276)
    draw_notice_frame(800, 175, 105, 62, "EVAC MAP", rl.Color{83, 110, 101, 255})
    draw_small_trash_bin(910, 485)
    draw_wall_vent(105, 500, 72, 26)
    draw_floor_scuffs(585, 430)
    rl.DrawCircleLines(945, 330, 20, rl.Color{117, 114, 101, 255})
    rl.DrawLine(945, 330, 945, 318, rl.Color{117, 114, 101, 255})
    rl.DrawLine(945, 330, 955, 335, rl.Color{117, 114, 101, 255})
    rl.DrawText("2:14", 928, 357, 10, rl.GRAY)

    if !game.reception_power {
        // Readable blackout state: emergency fixtures and a heavy world-only darkness overlay.
        rl.DrawRectangle(50, 85, 1000, 480, rl.Color{0, 0, 0, 125})
        rl.DrawCircle(135, 155, 28, rl.Color{110, 24, 20, 42})
        rl.DrawCircle(955, 155, 28, rl.Color{110, 24, 20, 42})
        rl.DrawRectangle(118, 136, 34, 5, rl.Color{130, 35, 30, 130})
        rl.DrawRectangle(938, 136, 34, 5, rl.Color{130, 35, 30, 130})
        rl.DrawText("EMERGENCY POWER ONLY", 430, 470, 18, rl.RED)
    } else {
        // The restored room brightens over roughly 1.4 seconds and briefly flickers as the bus stabilizes.
        darkness := u8(92.0 * (1.0 - game.reception_power_transition))
        if darkness > 0 {
            rl.DrawRectangle(50, 85, 1000, 480, rl.Color{0, 0, 0, darkness})
        }
        flicker_phase := i32(game.world_time * 18.0) % 5
        if game.reception_power_flicker > 0 && (flicker_phase == 0 || flicker_phase == 3) {
            rl.DrawRectangle(50, 85, 1000, 480, rl.Color{0, 0, 0, 75})
        }
        rl.DrawRectangle(88, 134, 115, 7, rl.Color{190, 205, 169, 225})
        rl.DrawRectangle(895, 134, 115, 7, rl.Color{190, 205, 169, 225})
        rl.DrawRectangle(455, 134, 190, 7, rl.Color{188, 201, 170, 210})
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
    rl.DrawText("ACCEPTED", 478, 329, 10, rl.Color{100, 145, 132, 255})
    for i := 0; i < 4; i += 1 {
        x := i32(535 + i*22)
        c := rl.DARKGRAY
        if i < game.security_sequence_step { c = rl.GREEN }
        rl.DrawCircle(x, 339, 6, c)
    }

    // Security officer workstation: the important operating notes are inside the
    // drawer instead of sitting conveniently in the open.
    rl.DrawRectangle(145, 270, 180, 62, rl.Color{63, 53, 45, 255})
    rl.DrawRectangle(154, 280, 118, 14, rl.Color{39, 41, 42, 255})
    for k: i32 = 0; k < 6; k += 1 { rl.DrawRectangle(160 + k*16, 284, 10, 4, rl.Color{90, 94, 92, 255}) }
    rl.DrawRectangle(280, 280, 28, 22, rl.Color{48, 50, 52, 255})
    rl.DrawCircle(294, 291, 5, rl.Color{74, 38, 28, 255})
    rl.DrawRectangle(160, 304, 150, 22, rl.Color{74, 59, 46, 255})
    rl.DrawRectangleLines(160, 304, 150, 22, rl.Color{34, 30, 27, 255})
    rl.DrawCircle(235, 315, 2, rl.GOLD)
    rl.DrawText("SECURITY DESK", 162, 338, 11, rl.GRAY)

    // Security is arranged in functional bands: camera wall at the north,
    // operator desk west, routing console center, and access/hiding equipment east.
    draw_cabinet(780, 390, 70, 125, rl.Color{65, 72, 76, 255})
    draw_security_camera(900, 145)
    draw_cable_run(130, 242, 690, rl.Color{72, 82, 82, 180})
    draw_notice_frame(875, 390, 92, 60, "ACCESS", rl.Color{115, 68, 53, 255})
    draw_small_trash_bin(105, 470)
    draw_floor_scuffs(525, 465)
    rl.DrawLine(917, 174, 917, 205, rl.Color{46, 49, 50, 255})
    rl.DrawLine(917, 205, 845, 205, rl.Color{46, 49, 50, 255})
    rl.DrawRectangle(145, 455, 145, 24, rl.Color{48, 51, 53, 255})
    rl.DrawText("CAM 01  02  03", 159, 462, 10, rl.Color{95, 118, 108, 255})

    if !game.security_unlocked {
        for y: i32 = 230; y < 350; y += 18 {
            rl.DrawLine(930, y, 1020, y, rl.RED)
        }
    } else if game.security_laser_shutdown > 0 {
        strength := game.security_laser_shutdown / 1.25
        if strength > 1.0 { strength = 1.0 }
        alpha := u8(210.0 * strength)
        fade_color := rl.Color{230, 35, 42, alpha}
        for y: i32 = 230; y < 350; y += 18 {
            rl.DrawLine(930, y, 930 + i32(90.0 * strength), y, fade_color)
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
    draw_paper_stack(510, 350)
    draw_paper_stack(585, 350)
    rl.DrawRectangle(88, 420, 90, 72, rl.Color{89, 71, 47, 255})
    rl.DrawRectangleLines(88, 420, 90, 72, rl.Color{47, 38, 29, 255})
    rl.DrawText("1978-86", 105, 447, 11, rl.BEIGE)
    rl.DrawRectangle(820, 430, 75, 48, rl.Color{72, 55, 38, 255})
    rl.DrawText("SEALED", 834, 447, 10, rl.Color{137, 89, 75, 255})
    // Archive staging is kept against the perimeter; the center remains a clear
    // reading/index lane linking the west and east shelf banks.
    draw_archive_box(92, 455, "BOX 31")
    draw_archive_box(900, 455, "R-17")
    draw_archive_box(842, 420, "SEALED")
    draw_chair(585, 442, rl.Color{72, 58, 43, 255})
    rl.DrawLine(315, 165, 315, 395, rl.Color{126, 112, 87, 190})
    for yy: i32 = 185; yy < 380; yy += 38 { rl.DrawLine(305, yy, 325, yy, rl.Color{126, 112, 87, 190}) }
    draw_floor_scuffs(470, 500)

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
    // Medical carts, sample racks and abandoned IV hardware give the room a
    // purpose beyond its receiver puzzle.
    rl.DrawLine(120, 300, 120, 405, rl.Color{91, 95, 94, 255})
    rl.DrawLine(105, 405, 135, 405, rl.Color{91, 95, 94, 255})
    rl.DrawCircle(120, 315, 8, rl.Color{121, 50, 45, 180})
    rl.DrawRectangle(835, 405, 72, 48, rl.Color{106, 111, 109, 255})
    for xx: i32 = 844; xx < 900; xx += 14 { rl.DrawCircle(xx, 420, 4, rl.Color{91, 126, 113, 255}) }
    draw_paper_stack(790, 470)
    draw_medical_cart(100, 440)
    draw_wall_vent(865, 250, 92, 30)
    rl.DrawRectangle(620, 420, 105, 52, rl.Color{115, 119, 114, 255})
    rl.DrawText("BIOHAZARD", 635, 437, 10, rl.Color{117, 40, 37, 255})
    draw_floor_scuffs(520, 500)

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
    // Shower/plumbing strip: visual detail only; interaction hotspots are data-driven.
    rl.DrawRectangle(365, 385, 190, 105, rl.Color{48, 51, 51, 255})
    for xx: i32 = 390; xx <= 520; xx += 65 {
        rl.DrawLine(xx, 398, xx, 430, rl.Color{105, 109, 108, 255})
        rl.DrawCircle(xx, 433, 6, rl.Color{105, 109, 108, 255})
        rl.DrawCircleLines(xx, 468, 11, rl.Color{72, 75, 74, 255})
    }
    rl.DrawText("SHOWERS", 425, 495, 10, rl.GRAY)
    draw_security_camera(965, 145)
    draw_cell_mattress(165, 245)
    draw_cell_mattress(320, 245)
    draw_cell_mattress(700, 245)
    draw_cell_mattress(855, 245)
    draw_pipe_bundle(110, 305, 820)
    draw_wall_vent(550, 145, 72, 26)
    draw_floor_scuffs(560, 460)

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
    for xx: i32 = 560; xx <= 650; xx += 45 {
        rl.DrawCircle(xx, 195, 16, rl.Color{54, 57, 55, 255})
        rl.DrawCircleLines(xx, 195, 13, rl.Color{145, 137, 101, 255})
        rl.DrawLine(xx, 195, xx + 8, 188, rl.Color{185, 167, 99, 255})
    }
    draw_warning_stripes(690, 270, 270)
    // Maintenance keeps tools and spare parts in a dedicated west-side work bay;
    // the central aisle to Relay 3 remains visually and physically open.
    draw_paper_stack(185, 200)
    draw_tool_pegboard(105, 285)
    draw_archive_box(115, 455, "SPARES")
    draw_archive_box(175, 455, "FUSES")
    draw_cable_run(610, 315, 310, rl.Color{102, 82, 50, 190})
    draw_floor_scuffs(715, 470)

    rl.DrawRectangle(530, 430, 58, 70, rl.Color{83, 86, 86, 255})
    rl.DrawCircle(559, 447, 13, rl.DARKGRAY)
    rl.DrawText("STEAM", 537, 506, 11, rl.GRAY)
    draw_cabinet(900, 390, 70, 125, rl.Color{61, 63, 62, 255})
}

draw_processing :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{37, 43, 38, 255})
    draw_wall_shell()
    rl.DrawText("HAZARDOUS WASTE PROCESSING / SERVICE ACCESS", 72, 120, 16, rl.Color{155, 171, 92, 255})

    // Conductive runoff basins divide the chamber. The scanner-operated service
    // bridge is the only safe crossing; this keeps the top-down movement model
    // intact instead of introducing incompatible jumping physics.
    rl.DrawRectangle(430, 120, 240, 150, rl.Color{37, 72, 42, 255})
    rl.DrawRectangle(430, 370, 240, 160, rl.Color{37, 72, 42, 255})
    for yy: i32 = 132; yy < 520; yy += 30 {
        if yy >= 270 && yy < 370 { continue }
        rl.DrawLine(438, yy, 662, yy + 12, rl.Color{91, 130, 63, 120})
    }
    rl.DrawText("CONDUCTIVE RUNOFF", 452, 190, 12, rl.Color{133, 165, 78, 255})
    rl.DrawText("NO FOOT TRAFFIC", 470, 455, 12, rl.Color{133, 165, 78, 255})

    if game.processing_bridge_extended {
        rl.DrawRectangle(430, 288, 240, 64, rl.Color{80, 82, 76, 255})
        for xx: i32 = 440; xx < 665; xx += 28 { rl.DrawLine(xx, 292, xx, 348, rl.Color{116, 117, 107, 255}) }
        rl.DrawRectangleLines(430, 288, 240, 64, rl.Color{158, 145, 92, 255})
        rl.DrawText("BRIDGE LOCKED", 492, 309, 12, rl.GREEN)
    } else {
        rl.DrawRectangle(430, 270, 240, 100, rl.Color{25, 48, 31, 255})
        rl.DrawLine(430, 270, 670, 370, rl.Color{174, 79, 45, 170})
        rl.DrawLine(430, 370, 670, 270, rl.Color{174, 79, 45, 170})
        rl.DrawText("BRIDGE RETRACTED", 486, 312, 12, rl.RED)
    }

    rl.DrawRectangle(780, 255, 110, 70, rl.Color{45, 54, 51, 255})
    rl.DrawRectangleLines(780, 255, 110, 70, rl.Color{120, 127, 102, 255})
    rl.DrawText("BRIDGE", 805, 267, 12, rl.LIGHTGRAY)
    if game.processing_console_step <= 0 { rl.DrawText("VENT: --", 796, 289, 10, rl.SKYBLUE) }
    else { rl.DrawText("VENT: BLUE", 790, 289, 10, rl.SKYBLUE) }
    if game.processing_bridge_extended { rl.DrawText("DRIVE: YELLOW", 786, 305, 9, rl.GOLD) }
    else { rl.DrawText("DRIVE: --", 796, 305, 9, rl.GRAY) }

    rl.DrawRectangle(160, 145, 170, 100, rl.Color{47, 57, 52, 255})
    rl.DrawText("FILTER TANKS", 190, 252, 11, rl.GRAY)
    for xx: i32 = 178; xx <= 286; xx += 54 {
        rl.DrawCircle(xx, 190, 22, rl.Color{64, 78, 68, 255})
        rl.DrawCircleLines(xx, 190, 18, rl.Color{122, 139, 102, 255})
    }
    draw_warning_stripes(410, 545, 280)
    draw_hazard_barrel(110, 390, rl.Color{153, 136, 42, 255})
    draw_hazard_barrel(150, 405, rl.Color{153, 136, 42, 255})
    draw_wall_vent(875, 160, 95, 28)
    draw_notice_frame(730, 145, 115, 60, "DECON", rl.Color{119, 137, 71, 255})
    rl.DrawRectangle(735, 430, 90, 58, rl.Color{68, 61, 46, 255})
    rl.DrawText("PPE", 766, 451, 12, rl.GOLD)
    draw_cabinet(900, 400, 70, 125, rl.Color{60, 65, 58, 255})
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
    // Observation warning lamps and discarded restraint equipment.
    for xx: i32 = 415; xx <= 670; xx += 85 {
        lamp := rl.Color{96, 20, 24, 255}
        if game.containment_solved { lamp = rl.Color{42, 102, 61, 255} }
        rl.DrawCircle(xx, 205, 7, lamp)
    }
    rl.DrawRectangle(120, 430, 145, 48, rl.Color{72, 75, 75, 255})
    rl.DrawLine(135, 438, 245, 470, rl.Color{38, 41, 42, 255})
    rl.DrawText("RESTRAINT CART", 132, 486, 10, rl.GRAY)
    draw_security_camera(920, 155)
    draw_glass_shards(735, 390)
    draw_notice_frame(795, 145, 105, 58, "BIO LOCK", rl.Color{126, 41, 45, 255})
    draw_cable_run(410, 410, 290, rl.Color{91, 57, 57, 180})
    draw_floor_scuffs(300, 470)

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
    // Physical case board ties the digital upload back to the detective fantasy.
    rl.DrawRectangle(350, 145, 400, 95, rl.Color{76, 64, 49, 255})
    for xx: i32 = 380; xx <= 680; xx += 100 {
        rl.DrawRectangle(xx, 165, 58, 42, rl.Color{182, 170, 142, 255})
        rl.DrawCircle(xx + 29, 163, 3, rl.RED)
    }
    rl.DrawLine(409, 207, 509, 165, rl.Color{124, 37, 37, 180})
    rl.DrawLine(538, 207, 609, 165, rl.Color{124, 37, 37, 180})
    rl.DrawText("PARK   RUIZ   COLE   MORRISON", 396, 218, 10, rl.LIGHTGRAY)

    for y: i32 = 270; y < 450; y += 62 {
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
    draw_archive_box(90, 430, "CASE 04")
    draw_archive_box(148, 438, "C-17")
    draw_small_trash_bin(930, 475)
    draw_cable_run(350, 255, 400, rl.Color{66, 91, 90, 180})
    draw_floor_scuffs(520, 500)
}

draw_storage :: proc(game: ^Game) {
    draw_concrete_floor(50, 85, 1000, 480, rl.Color{57, 55, 49, 255})
    draw_wall_shell()
    rl.DrawText("SUPPLY STORAGE / DECOMMISSIONED", 72, 120, 17, rl.BEIGE)
    draw_shelf(150, 150, 170, 120, false); draw_shelf(150, 330, 170, 120, false)
    draw_shelf(410, 150, 170, 120, false); draw_shelf(410, 330, 170, 120, false)
    rl.DrawRectangle(675, 160, 150, 95, rl.Color{78, 64, 48, 255})
    rl.DrawText("PERSONAL EFFECTS", 675, 270, 13, rl.GRAY)
    for yy: i32 = 330; yy <= 430; yy += 50 {
        rl.DrawRectangle(700, yy, 115, 38, rl.Color{78, 66, 50, 255})
        rl.DrawRectangleLines(700, yy, 115, 38, rl.Color{44, 39, 32, 255})
        rl.DrawText("LOT R-17", 724, yy + 12, 10, rl.BEIGE)
    }
    draw_chair(885, 420, rl.Color{61, 67, 64, 255})
    draw_archive_box(610, 430, "LOT 17")
    draw_archive_box(610, 470, "SEALED")
    // Property bag belongs beside the personal-effects intake station rather than
    // floating between shelving aisles.
    draw_abandoned_bag(690, 282)
    draw_wall_vent(875, 150, 90, 28)
    draw_floor_scuffs(520, 500)
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

draw_laser_barrier :: proc(entity: ^Entity, disabled: bool, shutdown_timer: f32) {
    x := i32(entity.position[0]); y := i32(entity.position[1])
    w := i32(entity.size[0]); h := i32(entity.size[1])
    if disabled {
        if shutdown_timer > 0 {
            strength := shutdown_timer / 1.25
            if strength > 1.0 { strength = 1.0 }
            alpha := u8(210.0 * strength)
            fading := rl.Color{225, 35, 42, alpha}
            for yy: i32 = y + 4; yy < y + h; yy += 15 {
                rl.DrawLine(x, yy, x + i32(f32(w) * strength), yy, fading)
            }
            rl.DrawText("GRID SHUTDOWN", x - 54, y + h/2, 12, rl.SKYBLUE)
        } else {
            rl.DrawText("GRID OFF", x - 20, y + h/2, 13, rl.SKYBLUE)
        }
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

draw_searchable_container :: proc(entity: ^Entity) {
    x := i32(entity.position[0]); y := i32(entity.position[1])
    w := i32(entity.size[0]); h := i32(entity.size[1])
    color := rl.Color{69, 62, 51, 255}
    if entity.container_id == .RECEPTION_SUPPLY || entity.container_id == .MAINTENANCE_LOCKER {
        color = rl.Color{58, 66, 65, 255}
    }
    draw_cabinet(x, y, w, h, color)
    rl.DrawRectangleLines(x + 4, y + h/2, w - 8, 1, rl.Color{30, 29, 27, 180})
    rl.DrawCircle(x + w - 11, y + h/2 - 6, 2, rl.Color{164, 139, 88, 255})
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
        case .SEARCHABLE_CONTAINER:
            draw_searchable_container(entity)
        case .INSPECTABLE_PROP:
            draw_environment_prop(game, entity)
        case .FUSE_ITEM:
            if !game.reception_fuse_collected { draw_simple_item(entity, rl.Color{160, 125, 52, 255}, "FUSE") }
        case .POWER_PANEL:
            if game.reception_power {
                draw_simple_item(entity, rl.Color{52, 92, 67, 255}, "POWER ON")
                x := i32(entity.position[0]); y := i32(entity.position[1])
                rl.DrawCircle(x + i32(entity.size[0]) - 10, y + 10, 4, rl.GREEN)
            } else {
                draw_simple_item(entity, rl.Color{55, 68, 66, 255}, "POWER")
                x := i32(entity.position[0]); y := i32(entity.position[1])
                rl.DrawCircle(x + i32(entity.size[0]) - 10, y + 10, 4, rl.RED)
            }
        case .SECURITY_CONSOLE:
            // Main console drawn in room art.
        case .SECURITY_CLUE:
            // Note drawn in room art.
        case .LASER_BARRIER:
            draw_laser_barrier(entity, game.security_unlocked, game.security_laser_shutdown)
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
        case .PROCESSING_CONSOLE:
            // Console art is room-specific.
        case .PROCESSING_BRIDGE_LOCK:
            // Dynamic bridge/gap art is room-specific.
        case .PROCESSING_EVIDENCE:
            if !game.processing_evidence { draw_simple_item(entity, rl.Color{138, 116, 71, 255}, "INCIDENT") }
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
    // The original sprite has one frame, so the walk cycle is a subtle procedural boot animation.
    // It preserves the officer's face/body identity and collision rectangle while making movement readable.
    left_step: i32 = 0
    right_step: i32 = 0
    if game.player_moving {
        if i32(game.player_walk_phase) % 2 == 0 { left_step = 2; right_step = -1 }
        else { left_step = -1; right_step = 2 }
    }
    boot := rl.Color{15, 18, 22, 255}
    switch game.player_facing {
    case .UP, .DOWN:
        rl.DrawRectangle(x + 7, y + 36 + left_step, 7, 5, boot)
        rl.DrawRectangle(x + 19, y + 36 + right_step, 7, 5, boot)
    case .LEFT:
        rl.DrawRectangle(x + 5 + left_step, y + 35, 8, 5, boot)
        rl.DrawRectangle(x + 17 + right_step, y + 35, 7, 5, boot)
    case .RIGHT:
        rl.DrawRectangle(x + 8 + left_step, y + 35, 7, 5, boot)
        rl.DrawRectangle(x + 20 + right_step, y + 35, 8, 5, boot)
    }
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
    } else if game.enemy.state == .SUSPICIOUS || game.enemy.state == .INVESTIGATE {
        body = rl.Color{163, 151, 128, 255}; head = rl.Color{193, 181, 151, 255}
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

    if game.enemy.state == .SUSPICIOUS {
        rl.DrawText("?", x + 13, y - 28, 27, rl.GOLD)
    }
    if game.enemy.state == .INVESTIGATE {
        rl.DrawCircleLines(x + 21, y + 24, 29, rl.Color{190, 151, 65, 150})
    }
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
    case .PROCESSING:   draw_processing(game)
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
        if game.room == .RECEPTION && !game.reception_power { radius = 145 }
        if game.room == .RECEPTION && game.reception_power { radius = 245 }
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
