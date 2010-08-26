slideshow_styles = {"Photo","Layer"}
style = 1
Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"

PIC_H = (screen.height/NUM_ROWS) - 10
PIC_W = PIC_H--(screen.width/(NUM_VIS_COLS+1)) 
SEL_W = PIC_W*1.1
SEL_H = PIC_H*1.1




dofile("Class.lua") -- Must be declared before any class definitions.
dofile("adapter/Adapter.lua")

dofile("MVC.lua")
dofile("TextBox.lua")
dofile("FocusableImage.lua")
dofile("FrontPageView.lua")
dofile("FrontPageController.lua")
---[[
dofile("SlideshowView.lua")
dofile("SlideshowController.lua")
--]]
--[[
dofile("HelpMenuView.lua")
dofile("HelpMenuController.lua")
--]]

---[[
dofile("SourceManagerView.lua")
dofile("SourceManagerController.lua")
--]]
dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   SLIDE_SHOW       = 2,
   SOURCE_MANAGER   = 3,
   COMPONENTS_LAST  = 3
}
model = Model()

Setup_Album_Covers()

local front_page_view = FrontPageView(model)
front_page_view:initialize()
---[[
local slide_show_view = SlideshowView(model)
slide_show_view:initialize()
--]]
---[[
local source_manager_view = SourceManagerView(model)
source_manager_view:initialize()
--]]
--[[
local item_selected_view = ItemSelectedView(model)
item_selected_view:initialize()
--]]

function app:on_closing()
	settings.searches = searches
	settings.adaptersTable = adaptersTable
	settings.user_ids = user_ids
end

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.FRONT_PAGE)

