package main

Balance_Stage :: enum {
    INTRODUCTION,
    INVESTIGATION,
    RISING_DANGER,
    PEAK_TENSION,
    RESOLUTION,
}

balance_stage_for_room :: proc(room: Room_ID) -> Balance_Stage {
    switch room {
    case .ENTRANCE, .RECEPTION:
        return .INTRODUCTION
    case .SECURITY, .ARCHIVE, .LABORATORY:
        return .INVESTIGATION
    case .DETENTION, .MAINTENANCE, .PROCESSING, .STORAGE:
        return .RISING_DANGER
    case .CONTAINMENT:
        return .PEAK_TENSION
    case .FINAL_AREA:
        return .RESOLUTION
    }
    return .INTRODUCTION
}

balance_stage_name :: proc(stage: Balance_Stage) -> cstring {
    switch stage {
    case .INTRODUCTION: return "INTRO"
    case .INVESTIGATION: return "INVESTIGATION"
    case .RISING_DANGER: return "RISING"
    case .PEAK_TENSION: return "PEAK"
    case .RESOLUTION: return "RESOLUTION"
    }
    return "INTRO"
}

balance_stage_name_string :: proc(stage: Balance_Stage) -> string {
    switch stage {
    case .INTRODUCTION: return "INTRO"
    case .INVESTIGATION: return "INVESTIGATION"
    case .RISING_DANGER: return "RISING"
    case .PEAK_TENSION: return "PEAK"
    case .RESOLUTION: return "RESOLUTION"
    }
    return "INTRO"
}

difficulty_scale_for_room :: proc(tuning: ^Tuning, room: Room_ID) -> f32 {
    switch balance_stage_for_room(room) {
    case .INTRODUCTION: return tuning.difficulty_intro_scale
    case .INVESTIGATION: return tuning.difficulty_investigation_scale
    case .RISING_DANGER: return tuning.difficulty_rising_scale
    case .PEAK_TENSION: return tuning.difficulty_peak_scale
    case .RESOLUTION: return tuning.difficulty_resolution_scale
    }
    return 1.0
}

monster_patrol_speed_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_patrol_speed * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_chase_speed_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_chase_speed * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_detection_range_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_detection_range * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_hearing_range_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_hearing_range * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_alert_seconds_for_room :: proc(game: ^Game) -> f32 {
    scale := difficulty_scale_for_room(&game.tuning, game.room)
    if scale <= 0.01 { scale = 1.0 }
    return game.tuning.monster_alert_seconds / scale
}

monster_investigate_seconds_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_investigate_seconds * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_lost_seconds_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_lost_seconds * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_search_seconds_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_search_seconds * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_disengage_seconds_for_room :: proc(game: ^Game) -> f32 {
    return game.tuning.monster_disengage_seconds * difficulty_scale_for_room(&game.tuning, game.room)
}

monster_cross_room_delay_for_room :: proc(game: ^Game) -> f32 {
    scale := difficulty_scale_for_room(&game.tuning, game.room)
    if scale <= 0.01 { scale = 1.0 }
    return game.tuning.monster_cross_room_delay / scale
}

monster_respawn_min_for_room :: proc(game: ^Game) -> f32 {
    scale := difficulty_scale_for_room(&game.tuning, game.room)
    if scale <= 0.01 { scale = 1.0 }
    return game.tuning.monster_respawn_min / scale
}

monster_respawn_max_for_room :: proc(game: ^Game) -> f32 {
    scale := difficulty_scale_for_room(&game.tuning, game.room)
    if scale <= 0.01 { scale = 1.0 }
    return game.tuning.monster_respawn_max / scale
}
