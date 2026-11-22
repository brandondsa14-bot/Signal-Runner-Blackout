package main

import "core:fmt"
import "core:os"

CP5_BUILD_VERSION :: "cp5-2026-11-20"

Telemetry :: struct {
    enabled:                   bool,
    session_seconds:           f32,
    room_seconds:              [ROOM_COUNT]f32,
    objective_seconds:         [OBJECTIVE_COUNT]f32,
    wrong_puzzle_submissions:  int,
    hints_shown:               int,
    monster_encounters:        int,
    monster_escapes:           int,
    monster_captures:          int,
    chase_seconds:             f32,
    checkpoint_retries:        int,
    chase_active:              bool,
    snapshot_written:          bool,
}

telemetry_reset :: proc(game: ^Game) {
    game.telemetry = Telemetry{
        enabled = game.tuning.telemetry_enabled,
    }
}

telemetry_update :: proc(game: ^Game, dt: f32) {
    if !game.telemetry.enabled || game.state != .PLAYING {
        return
    }

    game.telemetry.session_seconds += dt
    room_index := int(game.room)
    if room_index >= 0 && room_index < ROOM_COUNT {
        game.telemetry.room_seconds[room_index] += dt
    }

    for i := 0; i < OBJECTIVE_COUNT; i += 1 {
        id := Objective_ID(i)
        if objective_status(game, id) == .ACTIVE {
            game.telemetry.objective_seconds[i] += dt
            break
        }
    }

    if game.enemy.state == .CHASE {
        game.telemetry.chase_seconds += dt
    }
}

telemetry_record_wrong_submission :: proc(game: ^Game) {
    if game.telemetry.enabled {
        game.telemetry.wrong_puzzle_submissions += 1
    }
}

telemetry_record_hint :: proc(game: ^Game) {
    if game.telemetry.enabled {
        game.telemetry.hints_shown += 1
    }
}

telemetry_record_enemy_transition :: proc(game: ^Game, old_state, new_state: Enemy_State) {
    if !game.telemetry.enabled {
        return
    }

    if new_state == .CHASE && old_state != .CHASE {
        game.telemetry.monster_encounters += 1
        game.telemetry.chase_active = true
    }

    if new_state == .DISENGAGE && game.telemetry.chase_active {
        game.telemetry.monster_escapes += 1
        game.telemetry.chase_active = false
    }
}

telemetry_record_capture :: proc(game: ^Game) {
    if !game.telemetry.enabled {
        return
    }
    game.telemetry.monster_captures += 1
    game.telemetry.checkpoint_retries += 1
    game.telemetry.chase_active = false
}

telemetry_profile_path :: proc(game: ^Game) -> string {
    if game.tuning.profile_id == 0 {
        return "telemetry/latest_before.csv"
    }
    if game.tuning.profile_id == 1 {
        return "telemetry/latest_after.csv"
    }
    return "telemetry/latest_custom.csv"
}

