dofile("Globals.lua")
dofile("Class.lua")
dofile("MVC.lua")
dofile("ItemSelectionView.lua")
dofile("ItemSelectionController.lua")
dofile("Selection_Menu.lua")

Components = {
   ITEM_SELECTION = 1
}

-- Model initialization
local model = Model()


-- View/Controller initialization
local item_selection_view = ItemSelectionView(model,SP)
item_selection_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.ITEM_SELECTION)
--model:start_app(Components.PROVIDER_SELECTION)
