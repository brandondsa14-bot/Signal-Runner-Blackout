package main

import rl "vendor:raylib"

inventory_slot_rect :: proc(index: int) -> rl.Rectangle {
    col := index % 5
    row := index / 5
    return rl.Rectangle{
        x = f32(125 + col*172),
        y = f32(175 + row*86),
        width = 158,
        height = 72,
    }
}

search_row_rect :: proc(index: int) -> rl.Rectangle {
    return rl.Rectangle{x=150, y=f32(210 + index*58), width=330, height=50}
}

item_use_row_rect :: proc(index: int) -> rl.Rectangle {
    return rl.Rectangle{x=175, y=f32(218 + index*48), width=360, height=40}
}

draw_modal_exit_hint :: proc(label: cstring) {
    rl.DrawRectangle(845, 96, 125, 34, rl.Color{18, 15, 13, 248})
    rl.DrawRectangleLines(845, 96, 125, 34, rl.Color{161, 118, 62, 255})
    rl.DrawText("I", 858, 105, 16, rl.GOLD)
    rl.DrawText(label, 884, 107, 11, rl.RAYWHITE)
}

draw_item_icon :: proc(item: Item_ID, x, y, size: i32, selected: bool) {
    bg := rl.Color{31, 29, 27, 255}
    border := rl.Color{84, 75, 61, 255}
    if selected { border = rl.Color{172, 137, 72, 255} }
    rl.DrawRectangle(x, y, size, size, bg)
    rl.DrawRectangleLines(x, y, size, size, border)

    cx := x + size/2
    cy := y + size/2
    #partial switch item {
    case .CEMETERY_KEY, .ARCHIVE_KEY, .CELL_KEY:
        rl.DrawCircle(cx - 7, cy, 7, rl.Color{176, 139, 66, 255})
        rl.DrawRectangle(cx, cy - 2, 15, 4, rl.Color{176, 139, 66, 255})
        rl.DrawRectangle(cx + 10, cy + 2, 3, 6, rl.Color{176, 139, 66, 255})
    case .EMPLOYEE_BADGE, .SECURITY_KEYCARD, .MAINTENANCE_BADGE:
        rl.DrawRectangle(cx - 13, cy - 9, 26, 18, rl.Color{76, 102, 96, 255})
        rl.DrawRectangle(cx - 10, cy - 5, 8, 8, rl.LIGHTGRAY)
        rl.DrawLine(cx + 1, cy - 4, cx + 9, cy - 4, rl.GRAY)
        rl.DrawLine(cx + 1, cy + 1, cx + 9, cy + 1, rl.GRAY)
    case .REPLACEMENT_FUSE:
        rl.DrawRectangle(cx - 12, cy - 5, 24, 10, rl.Color{195, 184, 150, 255})
        rl.DrawRectangle(cx - 15, cy - 7, 4, 14, rl.GRAY)
        rl.DrawRectangle(cx + 11, cy - 7, 4, 14, rl.GRAY)
    case .SCREWDRIVER:
        rl.DrawRectangle(cx - 3, cy - 14, 6, 19, rl.GRAY)
        rl.DrawRectangle(cx - 6, cy + 4, 12, 12, rl.Color{96, 70, 45, 255})
    case .ARCHIVE_RECORDS, .EXPERIMENT_LOG, .PERSONAL_EFFECTS:
        rl.DrawRectangle(cx - 11, cy - 14, 22, 28, rl.Color{154, 139, 103, 255})
        rl.DrawLine(cx - 7, cy - 7, cx + 7, cy - 7, rl.DARKGRAY)
        rl.DrawLine(cx - 7, cy - 1, cx + 7, cy - 1, rl.DARKGRAY)
        rl.DrawLine(cx - 7, cy + 5, cx + 4, cy + 5, rl.DARKGRAY)
    case .TORN_EMPLOYEE_PHOTO, .GROUP_PHOTO:
        rl.DrawRectangle(cx - 13, cy - 11, 26, 22, rl.Color{158, 153, 137, 255})
        rl.DrawCircle(cx - 5, cy - 2, 4, rl.DARKGRAY)
        rl.DrawLine(cx - 10, cy + 8, cx, cy, rl.DARKGRAY)
        rl.DrawLine(cx, cy, cx + 10, cy + 8, rl.DARKGRAY)
    case:
        rl.DrawCircle(cx, cy, 8, rl.GRAY)
    }
}

draw_equipped_item_hud :: proc(game: ^Game) {
    if game.equipped_item == .NONE || !inventory_has(game, game.equipped_item) { return }
    def := item_def(game.equipped_item)
    x: i32 = 720
    y: i32 = 15
    draw_item_icon(game.equipped_item, x, y, 42, true)
    rl.DrawText("SELECTED", x - 4, y + 47, 9, rl.Color{122, 109, 87, 255})
    rl.DrawText(def.name, x - 120, y + 28, 10, rl.Color{190, 181, 159, 255})
}

