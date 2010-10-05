
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
S_GROUP           = 4
DEFAULT_COLOR     = "FFFFFFC0"

ADD               = 1
CHG               = 2
DEL               = 3

-- Section index constants. These also determine their order.

SECTION_FILE      = 1
SECTION_EDIT      = 2
SECTION_ARRANGE   = 3
SECTION_HELP      = 4

-- Style constants

BUTTON_TEXT_STYLE = { font = "DejaVu Sans 30px" , color = "FFFFFFFF" }

-- Background image 
BG_IMAGE = Image {src = "baduk.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}}

---------------------
-- Variables
---------------------
dragging          = nil
current_inspector = nil
current_focus 	  = nil
menu_hide         = false
popup_hide        = false
mouse_mode        = S_SELECT
mouse_state       = BUTTON_UP
g = Group()
contents    	  = ""
item_num 	  = 0
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
        search_button       = assets( "assets/button-search.png" ),
        search_focus        = assets( "assets/button-search-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
            [SECTION_FILE] =
            {
                button  = assets( "assets/button-red.png" ),
                text    = Text  { text = strings[ "  FILE " ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 370,
                init    = dofile( "section-file" )
            },

            [SECTION_EDIT] =
            {
                button  = assets( "assets/button-green.png" ),
                text    = Text  { text = strings[ "  EDIT  " ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 500,
                init    = dofile( "section-edit" )
            },

            [SECTION_ARRANGE] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "  ARRANGE" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 300,
                init    = dofile( "section-arrange" )
            },
           [SECTION_HELP] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "  HELP" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 200,
                init    = dofile( "section-help" )
            }
        }
    }


