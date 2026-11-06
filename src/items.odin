package main

import rl "vendor:raylib"

Item_ID :: enum {
    NONE,
    CEMETERY_KEY,
    EMPLOYEE_BADGE,
    ARCHIVE_KEY,
    REPLACEMENT_FUSE,
    SECURITY_KEYCARD,
    ARCHIVE_RECORDS,
    CELL_KEY,
    PERSONAL_EFFECTS,
    MAINTENANCE_BADGE,
    SCREWDRIVER,
    EXPERIMENT_LOG,
    TORN_EMPLOYEE_PHOTO,
    GROUP_PHOTO,
    COUNT,
}

ITEM_COUNT :: int(Item_ID.COUNT)

Item_Class :: enum {
    CONSUMABLE,
    REUSABLE,
    EVIDENCE,
    TOOL,
}

Item_Def :: struct {
    name:        cstring,
    description: cstring,
    use_text:    cstring,
    class:       Item_Class,
}

item_def :: proc(item: Item_ID) -> Item_Def {
    switch item {
    case .CEMETERY_KEY:
        return Item_Def{"Cemetery Key", "A worn key recovered from the visitor terminal. The cemetery tag is nearly unreadable.", "Surface cemetery access.", .REUSABLE}
    case .EMPLOYEE_BADGE:
        return Item_Def{"Old Employee ID Badge", "A faded employee badge issued to Reception Clerk M. Harrow. Its magnetic strip is still intact.", "Reusable staff authentication for low-security doors.", .REUSABLE}
    case .ARCHIVE_KEY:
        return Item_Def{"Rusted Brass Archive Key", "A small brass key with a corroded paper label: RECORDS ARCHIVE.", "Physical key for the archive's mechanical lock.", .REUSABLE}
    case .REPLACEMENT_FUSE:
        return Item_Def{"20A Ceramic Fuse", "An intact 20-amp ceramic fuse wrapped in brittle maintenance paper.", "Single-use replacement for the Underground Reception power panel.", .CONSUMABLE}
    case .SECURITY_KEYCARD:
        return Item_Def{"Security Keycard", "A black facility security card released after the control-room frequency sequence was solved.", "Reusable authorization for restricted electronic systems.", .REUSABLE}
    case .ARCHIVE_RECORDS:
        return Item_Def{"Missing-Person Intake Records", "Intake sheets naming Lena Park, Mateo Ruiz, Evan Cole, and Leah Morrison.", "Permanent case evidence.", .EVIDENCE}
    case .CELL_KEY:
        return Item_Def{"Detention Cell Key", "A heavy numbered key used as a physical override for the detention cells.", "Reusable physical detention key.", .REUSABLE}
    case .PERSONAL_EFFECTS:
        return Item_Def{"Cell 04 Personal Effects", "A sealed evidence bag containing personal belongings and a Maintenance badge.", "Permanent case evidence.", .EVIDENCE}
    case .MAINTENANCE_BADGE:
        return Item_Def{"Maintenance Badge", "A grease-stained department badge recovered from Cell 04's belongings.", "Reusable Maintenance access credential.", .REUSABLE}
    case .SCREWDRIVER:
        return Item_Def{"Flathead Screwdriver", "A facility-issued flathead screwdriver with an insulated handle.", "Reusable tool for screwed panels and covers.", .TOOL}
    case .EXPERIMENT_LOG:
        return Item_Def{"C-17 Experiment Log", "Project Resonance records identifying Subject C-17 and the failed neural-resonance procedure.", "Permanent case evidence.", .EVIDENCE}
    case .TORN_EMPLOYEE_PHOTO:
        return Item_Def{"Torn Employee Photograph", "Half of a staff photograph. A handwritten note on the back reads: 'Vale moved them below after midnight.'", "Permanent optional evidence.", .EVIDENCE}
    case .GROUP_PHOTO:
        return Item_Def{"Damaged Group Photograph", "The four missing civilians are pictured together at the cemetery gate before they disappeared.", "Permanent optional evidence.", .EVIDENCE}
    case .NONE, .COUNT:
        return Item_Def{"Empty", "No item selected.", "", .REUSABLE}
    }
    return Item_Def{"Unknown Item", "No description available.", "", .REUSABLE}
}

