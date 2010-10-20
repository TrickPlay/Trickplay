
---------------------
-- Global 
---------------------
----------------
-- Constants 
----------------

BUTTON_UP         = 0
BUTTON_DOWN       = 1
S_SELECT          = 0
S_RECTANGLE       = 1
S_DRAGGING        = 2
S_MENU            = 3
S_CLONE           = 4
S_GROUP           = 5
DEFAULT_COLOR     = "FFFFFFC0"

ADD               = 1
CHG               = 2
DEL               = 3

-- Section index constants. These also determine their order.

SECTION_FILE      = 1
SECTION_EDIT      = 2
SECTION_ARRANGE   = 3
SECTION_SETTING      = 4

-- Style constants

BUTTON_TEXT_STYLE = { font = "DejaVu Sans 30px" , color = "FFFFFFFF" }

-- Background image 
BG_IMAGE = Image { name= "bg_img", src = "transparency-grid-40.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}}

CURRENT_DIR 	  = "./editor"
---------------------
-- Variables
---------------------
dragging          = nil
current_inspector = nil 
current_fn  	  = ""

current_focus 	  = nil

menu_hide         = false
popup_hide        = false
mouse_mode        = S_SELECT
mouse_state       = BUTTON_UP
g = Group{}

contents    	  = ""
item_num 	  = 0
shift 		  = false
control 	  = false
undo_list 	  = {}
redo_list 	  = {}

-- localized string table

strings = dofile( "localized:strings.lua" ) or {}
function missing_localized_string( t , s )
        rawset(t,s,s)
        return s
end

setmetatable( strings , { __index = missing_localized_string } )


-- The asset cache
assets = dofile( "assets-cache" )

ui =
    {
        assets              = assets,
        factory             = dofile( "ui-factory" ),
        fs_focus            = nil,
        bar                 = Group {},
        bar_background      = assets( "assets/menu-background.png" ),
        button_focus        = assets( "assets/button-focus.png" ),
        help_button       = assets( "assets/button-help.png" ),
        help_focus        = assets( "assets/button-help-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
            [SECTION_FILE] =
            {
                button  = assets( "assets/button-red.png" ),
                text    = Text  { text = strings[ "  FILE " ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 340,
                init    = dofile( "section-file" )
            },

            [SECTION_EDIT] =
            {
                button  = assets( "assets/button-green.png" ),
                text    = Text  { text = strings[ "  EDIT  " ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 610,
                init    = dofile( "section-edit" )
            },

            [SECTION_ARRANGE] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "  ARRANGE" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 810,
                init    = dofile( "section-arrange" )
            },
           [SECTION_SETTING] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "  SETTING" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 340,
                init    = dofile( "section-setting" )
            }
        }
    }


