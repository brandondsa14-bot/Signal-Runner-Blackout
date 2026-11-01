package main

import rl "vendor:raylib"

room_name :: proc(room: Room_ID) -> cstring {
    switch room {
    case .ENTRANCE:     return "CEMETERY VISITOR GATE"
    case .RECEPTION:    return "UNDERGROUND RECEPTION"
    case .SECURITY:     return "SECURITY CONTROL"
    case .ARCHIVE:      return "RECORDS ARCHIVE"
    case .LABORATORY:   return "MEDICAL LABORATORY"
    case .DETENTION:    return "DETENTION BLOCK D"
    case .MAINTENANCE:  return "MAINTENANCE TUNNELS"
    case .CONTAINMENT:  return "CONTAINMENT WING C"
    case .FINAL_AREA:   return "FINAL INVESTIGATION"
    case .STORAGE:      return "SUPPLY STORAGE"
    }
    return "UNKNOWN"
}

room_objective :: proc(game: ^Game) -> cstring {
    switch game.room {
    case .ENTRANCE:
        if !game.has_cemetery_key { return "Access the visitor terminal." }
        if !game.hidden_stair_found { return "Investigate the far-right gravestone." }
        return "Descend the hidden staircase."
    case .RECEPTION:
        if !game.has_spare_fuse { return "Search reception for a spare fuse." }
        if !game.reception_power { return "Install the fuse in the power panel." }
        return "Security power is restored. Explore the facility."
    case .SECURITY:
        if !game.security_unlocked { return "Use the clue to solve the frequency sequence." }
        return "Security keycard acquired. Archive and lab are accessible."
    case .ARCHIVE:
        if !game.archive_records { return "Recover the missing-person intake records." }
        if !game.archive_code_known { return "Scan the suspicious east archive shelf." }
        return "Code 7-3-1 recovered. Investigate the laboratory."
    case .LABORATORY:
        if !game.lab_audio_log { return "Listen to the damaged resonance recording." }
        if !game.lab_alignment_solved { return "Calibrate receivers A, B and C." }
        return "Laboratory power aligned. Detention access can be attempted."
    case .DETENTION:
        if !game.detention_locks_bypassed { return "Bypass the electronic cell locks with the scanner." }
        if !game.has_cell_key { return "Find the physical cell key." }
        if !game.has_personal_effects { return "Inspect the belongings recovered from Cell 04." }
        return "Maintenance badge recovered. Reach the maintenance tunnels."
    case .MAINTENANCE:
        if !game.has_screwdriver { return "Find a tool to open Relay Panel 3." }
        if !game.maintenance_panel_open { return "Open Relay Panel 3." }
        if !game.maintenance_online { return "Use RED frequency to align Relay 3." }
        return "All three facility transmitters are online."
    case .CONTAINMENT:
        if !game.containment_solved { return "Calibrate the three containment nodes while staying alive." }
        if !game.has_experiment_log { return "Recover the C-17 experiment log." }
        return "The final investigation room is unlocked."
    case .FINAL_AREA:
        if !has_required_final_evidence(game) { return "You are missing critical evidence." }
        if !game.final_decrypted { return "Use BLUE frequency to decrypt the evidence mirror." }
        return "Upload the evidence to Marshall PD."
    case .STORAGE:
        return "Optional: search the decommissioned personal-effects storage."
    }
    return "Investigate."
}