item_class_name :: proc(class: Item_Class) -> cstring {
    switch class {
    case .CONSUMABLE: return "CONSUMABLE"
    case .REUSABLE:   return "REUSABLE"
    case .EVIDENCE:   return "EVIDENCE"
    case .TOOL:       return "TOOL"
    }
    return "ITEM"
}

inventory_has :: proc(game: ^Game, item: Item_ID) -> bool {
    index := int(item)
    if index <= 0 || index >= ITEM_COUNT { return false }
    return game.inventory[index]
}

inventory_add :: proc(game: ^Game, item: Item_ID) {
    index := int(item)
    if index <= 0 || index >= ITEM_COUNT { return }
    game.inventory[index] = true
    if game.equipped_item == .NONE {
        game.equipped_item = item
    }
}

inventory_remove :: proc(game: ^Game, item: Item_ID) {
    index := int(item)
    if index <= 0 || index >= ITEM_COUNT { return }
    game.inventory[index] = false
    if game.equipped_item == item {
        game.equipped_item = .NONE
    }
}

inventory_count :: proc(game: ^Game) -> int {
    count := 0
    for i := 1; i < ITEM_COUNT; i += 1 {
        if game.inventory[i] { count += 1 }
    }
    return count
}

inventory_item_at :: proc(game: ^Game, visible_index: int) -> (Item_ID, bool) {
    cursor := 0
    for i := 1; i < ITEM_COUNT; i += 1 {
        if !game.inventory[i] { continue }
        if cursor == visible_index {
            return Item_ID(i), true
        }
        cursor += 1
    }
    return .NONE, false
}

sync_legacy_inventory_flags :: proc(game: ^Game, item: Item_ID, possessed: bool) {
    switch item {
    case .CEMETERY_KEY:      game.has_cemetery_key = possessed
    case .REPLACEMENT_FUSE:  game.has_spare_fuse = possessed
    case .SECURITY_KEYCARD:  game.security_keycard = possessed
    case .ARCHIVE_RECORDS:   game.archive_records = possessed
    case .CELL_KEY:          game.has_cell_key = possessed
    case .PERSONAL_EFFECTS:  game.has_personal_effects = possessed
    case .MAINTENANCE_BADGE: game.maintenance_badge = possessed
    case .SCREWDRIVER:       game.has_screwdriver = possessed
    case .EXPERIMENT_LOG:    game.has_experiment_log = possessed
    case .GROUP_PHOTO:       game.optional_photo = possessed
    case .NONE, .EMPLOYEE_BADGE, .ARCHIVE_KEY, .TORN_EMPLOYEE_PHOTO, .COUNT:
    }
}

add_item_with_progress :: proc(game: ^Game, item: Item_ID) {
    inventory_add(game, item)
    sync_legacy_inventory_flags(game, item, true)
}

remove_item_with_progress :: proc(game: ^Game, item: Item_ID) {
    inventory_remove(game, item)
    sync_legacy_inventory_flags(game, item, false)
}

Container_ID :: enum {
    NONE,
    RECEPTION_DESK,
    RECEPTION_SUPPLY,
    ARCHIVE_FILE_CABINET,
    MAINTENANCE_LOCKER,
    STORAGE_PERSONAL_LOCKER,
    COUNT,
}

container_name :: proc(id: Container_ID) -> cstring {
    switch id {
    case .RECEPTION_DESK:        return "RECEPTION DESK DRAWER"
    case .RECEPTION_SUPPLY:      return "ELECTRICAL SUPPLY CABINET"
    case .ARCHIVE_FILE_CABINET:  return "ARCHIVE FILING CABINET"
    case .MAINTENANCE_LOCKER:    return "MAINTENANCE TOOL LOCKER"
    case .STORAGE_PERSONAL_LOCKER:return "PERSONAL-EFFECTS LOCKER"
    case .NONE, .COUNT:          return "CONTAINER"
    }
    return "CONTAINER"
}

