package main

import rl "vendor:raylib"

SCREEN_WIDTH  :: 1100
SCREEN_HEIGHT :: 640

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Signal Runner: Blackout")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    rl.SetTargetFPS(60)

    // CP3 resource-pipeline requirement remains intact: load once, share everywhere.
    resources := load_resources()
    defer unload_resources(&resources)

    tuning := load_tuning("data/tuning.json")
    rl.SetMusicVolume(resources.ambience_music, tuning.ambient_volume)
    rl.SetMusicVolume(resources.chase_music, tuning.chase_volume)

    game := new_game(&resources, tuning)

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // Loaded music resources only update their stream buffers here.
        rl.UpdateMusicStream(resources.ambience_music)
        rl.UpdateMusicStream(resources.chase_music)

        // Pass 1: gameplay, puzzles, room transitions, survival and enemy AI.
        update_game(&game, dt)

        // Pass 2: render the resulting state.
        rl.BeginDrawing()
        render_game(&game)
        rl.EndDrawing()
    }
}
