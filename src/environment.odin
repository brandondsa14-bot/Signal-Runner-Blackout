package main

import rl "vendor:raylib"

Prop_ID :: enum {
    NONE,
    CEMETERY_TOOLBOX,
    CEMETERY_PLAQUE,
    RECEPTION_PHONE,
    RECEPTION_REGISTER,
    RECEPTION_BROCHURES,
    SECURITY_MONITOR,
    SECURITY_COFFEE,
    SECURITY_BINDER,
    ARCHIVE_BOOKSHELF,
    ARCHIVE_TYPEWRITER,
    LAB_EXAM_TABLE,
    LAB_COMPUTER,
    LAB_SAMPLE_TRAY,
    DETENTION_SCRATCHES,
    DETENTION_SINK,
    DETENTION_TOILET,
    MAINTENANCE_VALVE,
    MAINTENANCE_SIGN,
    PROCESSING_TANK,
    PROCESSING_MANIFEST,
    CONTAINMENT_GLASS,
    CONTAINMENT_GURNEY,
    STORAGE_BAG_RACK,
    STORAGE_CLIPBOARD,
    FINAL_CASE_BOARD,
    FINAL_RADIO,
    COUNT,
}

PROP_COUNT :: int(Prop_ID.COUNT)

prop_id_from_string :: proc(name: string) -> (Prop_ID, bool) {
    switch name {
    case "CEMETERY_TOOLBOX":     return .CEMETERY_TOOLBOX, true
    case "CEMETERY_PLAQUE":      return .CEMETERY_PLAQUE, true
    case "RECEPTION_PHONE":      return .RECEPTION_PHONE, true
    case "RECEPTION_REGISTER":   return .RECEPTION_REGISTER, true
    case "RECEPTION_BROCHURES":  return .RECEPTION_BROCHURES, true
    case "SECURITY_MONITOR":     return .SECURITY_MONITOR, true
    case "SECURITY_COFFEE":      return .SECURITY_COFFEE, true
    case "SECURITY_BINDER":      return .SECURITY_BINDER, true
    case "ARCHIVE_BOOKSHELF":    return .ARCHIVE_BOOKSHELF, true
    case "ARCHIVE_TYPEWRITER":   return .ARCHIVE_TYPEWRITER, true
    case "LAB_EXAM_TABLE":       return .LAB_EXAM_TABLE, true
    case "LAB_COMPUTER":         return .LAB_COMPUTER, true
    case "LAB_SAMPLE_TRAY":      return .LAB_SAMPLE_TRAY, true
    case "DETENTION_SCRATCHES":  return .DETENTION_SCRATCHES, true
    case "DETENTION_SINK":       return .DETENTION_SINK, true
    case "DETENTION_TOILET":     return .DETENTION_TOILET, true
    case "MAINTENANCE_VALVE":    return .MAINTENANCE_VALVE, true
    case "MAINTENANCE_SIGN":     return .MAINTENANCE_SIGN, true
    case "PROCESSING_TANK":      return .PROCESSING_TANK, true
    case "PROCESSING_MANIFEST":  return .PROCESSING_MANIFEST, true
    case "CONTAINMENT_GLASS":    return .CONTAINMENT_GLASS, true
    case "CONTAINMENT_GURNEY":   return .CONTAINMENT_GURNEY, true
    case "STORAGE_BAG_RACK":     return .STORAGE_BAG_RACK, true
    case "STORAGE_CLIPBOARD":    return .STORAGE_CLIPBOARD, true
    case "FINAL_CASE_BOARD":     return .FINAL_CASE_BOARD, true
    case "FINAL_RADIO":          return .FINAL_RADIO, true
    }
    return .NONE, false
}

