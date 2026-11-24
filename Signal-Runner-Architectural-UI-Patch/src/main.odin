package main

import rl "vendor:raylib"

// The game keeps one stable virtual coordinate system. The physical OS window
// can be smaller or larger without changing level coordinates, collision, AI,
// pixel-art proportions, or UI placement.
SCREEN_WIDTH            :: 1100
SCREEN_HEIGHT           :: 640
HUD_BAND_HEIGHT         :: 160
BOTTOM_CONTROLS_HEIGHT  :: 52
VIRTUAL_WIDTH           :: SCREEN_WIDTH
VIRTUAL_HEIGHT          :: HUD_BAND_HEIGHT + SCREEN_HEIGHT + BOTTOM_CONTROLS_HEIGHT

FALLBACK_WINDOW_WIDTH   :: 1000
FALLBACK_WINDOW_HEIGHT  :: 760
DESKTOP_MARGIN_X        :: 80
DESKTOP_MARGIN_Y        :: 150

virtual_canvas_transform :: proc() -> (scale, offset_x, offset_y: f32) {
    window_w := f32(rl.GetScreenWidth())
    window_h := f32(rl.GetScreenHeight())

    scale = window_w / f32(VIRTUAL_WIDTH)
    height_scale := window_h / f32(VIRTUAL_HEIGHT)
    if height_scale < scale { scale = height_scale }
    if scale <= 0 { scale = 1 }

    draw_w := f32(VIRTUAL_WIDTH) * scale
    draw_h := f32(VIRTUAL_HEIGHT) * scale
    offset_x = (window_w - draw_w) / 2.0
    offset_y = (window_h - draw_h) / 2.0
    return
}

screen_to_virtual :: proc(screen_position: rl.Vector2) -> rl.Vector2 {
    scale, offset_x, offset_y := virtual_canvas_transform()
    if scale <= 0 { return rl.Vector2{-10000, -10000} }

    x := (screen_position[0] - offset_x) / scale
    y := (screen_position[1] - offset_y) / scale
    if x < 0 || y < 0 || x >= f32(VIRTUAL_WIDTH) || y >= f32(VIRTUAL_HEIGHT) {
        return rl.Vector2{-10000, -10000}
    }
    return rl.Vector2{x, y}
}

fit_window_to_monitor :: proc() {
    monitor := rl.GetCurrentMonitor()
    monitor_w := rl.GetMonitorWidth(monitor)
    monitor_h := rl.GetMonitorHeight(monitor)

    safe_w := monitor_w - DESKTOP_MARGIN_X
    safe_h := monitor_h - DESKTOP_MARGIN_Y
    if safe_w <= 0 || safe_h <= 0 { return }

    scale := f32(safe_w) / f32(VIRTUAL_WIDTH)
    height_scale := f32(safe_h) / f32(VIRTUAL_HEIGHT)
    if height_scale < scale { scale = height_scale }
    if scale > 1.0 { scale = 1.0 }
    if scale <= 0 { return }

    window_w := i32(f32(VIRTUAL_WIDTH) * scale)
    window_h := i32(f32(VIRTUAL_HEIGHT) * scale)
    rl.SetWindowSize(window_w, window_h)

    // Bias toward the top of the usable desktop so a macOS Dock or Windows
    // taskbar is less likely to cover the bottom controls strip.
    monitor_pos := rl.GetMonitorPosition(monitor)
    x := i32(monitor_pos[0]) + (monitor_w - window_w)/2
    y := i32(monitor_pos[1]) + 32
    rl.SetWindowPosition(x, y)
}

draw_virtual_canvas :: proc(target: rl.RenderTexture2D) {
    scale, offset_x, offset_y := virtual_canvas_transform()
    draw_w := f32(VIRTUAL_WIDTH) * scale
    draw_h := f32(VIRTUAL_HEIGHT) * scale

    source := rl.Rectangle{
        x = 0,
        y = 0,
        width = f32(target.texture.width),
        height = -f32(target.texture.height),
    }
    destination := rl.Rectangle{
        x = offset_x,
        y = offset_y,
        width = draw_w,
        height = draw_h,
    }
    rl.DrawTexturePro(target.texture, source, destination, rl.Vector2{0, 0}, 0, rl.WHITE)
}

main :: proc() {
    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(FALLBACK_WINDOW_WIDTH, FALLBACK_WINDOW_HEIGHT, "Signal Runner: Blackout")
    defer rl.CloseWindow()

    fit_window_to_monitor()
    rl.SetWindowMinSize(720, 558)

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    rl.SetTargetFPS(60)

    // CP3 resource-pipeline requirement remains intact: load once, share everywhere.
    resources := load_resources()
    defer unload_resources(&resources)

    tuning := load_tuning("data/tuning_active.json")
    rl.SetMusicVolume(resources.ambience_music, tuning.ambient_volume)
    rl.SetMusicVolume(resources.chase_music, tuning.chase_volume)

    game := new_game(&resources, tuning)

    canvas: rl.RenderTexture2D = rl.LoadRenderTexture(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    defer rl.UnloadRenderTexture(canvas)
    rl.SetTextureFilter(canvas.texture, .POINT)

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // Loaded music resources only update their stream buffers here.
        rl.UpdateMusicStream(resources.ambience_music)
        rl.UpdateMusicStream(resources.chase_music)

        // Pass 1: gameplay, puzzles, room transitions, survival and enemy AI.
        update_game(&game, dt)

        // Pass 2a: draw the complete game to a stable virtual canvas.
        rl.BeginTextureMode(canvas)
        rl.ClearBackground(rl.Color{5, 6, 7, 255})
        render_game(&game)
        rl.EndTextureMode()

        // Pass 2b: fit that canvas into the actual desktop window without
        // stretching or cropping. Extra space becomes neutral letterboxing.
        rl.BeginDrawing()
        rl.ClearBackground(rl.Color{3, 4, 5, 255})
        draw_virtual_canvas(canvas)
        rl.EndDrawing()
    }
}