container_intro :: proc(id: Container_ID) -> cstring {
    switch id {
    case .RECEPTION_DESK:         return "Looks like someone left this drawer unlocked. Let's see what's inside."
    case .RECEPTION_SUPPLY:       return "An electrical cabinet. The latch is stiff, but it opens."
    case .ARCHIVE_FILE_CABINET:   return "Most of these folders were emptied in a hurry. A few things remain."
    case .MAINTENANCE_LOCKER:     return "Facility tools and scraps. Some of this may explain what happened here."
    case .STORAGE_PERSONAL_LOCKER:return "Personal effects were stored here before being routed to detention."
    case .NONE, .COUNT:           return "I should inspect the contents carefully."
    }
    return "I should inspect the contents carefully."
}

Search_Object_ID :: enum {
    NONE,
    OLD_BADGE,
    ARCHIVE_BRASS_KEY,
    TORN_EMPLOYEE_PHOTO,
    EMPTY_AMMO_BOX,
    REPLACEMENT_FUSE,
    ELECTRICAL_MEMO,
    DEAD_FLASHLIGHT,
    ARCHIVE_CARBON_COPY,
    ARCHIVE_EVIDENCE_TAG,
    DAMAGED_CASSETTE,
    MAINT_GLOVES,
    BENT_WRENCH,
    OLD_UTILITY_CARD,
    STORAGE_WALLET,
    STORAGE_LABEL,
    STORAGE_PHOTO_COPY,
    COUNT,
}

SEARCH_OBJECT_COUNT :: int(Search_Object_ID.COUNT)

Search_Object_Def :: struct {
    name:         cstring,
    description:  cstring,
    collect_item: Item_ID,
}

search_object_def :: proc(id: Search_Object_ID) -> Search_Object_Def {
    switch id {
    case .OLD_BADGE:
        return Search_Object_Def{"Old security badge", "Reception Clerk M. Harrow. The laminate is cracked, but the magnetic strip looks usable.", .EMPLOYEE_BADGE}
    case .ARCHIVE_BRASS_KEY:
        return Search_Object_Def{"Rusted brass key", "A faded paper tag reads: RECORDS ARCHIVE. This is a physical key, not an electronic card.", .ARCHIVE_KEY}
    case .TORN_EMPLOYEE_PHOTO:
        return Search_Object_Def{"Torn employee photograph", "Half a staff photo. On the back: 'Vale moved them below after midnight.'", .TORN_EMPLOYEE_PHOTO}
    case .EMPTY_AMMO_BOX:
        return Search_Object_Def{"Empty ammunition box", "Marshall PD issue ammunition packaging. Empty. Why was police ammunition stored down here?", .NONE}
    case .REPLACEMENT_FUSE:
        return Search_Object_Def{"20A ceramic fuse", "An intact replacement fuse wrapped in an electrical-maintenance work order.", .REPLACEMENT_FUSE}
    case .ELECTRICAL_MEMO:
        return Search_Object_Def{"Electrical maintenance memo", "'Reception lighting bus: 20A ceramic only. Do not bridge the failed circuit.'", .NONE}
    case .DEAD_FLASHLIGHT:
        return Search_Object_Def{"Dead emergency flashlight", "The battery compartment is corroded white. It will not power on.", .NONE}
    case .ARCHIVE_CARBON_COPY:
        return Search_Object_Def{"Carbon-copy request form", "A transfer request signed by Dr. Vale. Four civilian intake numbers are written in the margin.", .NONE}
    case .ARCHIVE_EVIDENCE_TAG:
        return Search_Object_Def{"Evidence routing tag", "The tag says DETENTION D / CELL 04. A corner has been torn away.", .NONE}
    case .DAMAGED_CASSETTE:
        return Search_Object_Def{"Damaged microcassette", "The tape has been pulled from the shell and knotted around a paperclip.", .NONE}
    case .MAINT_GLOVES:
        return Search_Object_Def{"Rubber maintenance gloves", "Old insulated gloves. One palm is burned through.", .NONE}
    case .BENT_WRENCH:
        return Search_Object_Def{"Bent pipe wrench", "The jaw is warped as if something much stronger than a person twisted it.", .NONE}
    case .OLD_UTILITY_CARD:
        return Search_Object_Def{"Old utility card", "A decommissioned access card stamped VOID. The number 03 is circled in grease pencil.", .NONE}
    case .STORAGE_WALLET:
        return Search_Object_Def{"Empty leather wallet", "No identification remains. The stitching is dark with old moisture.", .NONE}
    case .STORAGE_LABEL:
        return Search_Object_Def{"Personal-effects label", "Four bags were processed together. One line reads: 'return to D-04'.", .NONE}
    case .STORAGE_PHOTO_COPY:
        return Search_Object_Def{"Photocopied cemetery image", "A poor copy of a photograph showing the missing group at the cemetery gate.", .NONE}
    case .NONE, .COUNT:
        return Search_Object_Def{"Empty", "Nothing useful remains here.", .NONE}
    }
    return Search_Object_Def{"Unknown object", "No description available.", .NONE}
}

