package main

import rl "vendor:raylib"

Resources :: struct {
    player_texture:   rl.Texture2D,
    player_portrait:  rl.Texture2D,
    monster_jumpscare_texture: rl.Texture2D,
    ambience_music:   rl.Music,
    pickup_sound:     rl.Sound,
    chase_music:      rl.Music,
    scanner_success:  rl.Sound,
    scanner_fail:     rl.Sound,
    jumpscare_sound:  rl.Sound,
    distant_metal:    rl.Sound,
}

load_resources :: proc() -> Resources {
    resources := Resources{}

    // CP3 pipeline preserved: resources are loaded once at game boot and shared.
    resources.player_texture  = rl.LoadTexture("assets/player_police.png")
    resources.player_portrait = rl.LoadTexture("assets/player_portrait.png")
    resources.monster_jumpscare_texture = rl.LoadTexture("assets/monster_jumpscare.png")
    resources.ambience_music  = rl.LoadMusicStream("assets/ambience.mp3")
    resources.pickup_sound    = rl.LoadSound("assets/pickup.mp3")
    resources.chase_music     = rl.LoadMusicStream("assets/monster_chase.wav")
    resources.scanner_success = rl.LoadSound("assets/scanner_success.wav")
    resources.scanner_fail    = rl.LoadSound("assets/scanner_fail.wav")
    resources.jumpscare_sound = rl.LoadSound("assets/monster_jumpscare.wav")
    resources.distant_metal   = rl.LoadSound("assets/distant_metal.wav")

    resources.ambience_music.looping = true
    resources.chase_music.looping = true
    rl.PlayMusicStream(resources.ambience_music)

    return resources
}

unload_resources :: proc(resources: ^Resources) {
    rl.UnloadTexture(resources.player_texture)
    rl.UnloadTexture(resources.player_portrait)
    rl.UnloadTexture(resources.monster_jumpscare_texture)
    rl.UnloadMusicStream(resources.ambience_music)
    rl.UnloadSound(resources.pickup_sound)
    rl.UnloadMusicStream(resources.chase_music)
    rl.UnloadSound(resources.scanner_success)
    rl.UnloadSound(resources.scanner_fail)
    rl.UnloadSound(resources.jumpscare_sound)
    rl.UnloadSound(resources.distant_metal)
}
