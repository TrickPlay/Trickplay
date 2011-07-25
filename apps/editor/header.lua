
---------------------
-- Global 
---------------------
editor_lb = editor
editor_use = false

----------------
-- Constants 
----------------

BUTTON_UP         = 0
BUTTON_DOWN       = 1
S_SELECT          = 0
S_RECTANGLE       = 1
S_POPUP        	  = 2
S_MENU        	  = 3
S_FOCUS        	  = 4
S_MENU_M	  = 5

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

DEFAULT_COLOR     = {255,255,255,255}
BUTTON_TEXT_STYLE = { font = "DejaVu Sans 30px" , color = "FFFFFFFF" }

---------------------
-- Variables
---------------------
CURRENT_DIR 	  = ""
dragging          = nil
current_inspector = nil 
--current_project   =""
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

guideline_show	  = true
snap_on 	  = false

h_guideline = 0
v_guideline = 0
focus_type = ""

shift 		  = false
shift_changed 	  = false
control 	  = false

undo_list 	  = {}
redo_list 	  = {}



-- localized string table

strings = dofile( "localized:strings.lua" ) or {}
function missing_localized_string( t , s )
	--print( "\t*** MISSING LOCALIZED STRING '"..s.."'" )
        rawset(t,s,s) -- only warn once per string
        return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- The asset cache
assets = dofile( "assets-cache" )

ui =
    {
        assets              = assets,
        factory             = dofile( "ui-factory" ),
    }
--[[
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
                text    = Text  { text = strings[ "  File " ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 340,
                init    = dofile( "section-file" )
            },

            [SECTION_EDIT] =
            {
                button  = assets( "assets/button-green.png" ),
                text    = Text  { text = strings[ "  Edit  " ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 555,
                init    = dofile( "section-edit" )
            },

            [SECTION_ARRANGE] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "  Arrange" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 800,
                init    = dofile( "section-arrange" )
            },
           [SECTION_SETTING] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "  View" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 640,
                init    = dofile( "section-setting" )
            }
        }
    }
]]
-- Background image 

BG_IMAGE_20 = Image{src = "assets/transparency-grid-20.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_40 = Image{src = "assets/transparency-grid-40.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 255}
BG_IMAGE_80 = Image{src = "assets/transparency-grid-80.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_white = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}



--- Cursor Images

CS_crosshair = Image{name = "mouse_pointer", src = "assets/crosshair.png", opacity = 255, scale = {screen.width/screen.display_size[1], screen.height /screen.display_size[2]} }
CS_move_into = Image{name = "mouse_pointer", src = "assets/move-into.png", opacity = 255, scale = {screen.width/screen.display_size[1], screen.height /screen.display_size[2]}}
CS_move = Image{name = "mouse_pointer", src = "assets/move.png", opacity = 255, scale = {screen.width/screen.display_size[1], screen.height/screen.display_size[2]}}
CS_pointer_plus = Image{name = "mouse_pointer", src = "assets/pointer-plus.png", opacity = 255, scale = {screen.width/screen.display_size[1], screen.height / screen.display_size[2]}}
CS_pointer = Image{name = "mouse_pointer", src = "assets/pointer.png", opacity = 255, scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}}