render_title :: proc(game: ^Game) {
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("SIGNAL RUNNER", 330, 170, 54, rl.RAYWHITE)
    rl.DrawText("BLACKOUT", 420, 232, 42, rl.RED)
    rl.DrawText("A survival-horror investigation", 340, 305, 20, rl.GRAY)
    rl.DrawText("PRESS ENTER", 430, 410, 24, rl.LIGHTGRAY)
    if game.reduced_fx {
        rl.DrawText("V: REDUCED HORROR FX — ON", 392, 470, 17, rl.SKYBLUE)
    } else {
        rl.DrawText("V: REDUCED HORROR FX", 412, 470, 17, rl.DARKGRAY)
    }
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

render_ending :: proc(game: ^Game) {
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("MARSHALL PD — EVIDENCE MIRROR", 300, 90, 24, rl.GRAY)

    switch game.ending_page {
    case 0:
        rl.DrawText("UPLOAD COMPLETE.", 375, 220, 42, rl.SKYBLUE)
        rl.DrawText("The underground archive is no longer a secret.", 245, 300, 24, rl.RAYWHITE)
    case 1:
        rl.DrawText("THREE VICTIMS WERE RECOVERED.", 245, 225, 32, rl.RAYWHITE)
        rl.DrawText("LEAH MORRISON WAS FOUND ALIVE IN OBSERVATION.", 155, 295, 26, rl.GOLD)
    case 2:
        rl.DrawText("PROJECT RESONANCE IDENTIFIED C-17", 235, 220, 30, rl.RAYWHITE)
        rl.DrawText("AS FORMER SECURITY OFFICER ELIAS VOSS.", 220, 275, 28, rl.RAYWHITE)
        rl.DrawText("The Clay Stalker was made here.", 330, 345, 23, rl.RED)
    case 3:
        rl.DrawText("DR. ADRIAN VALE'S RECORDS", 315, 215, 31, rl.RAYWHITE)
        rl.DrawText("LINKED HIM TO THE ABDUCTIONS AND THE COVER-UP.", 155, 275, 27, rl.RAYWHITE)
        rl.DrawText("The facility was sealed before dawn.", 295, 345, 23, rl.GRAY)
    case 4:
        rl.DrawText("CASE CLOSED", 385, 215, 44, rl.RAYWHITE)
        rl.DrawText("SIGNAL RUNNER: BLACKOUT", 320, 285, 30, rl.RED)
        rl.DrawText("The signal finally went quiet.", 360, 355, 21, rl.GRAY)
    }
    rl.DrawText("ENTER", 515, 540, 17, rl.DARKGRAY)
}

render_game_over :: proc(game: ^Game) {
    rl.ClearBackground(rl.Color{8, 6, 7, 255})
    rl.DrawCircle(550, 250, 160, rl.Color{45, 8, 12, 90})
    rl.DrawText("NO SIGNAL", 380, 190, 55, rl.Color{135, 20, 26, 255})
    rl.DrawText("THE INVESTIGATION ENDED BELOW MARSHALL.", 240, 290, 24, rl.GRAY)
    rl.DrawText("R — RESTART INVESTIGATION", 350, 405, 21, rl.RAYWHITE)
    rl.DrawText("ENTER — MAIN MENU", 390, 450, 21, rl.LIGHTGRAY)
}

render_jumpscare :: proc(game: ^Game) {
    rl.ClearBackground(rl.Color{7, 5, 6, 255})
    ox: i32 = 0
    oy: i32 = 0
    if !game.reduced_fx {
        ox = rl.GetRandomValue(-9, 9)
        oy = rl.GetRandomValue(-7, 7)
    }

    // Dedicated 640x640 close-up asset; never reuses or enlarges the gameplay monster.
    source := rl.Rectangle{x=0, y=0, width=640, height=640}
    dest := rl.Rectangle{x=f32(230 + ox), y=f32(-5 + oy), width=640, height=640}
    rl.DrawTexturePro(game.resources.monster_jumpscare_texture, source, dest, rl.Vector2{0, 0}, 0, rl.WHITE)

    if !game.reduced_fx {
        for y: i32 = 70; y < 575; y += 52 {
            jitter := rl.GetRandomValue(-18, 18)
            rl.DrawRectangle(60 + jitter, y, 980, 3, rl.Color{110, 12, 18, 65})
        }
    }
    rl.DrawRectangle(0, 565, 1100, 75, rl.Color{0, 0, 0, 210})
    rl.DrawText("SUBJECT C-17", 455 + ox, 587 + oy, 24, rl.Color{145, 18, 24, 255})

    // Brief cut/fade to black before life resolution; no strobing.
    if game.jumpscare_timer > game.tuning.jumpscare_duration - 0.22 {
        rl.DrawRectangle(0, 0, 1100, 640, rl.Color{0, 0, 0, 220})
    }
}

render_playing :: proc(game: ^Game) {
    rl.ClearBackground(rl.Color{12, 13, 14, 255})
    draw_room_background(game)
    draw_atmosphere(game)
    draw_level_entities(game)

    if game.enemy.active {
        draw_clay_stalker(game)
    }

    if game.scanner_pulse_timer > 0 && game.player_index >= 0 {
        p := game.entities[game.player_index].position
        color := scanner_color(game.scanner_mode)
        rl.DrawCircleLines(i32(p[0] + 16), i32(p[1] + 20), game.tuning.scanner_range, color)
    }

    draw_interaction_prompt(game)
    draw_hud(game)

    if game.message_timer > 0 {
        draw_message(game)
    }
    if game.inventory_open {
        draw_inventory_overlay(game)
    }
    if game.objectives_open {
        draw_objective_log(game)
    }

    if game.enemy.active && game.enemy.state == .CHASE && !game.inventory_open && !game.objectives_open {
        rl.DrawRectangleLinesEx(rl.Rectangle{x=4, y=4, width=1092, height=632}, 4, rl.Color{150, 0, 0, 170})
        rl.DrawText("RUN", 520, 60, 26, rl.RED)
    }
}

scanner_color :: proc(mode: Scanner_Mode) -> rl.Color {
    switch mode {
    case .RED: return rl.RED
    case .BLUE: return rl.SKYBLUE
    case .YELLOW: return rl.GOLD
    }
    return rl.RED
}

draw_hud :: proc(game: ^Game) {
    // Thin persistent case-status bars. Larger investigation UI sits over the world.
    rl.DrawRectangle(0, 0, 1100, 80, rl.Color{0, 0, 0, 225})
    rl.DrawRectangle(0, 560, 1100, 80, rl.Color{0, 0, 0, 220})
    rl.DrawText(room_name(game.room), 18, 13, 17, rl.RAYWHITE)
    rl.DrawText("MARSHALL PD / CASE 04-17", 18, 40, 12, rl.Color{125, 112, 92, 255})

    draw_lives(game)
    draw_ai_state(game)
    draw_current_objective_panel(game)
    draw_minimap(game)

    if game.room == .ENTRANCE {
        rl.DrawText("1 RED SIGNAL  |  E INTERACT  |  I INVESTIGATION LOG  |  TAB INVENTORY", 18, 586, 14, rl.LIGHTGRAY)
    } else {
        draw_scanner_hud(game)
        rl.DrawText("E INTERACT  |  F PULSE  |  I LOG  |  TAB INVENTORY  |  V REDUCED FX", 18, 610, 13, rl.LIGHTGRAY)
    }

    if game.player_hidden {
        rl.DrawText("HIDDEN", 930, 586, 15, rl.SKYBLUE)
    }
}

draw_lives :: proc(game: ^Game) {
    rl.DrawText("LIVES", 805, 12, 13, rl.GRAY)
    for i := 0; i < 3; i += 1 {
        x := i32(858 + i*30)
        active := i < game.lives
        color := rl.Color{55, 30, 34, 255}
        if active { color = rl.Color{165, 24, 34, 255} }
        rl.DrawCircle(x, 27, 9, color)
        rl.DrawRectangle(x - 5, 27, 10, 10, color)
        if active { rl.DrawLine(x - 3, 20, x + 3, 33, rl.Color{230, 90, 95, 180}) }
    }
}

draw_ai_state :: proc(game: ^Game) {
    if !room_allows_monster(game.room) { return }
    rl.DrawText("STALKER", 965, 12, 12, rl.DARKGRAY)
    switch game.enemy.state {
    case .DORMANT:    rl.DrawText("DORMANT", 958, 31, 12, rl.GRAY)
    case .PATROL:     rl.DrawText("PATROL", 968, 31, 12, rl.GOLD)
    case .ALERT:      rl.DrawText("ALERT", 973, 31, 12, rl.ORANGE)
    case .CHASE:      rl.DrawText("CHASE", 973, 31, 12, rl.RED)
    case .SEARCH:     rl.DrawText("SEARCH", 966, 31, 12, rl.ORANGE)
    case .DISENGAGE:  rl.DrawText("LEAVING", 957, 31, 12, rl.GRAY)
    }
}

draw_scanner_hud :: proc(game: ^Game) {
    rl.DrawText("SCANNER", 18, 574, 13, rl.SKYBLUE)
    draw_scanner_box(88, 571, "1 RED", .RED, game.scanner_mode == .RED)
    draw_scanner_box(166, 571, "2 BLUE", .BLUE, game.scanner_mode == .BLUE)
    draw_scanner_box(254, 571, "3 YELLOW", .YELLOW, game.scanner_mode == .YELLOW)

    if game.room == .SECURITY {
        rl.DrawText("SEQUENCE", 410, 574, 12, rl.GRAY)
        for i := 0; i < 4; i += 1 {
            color := rl.DARKGRAY
            if i < game.security_sequence_step { color = rl.GREEN }
            rl.DrawCircle(i32(485 + i*18), 581, 6, color)
        }
    }

    signals := 0
    if game.security_unlocked { signals += 1 }
    if game.lab_alignment_solved { signals += 1 }
    if game.maintenance_online { signals += 1 }
    rl.DrawText("FACILITY SIGNALS", 620, 574, 12, rl.GRAY)
    for i := 0; i < 3; i += 1 {
        color := rl.DARKGRAY
        if i < signals { color = rl.SKYBLUE }
        rl.DrawRectangle(i32(750 + i*20), 575, 14, 12, color)
    }
}

draw_scanner_box :: proc(x, y: i32, text: cstring, mode: Scanner_Mode, selected: bool) {
    color := scanner_color(mode)
    border := rl.DARKGRAY
    if selected { border = color }
    rl.DrawRectangleLines(x, y, 72, 21, border)
    rl.DrawText(text, x + 6, y + 5, 11, color)
}

draw_interaction_prompt :: proc(game: ^Game) {
    if game.player_index < 0 || game.inventory_open || game.objectives_open { return }

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || !near_entity(game, entity) { continue }

        switch entity.kind {
        case .TERMINAL: draw_prompt("E  ACCESS VISITOR TERMINAL"); return
        case .CEMETERY_DOOR:
            if !game.cemetery_door_open { draw_prompt("E  USE CEMETERY DOOR"); return }
        case .GRAVE_CLUE:
            if game.hidden_stair_found { draw_prompt("E  DESCEND HIDDEN STAIRWAY") } else { draw_prompt("E  INSPECT GRAVESTONE") }
            return
        case .DOOR_TRIGGER:
            if can_enter_room(game, entity.target_room) { draw_prompt("E  OPEN / PASS THROUGH") } else { draw_prompt("E  INSPECT LOCKED ACCESS") }
            return
        case .FUSE_ITEM:
            if !game.has_spare_fuse { draw_prompt("E  TAKE SPARE FUSE"); return }
        case .POWER_PANEL: draw_prompt("E  INSPECT POWER PANEL"); return
        case .SECURITY_CLUE: draw_prompt("E  READ SHIFT NOTE"); return
        case .SECURITY_CONSOLE: draw_prompt("E  INPUT CURRENT FREQUENCY"); return
        case .ARCHIVE_RECORDS:
            if !game.archive_records { draw_prompt("E  RECOVER INTAKE RECORDS"); return }
        case .ARCHIVE_HIDDEN_CLUE: draw_prompt("F  SCAN SUSPICIOUS COATING"); return
        case .LAB_AUDIO_LOG: draw_prompt("E  PLAY DAMAGED RECORDING"); return
        case .LAB_RECEIVER_A, .LAB_RECEIVER_B, .LAB_RECEIVER_C: draw_prompt("E  CALIBRATE WITH CURRENT FREQUENCY"); return
        case .DETENTION_CONSOLE: draw_prompt("F  SCAN CELL-LOCK BUS"); return
        case .CELL_KEY_ITEM:
            if !game.has_cell_key { draw_prompt("E  TAKE CELL KEY"); return }
        case .MISSING_EFFECTS:
            if !game.has_personal_effects { draw_prompt("E  INSPECT CELL 04 BELONGINGS"); return }
        case .SCREWDRIVER_ITEM:
            if !game.has_screwdriver { draw_prompt("E  TAKE SCREWDRIVER"); return }
        case .MAINT_PANEL:
            if game.maintenance_panel_open { draw_prompt("F  SCAN OPEN RELAY PANEL") } else { draw_prompt("E  OPEN RELAY PANEL") }
            return
        case .NOISE_PIPE: draw_prompt("E  STRIKE STEAM PIPE (DISTRACTION)"); return
        case .CONTAINMENT_NODE_A, .CONTAINMENT_NODE_B, .CONTAINMENT_NODE_C: draw_prompt("E  CALIBRATE CONTAINMENT NODE"); return
        case .EXPERIMENT_LOG:
            if game.containment_solved && !game.has_experiment_log { draw_prompt("E  RECOVER C-17 EXPERIMENT LOG"); return }
        case .FINAL_TERMINAL:
            if game.final_decrypted { draw_prompt("E  UPLOAD EVIDENCE") } else { draw_prompt("F  SCAN ENCRYPTED EVIDENCE MIRROR") }
            return
        case .OPTIONAL_NOTE: draw_prompt("E  READ DOCUMENT"); return
        case .OPTIONAL_PHOTO:
            if !game.optional_photo { draw_prompt("E  TAKE PHOTOGRAPH"); return }
        case .HIDE_SPOT:
            if game.player_hidden { draw_prompt("E  LEAVE HIDING PLACE") } else { draw_prompt("E  HIDE") }
            return
        case .PLAYER, .WALL, .BLOCKER, .SIGNAL_BARRIER, .MONSTER_SPAWN, .MONSTER_ENTRY, .LASER_BARRIER,
             .LIBRARY_TRIGGER, .SIDE_ROOM_TRIGGER, .DUNGEON_DOOR, .RETURN_TRIGGER,
             .LIBRARY_KEY_ITEM, .STAFF_LOCKER, .WARDEN_DESK, .ENDING_EXIT:
        }
    }
}