prop_prompt :: proc(id: Prop_ID) -> cstring {
    switch id {
    case .CEMETERY_TOOLBOX:    return "E  INSPECT GROUNDSKEEPER TOOLBOX"
    case .CEMETERY_PLAQUE:     return "E  READ CEMETERY PLAQUE"
    case .RECEPTION_PHONE:     return "E  INSPECT DAMAGED TELEPHONE"
    case .RECEPTION_REGISTER:  return "E  EXAMINE VISITOR REGISTER"
    case .RECEPTION_BROCHURES: return "E  INSPECT OLD BROCHURES"
    case .SECURITY_MONITOR:    return "E  INSPECT SURVEILLANCE MONITOR"
    case .SECURITY_COFFEE:     return "E  INSPECT SECURITY DESK"
    case .SECURITY_BINDER:     return "E  EXAMINE MAINTENANCE BINDER"
    case .ARCHIVE_BOOKSHELF:   return "E  SEARCH REFERENCE SHELF"
    case .ARCHIVE_TYPEWRITER:  return "E  INSPECT TYPEWRITER"
    case .LAB_EXAM_TABLE:      return "E  EXAMINE MEDICAL TABLE"
    case .LAB_COMPUTER:        return "E  INSPECT RESEARCH TERMINAL"
    case .LAB_SAMPLE_TRAY:     return "E  EXAMINE SAMPLE TRAY"
    case .DETENTION_SCRATCHES: return "E  EXAMINE CELL-WALL SCRATCHES"
    case .DETENTION_SINK:      return "E  INSPECT CELL SINK"
    case .DETENTION_TOILET:    return "E  INSPECT TOILET"
    case .MAINTENANCE_VALVE:   return "E  INSPECT PRESSURE VALVE"
    case .MAINTENANCE_SIGN:    return "E  READ MAINTENANCE PLACARD"
    case .PROCESSING_TANK:     return "E  INSPECT CHEMICAL HOLDING TANK"
    case .PROCESSING_MANIFEST: return "E  READ WASTE-PROCESSING MANIFEST"
    case .CONTAINMENT_GLASS:   return "E  EXAMINE CONTAINMENT GLASS"
    case .CONTAINMENT_GURNEY:  return "E  EXAMINE RESTRAINT GURNEY"
    case .STORAGE_BAG_RACK:    return "E  INSPECT EVIDENCE-BAG RACK"
    case .STORAGE_CLIPBOARD:   return "E  READ STORAGE CLIPBOARD"
    case .FINAL_CASE_BOARD:    return "E  EXAMINE EVIDENCE BOARD"
    case .FINAL_RADIO:         return "E  INSPECT MAINTENANCE RADIO"
    case .NONE, .COUNT:        return "E  INSPECT"
    }
    return "E  INSPECT"
}

show_custom_message :: proc(game: ^Game, line1, line2: cstring) {
    game.custom_message_line1 = line1
    game.custom_message_line2 = line2
    game.message_kind = 999
    game.message_timer = game.tuning.message_duration
}

prop_stage :: proc(game: ^Game, id: Prop_ID) -> int {
    index := int(id)
    if index <= 0 || index >= PROP_COUNT { return 0 }
    return int(game.prop_interactions[index])
}

increment_prop_stage :: proc(game: ^Game, id: Prop_ID) {
    index := int(id)
    if index <= 0 || index >= PROP_COUNT { return }
    if game.prop_interactions[index] < 250 { game.prop_interactions[index] += 1 }
}

