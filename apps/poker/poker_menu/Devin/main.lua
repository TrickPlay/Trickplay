dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
--dofile("Utils.lua")
dofile("MVC.lua")
dofile("Views.lua")
dofile("Chip.lua")
dofile("Player.lua")

Components = {
    PLAYER_SELECTION = 1,
    PLAYER_BETTING = 2
}

Components.COMPONENTS_LAST = 2
Components.COMPONENTS_FIRST = 1


-- Model initialization
local model = Model()


-- View/Controller initialization
BettingView(model):initialize()
PlayerSelectionView(model):initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    print("current comp: "..model:get_active_component())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.PLAYER_SELECTION)
