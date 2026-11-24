package main

Game_State :: enum {
    TITLE,
    STORY,
    PLAYING,
    JUMPSCARE,
    GAME_OVER,
    ENDING,
}

ROOM_COUNT :: 11

Room_ID :: enum {
    ENTRANCE,
    RECEPTION,
    SECURITY,
    ARCHIVE,
    LABORATORY,
    DETENTION,
    MAINTENANCE,
    PROCESSING,
    CONTAINMENT,
    FINAL_AREA,
    STORAGE,
}

Facing_Direction :: enum {
    DOWN,
    LEFT,
    RIGHT,
    UP,
}

Scanner_Mode :: enum {
    RED,
    BLUE,
    YELLOW,
}

Enemy_State :: enum {
    DORMANT,
    PATROL,
    SUSPICIOUS,
    INVESTIGATE,
    ALERT,
    CHASE,
    SEARCH,
    DISENGAGE,
}
