package main

import rl "vendor:raylib"

Hint_Context :: enum {
    NONE,
    ENTRANCE,
    RECEPTION,
    SECURITY,
    ARCHIVE,
    LABORATORY,
    DETENTION,
    MAINTENANCE,
    CONTAINMENT,
    FINAL_AREA,
    STORAGE,
    COUNT,
}

HINT_CONTEXT_COUNT :: int(Hint_Context.COUNT)

scanner_mode_label :: proc(mode: Scanner_Mode) -> cstring {
    switch mode {
    case .RED:    return "RED"
    case .BLUE:   return "BLUE"
    case .YELLOW: return "YELLOW"
    }
    return "?"
}

hint_context_for_game :: proc(game: ^Game) -> Hint_Context {
    switch game.room {
    case .ENTRANCE:     return .ENTRANCE
    case .RECEPTION:    return .RECEPTION
    case .SECURITY:     return .SECURITY
    case .ARCHIVE:      return .ARCHIVE
    case .LABORATORY:   return .LABORATORY
    case .DETENTION:    return .DETENTION
    case .MAINTENANCE:  return .MAINTENANCE
    case .CONTAINMENT:  return .CONTAINMENT
    case .FINAL_AREA:   return .FINAL_AREA
    case .STORAGE:      return .STORAGE
    }
    return .NONE
}

hint_progress_token :: proc(game: ^Game, ctx: Hint_Context) -> int {
    switch ctx {
    case .ENTRANCE:
        token := 0
        if game.has_cemetery_key { token += 10 }
        if game.hidden_stair_found { token += 20 }
        return token
    case .RECEPTION:
        token := 0
        if game.has_spare_fuse { token += 10 }
        if game.reception_power { token += 20 }
        if inventory_has(game, .EMPLOYEE_BADGE) { token += 30 }
        if game.security_door_unlocked { token += 40 }
        return token
    case .SECURITY:
        token := 0
        if game.security_clue_read { token += 10 }
        if game.security_router_seen { token += 20 }
        token += game.security_sequence_step
        if game.security_unlocked { token += 100 }
        return token
    case .ARCHIVE:
        token := 0
        if game.archive_records { token += 10 }
        if game.archive_code_known { token += 20 }
        return token
    case .LABORATORY:
        token := 0
        if game.lab_audio_log { token += 10 }
        if game.lab_receiver_a { token += 1 }
        if game.lab_receiver_b { token += 1 }
        if game.lab_receiver_c { token += 1 }
        if game.lab_alignment_solved { token += 50 }
        return token
    case .DETENTION:
        token := 0
        if game.detention_locks_bypassed { token += 10 }
        if game.has_cell_key { token += 20 }
        if game.has_personal_effects { token += 40 }
        return token
    case .MAINTENANCE:
        token := 0
        if game.has_screwdriver { token += 10 }
        if game.maintenance_panel_open { token += 20 }
        if game.maintenance_online { token += 40 }
        return token
    case .CONTAINMENT:
        token := 0
        if game.containment_node_a { token += 1 }
        if game.containment_node_b { token += 1 }
        if game.containment_node_c { token += 1 }
        if game.containment_solved { token += 20 }
        if game.has_experiment_log { token += 40 }
        return token
    case .FINAL_AREA:
        token := 0
        if has_required_final_evidence(game) { token += 10 }
        if game.final_decrypted { token += 20 }
        if game.case_transmitted { token += 40 }
        return token
    case .STORAGE:
        token := 0
        if game.optional_photo { token += 10 }
        return token
    case .NONE, .COUNT:
        return 0
    }
    return 0
}

hint_system_paused :: proc(game: ^Game) -> bool {
    if game.state != .PLAYING { return true }
    if game.search_open || game.item_use_open || game.inventory_open || game.objectives_open || game.hint_solution_open { return true }
    if game.message_timer > 0 { return true }
    if game.enemy.state == .ALERT || game.enemy.state == .CHASE || game.enemy.state == .SEARCH { return true }
    return false
}

hint_help_available :: proc(game: ^Game) -> bool {
    ctx := hint_context_for_game(game)
    if ctx == .NONE || ctx == .COUNT { return false }
    return game.hint_stage[int(ctx)] >= 4
}

