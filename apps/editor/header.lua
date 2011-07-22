local header = {}
---------------------
-- Global 
---------------------
editor_lb = editor
editor_use = false

-- Table g contains all the ui elements in the screen 
g = Group{name = "screen_objects", extra={canvas_xf = 0, canvas_f = 0, canvas_xt = 0, canvas_t = 0, canvas_w = screen.w, canvas_h = screen.h, scroll_x = 0, scroll_y = 0, scroll_dy = 1}}

-- localized string table
strings = dofile( "localized:strings.lua" ) or {}

function missing_localized_string( t , s )
	rawset(t,s,s) -- only warn once per string
    return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- The asset cache
assets = dofile( "assets-cache" )

-- The ui factory 
factory = dofile( "ui-factory" )

-- The ui elements 
ui_element = dofile( "lib/ui_element"),

-- The ui elements for editor inspector 
editor_lib = dofile( "editor_lib"),

ui =
    {
        assets              = assets,
        factory             = factory,
		ui_element			= ui_element, 
		editor_lib 			= editor_lib,
    }

----------------
-- Constants 
----------------
--BUTTON_UP         = 0
--BUTTON_DOWN       = 1

-- Screen states 
S_SELECT          = 0
S_RECTANGLE       = 1
S_POPUP        	  = 2
S_MENU        	  = 3
S_FOCUS        	  = 4
S_MENU_M	  	  = 5

-- Undo/Redo action items  
ADD               = 1
CHG               = 2
DEL               = 3
ARG		 	      = 4

BRING_FR	      = 5
SEND_BK		      = 6
BRING_FW	      = 7
SEND_BW		      = 8

-- Style constants
DEFAULT_COLOR     = {255,255,255,255}

---------------------
-- Variables
---------------------
current_dir 	  = ""
current_inspector = nil 
current_fn  	  = ""
current_focus 	  = nil

input_mode        = S_MENU

-- table for mouse dragging information 
dragging          = nil

menu_hide         = false
popup_hide        = false

--mouse_state       = BUTTON_UP
contents    	  = ""
item_num 	      = 0

guideline_show	  = true
snap_on 	      = false

-- index for new guideline
h_guideline       = 0
v_guideline       = 0

-- key focuses 
focus_type        = ""

-- for the modifier keys 
shift 		      = false
shift_changed 	  = false
control 	      = false

-- table for ui elements selcection 
selected_objs	  = {}

-- table for undo/redo 
undo_list 	  	  = {}
redo_list 	      = {}


-- background images 
BG_IMAGE_20 = Image{src = "assets/transparency-grid-20-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 255}
BG_IMAGE_40 = Image{src = "assets/transparency-grid-40-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_80 = Image{src = "assets/transparency-grid-80-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_white = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_import = Image{src = "assets/white.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

skins = {}

for i, j in pairs(skin_list) do
	table.insert(skins, i) 
end 

return header