write_telemetry_snapshot :: proc(game: ^Game) -> bool {
    if !game.telemetry.enabled {
        return false
    }

    profile := tuning_profile_name_string(game.tuning.profile_id)
    stage := balance_stage_name_string(balance_stage_for_room(game.room))

    content := fmt.aprintf("""
        Signal Runner: Blackout - CP5 telemetry
        build_version,profile,stage,scenario,test_conditions,session_seconds,wrong_puzzle_submissions,hints_shown,monster_encounters,monster_escapes,monster_captures,chase_seconds,checkpoint_retries
        %s,%s,%s,%s,%s,%.2f,%d,%d,%d,%d,%d,%.2f,%d

        room,seconds
        ENTRANCE,%.2f
        RECEPTION,%.2f
        SECURITY,%.2f
        ARCHIVE,%.2f
        LABORATORY,%.2f
        DETENTION,%.2f
        MAINTENANCE,%.2f
        CONTAINMENT,%.2f
        FINAL_AREA,%.2f
        STORAGE,%.2f

        objective,seconds,completed
        VISITOR_TERMINAL,%.2f,%t
        HIDDEN_STAIRWAY,%.2f,%t
        RECEPTION_POWER,%.2f,%t
        SECURITY_ACCESS,%.2f,%t
        ARCHIVE_RECORDS,%.2f,%t
        ARCHIVE_CODE,%.2f,%t
        LAB_ALIGNMENT,%.2f,%t
        DETENTION_BYPASS,%.2f,%t
        CELL_04_EVIDENCE,%.2f,%t
        MAINTENANCE_RELAY,%.2f,%t
        CONTAINMENT_RELEASE,%.2f,%t
        C17_LOG,%.2f,%t
        FINAL_DECRYPT,%.2f,%t
        TRANSMIT_CASE,%.2f,%t
        """,
        CP5_BUILD_VERSION, profile, stage, game.tuning.telemetry_scenario, game.tuning.telemetry_conditions,
        game.telemetry.session_seconds,
        game.telemetry.wrong_puzzle_submissions,
        game.telemetry.hints_shown,
        game.telemetry.monster_encounters,
        game.telemetry.monster_escapes,
        game.telemetry.monster_captures,
        game.telemetry.chase_seconds,
        game.telemetry.checkpoint_retries,
        game.telemetry.room_seconds[int(Room_ID.ENTRANCE)],
        game.telemetry.room_seconds[int(Room_ID.RECEPTION)],
        game.telemetry.room_seconds[int(Room_ID.SECURITY)],
        game.telemetry.room_seconds[int(Room_ID.ARCHIVE)],
        game.telemetry.room_seconds[int(Room_ID.LABORATORY)],
        game.telemetry.room_seconds[int(Room_ID.DETENTION)],
        game.telemetry.room_seconds[int(Room_ID.MAINTENANCE)],
        game.telemetry.room_seconds[int(Room_ID.CONTAINMENT)],
        game.telemetry.room_seconds[int(Room_ID.FINAL_AREA)],
        game.telemetry.room_seconds[int(Room_ID.STORAGE)],
        game.telemetry.objective_seconds[int(Objective_ID.VISITOR_TERMINAL)], objective_complete(game, .VISITOR_TERMINAL),
        game.telemetry.objective_seconds[int(Objective_ID.HIDDEN_STAIRWAY)], objective_complete(game, .HIDDEN_STAIRWAY),
        game.telemetry.objective_seconds[int(Objective_ID.RECEPTION_POWER)], objective_complete(game, .RECEPTION_POWER),
        game.telemetry.objective_seconds[int(Objective_ID.SECURITY_ACCESS)], objective_complete(game, .SECURITY_ACCESS),
        game.telemetry.objective_seconds[int(Objective_ID.ARCHIVE_RECORDS)], objective_complete(game, .ARCHIVE_RECORDS),
        game.telemetry.objective_seconds[int(Objective_ID.ARCHIVE_CODE)], objective_complete(game, .ARCHIVE_CODE),
        game.telemetry.objective_seconds[int(Objective_ID.LAB_ALIGNMENT)], objective_complete(game, .LAB_ALIGNMENT),
        game.telemetry.objective_seconds[int(Objective_ID.DETENTION_BYPASS)], objective_complete(game, .DETENTION_BYPASS),
        game.telemetry.objective_seconds[int(Objective_ID.CELL_04_EVIDENCE)], objective_complete(game, .CELL_04_EVIDENCE),
        game.telemetry.objective_seconds[int(Objective_ID.MAINTENANCE_RELAY)], objective_complete(game, .MAINTENANCE_RELAY),
        game.telemetry.objective_seconds[int(Objective_ID.CONTAINMENT_RELEASE)], objective_complete(game, .CONTAINMENT_RELEASE),
        game.telemetry.objective_seconds[int(Objective_ID.C17_LOG)], objective_complete(game, .C17_LOG),
        game.telemetry.objective_seconds[int(Objective_ID.FINAL_DECRYPT)], objective_complete(game, .FINAL_DECRYPT),
        game.telemetry.objective_seconds[int(Objective_ID.TRANSMIT_CASE)], objective_complete(game, .TRANSMIT_CASE),
    )
    defer delete(content)

    path := telemetry_profile_path(game)
    err := os.write_entire_file(path, content)
    if err != nil {
        fmt.eprintfln("[CP5] Could not write telemetry snapshot %s: %v", path, err)
        return false
    }

    game.telemetry.snapshot_written = true
    fmt.printfln("[CP5] Telemetry snapshot written: %s", path)
    return true
}