draw_prompt :: proc(text: cstring) {
    rl.DrawRectangle(275, 515, 550, 36, rl.Color{0, 0, 0, 225})
    rl.DrawRectangleLines(275, 515, 550, 36, rl.GRAY)
    rl.DrawText(text, 310, 526, 15, rl.RAYWHITE)
}

draw_inventory_overlay :: proc(game: ^Game) {
    rl.DrawRectangle(120, 95, 860, 450, rl.Color{8, 9, 10, 245})
    rl.DrawRectangleLines(120, 95, 860, 450, rl.GRAY)
    rl.DrawText("OFFICER'S FIELD INVENTORY", 155, 120, 25, rl.RAYWHITE)
    rl.DrawText("TAB — CLOSE", 825, 126, 14, rl.GRAY)

    y: i32 = 172
    if game.has_cemetery_key { draw_inventory_line(155, y, "Cemetery Key", "Visitor-gate key recovered from the surface terminal."); y += 42 }
    if game.has_spare_fuse { draw_inventory_line(155, y, "20A Ceramic Fuse", "Spare reception fuse; restored partial facility power."); y += 42 }
    if game.security_keycard { draw_inventory_line(155, y, "Security Keycard", "Security desk card; grants archive and lab access."); y += 42 }
    if game.archive_records { draw_inventory_line(155, y, "Missing-Person Intake Records", "Facility intake sheets naming all four missing people."); y += 42 }
    if game.has_cell_key { draw_inventory_line(155, y, "Detention Cell Key", "Physical override for the old mechanical cell locks."); y += 42 }
    if game.maintenance_badge { draw_inventory_line(155, y, "Maintenance Badge", "Recovered from Cell 04 belongings; opens maintenance access."); y += 42 }
    if game.has_screwdriver { draw_inventory_line(155, y, "Flathead Screwdriver", "Facility tool used to open sealed relay panels."); y += 42 }
    if game.has_experiment_log { draw_inventory_line(155, y, "C-17 Experiment Log", "Records linking Project Resonance to the Clay Stalker."); y += 42 }
    if game.optional_photo { draw_inventory_line(155, y, "Damaged Group Photograph", "Optional evidence showing the four missing people at the cemetery."); y += 42 }

    if y == 172 { rl.DrawText("No physical evidence collected yet.", 155, 190, 18, rl.GRAY) }
}

