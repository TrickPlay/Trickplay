if not GLOBALS_LOADED then
   dofile("Globals.lua")
end

local size_crust_avlble = {
   [Crusts.HAND_TOSSED] = {
      [Sizes.SMALL] = true,
      [Sizes.MEDIUM] = true,
      [Sizes.LARGE] = true,
      [Sizes.XLARGE] = true
   },
   [Crusts.DEEP_DISH] = {
      [Sizes.MEDIUM] = true,
      [Sizes.LARGE] = true
   },
   [Crusts.CRUNCHY_THIN] = {
      [Sizes.MEDIUM] = true,
      [Sizes.LARGE] = true
   },
   [Crusts.BROOKLYN_STYLE] = {
      [Sizes.LARGE] = true
   }
}

local DEFAULT_CRUST = Crusts.HAND_TOSSED
local DEFAULT_SIZE = Sizes.LARGE
local DEFAULT_CHEESE_CUSTOMIZATION = {enabled=true, placement=Placement.WHOLE, coverage=Coverage.NORMAL}
local DEFAULT_SAUCE_CUSTOMIZATION = {enabled=true, sauce=Sauces.ROBUST, coverage=Coverage.NORMAL}

DominosPizza = Class(nil,
   function(self, crust, size, cheese_customization, sauce_customization, toppings)
      self.crust = crust or DEFAULT_CRUST
      self.size = size or DEFAULT_SIZE
      self.cheese_customization = cheese_customization or DEFAULT_CHEESE_CUSTOMIZATION
      self.sauce_customization = sauce_customization or DEFAULT_SAUCE_CUSTOMIZATION
      self.toppings = toppings or {}
      
      local function checkRep()
         assert(size_crust_avlble[self.crust][self.size], "Illegal crust/size combination: " .. self.crust.name .. "/" .. self.size.name)
         for topping, tweaks in pairs(self.toppings) do
            assert(topping.isTopping, tostring(topping) .. " is not topping")
            local coverage_found = false
            for k, v in pairs(Coverage) do
               if tweaks.coverage == v then
                  coverage_found = true
                  break
               end
            end
            assert(coverage_found, "Invalid Coverage for topping " .. topping.name)
            local placement_found = false
            for k, v in pairs(Placement) do
               if tweaks.placement == v then
                  placement_found = true
                  break
               end
            end
            assert(placement_found, "Placement not valid for topping " .. topping.name)
         end
      end

      -- debug
      checkRep()
   end)

CHEESE_PIZZA = DominosPizza(
   DEFAULT_CRUST,
   DEFAULT_SIZE,
   DEFAULT_CHEESE_CUSTOMIZATION,
   DEFAULT_SAUCE_CUSTOMIZATION
)

PEPPERONI_PIZZA = DominosPizza(
   DEFAULT_CRUST,
   DEFAULT_SIZE,
   DEFAULT_CHEESE_CUSTOMIZATION,
   DEFAULT_SAUCE_CUSTOMIZATION,
   {
      [Toppings.PEPPERONI] = {
         coverage = Coverage.NORMAL,
         placement = Placement.WHOLE
      }
   }
)

-- invalid pizza, > 10 toppings
local massive_toppings = {}
for _,v in pairs(Toppings) do
   massive_toppings[v]={
      coverage=Coverage.EXTRA,
      placement=Placement.WHOLE
   }
end
MASSIVE_PIZZA = DominosPizza(
   DEFAULT_CRUST,
   DEFAULT_SIZE,
   DEFAULT_CHEESE_CUSTOMIZATION,
   DEFAULT_SAUCE_CUSTOMIZATION,
   massive_toppings
)