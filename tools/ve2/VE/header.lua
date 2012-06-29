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

--hdr.inspector_skins = {"Custom", "CarbonCandy"}


--hdr.uiElements = {"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
--"ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane" }

--hdr.uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "Group", "ArrowPane", "TabBar"} 

--hdr.attr_name_list = {"lock", "visible_width", "visible_height", "virtual_height", "virtual_width", "arror_color", "arrow_visible", "bar_color_inner", "bar_color_outer", "focus_bar_color_inner", "focus_bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness","frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "horz_bar_visible", "box_color", "focus_box_color", "box_border_width", "color", "border_color", "border_width", "color", "border_color", "border_width", "font", "text_font","title_font", "message_font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "scale", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "x", "y", "z", "w", "h", "opacity", "ui_width", "ui_height", "f_color", "border_color", "border_width", "border_corner_radius", "text_indent", "fill_color", "title", "message", "duration", "fade_duration", "items", "item_func", "selected_item", "button_color", "select_color", "button_radius", "select_radius", "p_pos", "item_pos", "line_space", "dot_diameter", "dot_color", "number_of_dots", "overall_diameter", "cycle_time", "clone_src", "empty_top_color", "empty_bottom_color", "stroke_color", "progress", "arrow_size", "skin", "reactive", "focus_color", "focus_border_color", "focus_button_color", "focus_box_color", "focus_fill_color", "cursor_color","text_color", "justify", "single_line", "alignment", "wrap_mode", "direction", "selected_item", "focus_text_color", "menu_width","horz_padding","vert_spacing","horz_spacing","vert_offset","background_color","separator_thickness","expansion_location", "show_ring", "box_size","check_size","line_space", "box_position", "item_position", "selected_items", "items", "select_color", "button_radius","select_radius", "label_color", "button_width", "button_height", "display_border_color","display_fill_color","display_border_width", "tab_position", "tab_spacing", "display_width", "display_height",  "tab_labels", "arrow_dist_to_frame","icon","label","title","title_font", "title_color", "message", "message_font", "message_color", "on_screen_duration","fade_duration","title_separator_color","title_separator_thickness","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time", "empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","rows","columns","variable_cell_size","cell_width","cell_height", "cell_spacing_width", "cell_spacing_height", "cell_timing","cell_timing_offset","arrows_visible", "arrow_color","focus_arrow_color" }


--hdr.AUTO_SAVE_DURATION = 60000  
--hdr.AUTO_SAVE = true
--hdr.LeftTab = 65056

---------------------
-- Global Variables
---------------------
editor_lb = editor
--editor_use = false

--current_dir 	   = ""
--current_inspector  = nil 
--current_fn  	   = ""
--restore_fn  	   = ""
current_focus 	   = nil
--prev_tab 		   = nil
--selected_container = nil
--selected_content   = nil

input_mode         = hdr.S_SELECT
--menu_hide          = false


-- table for mouse dragging information 
--dragging          = nil

mouse_state       = hdr.BUTTON_UP
--contents    	  = ""
--item_num 	      = 0

--guideline_show	  = true

-- index for new guideline
--h_guideline       = 0
--v_guideline       = 0

-- key focuses 
--focus_type        = ""

-- cursor 
--cursor_type 	  = 68

-- for the modifier keys 
shift 		      = false
control 	      = false

--menu_bar_hover 	  = false

-- table for skin 
--skins = {}

-- table for ui elements selcection 
selected_objs	  = {}

-- table for undo/redo 
--undo_list 	  	  = {}
--redo_list 	      = {}

-- Table g contains all the ui elements in the screen 
--g = Group{name = "screen_objects", extra={canvas_xf = 0, canvas_f = 0, canvas_xt = 0, canvas_t = 0, canvas_w = screen.w, canvas_h = screen.h, scroll_x = 0, scroll_y = 0, scroll_dy = 1}}


-- Screen ui functions 
--screen_ui = dofile("screen_ui")

return hdr
