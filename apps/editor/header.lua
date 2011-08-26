local hdr = {}

hdr.test = 0
----------------
-- Constants 
----------------
-- Screen states 
hdr.S_SELECT          = 0
hdr.S_RECTANGLE       = 1
hdr.S_POPUP        	  = 2
hdr.S_MENU        	  = 3
hdr.S_FOCUS        	  = 4
hdr.S_MENU_M	  	  = 5

-- Mouse state 
hdr.BUTTON_UP         = 0
hdr.BUTTON_DOWN       = 1

-- Undo/Redo action items  
hdr.ADD               = 1
hdr.CHG               = 2
hdr.DEL               = 3
hdr.ARG		 	      = 4

hdr.BRING_FR	      = 5
hdr.SEND_BK		      = 6
hdr.BRING_FW	      = 7
hdr.SEND_BW		      = 8

-- Style constants
hdr.DEFAULT_COLOR     = {255,255,255,255}

hdr.inspector_skins = {"Custom", "CarbonCandy"}


hdr.uiElements = {"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
                    "ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane" }

hdr.uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "Group", "ArrowPane", "TabBar"} 

hdr.attr_name_list = {"color", "border_color", "border_width", "color", "border_color", "border_width", "font", "text_font","title_font", "message_font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "scale", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "x", "y", "z", "w", "h", "opacity", "ui_width", "ui_height", "f_color", "border_color", "border_width", "border_corner_radius", "text_indent", "fill_color", "title", "message", "duration", "fade_duration", "items", "item_func", "selected_item", "button_color", "select_color", "button_radius", "select_radius", "p_pos", "item_pos", "line_space", "dot_diameter", "dot_color", "number_of_dots", "overall_diameter", "cycle_time", "clone_src", "empty_top_color", "empty_bottom_color", "stroke_color", "progress"}

hdr.AUTO_SAVE_DURATION = 60000  
hdr.AUTO_SAVE = true

---------------------
-- Global Variables
---------------------
editor_lb = editor
editor_use = false

current_dir 	   = ""
current_inspector  = nil 
current_fn  	   = ""
restore_fn  	   = ""
current_focus 	   = nil
prev_tab 		   = nil
selected_container = nil
selected_content   = nil

input_mode         = hdr.S_MENU
menu_hide          = false


-- table for mouse dragging information 
dragging          = nil

mouse_state       = hdr.BUTTON_UP
contents    	  = ""
item_num 	      = 0

guideline_show	  = true

-- index for new guideline
h_guideline       = 0
v_guideline       = 0

-- key focuses 
focus_type        = ""

-- cursor 
cursor_type 	  = 68

-- for the modifier keys 
shift 		      = false
shift_changed 	  = false
control 	      = false


-- table for skin 
skins = {}

-- table for ui elements selcection 
selected_objs	  = {}

-- table for undo/redo 
undo_list 	  	  = {}
redo_list 	      = {}

-- Table g contains all the ui elements in the screen 
g = Group{name = "screen_objects", extra={canvas_xf = 0, canvas_f = 0, canvas_xt = 0, canvas_t = 0, canvas_w = screen.w, canvas_h = screen.h, scroll_x = 0, scroll_y = 0, scroll_dy = 1}}

-- localized string table
	strings = dofile( "localized:strings" ) or {}

function missing_localized_string( t , s )
	rawset(t,s,s) -- only warn once per string
    return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- The asset cache
	assets = dofile( "assets-cache" )
-- Editor Defined UI Elements 
	ui_element	= dofile("/lib/ui_element")
-- Utility Functions 
	util 	   	= dofile("util")
-- Project Management Functions 
	project_mng	= dofile("project_mng")
-- Create Message Windows
	msg_window  = dofile("msgw")

	ui =
    	{
        	assets              = assets,
        	factory             = dofile( "ui-factory" ),
    	}

-- Inspector Setting Functions 
	apply	   	= dofile("apply")
-- UI Elements for Editor UI
	editor_lib  = dofile("editor_lib")
-- Editor functions 
	editor 	   	= dofile("editor")
-- Editor Main Menu 
	menu 		= dofile("menu")
-- Screen ui functions 
	screen_ui 		= dofile("screen_ui")

-- background images 
BG_IMAGE_20 = Image{src = "assets/transparency-grid-20-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 255}
BG_IMAGE_40 = Image{src = "assets/transparency-grid-40-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_80 = Image{src = "assets/transparency-grid-80-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_white = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_import = Image{src = "assets/white.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

return hdr
