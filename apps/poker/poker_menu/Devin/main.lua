dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
--dofile("Utils.lua")
dofile("MVC.lua")
dofile("Views.lua")
dofile("Chip.lua")

Components = {
    PLAYER_SELECTION = 1,
    PLAYER_BETTING = 2
}

-- Model initialization
local model = Model()


-- View/Controller initialization
local player_selection_view = PlayerSelectionView(model)
player_selection_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    print("current comp: "..model:get_active_component())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.PLAYER_SELECTION)