container_slot_object :: proc(container: Container_ID, slot: int) -> (Search_Object_ID, bool) {
    switch container {
    case .RECEPTION_DESK:
        switch slot {
        case 0: return .OLD_BADGE, true
        case 1: return .ARCHIVE_BRASS_KEY, true
        case 2: return .TORN_EMPLOYEE_PHOTO, true
        case 3: return .EMPTY_AMMO_BOX, true
        }
    case .RECEPTION_SUPPLY:
        switch slot {
        case 0: return .ELECTRICAL_MEMO, true
        case 1: return .DEAD_FLASHLIGHT, true
        }
    case .ARCHIVE_FILE_CABINET:
        switch slot {
        case 0: return .ARCHIVE_CARBON_COPY, true
        case 1: return .ARCHIVE_EVIDENCE_TAG, true
        case 2: return .DAMAGED_CASSETTE, true
        }
    case .MAINTENANCE_LOCKER:
        switch slot {
        case 0: return .MAINT_GLOVES, true
        case 1: return .BENT_WRENCH, true
        case 2: return .OLD_UTILITY_CARD, true
        }
    case .STORAGE_PERSONAL_LOCKER:
        switch slot {
        case 0: return .STORAGE_WALLET, true
        case 1: return .STORAGE_LABEL, true
        case 2: return .STORAGE_PHOTO_COPY, true
        }
    case .NONE, .COUNT:
    }
    return .NONE, false
}

container_visible_count :: proc(game: ^Game, container: Container_ID) -> int {
    count := 0
    for slot := 0; slot < 8; slot += 1 {
        object, ok := container_slot_object(container, slot)
        if !ok { break }
        if object != .NONE && !game.search_object_taken[int(object)] {
            count += 1
        }
    }
    return count
}

container_object_at :: proc(game: ^Game, container: Container_ID, visible_index: int) -> (Search_Object_ID, bool) {
    cursor := 0
    for slot := 0; slot < 8; slot += 1 {
        object, ok := container_slot_object(container, slot)
        if !ok { break }
        if object == .NONE || game.search_object_taken[int(object)] { continue }
        if cursor == visible_index { return object, true }
        cursor += 1
    }
    return .NONE, false
}

open_search_container :: proc(game: ^Game, container: Container_ID) {
    game.search_open = true
    game.active_container = container
    game.search_cursor = 0
    game.search_feedback = 0
    game.inventory_open = false
    game.objectives_open = false
    game.item_use_open = false
}