draw_inventory_overlay :: proc(game: ^Game) {
    rl.DrawRectangle(95, 74, 910, 500, rl.Color{8, 8, 8, 248})
    rl.DrawRectangleLines(95, 74, 910, 500, rl.Color{97, 79, 56, 255})
    rl.DrawRectangleLines(100, 79, 900, 490, rl.Color{39, 35, 29, 255})
    rl.DrawText("MARSHALL PD — FIELD INVENTORY", 135, 104, 24, rl.Color{202, 190, 162, 255})
    rl.DrawText("TAB / ESC — CLOSE     E / CLICK — SELECT     WHEEL / ARROWS — NAVIGATE", 135, 137, 11, rl.Color{107, 99, 83, 255})

    count := inventory_count(game)
    if count <= 0 {
        rl.DrawText("No physical evidence or tools collected.", 150, 195, 18, rl.GRAY)
        return
    }

    for i := 0; i < count; i += 1 {
        item, ok := inventory_item_at(game, i)
        if !ok { continue }
        rect := inventory_slot_rect(i)
        selected := i == game.inventory_cursor
        fill := rl.Color{18, 17, 16, 255}
        border := rl.Color{55, 49, 41, 255}
        if selected {
            fill = rl.Color{37, 31, 23, 255}
            border = rl.Color{172, 137, 72, 255}
        }
        rl.DrawRectangleRec(rect, fill)
        rl.DrawRectangleLinesEx(rect, 1, border)
        draw_item_icon(item, i32(rect.x)+7, i32(rect.y)+10, 42, selected)
        def := item_def(item)
        rl.DrawText(def.name, i32(rect.x)+55, i32(rect.y)+13, 9, rl.RAYWHITE)
        rl.DrawText(item_class_name(def.class), i32(rect.x)+55, i32(rect.y)+33, 8, rl.Color{137, 116, 79, 255})
        if game.equipped_item == item {
            rl.DrawText("EQUIPPED", i32(rect.x)+55, i32(rect.y)+51, 8, rl.GREEN)
        }
    }

    selected_item, found := inventory_item_at(game, game.inventory_cursor)
    if found {
        def := item_def(selected_item)
        rl.DrawRectangle(125, 463, 850, 82, rl.Color{13, 12, 11, 255})
        rl.DrawRectangleLines(125, 463, 850, 82, rl.Color{62, 55, 45, 255})
        rl.DrawText(def.name, 145, 476, 16, rl.GOLD)
        rl.DrawText(def.description, 145, 500, 12, rl.LIGHTGRAY)
        rl.DrawText(def.use_text, 145, 524, 10, rl.Color{136, 126, 106, 255})
    }
}

draw_search_overlay :: proc(game: ^Game) {
    rl.DrawRectangle(105, 80, 890, 480, rl.Color{8, 8, 9, 249})
    rl.DrawRectangleLines(105, 80, 890, 480, rl.Color{94, 77, 56, 255})
    rl.DrawText("INVESTIGATION SEARCH", 145, 108, 23, rl.Color{201, 187, 157, 255})
    rl.DrawText(container_name(game.active_container), 145, 140, 14, rl.Color{150, 125, 80, 255})
    rl.DrawText(container_intro(game.active_container), 145, 162, 11, rl.LIGHTGRAY)
    rl.DrawText("WHEEL / W-S — SELECT     E — PICK UP / INSPECT     I / ESC — LEAVE", 145, 181, 10, rl.GRAY)
    draw_modal_exit_hint("EXIT SEARCH")

    count := container_visible_count(game, game.active_container)
    if count <= 0 {
        rl.DrawText("Nothing else remains inside.", 150, 215, 18, rl.GRAY)
        return
    }

    for i := 0; i < count; i += 1 {
        obj, ok := container_object_at(game, game.active_container, i)
        if !ok { continue }
        def := search_object_def(obj)
        rect := search_row_rect(i)
        selected := i == game.search_cursor
        fill := rl.Color{18, 17, 16, 255}
        border := rl.Color{54, 49, 42, 255}
        if selected { fill = rl.Color{38, 31, 24, 255}; border = rl.Color{169, 129, 70, 255} }
        rl.DrawRectangleRec(rect, fill)
        rl.DrawRectangleLinesEx(rect, 1, border)
        marker: cstring = "INSPECT"
        if def.collect_item != .NONE { marker = "PICK UP" }
        rl.DrawText(def.name, i32(rect.x)+14, i32(rect.y)+10, 14, rl.RAYWHITE)
        rl.DrawText(marker, i32(rect.x)+245, i32(rect.y)+28, 9, rl.Color{148, 124, 82, 255})
    }

    obj, found := container_object_at(game, game.active_container, game.search_cursor)
    if found {
        def := search_object_def(obj)
        rl.DrawRectangle(520, 210, 430, 245, rl.Color{13, 12, 11, 255})
        rl.DrawRectangleLines(520, 210, 430, 245, rl.Color{61, 54, 44, 255})
        rl.DrawText(def.name, 545, 234, 18, rl.GOLD)
        rl.DrawText(def.description, 545, 270, 10, rl.LIGHTGRAY)
        if def.collect_item != .NONE {
            item := item_def(def.collect_item)
            rl.DrawText("[E] PICK UP", 545, 362, 14, rl.GREEN)
            rl.DrawText(item_class_name(item.class), 545, 390, 11, rl.Color{146, 121, 79, 255})
        } else {
            rl.DrawText("[E] INSPECT", 545, 362, 14, rl.Color{164, 144, 104, 255})
            rl.DrawText("Not useful as a carried item.", 545, 390, 11, rl.GRAY)
        }
    }

    if game.search_feedback == 1 { rl.DrawText("Collected. I'll hold onto it.", 520, 470, 15, rl.GREEN) }
    if game.search_feedback == 2 { rl.DrawText("I make a note of it and leave it where it is.", 520, 470, 14, rl.LIGHTGRAY) }
    if game.search_feedback == 3 { rl.DrawText("I already have this item.", 520, 470, 14, rl.GRAY) }
}

