local old_print = print
function print(...)
   a,b,c = ...
   if not string.find(a,"^Graying") and not string.find(a,"^Hiding") and not string.find(a,"^Showing") then
      old_print(...)
   end
end

dofile("SuppressErrors.lua")
dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
dofile("Utils.lua")
dofile("dominos_ordering/DominosPizza.lua")
dofile("dominos_ordering/Navigator.lua")
dofile("Menu/EmptyPizza.lua")
dofile("Menu/Selection_Menu.lua")
dofile("MVC.lua")
dofile("Views.lua")

Components = {
   COMPONENTS_FIRST = 1,
   ADDRESS_INPUT = 1,
   PROVIDER_SELECTION = 2,
   FOOD_SELECTION = 3,
   ITEM_SELECTION = 4,
   CUSTOMIZE = 5,
   TAB = 6,
   ACCORDIAN = 7,
   CUSTOMIZE_ITEM = 8,
   COMPONENTS_LAST = 9,
   CHECKOUT = 9
}


-- Model initialization
model = Model()

-- View/Controller initialization
local address_input_view = AddressInputView(model)
address_input_view:initialize()
local provider_selection_view = ProviderSelectionView(model)
provider_selection_view:initialize()

local food_selection_view = FoodSelectionView(model)
food_selection_view:initialize()

local item_selection_view = ItemSelectionView(model,SP)
item_selection_view:initialize()
--model.current_item = EmptyPizza()

local customize_view = CustomizeView(model)
customize_view:initialize()
local tab_view = TabView(model,customize_view)
tab_view:initialize()
customize_view:get_controller():set_child_controller(tab_view:get_controller())
local acc_view = AccordianView(model,customize_view)
acc_view:initialize()

local windmill_view = WindMillView(model)
windmill_view:initialize()

local checkout_view = CheckoutView(model)
checkout_view:initialize()

function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

if NETWORKING then
   Navigator:init_session()
end
model:start_app(Components.ADDRESS_INPUT)
--model:start_app(Components.CHECKOUT)
--model:start_app(Components.CUSTOMIZE_ITEM)
--model:start_app(Components.PROVIDER_SELECTION)
