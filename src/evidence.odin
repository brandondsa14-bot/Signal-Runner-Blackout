package main

Evidence_ID :: enum {
    INTAKE_RECORDS,
    LENA_TRANSFER_FORM,
    MATEO_ROUTING_TAG,
    EVAN_MICROCASSETTE,
    RESONANCE_RECORDING,
    LEAH_RADIO_LOG,
    CELL04_EFFECTS,
    GROUP_PHOTO,
    C17_EXPERIMENT_LOG,
    VALE_PURGE_ORDER,
    ANNEX_OPERATIONS_NOTICE,
    MATEO_RELAY_INCIDENT,
    COUNT,
}

EVIDENCE_COUNT :: int(Evidence_ID.COUNT)

Evidence_Def :: struct {
    title:       cstring,
    case_name:   cstring,
    location:    cstring,
    summary:     cstring,
    mandatory:   bool,
}

evidence_def :: proc(id: Evidence_ID) -> Evidence_Def {
    switch id {
    case .INTAKE_RECORDS:
        return Evidence_Def{"Missing-Person Intake Records", "ALL FOUR", "Records Archive", "Vale's intake sheets place Lena Park, Mateo Ruiz, Evan Cole and Leah Morrison inside the annex.", true}
    case .LENA_TRANSFER_FORM:
        return Evidence_Def{"Lena Park Transfer Request", "LENA PARK", "Records Archive", "Reporter Lena Park was moved to archive isolation after refusing to surrender her camera and notes; the transfer references a sealed service shaft.", false}
    case .MATEO_ROUTING_TAG:
        return Evidence_Def{"Mateo Ruiz Evidence Routing Tag", "MATEO RUIZ", "Records Archive", "A routing tag sends contractor Mateo Ruiz's utility tools from Detention D / Cell 04 to Relay 3 under forced maintenance authorization.", false}
    case .EVAN_MICROCASSETTE:
        return Evidence_Def{"Evan Cole Microcassette", "EVAN COLE", "Records Archive", "Groundskeeper Evan Cole records freshly reopened cemetery service tunnels and says he will meet Lena's group at the visitor gate.", false}
    case .RESONANCE_RECORDING:
        return Evidence_Def{"Project Resonance Calibration Recording", "EVAN / PROJECT RESONANCE", "Medical Laboratory", "The recording identifies 'groundskeeper E.C.' as an unauthorized calibration subject and documents a fatal neural reaction; it also links the tri-band scanner to C-17's carrier-response system.", true}
    case .LEAH_RADIO_LOG:
        return Evidence_Def{"Leah Morrison Radio Log", "LEAH MORRISON", "Detention Block D", "A detention note records Leah hiding a maintenance radio before transfer to Observation—the source of the 2:14 AM call.", false}
    case .CELL04_EFFECTS:
        return Evidence_Def{"Cell 04 Personal Effects", "MATEO / LEAH", "Detention Block D", "Mateo's maintenance badge and Leah's EMT property tag prove the civilians were detained here and that Mateo was forced into facility maintenance work.", true}
    case .GROUP_PHOTO:
        return Evidence_Def{"Cemetery Gate Group Photograph", "ALL FOUR", "Supply Storage", "The four missing people are pictured together at St. Mercy Cemetery, proving the cases were connected.", false}
    case .C17_EXPERIMENT_LOG:
        return Evidence_Def{"C-17 Experiment Log", "ELIAS VOSS / C-17", "Containment Wing C", "The log identifies the Clay Stalker as former security officer Elias Voss and documents the failed neural-matrix procedure.", true}
    case .VALE_PURGE_ORDER:
        return Evidence_Def{"Dr. Vale Purge Order", "ADRIAN VALE", "Final Investigation", "Vale ordered the evidence mirror purged if police reached the facility, directly tying him to the cover-up.", false}
    case .ANNEX_OPERATIONS_NOTICE:
        return Evidence_Def{"Annex Operations Notice", "FACILITY", "Underground Reception", "An old notice confirms St. Mercy's civil-defense annex was reactivated under the Project Resonance shell program.", false}
    case .MATEO_RELAY_INCIDENT:
        return Evidence_Def{"Relay 3 Incident Report", "MATEO RUIZ", "Waste Processing", "A maintenance incident report confirms Mateo was forced to service Relay 3 and died during an arc-flash after attempting to interrupt Project Resonance power.", false}
    case .COUNT:
        return Evidence_Def{"Unknown", "", "", "", false}
    }
    return Evidence_Def{"Unknown", "", "", "", false}
}

evidence_add :: proc(game: ^Game, id: Evidence_ID) {
    index := int(id)
    if index < 0 || index >= EVIDENCE_COUNT { return }
    game.evidence[index] = true
}

evidence_has :: proc(game: ^Game, id: Evidence_ID) -> bool {
    index := int(id)
    if index < 0 || index >= EVIDENCE_COUNT { return false }
    return game.evidence[index]
}

evidence_collected_count :: proc(game: ^Game) -> int {
    count := 0
    for i := 0; i < EVIDENCE_COUNT; i += 1 {
        if game.evidence[i] { count += 1 }
    }
    return count
}

missing_person_clue_count :: proc(game: ^Game) -> int {
    count := 0
    if game.case_lena_clue { count += 1 }
    if game.case_mateo_clue { count += 1 }
    if game.case_evan_clue { count += 1 }
    if game.case_leah_clue { count += 1 }
    return count
}
