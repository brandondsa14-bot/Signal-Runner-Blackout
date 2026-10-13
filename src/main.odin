package main

import rl "vendor:raylib"

SCREEN_WIDTH  :: 1100
SCREEN_HEIGHT :: 640

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Signal Runner: Blackout - CP2")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    game := new_game()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // PASS 1: game logic / update handles movement, collisions, interactions, signal changes, and state transitions. 
        update_game(&game, dt)

        // PASS 2: The render pass runs afterward and only draws the current game state.

        rl.BeginDrawing()
        render_game(&game)
        rl.EndDrawing()
    }
}

//update_game : the procedure that updates gameplay.
// Looks inside it for movement, collisions, interactions, and state changes, plus any helper procedures it calls.

//render_game : the procedure that draws the game. Look inside it for drawing helpers and
// Raylib calls such as rl.DrawRectangle, rl.DrawTexture, or rl.DrawText.