draw_inventory_line :: proc(x, y: i32, name, desc: cstring) {
    rl.DrawText(name, x, y, 17, rl.GOLD)
    rl.DrawText(desc, x + 245, y + 1, 14, rl.LIGHTGRAY)
}


draw_current_objective_panel :: proc(game: ^Game) {
    id, found := current_objective(game)
    x: i32 = 14
    y: i32 = 90
    w: i32 = 470
    h: i32 = 70

    rl.DrawRectangle(x, y, w, h, rl.Color{13, 12, 11, 220})
    rl.DrawRectangleLines(x, y, w, h, rl.Color{82, 70, 53, 255})
    rl.DrawRectangleLines(x + 3, y + 3, w - 6, h - 6, rl.Color{40, 36, 31, 255})
    rl.DrawText("CURRENT OBJECTIVE", x + 14, y + 10, 12, rl.Color{164, 136, 83, 255})

    if found {
        rl.DrawText(objective_title(id), x + 14, y + 29, 16, rl.RAYWHITE)
        rl.DrawText(room_objective(game), x + 14, y + 50, 11, rl.Color{162, 158, 145, 255})
    } else {
        rl.DrawText("Investigation complete.", x + 14, y + 31, 16, rl.Color{145, 170, 145, 255})
    }
}

minimap_structure_color :: proc(kind: Entity_Kind) -> rl.Color {
    #partial switch kind {
    case .WALL:
        return rl.Color{97, 88, 71, 255}
    case .BLOCKER, .HIDE_SPOT:
        return rl.Color{61, 58, 52, 255}
    case .DOOR_TRIGGER, .CEMETERY_DOOR, .SIGNAL_BARRIER, .LASER_BARRIER:
        return rl.Color{132, 91, 58, 255}
    case:
        return rl.Color{0, 0, 0, 0}
    }
}

