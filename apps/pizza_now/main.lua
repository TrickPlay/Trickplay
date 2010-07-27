dofile("Utils.lua")
dofile("Globals.lua")
dofile("Menu/EmptyPizza.lua")
dofile("Class.lua")
dofile("MVC.lua")
dofile("Views.lua")

Components = {
   ADDRESS_INPUT = 1,
   PROVIDER_SELECTION = 2,
   CUSTOMIZE = 3,
   TAB = 4,
   CUSTOMIZE_ITEM = 5
}

-- Model initialization
local model = Model()


-- View/Controller initialization
local address_input_view = AddressInputView(model)
address_input_view:initialize()
local provider_selection_view = ProviderSelectionView(model)
provider_selection_view:initialize()

model.current_item = EmptyPizza()

local customize_view = CustomizeView(model)
customize_view:initialize()
local tab_view = TabView(model,customize_view)
tab_view:initialize()
local windmill_view = WindMillView(model)
windmill_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

--model:start_app(Components.ADDRESS_INPUT)
model:start_app(Components.CUSTOMIZE_ITEM)
--model:start_app(Components.PROVIDER_SELECTION)