update_hint_system :: proc(game: ^Game, dt: f32) {
    if !game.hints_enabled || hint_system_paused(game) { return }

    ctx := hint_context_for_game(game)
    if ctx == .NONE || ctx == .COUNT { return }
    index := int(ctx)
    token := hint_progress_token(game, ctx)

    if game.hint_progress_token[index] < 0 {
        game.hint_progress_token[index] = token
    } else if token > game.hint_progress_token[index] {
        // Only forward, meaningful progress resets the stuck timer. Wrong inputs
        // that reduce a sequence do not count as progress.
        game.hint_progress_token[index] = token
        game.hint_elapsed[index] = 0
        game.hint_stage[index] = 0
        game.hint_notification_timer = 0
    }

    if game.hint_stage[index] < 4 {
        game.hint_elapsed[index] += dt
        if game.hint_elapsed[index] >= game.tuning.hint_interval_seconds {
            game.hint_elapsed[index] = 0
            game.hint_stage[index] += 1
            game.hint_notification_context = ctx
            game.hint_notification_stage = game.hint_stage[index]
            game.hint_notification_timer = game.tuning.hint_notification_seconds
        }
    }

    if game.hint_stage[index] >= 4 && rl.IsKeyPressed(.H) {
        game.hint_solution_open = true
    }
}

contextual_next_step :: proc(game: ^Game) -> cstring {
    switch game.room {
    case .ENTRANCE:
        if !game.has_cemetery_key { return "Use E at the visitor terminal near the gate." }
        if !game.hidden_stair_found { return "Inspect the far-right gravestone with E." }
        return "Return to the opened grave and descend underground."
    case .RECEPTION:
        if !game.has_spare_fuse { return "Search Reception, then inspect the floor near the power panel for the fuse." }
        if !game.reception_power { return "Press E at the power panel and choose the 20A fuse." }
        if !inventory_has(game, .EMPLOYEE_BADGE) { return "Search the Reception desk for a staff badge." }
        if !game.security_door_unlocked { return "Use the employee badge on the Security Control door." }
        return "Enter Security Control and inspect the frequency system."
    case .SECURITY:
        if game.security_unlocked { return "The east laser grid is down. Follow the open route toward the laboratory." }
        if !game.security_clue_read { return "Examine the Shift Note beside the Frequency Router." }
        if !game.security_router_seen { return "Approach the Frequency Router and press E to inspect its controls." }
        if game.security_sequence_step <= 0 { return "Choose a scanner colour with 1/2/3, then press E at the router." }
        return "Continue entering the sequence; the green dots show accepted signals."
    case .ARCHIVE:
        if !game.archive_records { return "Recover the missing-person intake records from the archive index." }
        if !game.archive_code_known { return "Use the scanner on the suspicious coating along the east shelving." }
        return "The erased code is recorded. Continue to the Medical Laboratory."
    case .LABORATORY:
        if !game.lab_audio_log { return "Play the damaged recording before calibrating the receivers." }
        if !game.lab_alignment_solved { return "Match each receiver to the frequency order described in the recording." }
        return "Laboratory alignment is complete. Attempt Detention Block D access."
    case .DETENTION:
        if !game.detention_locks_bypassed { return "Inspect the cell-lock bus and use the required scanner carrier." }
        if !game.has_cell_key { return "Search the opened detention area for the physical Cell 04 key." }
        if !game.has_personal_effects { return "Use the cell key to recover the belongings from Cell 04." }
        return "The maintenance badge is secured. Reach the maintenance tunnels."
    case .MAINTENANCE:
        if !game.has_screwdriver { return "Search maintenance storage for a tool that can open Relay Panel 3." }
        if !game.maintenance_panel_open { return "Use the screwdriver on Relay Panel 3." }
        if !game.maintenance_online { return "Scan the opened relay using the frequency indicated by maintenance notes." }
        return "Relay 3 is online. Proceed toward Containment Wing C."
    case .CONTAINMENT:
        if !game.containment_solved { return "Calibrate all three containment nodes while avoiding C-17." }
        if !game.has_experiment_log { return "Recover the released C-17 experiment log." }
        return "Containment evidence secured. Continue to the final investigation room."
    case .FINAL_AREA:
        if !has_required_final_evidence(game) { return "Review your evidence and recover any missing critical exhibit." }
        if !game.final_decrypted { return "Use the scanner to decrypt the evidence mirror." }
        return "Press E at the terminal to transmit the complete case file."
    case .STORAGE:
        return "Optional: search the personal-effects storage before returning to the investigation."
    }
    return "Continue the investigation."
}