handle_environment_prop :: proc(game: ^Game, id: Prop_ID, position: rl.Vector2) {
    stage := prop_stage(game, id)
    increment_prop_stage(game, id)

    switch id {
    case .CEMETERY_TOOLBOX:
        show_custom_message(game, "The groundskeeper's tools are clean except for one shovel.", "Fresh clay is packed beneath the blade.")
    case .CEMETERY_PLAQUE:
        show_custom_message(game, "ST. MERCY MEMORIAL / SERVICE ANNEX — 1962", "Service annex? The public cemetery map never mentioned one.")
    case .RECEPTION_PHONE:
        if stage == 0 { show_custom_message(game, "The desk phone is dead. The redial display is frozen at 2:14.", "Same time as the call that brought me here.") }
        else { show_custom_message(game, "No dial tone. No outside line.", "Whatever called me used another transmitter.") }
    case .RECEPTION_REGISTER:
        show_custom_message(game, "The visitor register officially ends in 1987.", "Four recent indentations press through the blank page beneath it.")
    case .RECEPTION_BROCHURES:
        show_custom_message(game, "Civil-defense pamphlets, cemetery maps, evacuation routes.", "Someone circled the words 'signal annex' in red pencil.")
        evidence_add(game, .ANNEX_OPERATIONS_NOTICE)
    case .SECURITY_MONITOR:
        if stage == 0 {
            show_custom_message(game, "The camera feed is dead... mostly.", "One frame keeps showing a shape where the corridor should be empty.")
            game.prop_event_id = id
            game.prop_event_timer = 1.4
            rl.PlaySound(game.resources.monitor_flicker_sound)
        } else {
            show_custom_message(game, "Static. Empty corridor. Static again.", "I'm not sure the last frame was empty.")
        }
    case .SECURITY_COFFEE:
        show_custom_message(game, "Cold coffee. Two sugars. A ring stain over yesterday's shift roster.", "Whoever worked this desk left in a hurry.")
    case .SECURITY_BINDER:
        show_custom_message(game, "Router maintenance binder: 'Inputs are submitted one channel at a time.'", "The actual channel order is supposed to stay on the shift handover card.")
        game.security_instructions_read = true
    case .ARCHIVE_BOOKSHELF:
        if stage == 0 { show_custom_message(game, "Security manuals, maintenance logs... and gardening books.", "One binder is cleaner than the shelf around it.") }
        else { show_custom_message(game, "The clean binder was moved recently.", "The filing cabinet beside it has the same transfer-number prefix.") }
    case .ARCHIVE_TYPEWRITER:
        show_custom_message(game, "The ribbon is dry, but the last line is still legible:", "'CIVILIAN TRANSFER — DIRECTOR APPROVAL REQUIRED.'")
    case .LAB_EXAM_TABLE:
        show_custom_message(game, "Leather restraints. Conductive gel. Burn scoring around the headrest.", "Whatever they were testing, they did not expect cooperation.")
    case .LAB_COMPUTER:
        show_custom_message(game, "SUBJECT RESPONSE / CARRIER INSTABILITY / SESSION ABORTED", "The operator field is signed: A. Vale.")
    case .LAB_SAMPLE_TRAY:
        show_custom_message(game, "The labels say 'neural matrix — conductive substrate.'", "The residue looks disturbingly organic.")
    case .DETENTION_SCRATCHES:
        show_custom_message(game, "Four names are scratched into the concrete.", "Lena. Mateo. Evan. Leah. Someone counted the days underneath.")
        game.case_leah_clue = true
    case .DETENTION_SINK:
        show_custom_message(game, "Rust in the basin. The tap still produces a thin brown stream.", "There are fibers caught around the drain like torn medical gauze.")
    case .DETENTION_TOILET:
        if stage == 0 {
            show_custom_message(game, "Well, even secret underground facilities need plumbing.", "The handle still moves.")
        } else {
            show_custom_message(game, "The handle rattles. A low gurgle echoes through the pipes.", "Still works. That's surprisingly reassuring.")
            rl.PlaySound(game.resources.plumbing_sound)
            enemy_attract_to(game, position, false)
        }
    case .MAINTENANCE_VALVE:
        show_custom_message(game, "Pressure is still trapped in this line.", "The gauge needle jumps whenever the facility signal changes.")
    case .MAINTENANCE_SIGN:
        show_custom_message(game, "RELAY 3: RED CARRIER / MANUAL COVER RELEASE REQUIRED", "So the scanner alone won't open the panel.")
    case .PROCESSING_TANK:
        show_custom_message(game, "The runoff is conductive enough to trip the old floor sensors.", "Crossing without the maintenance bridge would be suicide.")
    case .PROCESSING_MANIFEST:
        show_custom_message(game, "WASTE PROCESSING: vent pressure on BLUE; engage bridge drive on YELLOW.", "Mateo Ruiz's initials are beside the last manual override.")
        game.case_mateo_clue = true
    case .CONTAINMENT_GLASS:
        show_custom_message(game, "The observation glass is bowed outward.", "Finger-shaped grooves are pressed into it from the other side.")
    case .CONTAINMENT_GURNEY:
        show_custom_message(game, "The restraints were cut, not opened.", "The ID strip reads VOSS, E. — SECURITY.")
    case .STORAGE_BAG_RACK:
        show_custom_message(game, "Four evidence bags were logged together, then split between departments.", "The chain-of-custody signatures stop after Dr. Vale's office.")
    case .STORAGE_CLIPBOARD:
        show_custom_message(game, "Property intake: cameras, phones, utility tools, EMT radio.", "The group came here prepared to document something.")
    case .FINAL_CASE_BOARD:
        show_custom_message(game, "Every route converges here: cemetery, intake, laboratory, detention, C-17.", "This wasn't four disappearances. It was one cover-up.")
    case .FINAL_RADIO:
        show_custom_message(game, "A maintenance transmitter is tuned to the Marshall PD repeater.", "Leah could have reached me from down here at 2:14 AM.")
        game.case_leah_clue = true
        evidence_add(game, .LEAH_RADIO_LOG)
    case .NONE, .COUNT:
        show_custom_message(game, "Nothing else stands out.", "")
    }
}

