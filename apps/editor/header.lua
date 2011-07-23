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

---------------------
-- Variables
---------------------
hdr.current_dir 	  = ""
hdr.current_inspector = nil 
hdr.current_fn  	  = ""
hdr.current_focus 	  = nil

hdr.input_mode        = S_MENU
hdr.menu_hide         = false

-- table for mouse dragging information 
hdr.dragging          = nil

--mouse_state       = BUTTON_UP
hdr.contents    	  = ""
hdr.item_num 	      = 0

hdr.guideline_show	  = true

-- index for new guideline
hdr.h_guideline       = 0
hdr.v_guideline       = 0

-- key focuses 
hdr.focus_type        = ""

-- table for ui elements selcection 
hdr.selected_objs	  = {}

-- table for undo/redo 
hdr.undo_list 	  	  = {}
hdr.redo_list 	      = {}


-- background images 
hdr.BG_IMAGE_20 = Image{src = "assets/transparency-grid-20-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 255}
hdr.BG_IMAGE_40 = Image{src = "assets/transparency-grid-40-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
hdr.BG_IMAGE_80 = Image{src = "assets/transparency-grid-80-2.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
hdr.BG_IMAGE_white = Image{src = "assets/white.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
hdr.BG_IMAGE_import = Image{src = "assets/white.png", position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

hdr.inspector_skins = {"custom", "defalut", "CarbonCandy"}

return hdr