minimap_draws_structure :: proc(kind: Entity_Kind) -> bool {
    #partial switch kind {
    case .WALL, .BLOCKER, .HIDE_SPOT, .DOOR_TRIGGER, .CEMETERY_DOOR, .SIGNAL_BARRIER, .LASER_BARRIER:
        return true
    case:
        return false
    }
}

draw_minimap :: proc(game: ^Game) {
    panel_x: i32 = 886
    panel_y: i32 = 86
    panel_w: i32 = 200
    panel_h: i32 = 150

    rl.DrawRectangle(panel_x, panel_y, panel_w, panel_h, rl.Color{9, 10, 10, 225})
    rl.DrawRectangleLines(panel_x, panel_y, panel_w, panel_h, rl.Color{80, 72, 59, 255})
    rl.DrawRectangleLines(panel_x + 3, panel_y + 3, panel_w - 6, panel_h - 6, rl.Color{38, 35, 31, 255})
    rl.DrawText("FACILITY MAP", panel_x + 10, panel_y + 8, 11, rl.Color{155, 132, 88, 255})

    map_x: i32 = panel_x + 10
    map_y: i32 = panel_y + 28
    map_w: i32 = panel_w - 20
    map_h: i32 = 88
    rl.DrawRectangle(map_x, map_y, map_w, map_h, rl.Color{18, 19, 18, 245})

    scale_x := f32(map_w) / f32(SCREEN_WIDTH)
    scale_y := f32(map_h) / f32(SCREEN_HEIGHT)

    for i := 0; i < game.entity_count; i += 1 {
        entity := &game.entities[i]
        if !entity.active || !minimap_draws_structure(entity.kind) {
            continue
        }

        mx := map_x + i32(entity.position[0] * scale_x)
        my := map_y + i32(entity.position[1] * scale_y)
        mw := i32(entity.size[0] * scale_x)
        mh := i32(entity.size[1] * scale_y)
        if mw < 1 { mw = 1 }
        if mh < 1 { mh = 1 }
        rl.DrawRectangle(mx, my, mw, mh, minimap_structure_color(entity.kind))
    }

    if game.player_index >= 0 {
        player := &game.entities[game.player_index]
        px := map_x + i32((player.position[0] + player.size[0] * 0.5) * scale_x)
        py := map_y + i32((player.position[1] + player.size[1] * 0.5) * scale_y)
        rl.DrawCircle(px, py, 3, rl.Color{205, 211, 198, 255})
        rl.DrawCircleLines(px, py, 4, rl.Color{95, 130, 125, 255})
    }

    // The minimap never reveals the monster. Exploration pips only reveal rooms already visited.
    for i := 0; i < ROOM_COUNT; i += 1 {
        pip_x := panel_x + 12 + i32(i*17)
        pip_y := panel_y + 128
        color := rl.Color{35, 34, 31, 255}
        if game.explored_rooms[i] { color = rl.Color{98, 87, 65, 255} }
        if i == int(game.room) { color = rl.Color{180, 145, 75, 255} }
        rl.DrawRectangle(i32(pip_x), i32(pip_y), 10, 6, color)
    }

    explored := explored_room_count(game)
    if explored >= ROOM_COUNT {
        rl.DrawText("AREA MAPPED", panel_x + 104, panel_y + 126, 9, rl.Color{125, 145, 125, 255})
    } else {
        rl.DrawText("EXPLORE", panel_x + 125, panel_y + 126, 9, rl.Color{92, 88, 78, 255})
    }
}

draw_objective_checkmark :: proc(x, y: i32) {
    color := rl.Color{117, 154, 116, 255}
    rl.DrawLine(x, y + 7, x + 5, y + 12, color)
    rl.DrawLine(x + 5, y + 12, x + 14, y + 2, color)
}

draw_objective_entry :: proc(game: ^Game, id: Objective_ID, y: i32) {
    status := objective_status(game, id)
    x: i32 = 145
    w: i32 = 810
    h: i32 = 24

    bg := rl.Color{18, 17, 15, 245}
    border := rl.Color{52, 47, 39, 255}
    text_color := rl.Color{130, 126, 113, 255}

    switch status {
    case .COMPLETED:
        bg = rl.Color{16, 21, 17, 245}
        border = rl.Color{54, 82, 59, 255}
        text_color = rl.Color{125, 154, 126, 255}
    case .ACTIVE:
        bg = rl.Color{39, 31, 22, 250}
        border = rl.Color{173, 132, 65, 255}
        text_color = rl.RAYWHITE
    case .LOCKED:
        bg = rl.Color{11, 11, 11, 245}
        border = rl.Color{38, 36, 33, 255}
        text_color = rl.Color{70, 68, 63, 255}
    }

    rl.DrawRectangle(x, y, w, h, bg)
    rl.DrawRectangleLines(x, y, w, h, border)

    switch status {
    case .COMPLETED:
        draw_objective_checkmark(x + 9, y + 4)
        rl.DrawText(objective_title(id), x + 37, y + 6, 12, text_color)
        rl.DrawText("COMPLETE", x + 728, y + 6, 10, rl.Color{92, 130, 93, 255})
    case .ACTIVE:
        rl.DrawRectangle(x + 8, y + 6, 12, 12, rl.Color{137, 43, 35, 255})
        rl.DrawRectangleLines(x + 6, y + 4, 16, 16, rl.Color{190, 143, 70, 255})
        rl.DrawText(objective_title(id), x + 37, y + 6, 12, text_color)
        rl.DrawText("ACTIVE", x + 741, y + 6, 10, rl.Color{200, 153, 75, 255})
    case .LOCKED:
        rl.DrawText("?", x + 11, y + 4, 16, rl.Color{82, 77, 68, 255})
        rl.DrawText("UNDISCOVERED LEAD", x + 37, y + 6, 12, text_color)
        rl.DrawText("LOCKED", x + 741, y + 6, 10, rl.Color{65, 63, 59, 255})
    }
}

