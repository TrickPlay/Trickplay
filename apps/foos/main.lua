dofile("Class.lua") -- Must be declared before any class definitions.
dofile("MVC.lua")
dofile("FrontPageView.lua")
dofile("FrontPageController.lua")
dofile("MainMenuView.lua")
dofile("MainMenuController.lua")
--[[
dofile("HelpMenuView.lua")
dofile("HelpMenuController.lua")
--]]
dofile("ItemSelectedView.lua")
dofile("ItemSelectedController.lua")
dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   MAIN_MENU        = 2,
   ITEM_SELECTED    = 3,
   HELP_MENU        = 4,
   COMPONENTS_LAST  = 4
}
model = Model()


local front_page_view = FrontPageView(model)
front_page_view:initialize()

local main_menu_view = MainMenuView(model)
main_menu_view:initialize()
--[[
local help_menu_view = HelpMenuView(model)
help_menu_view:initialize()
--]]
local item_selected_view = ItemSelectedView(model)
item_selected_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.FRONT_PAGE)