close_search_container :: proc(game: ^Game) {
    game.search_open = false
    game.active_container = .NONE
    game.search_cursor = 0
    game.search_feedback = 0
}

select_next_index :: proc(cursor: ^int, count: int, delta: int) {
    if count <= 0 {
        cursor^ = 0
        return
    }
    cursor^ += delta
    if cursor^ < 0 { cursor^ = count - 1 }
    if cursor^ >= count { cursor^ = 0 }
}

update_search_interface :: proc(game: ^Game) {
    if !game.search_open { return }

    if rl.IsKeyPressed(.I) || rl.IsKeyPressed(.ESCAPE) {
        close_search_container(game)
        return
    }

    count := container_visible_count(game, game.active_container)
    if game.search_cursor >= count && count > 0 { game.search_cursor = count - 1 }

    wheel := rl.GetMouseWheelMove()
    if wheel > 0 || rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) {
        select_next_index(&game.search_cursor, count, -1)
        game.search_feedback = 0
    }
    if wheel < 0 || rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.S) {
        select_next_index(&game.search_cursor, count, 1)
        game.search_feedback = 0
    }

    click_confirm := false
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()
        for i := 0; i < count; i += 1 {
            if rl.CheckCollisionPointRec(mouse, search_row_rect(i)) {
                game.search_cursor = i
                click_confirm = true
                break
            }
        }
    }

    object, found := container_object_at(game, game.active_container, game.search_cursor)
    if !found { return }

    confirm := rl.IsKeyPressed(.E) || rl.IsKeyPressed(.ENTER) || click_confirm
    if confirm {
        def := search_object_def(object)
        if def.collect_item != .NONE {
            if inventory_has(game, def.collect_item) {
                game.search_feedback = 3
            } else {
                game.search_object_taken[int(object)] = true
                add_item_with_progress(game, def.collect_item)
                rl.PlaySound(game.resources.pickup_sound)
                game.search_feedback = 1
                if game.search_cursor >= container_visible_count(game, game.active_container) && game.search_cursor > 0 {
                    game.search_cursor -= 1
                }
            }
        } else {
            game.search_feedback = 2
        }
    }
}

update_inventory_interface :: proc(game: ^Game) {
    if !game.inventory_open { return }

    if rl.IsKeyPressed(.TAB) || rl.IsKeyPressed(.ESCAPE) {
        game.inventory_open = false
        return
    }
    if rl.IsKeyPressed(.I) {
        game.inventory_open = false
        game.objectives_open = true
        return
    }

    count := inventory_count(game)
    if game.inventory_cursor >= count && count > 0 { game.inventory_cursor = count - 1 }

    wheel := rl.GetMouseWheelMove()
    if wheel > 0 || rl.IsKeyPressed(.LEFT) || rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.A) || rl.IsKeyPressed(.W) {
        select_next_index(&game.inventory_cursor, count, -1)
    }
    if wheel < 0 || rl.IsKeyPressed(.RIGHT) || rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.D) || rl.IsKeyPressed(.S) {
        select_next_index(&game.inventory_cursor, count, 1)
    }

    click_select := false
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()
        for i := 0; i < count; i += 1 {
            if rl.CheckCollisionPointRec(mouse, inventory_slot_rect(i)) {
                game.inventory_cursor = i
                click_select = true
                break
            }
        }
    }

    if rl.IsKeyPressed(.E) || rl.IsKeyPressed(.ENTER) || click_select {
        item, ok := inventory_item_at(game, game.inventory_cursor)
        if ok { game.equipped_item = item }
    }
}

open_item_selector :: proc(game: ^Game, entity_index: int) {
    game.item_use_open = true
    game.item_use_target_index = entity_index
    game.item_use_cursor = 0
    game.item_use_feedback = 0
    game.search_open = false
    game.inventory_open = false
    game.objectives_open = false

    // Start on the currently equipped item when possible.
    if game.equipped_item != .NONE {
        count := inventory_count(game)
        for i := 0; i < count; i += 1 {
            item, ok := inventory_item_at(game, i)
            if ok && item == game.equipped_item {
                game.item_use_cursor = i
                break
            }
        }
    }
}

