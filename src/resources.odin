package main

import rl "vendor:raylib"

Resources :: struct {
    player_texture:  rl.Texture2D,
    player_portrait: rl.Texture2D,
    ambience_music:  rl.Music,
    pickup_sound:    rl.Sound,
}

load_resources :: proc() -> Resources {
    resources := Resources{}

    // CP3: every resource is loaded ONCE here at startup and shared afterward.
    resources.player_texture  = rl.LoadTexture("assets/player_police.png")
    resources.player_portrait = rl.LoadTexture("assets/player_portrait.png")
    resources.ambience_music  = rl.LoadMusicStream("assets/ambience.mp3")
    resources.pickup_sound    = rl.LoadSound("assets/pickup.mp3")

    resources.ambience_music.looping = true
    rl.PlayMusicStream(resources.ambience_music)

    return resources
}

unload_resources :: proc(resources: ^Resources) {
    rl.UnloadTexture(resources.player_texture)
    rl.UnloadTexture(resources.player_portrait)
    rl.UnloadMusicStream(resources.ambience_music)
    rl.UnloadSound(resources.pickup_sound)
}
