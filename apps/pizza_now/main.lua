dofile("Utils.lua")
dofile("Globals.lua")
dofile("Class.lua")
dofile("MVC.lua")
dofile("views/AddressInputView.lua")
dofile("controllers/AddressInputController.lua")
dofile("views/KeyboardInputView.lua")
dofile("controllers/KeyboardInputController.lua")
dofile("views/ProviderSelectionView.lua")
dofile("controllers/ProviderSelectionController.lua")

Components = {
   ADDRESS_INPUT = 1,
   KEYBOARD_INPUT = 2,
   PROVIDER_SELECTION = 3,
   MENU = 4,
   CHECKOUT = 5,
}

-- dofile("views/BackgroundView.lua")


-- Model initialization
local model = Model()


-- View/Controller initialization
-- --local background_view = BackgroundView:new(model)
-- --background_view:initialize()

local address_input_view = AddressInputView(model)
address_input_view:initialize()
--local keyboard_input_view = KeyboardInputView(model)
--keyboard_input_view:initialize()
local provider_selection_view = ProviderSelectionView(model)
provider_selection_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Components.ADDRESS_INPUT)
--model:start_app(Components.PROVIDER_SELECTION)
