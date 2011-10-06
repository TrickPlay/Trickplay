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

PLAYER_NAME_FONT = "KacstArt 28px"
PLAYER_ACTION_FONT = "KacstArt 40px"

CUSTOMIZE_TINY_FONT = "KacstArt 24px"
CUSTOMIZE_TINIER_FONT = "KacstArt 20px"
CUSTOMIZE_TAB_FONT  = "KacstArt 48px"
CUSTOMIZE_ENTRY_FONT = "KacstArt 28px"
CUSTOMIZE_SUB_FONT  = "KacstArt 32px"
CUSTOMIZE_SUB_FONT_B  = "KacstArt 36px"
CUSTOMIZE_SUB_FONT_SP  = "KacstArt 42px"
CUSTOMIZE_NAME_FONT = "KacstArt 144px"

MENU_FONT = "DejaVu Sans Book 28px"
MENU_FONT_BOLD = "DejaVu Sans Bold 30px"
MENU_FONT_BOLD_BIG = "DejaVu Sans Bold 38px"

DEFAULT_FONT = "DejaVu Serif 40px"
DEFAULT_COLOR = Colors.WHITE

SUITED = 1
UNSUITED = 2

DIALOG_DISPLAY_TIME = 1000
CHANGE_VIEW_TIME = 500
CHANGE_FOCUS_TIME = 200
CARD_MOVE_DURATION = 300
CARD_MOVE_QUICK = 200

CARD_STARTING_POSITION = {-800, 0, 0}
Z_OFFSET = 2
ROTATION = 1
COLLECTION_OFFSET = 20
TABLEAU_OFFSET = 30
TABLEAU_OFFSET_FACE_UP = 45
WASTE_OFFSET = 40