draw_objective_log :: proc(game: ^Game) {
    // Full-screen modal investigation journal: aged, restrained and readable rather than a bright RPG quest list.
    rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.Color{0, 0, 0, 205})
    x: i32 = 95
    y: i32 = 42
    w: i32 = 910
    h: i32 = 552

    rl.DrawRectangle(x, y, w, h, rl.Color{14, 13, 12, 252})
    rl.DrawRectangleLines(x, y, w, h, rl.Color{104, 83, 54, 255})
    rl.DrawRectangleLines(x + 5, y + 5, w - 10, h - 10, rl.Color{45, 40, 34, 255})

    // Simple gothic/skeletal corner brackets.
    bracket := rl.Color{91, 75, 54, 255}
    rl.DrawLine(x + 15, y + 18, x + 55, y + 18, bracket)
    rl.DrawLine(x + 15, y + 18, x + 15, y + 48, bracket)
    rl.DrawLine(x + w - 15, y + 18, x + w - 55, y + 18, bracket)
    rl.DrawLine(x + w - 15, y + 18, x + w - 15, y + 48, bracket)

    rl.DrawText("INVESTIGATION LOG", x + 60, y + 20, 27, rl.Color{188, 166, 124, 255})
    rl.DrawText("MARSHALL PD — CASE 04-17 / BLACKOUT", x + 60, y + 52, 12, rl.Color{91, 87, 77, 255})
    rl.DrawText("I — CLOSE", x + 795, y + 27, 12, rl.Color{111, 104, 91, 255})

    current, found := current_objective(game)
    current_y := y + 82
    rl.DrawRectangle(x + 35, current_y, w - 70, 66, rl.Color{31, 25, 19, 255})
    rl.DrawRectangleLines(x + 35, current_y, w - 70, 66, rl.Color{151, 111, 57, 255})
    rl.DrawText("CURRENT OBJECTIVE", x + 50, current_y + 10, 11, rl.Color{166, 128, 66, 255})
    if found {
        rl.DrawText(objective_title(current), x + 50, current_y + 28, 17, rl.RAYWHITE)
        rl.DrawText(objective_description(current), x + 50, current_y + 49, 11, rl.Color{155, 151, 139, 255})
    } else {
        rl.DrawText("All recorded objectives are complete.", x + 50, current_y + 30, 17, rl.Color{125, 155, 125, 255})
    }

    completed := completed_objective_count(game)
    rl.DrawText("MAIN OBJECTIVES", x + 50, y + 160, 13, rl.Color{139, 119, 84, 255})
    rl.DrawText("? UNKNOWN   /   RED MARKER ACTIVE   /   CHECK COMPLETED", x + 420, y + 160, 10, rl.Color{77, 73, 66, 255})

    list_y := y + 181
    for i := 0; i < OBJECTIVE_COUNT; i += 1 {
        draw_objective_entry(game, Objective_ID(i), list_y + i32(i*25))
    }

    rl.DrawText("INVESTIGATION PROGRESS", x + 50, y + 538, 10, rl.Color{85, 80, 69, 255})
    // Progress is represented with fourteen small evidence marks rather than a modern progress bar.
    for i := 0; i < OBJECTIVE_COUNT; i += 1 {
        color := rl.Color{42, 39, 34, 255}
        if i < completed { color = rl.Color{91, 124, 91, 255} }
        rl.DrawRectangle(x + 205 + i32(i*18), y + 536, 11, 7, color)
    }
    rl.DrawText("TAB — FIELD INVENTORY", x + 720, y + 536, 10, rl.Color{85, 80, 69, 255})
}

