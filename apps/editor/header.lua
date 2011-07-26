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

hdr.inspector_skins = {"default", "custom", "CarbonCandy"}


hdr.uiElements = {"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
                    "ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane" }

hdr.uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "Group", "ArrowPane", "TabBar"} 

hdr.attr_name_list = {"color", "border_color", "border_width", "color", "border_color", "border_width", "font", "text_font","title_font", "message_font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "scale", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "x", "y", "z", "w", "h", "opacity", "ui_width", "ui_height", "f_color", "border_color", "border_width", "border_corner_radius", "text_indent", "fill_color", "title", "message", "duration", "fade_duration", "items", "item_func", "selected_item", "button_color", "select_color", "button_radius", "select_radius", "p_pos", "item_pos", "line_space", "dot_diameter", "dot_color", "number_of_dots", "overall_diameter", "cycle_time", "clone_src", "empty_top_color", "empty_bottom_color", "stroke_color", "progress"}

return hdr
