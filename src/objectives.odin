package main

Objective_ID :: enum {
    VISITOR_TERMINAL,
    HIDDEN_STAIRWAY,
    RECEPTION_POWER,
    SECURITY_ACCESS,
    ARCHIVE_RECORDS,
    ARCHIVE_CODE,
    LAB_ALIGNMENT,
    DETENTION_BYPASS,
    CELL_04_EVIDENCE,
    MAINTENANCE_RELAY,
    CONTAINMENT_RELEASE,
    C17_LOG,
    FINAL_DECRYPT,
    TRANSMIT_CASE,
}

Objective_Status :: enum {
    LOCKED,
    ACTIVE,
    COMPLETED,
}

OBJECTIVE_COUNT :: 14

objective_title :: proc(id: Objective_ID) -> cstring {
    switch id {
    case .VISITOR_TERMINAL:     return "Access the visitor terminal"
    case .HIDDEN_STAIRWAY:      return "Investigate the cemetery gravestone"
    case .RECEPTION_POWER:      return "Restore reception power"
    case .SECURITY_ACCESS:      return "Disable the security frequency lock"
    case .ARCHIVE_RECORDS:      return "Identify the four missing people"
    case .ARCHIVE_CODE:         return "Recover the erased archive code"
    case .LAB_ALIGNMENT:        return "Re-align the laboratory receivers"
    case .DETENTION_BYPASS:     return "Unlock Detention Block D"
    case .CELL_04_EVIDENCE:     return "Recover evidence from Cell 04"
    case .MAINTENANCE_RELAY:    return "Restore the third facility signal"
    case .CONTAINMENT_RELEASE:  return "Release the containment archive"
    case .C17_LOG:              return "Secure the Project Resonance log"
    case .FINAL_DECRYPT:        return "Decrypt the evidence mirror"
    case .TRANSMIT_CASE:        return "Transmit the case to Marshall PD"
    }
    return "Unknown objective"
}

objective_description :: proc(id: Objective_ID) -> cstring {
    switch id {
    case .VISITOR_TERMINAL:
        return "Use the visitor terminal to recover access to the cemetery."
    case .HIDDEN_STAIRWAY:
        return "Inspect the far-right gravestone and uncover the concealed stairway."
    case .RECEPTION_POWER:
        return "Find the spare 20A fuse and repair the underground reception panel."
    case .SECURITY_ACCESS:
        return "Use the shift note to enter the correct scanner-frequency sequence."
    case .ARCHIVE_RECORDS:
        return "Search the Records Archive for intake files connected to the disappearances."
    case .ARCHIVE_CODE:
        return "Use BLUE scanning to recover the chemically erased access code."
    case .LAB_ALIGNMENT:
        return "Use the damaged recording to calibrate all three laboratory receivers."
    case .DETENTION_BYPASS:
        return "Use the keycard, archive code and YELLOW carrier to bypass the cell-lock bus."
    case .CELL_04_EVIDENCE:
        return "Find the cell key and recover the personal-effects bag from Cell 04."
    case .MAINTENANCE_RELAY:
        return "Open Relay Panel 3 and synchronize it with the RED frequency."
    case .CONTAINMENT_RELEASE:
        return "Calibrate the three containment nodes while surviving the Clay Stalker."
    case .C17_LOG:
        return "Recover the C-17 experiment log from the released containment archive."
    case .FINAL_DECRYPT:
        return "Bring the critical evidence to the final mirror and decrypt it with BLUE."
    case .TRANSMIT_CASE:
        return "Upload the complete case file to Marshall Police before the signal is lost."
    }
    return "Continue the investigation."
}

objective_complete :: proc(game: ^Game, id: Objective_ID) -> bool {
    switch id {
    case .VISITOR_TERMINAL:    return game.has_cemetery_key
    case .HIDDEN_STAIRWAY:     return game.hidden_stair_found
    case .RECEPTION_POWER:     return game.reception_power
    case .SECURITY_ACCESS:     return game.security_unlocked
    case .ARCHIVE_RECORDS:     return game.archive_records
    case .ARCHIVE_CODE:        return game.archive_code_known
    case .LAB_ALIGNMENT:       return game.lab_alignment_solved
    case .DETENTION_BYPASS:    return game.detention_locks_bypassed
    case .CELL_04_EVIDENCE:    return game.has_personal_effects
    case .MAINTENANCE_RELAY:   return game.maintenance_online
    case .CONTAINMENT_RELEASE: return game.containment_solved
    case .C17_LOG:             return game.has_experiment_log
    case .FINAL_DECRYPT:       return game.final_decrypted
    case .TRANSMIT_CASE:       return game.case_transmitted
    }
    return false
}

objective_unlocked :: proc(game: ^Game, id: Objective_ID) -> bool {
    if id == .VISITOR_TERMINAL {
        return true
    }

    index := int(id)
    if index <= 0 || index >= OBJECTIVE_COUNT {
        return false
    }

    previous := Objective_ID(index - 1)
    return objective_complete(game, previous)
}

objective_status :: proc(game: ^Game, id: Objective_ID) -> Objective_Status {
    if objective_complete(game, id) {
        return .COMPLETED
    }
    if objective_unlocked(game, id) {
        return .ACTIVE
    }
    return .LOCKED
}

current_objective :: proc(game: ^Game) -> (Objective_ID, bool) {
    for i := 0; i < OBJECTIVE_COUNT; i += 1 {
        id := Objective_ID(i)
        if objective_status(game, id) == .ACTIVE {
            return id, true
        }
    }
    return .TRANSMIT_CASE, false
}

completed_objective_count :: proc(game: ^Game) -> int {
    count := 0
    for i := 0; i < OBJECTIVE_COUNT; i += 1 {
        if objective_complete(game, Objective_ID(i)) {
            count += 1
        }
    }
    return count
}

explored_room_count :: proc(game: ^Game) -> int {
    count := 0
    for i := 0; i < ROOM_COUNT; i += 1 {
        if game.explored_rooms[i] {
            count += 1
        }
    }
    return count
}