draw_message :: proc(game: ^Game) {
    rl.DrawRectangle(175, 438, 750, 112, rl.Color{0, 0, 0, 232})
    rl.DrawRectangleLines(175, 438, 750, 112, rl.GRAY)

    if game.message_kind >= 6 && game.message_kind <= 8 {
        rl.DrawTextureEx(game.resources.player_portrait, rl.Vector2{188, 441}, 0, 0.82, rl.WHITE)
    }

    x: i32 = 210
    if game.message_kind >= 6 && game.message_kind <= 8 { x = 300 }

    switch game.message_kind {
    case 1: rl.DrawText("YOU OBTAINED: CEMETERY KEY", x, 476, 22, rl.GOLD)
    case 2: rl.DrawText("The cemetery door unlocks.", x, 476, 21, rl.LIGHTGRAY)
    case 3: rl.DrawText("The RED frequency shifts the surface barrier.", x, 476, 19, rl.RED)
    case 4: rl.DrawText("The visitor terminal has nothing else.", x, 476, 19, rl.GRAY)
    case 5: rl.DrawText("Locked. The terminal key should fit this door.", x, 476, 18, rl.LIGHTGRAY)
    case 6: rl.DrawText("There's light coming through...", x, 465, 21, rl.RAYWHITE)
    case 7: rl.DrawText("Digging... digging...", x, 465, 21, rl.RAYWHITE)
    case 8:
        rl.DrawText("There's a hidden stairway here...", x, 458, 20, rl.RAYWHITE)
        rl.DrawText("Better take a look.", x, 493, 20, rl.RAYWHITE)
    case 20: rl.DrawText("OBTAINED: 20A CERAMIC FUSE", x, 476, 21, rl.GOLD)
    case 21:
        rl.DrawText("Partial power restored.", x, 462, 21, rl.GREEN)
        rl.DrawText("Security control is receiving power again.", x, 497, 17, rl.LIGHTGRAY)
    case 22: rl.DrawText("The power panel is missing a 20A fuse.", x, 476, 19, rl.LIGHTGRAY)
    case 23:
        rl.DrawText("SHIFT NOTE: 'Stabilize RED. Route BLUE.", x, 458, 18, rl.BEIGE)
        rl.DrawText("Confirm YELLOW. Seal on BLUE.'", x, 492, 18, rl.BEIGE)
    case 24: rl.DrawText("Frequency accepted. Continue the sequence.", x, 476, 19, rl.SKYBLUE)
    case 25:
        rl.DrawText("SEQUENCE FAILED — ROUTER RESET.", x, 462, 20, rl.RED)
        rl.DrawText("The alarm echoed down the corridor...", x, 495, 17, rl.GRAY)
    case 26:
        rl.DrawText("SECURITY ROUTER UNLOCKED.", x, 458, 21, rl.GREEN)
        rl.DrawText("OBTAINED: SECURITY KEYCARD", x, 493, 20, rl.GOLD)
    case 27:
        rl.DrawText("EVIDENCE: MISSING-PERSON INTAKE RECORDS", x, 458, 19, rl.GOLD)
        rl.DrawText("Lena Park, Mateo Ruiz, Evan Cole, Leah Morrison.", x, 493, 17, rl.LIGHTGRAY)
    case 28:
        rl.DrawText("BLUE TRACE FOUND: 7 - 3 - 1", x, 458, 21, rl.SKYBLUE)
        rl.DrawText("Someone tried to chemically erase this access code.", x, 493, 17, rl.LIGHTGRAY)
    case 29: rl.DrawText("The coating reacts, but not to this frequency.", x, 476, 18, rl.LIGHTGRAY)
    case 30:
        rl.DrawText("AUDIO LOG: 'Receiver order: BLUE, RED, YELLOW.'", x, 458, 18, rl.SKYBLUE)
        rl.DrawText("A second voice whispers: 'Don't let C-17 hear it.'", x, 493, 17, rl.GRAY)
    case 31: rl.DrawText("Receiver calibrated.", x, 476, 20, rl.GREEN)
    case 32: rl.DrawText("Frequency mismatch. The receiver rejects the signal.", x, 476, 18, rl.RED)
    case 33:
        rl.DrawText("LABORATORY ALIGNMENT COMPLETE.", x, 458, 20, rl.GREEN)
        rl.DrawText("A second facility transmitter comes online.", x, 493, 17, rl.SKYBLUE)
    case 34: rl.DrawText("YELLOW BYPASS ACCEPTED — CELL LOCK BUS OPEN.", x, 476, 18, rl.GREEN)
    case 35:
        rl.DrawText("BYPASS DENIED.", x, 458, 20, rl.RED)
        rl.DrawText("The bus expects the archive code and YELLOW carrier.", x, 493, 17, rl.LIGHTGRAY)
    case 36: rl.DrawText("OBTAINED: DETENTION CELL KEY", x, 476, 20, rl.GOLD)
    case 37:
        rl.DrawText("EVIDENCE: CELL 04 PERSONAL EFFECTS", x, 458, 19, rl.GOLD)
        rl.DrawText("A maintenance badge is clipped inside the bag.", x, 493, 17, rl.LIGHTGRAY)
    case 38: rl.DrawText("OBTAINED: FLATHEAD SCREWDRIVER", x, 476, 20, rl.GOLD)
    case 39: rl.DrawText("Relay Panel 3 is screwed shut.", x, 476, 19, rl.LIGHTGRAY)
    case 40:
        rl.DrawText("The panel is open.", x, 458, 20, rl.LIGHTGRAY)
        rl.DrawText("A RED resonance trace is pulsing across the relay.", x, 493, 17, rl.RED)
    case 41:
        rl.DrawText("RELAY 3 ONLINE.", x, 458, 21, rl.GREEN)
        rl.DrawText("All three containment transmitters are synchronized.", x, 493, 17, rl.SKYBLUE)
    case 42: rl.DrawText("Containment node calibrated.", x, 476, 19, rl.GREEN)
    case 43:
        rl.DrawText("WRONG FREQUENCY.", x, 458, 20, rl.RED)
        rl.DrawText("Something moved behind the containment glass.", x, 493, 17, rl.GRAY)
    case 44:
        rl.DrawText("CONTAINMENT LOCK RELEASED.", x, 458, 20, rl.GREEN)
        rl.DrawText("The C-17 archive drawer has opened.", x, 493, 17, rl.LIGHTGRAY)
    case 45:
        rl.DrawText("EVIDENCE: PROJECT RESONANCE / SUBJECT C-17", x, 458, 18, rl.GOLD)
        rl.DrawText("Former security officer Elias Voss. Neural resonance failure.", x, 493, 16, rl.LIGHTGRAY)
    case 46: rl.DrawText("The evidence mirror requires three critical case exhibits.", x, 476, 17, rl.LIGHTGRAY)
    case 47: rl.DrawText("Encryption carrier detected. BLUE frequency required.", x, 476, 18, rl.SKYBLUE)
    case 48:
        rl.DrawText("EVIDENCE MIRROR DECRYPTED.", x, 458, 20, rl.GREEN)
        rl.DrawText("Press E to transmit the case file to Marshall PD.", x, 493, 17, rl.LIGHTGRAY)
    case 49:
        rl.DrawText("DOCUMENT: 'Do not transfer C-17 above ground.'", x, 458, 18, rl.BEIGE)
        rl.DrawText("Several signatures have been violently crossed out.", x, 493, 17, rl.GRAY)
    case 50:
        rl.DrawText("I made it back to a secure checkpoint.", x, 458, 19, rl.RAYWHITE)
        rl.DrawText("My evidence is still with me.", x, 493, 17, rl.SKYBLUE)
    case 51: rl.DrawText("No power. This access door is electronically sealed.", x, 476, 17, rl.LIGHTGRAY)
    case 52: rl.DrawText("Security authorization is required for this section.", x, 476, 17, rl.LIGHTGRAY)
    case 53:
        rl.DrawText("DETENTION ACCESS DENIED.", x, 458, 19, rl.RED)
        rl.DrawText("Security card, archive code and lab alignment are required.", x, 493, 16, rl.LIGHTGRAY)
    case 54: rl.DrawText("Maintenance access requires a department badge.", x, 476, 17, rl.LIGHTGRAY)
    case 55: rl.DrawText("Containment requires all three facility signals online.", x, 476, 17, rl.LIGHTGRAY)
    case 56: rl.DrawText("The final wing remains sealed by containment protocol.", x, 476, 17, rl.LIGHTGRAY)
    case 58: rl.DrawText("The hidden archive code is already recorded: 7-3-1.", x, 476, 17, rl.SKYBLUE)
    case 59: rl.DrawText("Relay 3 is already synchronized.", x, 476, 18, rl.GREEN)
    case 60: rl.DrawText("Scanner pulse: no unusual signature nearby.", x, 476, 18, rl.GRAY)
    case 61: rl.DrawText("Too close. It would see me enter the locker.", x, 476, 18, rl.RED)
    case 62:
        if game.player_hidden { rl.DrawText("I hold my breath inside the locker.", x, 476, 18, rl.SKYBLUE) }
        else { rl.DrawText("I step out of the hiding place.", x, 476, 18, rl.LIGHTGRAY) }
    case 63: rl.DrawText("Reception power is already stable.", x, 476, 18, rl.GREEN)
    case 64: rl.DrawText("I already photographed and bagged these intake records.", x, 476, 17, rl.GRAY)
    case 65: rl.DrawText("The item is still behind the electronic cell lock.", x, 476, 18, rl.RED)
    case 66: rl.DrawText("The bag is inside Cell 04. I need the physical cell key.", x, 476, 17, rl.LIGHTGRAY)
    case 67: rl.DrawText("Cell 04 has been searched thoroughly.", x, 476, 18, rl.GRAY)
    case 68: rl.DrawText("The relay panel is open. The scanner can reach the bus now.", x, 476, 17, rl.SKYBLUE)
    case 69:
        rl.DrawText("I strike the steam pipe.", x, 458, 19, rl.LIGHTGRAY)
        rl.DrawText("The metallic crash carries into the corridor.", x, 493, 17, rl.GRAY)
    case 70: rl.DrawText("The C-17 archive drawer is still magnetically locked.", x, 476, 17, rl.RED)
    case 71: rl.DrawText("I already secured the C-17 experiment log.", x, 476, 17, rl.GRAY)
    case 72:
        rl.DrawText("OPTIONAL EVIDENCE: DAMAGED GROUP PHOTOGRAPH", x, 458, 17, rl.GOLD)
        rl.DrawText("The four missing people are standing at the cemetery gate.", x, 493, 16, rl.LIGHTGRAY)
    case 73: rl.DrawText("The photograph is already in my evidence bag.", x, 476, 17, rl.GRAY)
    case 74:
        rl.DrawText("RECEPTION MEMO: Visitor gate unmanned after 23:00.", x, 458, 17, rl.BEIGE)
        rl.DrawText("'C-17 transfer suspended until Relay 3 is stable.'", x, 493, 16, rl.GRAY)
    case 75:
        rl.DrawText("ARCHIVE ADDENDUM: Vale added four civilian names", x, 458, 17, rl.BEIGE)
        rl.DrawText("without notifying local police.", x, 493, 17, rl.GRAY)
    case 76:
        rl.DrawText("LAB NOTE: C-17 reacts violently to carrier noise.", x, 458, 17, rl.BEIGE)
        rl.DrawText("'Do not pulse the scanner while containment is open.'", x, 493, 16, rl.GRAY)
    case 77:
        rl.DrawText("DETENTION LOG: Cell 04 refused to identify the leak.", x, 458, 17, rl.BEIGE)
        rl.DrawText("Maintenance badge confiscated with personal effects.", x, 493, 16, rl.GRAY)
    case 78:
        rl.DrawText("MAINTENANCE CARD: Relay 3 requires RED carrier", x, 458, 17, rl.BEIGE)
        rl.DrawText("after the panel is physically opened.", x, 493, 17, rl.GRAY)
    case 79:
        rl.DrawText("STORAGE TAG: Four personal-effects bags arrived together.", x, 458, 16, rl.BEIGE)
        rl.DrawText("One was returned to Detention Cell 04.", x, 493, 17, rl.GRAY)
    case 80:
        rl.DrawText("VALE: 'If the police reach the mirror, purge everything.'", x, 458, 16, rl.BEIGE)
        rl.DrawText("The purge command was never completed.", x, 493, 17, rl.GRAY)
    }
}
