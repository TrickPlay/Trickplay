dofile("Utils.lua")
dofile("Globals.lua")
dofile("Class.lua")
dofile("MVC.lua")
dofile("Views.lua")

Components = {
   ADDRESS_INPUT = 1,
   PROVIDER_SELECTION = 2,
}

-- Model initialization
local model = Model()


-- View/Controller initialization
local address_input_view = AddressInputView(model)
address_input_view:initialize()
local provider_selection_view = ProviderSelectionView(model)
provider_selection_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.ADDRESS_INPUT)
--model:start_app(Components.PROVIDER_SELECTION)
