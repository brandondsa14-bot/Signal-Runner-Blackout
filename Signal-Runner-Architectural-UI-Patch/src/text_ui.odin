package main

import rl "vendor:raylib"

// Shared UI text wrapper. It measures words using Raylib's active default font,
// breaks on whitespace when possible, and guarantees that text never extends
// past max_width. max_lines <= 0 means unlimited lines.
draw_text_wrapped :: proc(
    text: cstring,
    x, y, max_width, font_size, line_height: i32,
    color: rl.Color,
    max_lines: int = 0,
) -> int {
    text_string := string(text)
    length := len(text_string)
    if length <= 0 || max_width <= 0 { return 0 }

    line_start := 0
    last_space := -1
    lines := 0
    i := 0

    for i < length {
        byte := text_string[i]
        if byte == 32 || byte == 9 { // space or tab
            last_space = i
        }

        if byte == 10 { // explicit newline
            line := rl.TextSubtext(text, i32(line_start), i32(i - line_start))
            rl.DrawText(line, x, y + i32(lines)*line_height, font_size, color)
            lines += 1
            if max_lines > 0 && lines >= max_lines { return lines }
            line_start = i + 1
            last_space = -1
            i = line_start
            continue
        }

        candidate := rl.TextSubtext(text, i32(line_start), i32(i - line_start + 1))
        if rl.MeasureText(candidate, font_size) > max_width {
            line_end := i
            next_start := i
            if last_space >= line_start {
                line_end = last_space
                next_start = last_space + 1
            } else if line_end <= line_start {
                line_end = i + 1
                next_start = i + 1
            }

            line := rl.TextSubtext(text, i32(line_start), i32(line_end - line_start))
            rl.DrawText(line, x, y + i32(lines)*line_height, font_size, color)
            lines += 1
            if max_lines > 0 && lines >= max_lines { return lines }

            for next_start < length && (text_string[next_start] == 32 || text_string[next_start] == 9) {
                next_start += 1
            }
            line_start = next_start
            last_space = -1
            i = line_start
            continue
        }

        i += 1
    }

    if line_start < length && (max_lines <= 0 || lines < max_lines) {
        line := rl.TextSubtext(text, i32(line_start), i32(length - line_start))
        rl.DrawText(line, x, y + i32(lines)*line_height, font_size, color)
        lines += 1
    }

    return lines
}

// PLAYING is rendered below the dedicated top HUD band. Mouse-driven modal UI
// still uses the original 1100x640 coordinate system, so convert screen-space
// mouse coordinates back into gameplay/UI coordinates before hit-testing.
playing_mouse_position :: proc() -> rl.Vector2 {
    // Convert from the physical, possibly resized OS window back into the fixed
    // virtual canvas before subtracting the dedicated top-HUD band.
    mouse := screen_to_virtual(rl.GetMousePosition())
    mouse[1] -= f32(HUD_BAND_HEIGHT)
    if mouse[0] < 0 || mouse[1] < 0 || mouse[0] >= f32(SCREEN_WIDTH) || mouse[1] >= f32(SCREEN_HEIGHT) {
        mouse[0] = -10000
        mouse[1] = -10000
    }
    return mouse
}