security_remaining_hint :: proc(game: ^Game) -> cstring {
    remaining := 4 - game.security_sequence_step
    switch remaining {
    case 1: return "One frequency remains. Continue from the next accepted position."
    case 2: return "Two frequencies remain. The green indicators show your accepted progress."
    case 3: return "Three frequencies remain. Use the Shift Note and continue from the next position."
    case 4: return "Four frequencies are required. Read the Shift Note before entering the sequence."
    }
    return "The router sequence is complete."
}

hint_line_1 :: proc(game: ^Game, ctx: Hint_Context, stage: int) -> cstring {
    switch ctx {
    case .SECURITY:
        if game.security_unlocked { return "The security lock is disabled." }
        if !game.security_clue_read { return "That Shift Note probably explains the router." }
        if !game.security_router_seen { return "The note describes colours. The router must accept them." }
        if game.security_sequence_step > 0 { return security_remaining_hint(game) }
        if stage <= 1 { return "The router responds to scanner colours." }
        if stage == 2 { return "Match the scanner colours to the Shift Note's order." }
        return "Select with 1/2/3, then press E at the router for each signal."
    case .RECEPTION:
        if !game.has_spare_fuse { return "The power panel needs a fuse. Check the floor near the electrical equipment." }
        if !game.reception_power { return "I already have the replacement fuse. I should try it on the power panel." }
        if !inventory_has(game, .EMPLOYEE_BADGE) { return "The Reception desk may contain staff access credentials." }
        return "That employee badge should work on the Security Control reader."
    case .ARCHIVE:
        if !game.archive_records { return "The intake index should identify who was brought into the facility." }
        return "The east shelving has an unusual coating. The scanner may reveal what was erased."
    case .LABORATORY:
        if !game.lab_audio_log { return "The damaged recording may explain how the receivers were calibrated." }
        return "The recording gives an order. Each receiver expects one scanner frequency."
    case .DETENTION:
        if !game.detention_locks_bypassed { return "The detention bus expects information gathered earlier in the facility." }
        if !game.has_cell_key { return "The electronic locks are open, but Cell 04 still needs a physical key." }
        return "The Cell 04 evidence bag should still be inside the opened block."
    case .MAINTENANCE:
        if !game.has_screwdriver { return "Relay Panel 3 is physically sealed. I need a proper hand tool." }
        if !game.maintenance_panel_open { return "I already have a screwdriver that should fit the relay cover." }
        return "The opened relay responds to a scanner carrier described in the maintenance notes."
    case .CONTAINMENT:
        if !game.containment_solved { return "The containment nodes are separate parts of one calibration system." }
        return "The archive drawer released when the nodes synchronized."
    case .FINAL_AREA:
        if !has_required_final_evidence(game) { return "The final mirror is rejecting the case because evidence is missing." }
        if !game.final_decrypted { return "The mirror uses the same scanner logic seen elsewhere in the facility." }
        return "The evidence is decrypted. I only need to transmit it."
    case .ENTRANCE:
        if !game.has_cemetery_key { return "The visitor terminal should tell me how to get through the cemetery gate." }
        return "The far-right gravestone is the one that looked disturbed."
    case .STORAGE:
        return "This room is optional. Anything useful here is evidence, not required progression."
    case .NONE, .COUNT:
        return ""
    }
    return ""
}

hint_line_2 :: proc(game: ^Game, ctx: Hint_Context, stage: int) -> cstring {
    if stage >= 4 { return "Need more help? Press H for step-by-step assistance." }
    switch ctx {
    case .SECURITY:
        if !game.security_clue_read { return "Look beside the Frequency Router and press E to read it." }
        if !game.security_router_seen { return "Approach the Frequency Router and press E once to inspect it." }
        return "The sequence only advances when the current scanner colour is accepted."
    case .RECEPTION:
        return "Use E to interact; the objective panel always shows the immediate next step."
    case .ARCHIVE:
        return "Use F to pulse the scanner when standing near a suspicious surface."
    case .LABORATORY:
        return "Read or play the clue first; then calibrate the receivers one at a time."
    case .DETENTION:
        return "Check earlier evidence, your inventory, and the scanner carrier before retrying."
    case .MAINTENANCE:
        return "Use a physical tool first, then the scanner after the panel is open."
    case .CONTAINMENT:
        return "Progress persists between nodes, so create distance from C-17 before calibrating."
    case .FINAL_AREA:
        return "The investigation log can show which major evidence objective is still incomplete."
    case .ENTRANCE:
        return "Use E near highlighted investigation objects."
    case .STORAGE:
        return "Return to Reception when you are ready to continue the main case."
    case .NONE, .COUNT:
        return ""
    }
    return ""
}

