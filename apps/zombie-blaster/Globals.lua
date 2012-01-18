------- Value Constants ---------


DEGREE_TO_RAD = math.pi/180


-------- Other ----------


HELP_ENABLED = true

ASSERTIONS_ENABLED = true

if not ASSERTIONS_ENABLED then
   local old_assert = assert
   function assert(...)
      if cond then
         if msg then print(msg)
         else print("assertion failed...") end
      end
   end
end

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
    ERASER_RUST                  ="5E2308",
    YELLOW                       ="FFFF00",
    AWESOME_YELLOW               ="FFFF99",
    GREEN                        ="00FF00",
    BLUE                         ="0000FF",
    MAGENTA                      ="FF00FF",
    CYAN                         ="00FFFF",
    ORANGE                       ="FFA500",
    PURPLE                       ="A020F0",
    PERU                         ="CD853F",
    FOCUS_RED                    ="602020"
}

END_GAME_FONT = "-banhart-skinny_black- 45px"

DEFAULT_FONT = "-banhart-skinny_black- 24px"
DEFAULT_COLOR = Colors.AWESOME_YELLOW

DIALOG_DISPLAY_TIME = 1000
CHANGE_VIEW_TIME = 500
CHANGE_FOCUS_TIME = 100