// Small original programmer-art props drawn from Raylib primitives. They align
// with data-driven hotspots and add room identity without external asset/licence risk.
draw_environment_prop :: proc(game: ^Game, entity: ^Entity) {
    x := i32(entity.position[0]); y := i32(entity.position[1]); w := i32(entity.size[0]); h := i32(entity.size[1])
    switch entity.prop_id {
    case .RECEPTION_PHONE:
        rl.DrawRectangle(x, y + 8, w, h - 8, rl.Color{42, 42, 40, 255}); rl.DrawRectangle(x + 5, y, w - 10, 8, rl.DARKGRAY)
    case .RECEPTION_REGISTER, .STORAGE_CLIPBOARD:
        rl.DrawRectangle(x, y, w, h, rl.Color{142, 126, 91, 255}); rl.DrawLine(x + 4, y + 7, x + w - 4, y + 7, rl.DARKGRAY)
    case .RECEPTION_BROCHURES:
        rl.DrawRectangle(x, y, w, h, rl.Color{87, 100, 91, 255}); rl.DrawRectangle(x + 4, y + 3, w - 8, h - 6, rl.Color{122, 130, 105, 255})
    case .SECURITY_MONITOR:
        draw_monitor(x, y, w, h, game.prop_event_id == .SECURITY_MONITOR && game.prop_event_timer > 0)
    case .SECURITY_COFFEE:
        rl.DrawCircle(x + w/2, y + h/2, f32(w)/3.0, rl.Color{91, 66, 47, 255})
        rl.DrawCircle(x + w/2, y + h/2, f32(w)/5.0, rl.Color{35, 22, 16, 255})
    case .SECURITY_BINDER:
        rl.DrawRectangle(x, y, w, h, rl.Color{68, 78, 72, 255}); rl.DrawRectangleLines(x, y, w, h, rl.GRAY)
    case .ARCHIVE_BOOKSHELF:
        draw_shelf(x, y, w, h, true)
    case .ARCHIVE_TYPEWRITER:
        rl.DrawRectangle(x, y + 8, w, h - 8, rl.Color{48, 48, 47, 255}); rl.DrawRectangle(x + 6, y, w - 12, 12, rl.LIGHTGRAY)
    case .LAB_EXAM_TABLE, .CONTAINMENT_GURNEY:
        rl.DrawRectangle(x, y + 8, w, h - 12, rl.Color{94, 101, 101, 255}); rl.DrawLine(x + 8, y + 8, x + 8, y + h, rl.DARKGRAY); rl.DrawLine(x + w - 8, y + 8, x + w - 8, y + h, rl.DARKGRAY)
    case .LAB_COMPUTER:
        draw_monitor(x, y, w, h, true)
    case .LAB_SAMPLE_TRAY:
        rl.DrawRectangle(x, y, w, h, rl.Color{103, 108, 108, 255}); for i: i32 = 0; i < 3; i += 1 { rl.DrawCircle(x + 9 + i*13, y + h/2, 4, rl.Color{86, 138, 123, 255}) }
    case .DETENTION_SCRATCHES:
        for i: i32 = 0; i < 4; i += 1 { rl.DrawLine(x + i*7, y, x + i*7 + 5, y + h, rl.Color{113, 103, 88, 210}) }
    case .DETENTION_SINK:
        rl.DrawRectangle(x, y, w, h, rl.Color{104, 108, 107, 255}); rl.DrawCircle(x + w/2, y + h/2, 5, rl.DARKGRAY)
    case .DETENTION_TOILET:
        rl.DrawRectangle(x + 5, y, w - 10, h/2, rl.Color{121, 124, 120, 255})
        rl.DrawEllipse(
            x + w/2,
            y + h*3/4,
            f32(w)/2.0 - 2.0,
            f32(h)/4.0,
            rl.Color{153, 154, 147, 255},
        )
    case .MAINTENANCE_VALVE:
        rl.DrawCircleLines(
            x + w/2,
            y + h/2,
            f32(w)/2.0 - 2.0,
            rl.ORANGE,
        )
        rl.DrawLine(x + 3, y + h/2, x + w - 3, y + h/2, rl.ORANGE)
    case .MAINTENANCE_SIGN:
        rl.DrawRectangle(x, y, w, h, rl.Color{132, 117, 64, 255}); rl.DrawText("R3", x + 6, y + 5, 10, rl.BLACK)
    case .PROCESSING_TANK:
        rl.DrawRectangle(x, y, w, h, rl.Color{53, 67, 62, 255}); rl.DrawRectangleLines(x, y, w, h, rl.Color{91, 126, 107, 255}); rl.DrawCircle(x + w/2, y + h/2, 8, rl.Color{98, 154, 91, 255})
    case .PROCESSING_MANIFEST:
        rl.DrawRectangle(x, y, w, h, rl.Color{137, 129, 91, 255}); rl.DrawRectangleLines(x, y, w, h, rl.DARKGRAY); rl.DrawText("WASTE", x + 4, y + 6, 8, rl.BLACK)
    case .CONTAINMENT_GLASS:
        rl.DrawRectangle(x, y, w, h, rl.Color{58, 83, 84, 120}); rl.DrawRectangleLines(x, y, w, h, rl.Color{118, 150, 145, 180})
    case .STORAGE_BAG_RACK:
        rl.DrawRectangle(x, y, w, h, rl.Color{67, 65, 58, 255}); for i: i32=0; i<3; i+=1 { rl.DrawRectangle(x+5+i*18, y+6, 12, h-12, rl.Color{125, 116, 91, 255}) }
    case .FINAL_CASE_BOARD:
        rl.DrawRectangle(x, y, w, h, rl.Color{74, 58, 44, 255}); for i: i32=0; i<3; i+=1 { rl.DrawRectangle(x+7+i*24, y+8, 18, 14, rl.BEIGE) }
    case .FINAL_RADIO:
        rl.DrawRectangle(x, y, w, h, rl.Color{42, 47, 45, 255}); rl.DrawRectangle(x+5, y+6, w-10, 8, rl.Color{44, 105, 72, 255}); rl.DrawLine(x+w-5, y, x+w+4, y-12, rl.GRAY)
    case .CEMETERY_TOOLBOX:
        rl.DrawRectangle(x, y, w, h, rl.Color{68, 55, 42, 255}); rl.DrawRectangle(x+w/3, y-5, w/3, 6, rl.GRAY)
    case .CEMETERY_PLAQUE:
        rl.DrawRectangle(x, y, w, h, rl.Color{75, 78, 75, 255}); rl.DrawRectangleLines(x, y, w, h, rl.LIGHTGRAY)
    case .NONE, .COUNT:
    }
}