close_item_selector :: proc(game: ^Game) {
    game.item_use_open = false
    game.item_use_target_index = -1
    game.item_use_cursor = 0
    game.item_use_feedback = 0
}

try_use_item_on_target :: proc(game: ^Game, item: Item_ID) -> bool {
    index := game.item_use_target_index
    if index < 0 || index >= game.entity_count { return false }
    entity := &game.entities[index]

    if entity.kind == .POWER_PANEL {
        if game.reception_power {
            show_message(game, 63)
            return false
        }
        if item != .REPLACEMENT_FUSE {
            show_message(game, 81)
            return false
        }

        remove_item_with_progress(game, .REPLACEMENT_FUSE)
        game.reception_power = true
        game.reception_power_transition = 0
        game.reception_power_flicker = 1.35
        show_message(game, 82)
        rl.PlaySound(game.resources.power_restore_sound)
        set_checkpoint(game, .RECEPTION)
        return true
    }

    if entity.kind == .MAINT_PANEL && !game.maintenance_panel_open {
        if item != .SCREWDRIVER {
            show_message(game, 81)
            return false
        }
        game.maintenance_panel_open = true
        show_message(game, 40)
        rl.PlaySound(game.resources.pickup_sound)
        return true
    }

    if entity.kind == .DOOR_TRIGGER {
        if entity.target_room == .SECURITY && !game.security_door_unlocked {
            if !game.reception_power {
                show_message(game, 51)
                return false
            }
            if item != .EMPLOYEE_BADGE {
                show_message(game, 81)
                return false
            }
            game.security_door_unlocked = true
            show_message(game, 83)
            rl.PlaySound(game.resources.scanner_success)
            return true
        }

        if entity.target_room == .ARCHIVE && !game.archive_door_unlocked {
            if !(game.security_unlocked && game.security_keycard) {
                show_message(game, 52)
                return false
            }
            if item != .ARCHIVE_KEY {
                show_message(game, 81)
                return false
            }
            game.archive_door_unlocked = true
            show_message(game, 84)
            rl.PlaySound(game.resources.pickup_sound)
            return true
        }
    }

    show_message(game, 81)
    return false
}

update_item_selector :: proc(game: ^Game) {
    if !game.item_use_open { return }

    if rl.IsKeyPressed(.I) || rl.IsKeyPressed(.ESCAPE) {
        close_item_selector(game)
        return
    }

    count := inventory_count(game)
    if game.item_use_cursor >= count && count > 0 { game.item_use_cursor = count - 1 }

    wheel := rl.GetMouseWheelMove()
    if wheel > 0 || rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) {
        select_next_index(&game.item_use_cursor, count, -1)
        game.item_use_feedback = 0
    }
    if wheel < 0 || rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.S) {
        select_next_index(&game.item_use_cursor, count, 1)
        game.item_use_feedback = 0
    }

    click_use := false
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()
        start := 0
        if game.item_use_cursor >= 6 { start = game.item_use_cursor - 5 }
        visible := count - start
        if visible > 6 { visible = 6 }
        for row := 0; row < visible; row += 1 {
            if rl.CheckCollisionPointRec(mouse, item_use_row_rect(row)) {
                game.item_use_cursor = start + row
                click_use = true
                break
            }
        }
    }

    if rl.IsKeyPressed(.E) || rl.IsKeyPressed(.ENTER) || click_use {
        item, ok := inventory_item_at(game, game.item_use_cursor)
        if !ok {
            game.item_use_feedback = 2
            return
        }
        if try_use_item_on_target(game, item) {
            if inventory_has(game, item) { game.equipped_item = item }
            else { game.equipped_item = .NONE }
            close_item_selector(game)
        } else {
            game.item_use_feedback = 1
        }
    }
}
