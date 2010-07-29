local Crusts = {
   HAND_TOSSED = {name="handtossed", canon="HANDTOSS"},
   DEEP_DISH = {name="deep dish", canon="DEEPDISH"},
   CRUNCHY_THIN = {name="crunchy thin", canon="THIN"},
   BROOKLYN_STYLE = {name="brooklyn style", canon="BK"}
}
local Sizes = {
   SMALL = {name="small", diam=10},
   MEDIUM = {name="medium", diam=12},
   LARGE = {name="large", diam=14},
   XLARGE = {name="x-large", diam=16}
}

-- roughly a struct.
local function Topping(name, crypt_code)
   assert(name)
   assert(crypt_code)
   return {name=name, crypt_code=crypt_code, isTopping=true}
end

local Toppings = {
   -- MEATS
   PEPPERONI = Topping("Pepperoni","P"),
   XL_PEPPERONI = Topping("Extra Large Pepperoni","Pl"),
   SLICED_ITALIAN_SAUSAGE = Topping("Sliced Italian Sausage","Sb"),
   ITALIAN_SAUSAGE = Topping("Italian Sausage","S"),
   BEEF = Topping("Beef", "B"),
   HAM = Topping("Ham","H"),
   BACON = Topping("Bacon","K"),
   CHICKEN = Topping("Premium Chicken","Du"),
   SALAMI = Topping("Salami","Sa"),
   PHILLY_STEAK = Topping("philly-steak","Pm"),
   -- UNMEATS
   GREEN_PEPPERS = Topping("Green Peppers","G"),
   BLACK_OLIVES = Topping("Black Olives","R"),
   PINEAPPLE = Topping("Pineapple","N"),
   MUSHROOMS = Topping("Mushrooms","M"),
   ONIONS = Topping("Onions","O"),
   JALAPENOS = Topping("Jalapeno Peppers","J"),
   BANANA_PEPPERS = Topping("Banana Peppers","Z"),
   SPINACH = Topping("Spinach", "Si"),
   RED_PEPPERS = Topping("Roasted Red Peppers","Rr"),
   CHEDDAR_CHEESE = Topping("Cheddar Cheese","E"),
   PROVOLONE = Topping("Shredded Provolone Cheese","Cp"),
   PARMESAN = Topping("Shredded Parmesan","Cs"),
   FETA = Topping("Feta Cheese","Fe"),
   GARLIC = Topping("Garlic","F"),
   TOMATOES = Topping("Diced Tomatoes","Td"),
   HOT_SAUCE = Topping("Hot Sauce","Ht")
}

local function Sauce(name,crypt_code)
   assert(name)
   assert(crypt_code)
   return {name=name, crypt_code=crypt_code, isSauce = true}
end

local Sauces = {
   ROBUST = Sauce("Inspired Robust Sauce","X"),
   WHITE = Sauce("White Sauce","Xw"),
   MARINARA = Sauce("Hearty Marinara Sauce","Xm"),
   BBQ = Sauce("BBQ Sauce","Bq")
}

local Placement = {
   WHOLE = "W",
   LEFT = "1",
   RIGHT = "2"
}

local Coverage = {
   NORMAL = "1",
   EXTRA = "1.5",
   LIGHT = ".5"
}

local size_crust_avlblty = {
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

local DEFAULT_CRUST = Crusts.HANDTOSSED
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
      
      -- DEBUGGING PURPOSES, take out in production code
      assert(size_crust_avlble[self.crust][self.size], "Illegal crust/size combination: " .. self.crust .. "/" .. self.size.name)
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
   end)
