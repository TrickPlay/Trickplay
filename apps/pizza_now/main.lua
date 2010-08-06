-- local old_print = print
-- function print(...)
--    a,b,c = ...
--    if not string.find(a,"^Graying") and not string.find(a,"^Hiding") and not string.find(a,"^Showing") then
--       old_print(...)
--    end
-- end

-- dofile("SuppressErrors.lua")
dofile("Class.lua") -- Must be declared before any class definitions.
dofile("Globals.lua")
dofile("Utils.lua")
dofile("TextBox.lua")
dofile("FocusableImage.lua")
dofile("dominos_ordering/DominosPizza.lua")
dofile("dominos_ordering/Navigator.lua")
dofile("Menu/EmptyPizza.lua")
dofile("Menu/Selection_Menu.lua")
dofile("MVC.lua")
dofile("Views.lua")

Components = {
   COMPONENTS_FIRST = 2,
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
--local address_input_view = AddressInputView(model)
--address_input_view:initialize()
local provider_selection_view = ProviderSelectionView(model)
provider_selection_view:initialize()

local food_selection_view = FoodSelectionView(model)
food_selection_view:initialize()

local item_selection_view = ItemSelectionView(model,SP)
item_selection_view:initialize()
--model.current_item = EmptyPizza()

local customize_view = CustomizeView(model)
customize_view:initialize()


local checkout_view = CheckoutView(model)
checkout_view:initialize()

function screen:on_key_down(k)
   if k == keys.r then
      table.insert(model.cart, EmptyPizza())
      model:get_active_controller():get_view():refresh_cart()
      model:notify()
   else
      assert(model:get_active_controller())
      model:get_active_controller():on_key_down(k)
   end
end


if NETWORKING then
   Navigator:init_session()
end

model:start_app(Components.PROVIDER_SELECTION)