draw_hint_notification :: proc(game: ^Game) {
    if game.hint_notification_timer <= 0 || game.message_timer > 0 || game.hint_solution_open { return }
    ctx := game.hint_notification_context
    if ctx == .NONE || ctx == .COUNT { return }

    x: i32 = 14
    y: i32 = 196
    w: i32 = 470
    h: i32 = 68
    rl.DrawRectangle(x, y, w, h, rl.Color{10, 9, 9, 238})
    rl.DrawRectangleLines(x, y, w, h, rl.Color{105, 78, 48, 255})
    rl.DrawText("OFFICER'S THOUGHT", x + 12, y + 8, 11, rl.Color{170, 132, 74, 255})
    rl.DrawText(hint_line_1(game, ctx, game.hint_notification_stage), x + 12, y + 27, 10, rl.RAYWHITE)
    rl.DrawText(hint_line_2(game, ctx, game.hint_notification_stage), x + 12, y + 45, 9, rl.Color{149, 143, 131, 255})
}

draw_security_solution :: proc(game: ^Game, x, y: i32) {
    rl.DrawText("STEP-BY-STEP — SECURITY FREQUENCY ROUTER", x, y, 18, rl.GOLD)
    if !game.security_clue_read {
        rl.DrawText("1. Read the Shift Note beside the router with E.", x, y + 34, 14, rl.RAYWHITE)
    } else {
        rl.DrawText("1. Shift Note read.", x, y + 34, 14, rl.GREEN)
    }
    rl.DrawText("2. Use 1 / 2 / 3 to choose RED, BLUE or YELLOW.", x, y + 62, 14, rl.RAYWHITE)
    rl.DrawText("3. Stand at the Frequency Router and press E to submit the selected colour.", x, y + 90, 14, rl.RAYWHITE)
    rl.DrawText("4. Accepted entries remain lit in the sequence indicator.", x, y + 118, 14, rl.RAYWHITE)
    rl.DrawText("Implemented router sequence:", x, y + 158, 13, rl.Color{153, 144, 127, 255})

    for i := 0; i < 4; i += 1 {
        mode := security_expected_mode(i)
        color := scanner_color(mode)
        box_x := x + i32(i*130)
        rl.DrawRectangle(box_x, y + 184, 112, 36, rl.Color{19, 18, 17, 255})
        rl.DrawRectangleLines(box_x, y + 184, 112, 36, color)
        rl.DrawText(scanner_mode_label(mode), box_x + 24, y + 195, 13, color)
    }

    if game.security_sequence_step > 0 && !game.security_unlocked {
        rl.DrawText(security_remaining_hint(game), x, y + 244, 13, rl.SKYBLUE)
    }
    if game.security_unlocked {
        rl.DrawText("The laser grid is already disabled. Use the east passage toward the laboratory.", x, y + 244, 13, rl.GREEN)
    }
}

draw_hint_solution_overlay :: proc(game: ^Game) {
    ctx := hint_context_for_game(game)
    rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.Color{0, 0, 0, 215})
    rl.DrawRectangle(105, 70, 890, 500, rl.Color{9, 9, 9, 252})
    rl.DrawRectangleLines(105, 70, 890, 500, rl.Color{108, 82, 53, 255})
    rl.DrawText("INVESTIGATION ASSISTANCE", 145, 102, 25, rl.Color{198, 179, 143, 255})
    rl.DrawText("H / I / ESC — CLOSE", 800, 108, 11, rl.Color{126, 116, 98, 255})

    if ctx == .SECURITY {
        draw_security_solution(game, 155, 155)
    } else {
        rl.DrawText("CURRENT NEXT STEP", 155, 165, 15, rl.GOLD)
        rl.DrawText(contextual_next_step(game), 155, 198, 14, rl.RAYWHITE)
        rl.DrawText("This assistance is derived from the current puzzle state and collected evidence.", 155, 245, 12, rl.GRAY)
        rl.DrawText("Automatic hints pause during menus, dialogue and Clay Stalker pursuit.", 155, 275, 12, rl.GRAY)
        rl.DrawText("Press K during gameplay to enable or disable automatic hints.", 155, 305, 12, rl.Color{145, 132, 105, 255})
    }
}
