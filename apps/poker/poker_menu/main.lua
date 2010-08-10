dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
dofile("Utils.lua")
dofile("MVC.lua")
dofile("Views.lua")

Components = {
    PLAYER_SELECTION = 1
}

-- Model initialization
local model = Model()


-- View/Controller initialization
local player_selection_view = PlayerSelectionView(model)
player_selection_view:initialize()

model:start_app(Components.PROVIDER_SELECTION)
