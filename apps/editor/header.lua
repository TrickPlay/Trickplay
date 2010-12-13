
---------------------
-- Global 
---------------------
editor_lb = editor

----------------
-- Constants 
----------------

BUTTON_UP         = 0
BUTTON_DOWN       = 1
S_SELECT          = 0
S_RECTANGLE       = 1
S_POPUP        	  = 2
S_MENU        	  = 3

DEFAULT_COLOR     = {255,255,255,255}

ADD               = 1
CHG               = 2
DEL               = 3
ARG		  = 4

BRING_FR	  = 5
SEND_BK		  = 6
BRING_FW	  = 7
SEND_BW		  = 8

-- Section index constants. These also determine their order.

SECTION_FILE      = 1
SECTION_EDIT      = 2
SECTION_ARRANGE   = 3
SECTION_SETTING   = 4

-- Style constants

BUTTON_TEXT_STYLE = { font = "DejaVu Sans 30px" , color = "FFFFFFFF" }

---------------------
-- Variables
---------------------
CURRENT_DIR 	  = ""
dragging          = nil
current_inspector = nil 
current_fn  	  = ""
current_focus 	  = nil
selected_objs	  = {}
menu_hide         = false
popup_hide        = false
input_mode        = S_MENU
mouse_state       = BUTTON_UP
g = Group{name = "screen_objects", extra={canvas_xf = 0, canvas_f = 0, canvas_xt = 0, canvas_t = 0, canvas_w = screen.w, canvas_h = screen.h, scroll_x = 0, scroll_y = 0, scroll_dy = 1}}
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
        help_button         = assets( "assets/button-help.png" ),
        help_focus          = assets( "assets/button-help-focus.png" ),
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
                height  = 665,
                init    = dofile( "section-edit" )
            },

            [SECTION_ARRANGE] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "  ARRANGE" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 840,
                init    = dofile( "section-arrange" )
            },
           [SECTION_SETTING] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "  SETTING" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 400,
                init    = dofile( "section-setting" )
            }
        }
    }

-- Background image 

BG_IMAGE_20 = Image{src = "assets/transparency-grid-20.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_40 = Image{src = "assets/transparency-grid-40.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 255}
BG_IMAGE_80 = Image{src = "assets/transparency-grid-80.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_white = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_import = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

-- Arrange Icon image
icon_l = Image{src = "assets/left.png", opacity = 155}
icon_r = Image{src = "assets/right.png", opacity = 155} 
icon_t = Image{src = "assets/top.png", opacity = 155}
icon_b = Image{src = "assets/bottom.png", opacity = 155} 
icon_hc = Image{src = "assets/align-horizontally-center.png", opacity = 175} 
icon_vc = Image{src = "assets/align-vertically-center.png", opacity = 175}
icon_dhc = Image{src = "assets/distribute-horizontal-center.png", opacity = 185}
icon_dvc = Image{src = "assets/distribute-vertical-center.png", opacity = 185}

-- Inspector attribute name index 
attr_t_idx = {"name", "source", "left", "top", "width", "height", "volume", "loop", "x", "y", "z", "w", "h", "x_scale", "y_scale", "r", "g", "b", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "rect_r", "rect_g", "rect_b", "rect_a", "bord_r", "bord_g", "bord_b", "bwidth", "src", "clip_use", "cx", "cy", "cw", "ch", "x_angle", "y_angle", "z_angle",  "opacity", "view code", "apply", "cancel"}


