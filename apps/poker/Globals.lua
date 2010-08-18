Directions = {
   RIGHT = {1,0},
   LEFT = {-1,0},
   DOWN = {0,1},
   UP = {0,-1}
}

Colors={
   SLATE_GRAY                   ="708090",
   WHITE                        ="FFFFFF",
   FIRE_BRICK                   ="B22222",
   LIME_GREEN                   ="32CD32",
   TURQUOISE                    ="40E0D0",
   BLACK                        ="000000",
   RED                          ="FF0000",
   YELLOW                       ="FFFF00",
   GREEN                        ="00FF00",
   BLUE                         ="0000FF",
   MAGENTA                      ="FF00FF",
   CYAN                         ="00FFFF",
   ORANGE                       ="FFA500",
   PURPLE                       ="A020F0",
   PERU                         ="CD853F",
   FOCUS_RED                    ="602020"
}

PLAYER_NAME_FONT = "KacstArt 20px"
PLAYER_ACTION_FONT = "KacstArt 40px"

CUSTOMIZE_TINY_FONT = "KacstArt 24px"
CUSTOMIZE_TINIER_FONT = "KacstArt 20px"
CUSTOMIZE_TAB_FONT  = "KacstArt 48px"
CUSTOMIZE_ENTRY_FONT = "KacstArt 28px"
CUSTOMIZE_SUB_FONT  = "KacstArt 32px"
CUSTOMIZE_SUB_FONT_B  = "KacstArt 36px"
CUSTOMIZE_SUB_FONT_SP  = "KacstArt 42px"
CUSTOMIZE_NAME_FONT = "KacstArt 144px"

DEFAULT_FONT = "DejaVu Serif 40px"
DEFAULT_COLOR = Colors.WHITE

Rounds = {
   HOLE=1,
   FLOP=2,
   TURN=3,
   RIVER=4,
}

Position = {
    EARLY = 1,
    EARLY2 = 2,     --Same as Early but redundancy for 6 players
    MIDDLE = 3,
    LATE = 4,
    SMALL_BLIND = 5,
    BIG_BLIND = 6
}
RaiseFactor = {
    UR = 1,     --Un-Raised Big-Blind
    R = 2,      --Raised Big-Blind
    RR = 3      --Re-Raised Big-Blind
}
Moves = {
    CALL = 1,
    RAISE = 2,
    FOLD = 3
}
SUITED = 1
UNSUITED = 2

HIGH_OUTS_RANGE = .66
LOW_OUTS_RANGE = .33

--adjusts standard deviation in decision making
Difficulty = {
    HARD = 1,
    MEDIUM = 2,
    EASY = 3
}