--BG_IMAGE_import = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
BG_IMAGE_import = Image{src = "assets/white.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

-- Arrange Icon image
icon_l = Image{src = "assets/left.png", opacity = 155}
icon_r = Image{src = "assets/right.png", opacity = 155} 
icon_t = Image{src = "assets/top.png", opacity = 155}
icon_b = Image{src = "assets/bottom.png", opacity = 155} 
icon_hc = Image{src = "assets/align-horizontally-center.png", opacity = 175} 
icon_vc = Image{src = "assets/align-vertically-center.png", opacity = 175}
icon_dhc = Image{src = "assets/distribute-horizontal-center.png", opacity = 185}
icon_dvc = Image{src = "assets/distribute-vertical-center.png", opacity = 185}

-- inspector - ui-factory.lua
--attr_t_idx = {"name", "source", "left", "top", "width", "height", "volume", "loop", "x", "y", "z", "ui_width", "ui_height", "bw", "bh", "label", "message", "w", "h", "skin",  "r", "g", "b", "a","fr","fg","fb","fa","font","text_font","title_font", "message_font", "itemsList", "selected_item", "text indent", "duration", "fade_duration", "border_width", "br", "bg", "bb", "ba", "fr", "fg", "fb", "fa", "border_corner_radius", "text",  "x_scale", "y_scale", "editable", "wants_enter", "wrap", "wrap_mode", "rect_r", "rect_g", "rect_b", "rect_a", "bord_r", "bord_g", "bord_b", "bwidth", "src", "clip_use", "cx", "cy", "cw", "ch", "x_angle", "y_angle", "z_angle",  "opacity", "view code", "apply", "cancel"}

--[[
attr_t_idx = {"name","source","left", "top", "width", "height", "volume", "loop", "x", "y", "z", "w", "h", "ui_width", "ui_height", "bw", "bh", "skin","r", "g", "b", "a","fr","fg","fb","fa","src","scale","clip","cx", "cy", "cw", "ch","x_angle", "y_angle", "z_angle","icon","label","message","opacity", "button_colorr","button_colorg","button_colorb","button_colora","focus_colorr","focus_colorg","focus_colorb","focus_colora","text_colorr","text_colorg","text_colorb","text_colora", "text_font","colorr", "colorg", "colorb", "colora","title_colorr","title_colorg","title_colorb","title_colora","title_font","message_colorr","message_colorg","message_colorb","message_colora","message_font", "border_colorr", "border_colorg", "border_colorb", "border_colora","fill_colorr","fill_colorg","fill_colorb","fill_colora","visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_innerr", "bar_color_innerg","bar_color_innerb","bar_color_innera", "bar_color_outerr","bar_color_outerg","bar_color_outerb","bar_color_outera", "empty_color_innerr", "empty_color_innerg", "empty_color_innerb","empty_color_innera","empty_color_outerr","empty_color_outerg", "empty_color_outerb", "empty_color_outera",  "frame_thickness", "frame_colorr","frame_colorg", "frame_colorb", "frame_colora",  "bar_thickness", "bar_offset", "vert_bar_visible", "hor_bar_visible", "box_colorr","box_colorg","box_colorb","box_colora", "box_width","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable","empty_top_colorr","empty_top_colorg","empty_top_colorb","empty_top_colora","empty_bottom_colorr","empty_bottom_colorg","empty_bottom_colorb","empty_bottom_colora","filled_top_colorr","filled_top_colorg","filled_top_colorb","filled_top_colora","filled_bottom_colorr","filled_bottom_colorg","filled_bottom_colorb","filled_bottom_colora","stroke_colorr","stroke_colorg","stroke_colorb","stroke_colora","progress","overall_diameter","dot_diameter","dot_colorr","dot_colorg","dot_colorb","dot_colora","number_of_dots","cycle_time","border_width","border_corner_radius","title_separator_colorr","title_separator_colorg","title_separator_colorb","title_separator_colora","color","font","direction","padding","br", "bg", "bb", "ba", "fr", "fg", "fb", "fa","menu_width","hor_padding","vert_spacing","hor_spacing","vert_offset","background_colorr","background_colorg","background_colorb","background_colora","separator_thickness","expansion_location","on_screen_duration","fade_duration","wrap_mode","rect_r", "rect_g", "rect_b", "rect_a", "bord_r", "bord_g", "bord_b", "bwidth","title_separator_thickness","items","selected_item","reactive", "focus"} 
]]


--imsi ----- missing attr_t_idx ::::  source, src, icon, expension_location, cell_size, items, reactive, "reactive", "focus", "vert_bar_visible", "hor_bar_visible",

attr_t_idx = {"name","left", "top", "width", "height", "volume", "loop", "x", "y", "z", "w", "h", "ui_width", "ui_height", "bw", "bh", "skin","r", "g", "b", "a","fr","fg","fb","fa","scale","clip","cx", "cy", "cw", "ch","x_angle", "y_angle", "z_angle","label","message","opacity", "button_colorr","button_colorg","button_colorb","button_colora","border_colorr", "border_colorg", "border_colorb", "border_colora","fill_colorr","fill_colorg","fill_colorb","fill_colora","focus_colorr","focus_colorg","focus_colorb","focus_colora","focus_fill_colorr","focus_fill_colorg","focus_fill_colorb","focus_fill_colora","cursor_colorr", "cursor_colorg", "cursor_colorb", "cursor_colora","focus_text_colorr","focus_text_colorg","focus_text_colorb","focus_text_colora","text_colorr","text_colorg","text_colorb","text_colora", "text_font","colorr", "colorg", "colorb", "colora","title_colorr","title_colorg","title_colorb","title_colora","title_font","message_colorr","message_colorg","message_colorb","message_colora","message_font", "visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_innerr", "bar_color_innerg","bar_color_innerb","bar_color_innera", "bar_color_outerr","bar_color_outerg","bar_color_outerb","bar_color_outera", "empty_color_innerr", "empty_color_innerg", "empty_color_innerb","empty_color_innera","empty_color_outerr","empty_color_outerg", "empty_color_outerb", "empty_color_outera",  "frame_thickness", "frame_colorr","frame_colorg", "frame_colorb", "frame_colora",  "bar_thickness", "bar_offset",  "box_colorr","box_colorg","box_colorb","box_colora", "box_width","rows","columns","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable","empty_top_colorr","empty_top_colorg","empty_top_colorb","empty_top_colora","empty_bottom_colorr","empty_bottom_colorg","empty_bottom_colorb","empty_bottom_colora","filled_top_colorr","filled_top_colorg","filled_top_colorb","filled_top_colora","filled_bottom_colorr","filled_bottom_colorg","filled_bottom_colorb","filled_bottom_colora","stroke_colorr","progress","overall_diameter","dot_diameter","dot_colorr","dot_colorg","dot_colorb","dot_colora","number_of_dots","cycle_time","padding","border_width","border_corner_radius","title_separator_colorr","title_separator_colorg","title_separator_colorb","title_separator_colora","color","font","direction","br", "bg", "bb", "ba", "fr", "fg", "fb", "fa","menu_width","hor_padding","vert_spacing","hor_spacing","vert_offset","background_colorr","background_colorg","background_colorb","background_colora","separator_thickness","on_screen_duration","fade_duration","wrap_mode","rect_r", "rect_g", "rect_b", "rect_a", "bord_r", "bord_g", "bord_b", "bwidth","title_separator_thickness","selected_item","reactive", "focus"} 

-- create_on_button_f -> copy_obj -> set_obj - util.lua   
attr_name_list = {"color", "border_color", "border_width", "color", "border_color", "border_width", "font", "text_font","title_font", "message_font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "scale", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "x", "y", "z", "w", "h", "opacity", "ui_width", "ui_height", "f_color", "border_color", "border_width", "border_corner_radius", "text_indent", "fill_color", "title", "message", "duration", "fade_duration", "items", "item_func", "selected_item", "button_color", "select_color", "button_radius", "select_radius", "p_pos", "item_pos", "line_space", "dot_diameter", "dot_color", "number_of_dots", "overall_diameter", "cycle_time", "clone_src", "empty_top_color", "empty_bottom_color", "stroke_color", "progress"}

ui_element = dofile("/lib/ui_element.lua")

uiElementLists = {"Rectangle", "Text", "Image", "Video", "Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", "ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane"}

uiElements_en = {"Rectangle", "Text", "Image", "Video"}

uiElements = {"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", --"CheckBox",  "RadioButton",  "ArrowPane",
           "ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane" }
	   -- "TabBar", "OSK",}
uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "Group", "ArrowPane", "TabBar"} 

skins = {}
for i, j in pairs(skin_list) do
	table.insert(skins, i) 
end 

