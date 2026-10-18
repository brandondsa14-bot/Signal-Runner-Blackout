package main

import rl "vendor:raylib"

SCREEN_WIDTH  :: 1100
SCREEN_HEIGHT :: 640

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Signal Runner: Blackout - CP3")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    rl.SetTargetFPS(60)

    // CP3 resource pipeline: loaded once, then shared with the game.
    resources := load_resources()
    defer unload_resources(&resources)

    tuning := load_tuning("data/tuning.json")
    rl.SetMusicVolume(resources.ambience_music, tuning.ambient_volume)

    game := new_game(&resources, tuning)

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // Streaming music is already loaded; only its buffer is updated here.
        rl.UpdateMusicStream(resources.ambience_music)

        // PASS 1: gameplay logic.
        update_game(&game, dt)

        // PASS 2: rendering.
        rl.BeginDrawing()
        render_game(&game)
        rl.EndDrawing()
    }
}
