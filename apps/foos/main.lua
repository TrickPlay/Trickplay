dofile("Class.lua") -- Must be declared before any class definitions.
dofile("MVC.lua")
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

dofile("adapter/Adapter.lua")
--[[
dofile("ItemSelectedView.lua")
dofile("ItemSelectedController.lua")
--]]
dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   SLIDE_SHOW       = 2,
   COMPONENTS_LAST  = 2
}
model = Model()

Setup_Album_Covers()

local front_page_view = FrontPageView(model)
front_page_view:initialize()
---[[
local slide_show_view = SlideshowView(model)
slide_show_view:initialize()
--]]
--[[
local help_menu_view = HelpMenuView(model)
help_menu_view:initialize()
--]]
--[[
local item_selected_view = ItemSelectedView(model)
item_selected_view:initialize()
--]]
function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.FRONT_PAGE)