item_use_context :: proc(game: ^Game) -> cstring {
    index := game.item_use_target_index
    if index < 0 || index >= game.entity_count { return "Choose an item to try." }
    entity := &game.entities[index]
    if entity.kind == .POWER_PANEL { return "The 20A fuse socket is empty. I need the correct replacement." }
    if entity.kind == .MAINT_PANEL { return "The relay cover is screwed shut. I need a suitable tool." }
    if entity.kind == .DOOR_TRIGGER && entity.target_room == .SECURITY { return "The reader has power. It expects a facility employee badge." }
    if entity.kind == .DOOR_TRIGGER && entity.target_room == .ARCHIVE { return "Electronic authorization passed. The door still has a physical keyway." }
    return "Choose an item to try."
}

draw_item_use_overlay :: proc(game: ^Game) {
    rl.DrawRectangle(130, 90, 840, 455, rl.Color{7, 7, 8, 249})
    rl.DrawRectangleLines(130, 90, 840, 455, rl.Color{98, 78, 54, 255})
    rl.DrawText("SELECT ITEM", 170, 118, 24, rl.Color{204, 190, 160, 255})
    draw_modal_exit_hint("EXIT")
    rl.DrawText(item_use_context(game), 170, 151, 12, rl.LIGHTGRAY)
    rl.DrawText("Wrong items are never consumed.", 170, 172, 10, rl.GRAY)

    count := inventory_count(game)
    if count <= 0 {
        rl.DrawText("I don't have anything that could help here.", 175, 215, 18, rl.LIGHTGRAY)
        rl.DrawText("I / ESC — CLOSE", 175, 485, 13, rl.GRAY)
        return
    }

    start := 0
    if game.item_use_cursor >= 6 { start = game.item_use_cursor - 5 }
    visible := count - start
    if visible > 6 { visible = 6 }
    for row := 0; row < visible; row += 1 {
        i := start + row
        item, ok := inventory_item_at(game, i)
        if !ok { continue }
        def := item_def(item)
        rect := item_use_row_rect(row)
        selected := i == game.item_use_cursor
        fill := rl.Color{18, 17, 16, 255}
        border := rl.Color{55, 49, 41, 255}
        if selected { fill = rl.Color{38, 30, 22, 255}; border = rl.Color{173, 135, 70, 255} }
        rl.DrawRectangleRec(rect, fill)
        rl.DrawRectangleLinesEx(rect, 1, border)
        rl.DrawText(def.name, i32(rect.x)+15, i32(rect.y)+9, 13, rl.RAYWHITE)
        rl.DrawText(item_class_name(def.class), i32(rect.x)+235, i32(rect.y)+12, 9, rl.Color{140, 117, 78, 255})
    }

    selected, found := inventory_item_at(game, game.item_use_cursor)
    if found {
        def := item_def(selected)
        draw_item_icon(selected, 610, 215, 70, true)
        rl.DrawText(def.name, 610, 300, 15, rl.GOLD)
        rl.DrawText(def.description, 610, 330, 9, rl.LIGHTGRAY)
        rl.DrawText("E — TRY ITEM", 610, 430, 14, rl.GREEN)
    }
    if game.item_use_feedback == 1 { rl.DrawText("That won't work here.", 610, 470, 14, rl.RED) }
    if game.item_use_feedback == 2 { rl.DrawText("No item selected.", 610, 470, 14, rl.GRAY) }
    rl.DrawText("I / ESC — LEAVE", 170, 500, 12, rl.GRAY)
}
