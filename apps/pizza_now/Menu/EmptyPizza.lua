local PEP_IMG_PATH = "assets/Topping_Pepperoni.png"

local CRUST_HANDTOSSED = Image{opacity = 0,src="assets/Crust_HandTossed.png"}
local CRUST_THIN = Image{opacity = 0,src="assets/Crust_HandTossed.png"}
local SAUCE_ROBUST = Image{opacity = 0,src="assets/Sauce_Robust.png"}
local SAUCE_BBQ = Image{opacity = 0,src="assets/Sauce_BBQ.png"}
local SAUCE_WHITE = Image{opacity = 0,src="assets/Sauce_White.png"}
local SAUCE_MARINARA = Image{opacity = 0,src="assets/Sauce_Marinara.png"}
screen:add(CRUST_HANDTOSSED,CRUST_THIN,SAUCE_ROBUST,SAUCE_BBQ,SAUCE_WHITE,SAUCE_MARINARA)
if not Class then
   dofile("Class.lua")
end

Meat_Toppings = {
   {name="Pepperoni",image=Image{src="assets/Topping_Pepperoni.png"}},
   "XL Pepperoni",
   {name="Sliced Italian Sausage",image=Image{src="assets/Topping_SlicedItalian.png"}}, 
   "Italian Sausage",
   "Beef",
   {name="Ham",image=Image{src="assets/Topping_Ham.png"}},
   "Bacon",
   "Premium Chicken",
   "Salami",
   "Philly Steak"
}
Veggie_Toppings = {
   "Green Peppers",
   {name="Black Olives",image=Image{src="assets/Topping_Olives.png"}},
   "Pineapple",
   {name="Mushrooms",image=Image{src="assets/Topping_Mushroom.png"}},
   {name="Onions",image=Image{src="assets/Topping_Onion.png"}},
   "Jalapeno Peppers",
   "Banana Peppers",
   "Spinach",
   "Roasted Red Peppers",
   "Cheddar Cheese",
   "Shredded Provolone Cheese",
   "Shredded Parmesan",
   "Feta Cheese",
   "Garlic",
   "Sliced Tomatoes",
   "Hot Sauce",
   "Parsley"
}

All_Options = {

   --NA = -1,

   Placement = {
      ["None"]   = 1,
      ["Left"]   = 2,
      ["Right"]  = 3,
      ["Entire"] = 4
   },
   Placement_r = {
      "None"   ,
      "Left"   ,
      "Right"  ,
      "Entire"
   },
   CoverageX = {
      ["None"]    = 1,
      ["Light"]   = 2,
      ["Regular"] = 3,
      ["Extra"]   = 4
   },
   CoverageX_r = {
      "None"    ,
      "Light"   ,
      "Regular" ,
      "Extra"   
   },  
   Coverage = {
      ["Light"]   = 2,
      ["Regular"] = 3,
      ["Extra"]   = 4
   },
   Size = {
      ["Small"]        = 1,
      ["Medium"]       = 2,
      ["Large"]        = 3,
      ["Extra Large"]  = 4
   },
   Crust_Style = {
      ["Handtossed"]     = 1,
      ["Deep Dish"]      = 2,
      ["Crunchy Thin"]   = 3,
      ["Brooklyn Style"] = 4
   },
   Crust_Style_r = {
      "Handtossed"     ,
      "Deep Dish"      ,
      "Crunchy Thin"   ,
      "Brooklyn Style" 
   },
   Sauce_Type = {
      ["Tomato"]   = 1,
      ["White"]    = 2,
      ["Marinara"] = 3,
      ["Barbeque"] = 4
   },
   Sauce_Type_r = {
      "Tomato"   ,
      "White"    ,
      "Marinara" ,
      "Barbeque"
   },
   Size_r = {"Small","Medium","Large","Extra Large"},

   Pizza_Toppings_r = {
      "Pepperoni","XL_Pepperoni","Sliced_Italian_Sausage", 
      "Italian_Sausage", "Beef", "Ham","Bacon","Premium_Chicken","Salami",
      "Philly_Steak", "Green_Peppers","Black_Olives", "Pineapple", 
      "Mushrooms","Onions","Jalapeno_Peppers","Banana_Peppers","Spinach",
      "Roasted_Red_Peppers","Cheddar_Cheese","Shredded_Provolone_Cheese",
      "Shredded_Parmesan","Feta_Cheese","Garlic","Sliced_Tomatoes",
      "Hot_Sauce","Cheddar_Cheese","Shredded_Provolone_Cheese",
      "Shredded_Parmesan", "Parsley", "American_Cheese"},
   Pizza_Toppings = {
      Pepperoni = 1, XL_Pepperoni = 1, Sliced_Italian_Sausage = 1, 
      Italian_Sausage = 1, Beef = 1, Ham = 1, Bacon = 1, Premium_Chicken = 1,
      Salami = 1, Philly_Steak = 1, Green_Peppers = 1, Black_Olives = 1, 
      Pineapple = 1, Mushrooms = 1,Onions = 1, Jalapeno_Peppers = 1, 
      Banana_Peppers = 1, Spinach = 1, Roasted_Red_Peppers = 1, 
      Cheddar_Cheese = 1, Shredded_Provolone_Cheese = 1, 
      Shredded_Parmesan = 1, Feta_Cheese = 1, Garlic = 1, Sliced_Tomatoes = 1,
      Hot_Sauce = 1, Cheddar_Cheese = 1, Shredded_Provolone_Cheese = 1,
      Shredded_Parmesan = 1},
   Dip = { BLUE_CHEESE        = 1,
           HOT_DIPPING_SAUCE     = 2,
           MARINARA_SAUCE        = 3,
           RANCH                 = 4,
           PARMESEAN_PEPPERCORN  = 5,
           ITALIAN_DIPPING_SAUCE = 6
        }
}

EmptyPizza = Class(
   function(self)
      --self._base.init(self)
      self.Name = "Pizza"
      self.CheckOutDesc =
         function()
            local lines = {}
            --top line
            lines.top = "- "..All_Options.Size_r[self.Tabs[1].Options[4].Size].." "..
               All_Options.Crust_Style_r[self.Tabs[1].Options[3].Crust_Style]..
               " Pizza with:\t\t",self:PriceString(),""
            --pizza base info
            lines.crust = "\t"..All_Options.CoverageX_r[self.Tabs[1].Options[1].CoverageX].." Cheese, "..
               All_Options.CoverageX_r[self.Tabs[1].Options[2].CoverageX].." "..
               All_Options.Sauce_Type_r[self.Tabs[1].Options[2].Sauce_Type].." Sauce"

            --sides
            lines.entire = ""
            lines.left  = ""
            lines.right = ""
            for i = 1,#self.Tabs[2].Options do
               if self.Tabs[2].Options[i].Placement == All_Options.Placement.Entire then
                  if lines.entire ~= "" then
                     lines.entire = lines.entire..", "..self.Tabs[2].Options[i].Name
                  else
                     lines.entire = "\t\t"..self.Tabs[2].Options[i].Name
                  end
               elseif self.Tabs[2].Options[i].Placement == All_Options.Placement.Left then
                  if lines.left ~= "" then
                     lines.left = lines.left..", "..self.Tabs[2].Options[i].Name
                  else
                     lines.left = "\t\t"..self.Tabs[2].Options[i].Name
                  end
               elseif self.Tabs[2].Options[i].Placement == All_Options.Placement.Right then
                  if lines.right ~= "" then
                     lines.right = lines.right..", "..self.Tabs[2].Options[i].Name
                  else
                     lines.right = "\t\t"..self.Tabs[2].Options[i].Name
                  end
               end
            end
            for i = 1,#self.Tabs[3].Options do
               if self.Tabs[3].Options[i].Placement == All_Options.Placement.Entire then
                  if lines.entire ~= "" then
                     lines.entire = lines.entire..", "..self.Tabs[3].Options[i].Name
                  else
                     lines.entire = "\t\t"..self.Tabs[3].Options[i].Name
                  end
               elseif self.Tabs[3].Options[i].Placement == All_Options.Placement.Left then
                  if lines.left ~= "" then
                     lines.left = lines.left..", "..self.Tabs[3].Options[i].Name
                  else
                     lines.left = "\t\t"..self.Tabs[3].Options[i].Name
                  end
               elseif self.Tabs[3].Options[i].Placement == All_Options.Placement.Right then
                  if lines.right ~= "" then
                     lines.right = lines.right..", "..self.Tabs[3].Options[i].Name
                  else
                     lines.right = "\t\t"..self.Tabs[3].Options[i].Name
                  end
               end
            end
            return lines
         end
      self.Price = 16.50
      self.PriceString = function() return string.format("$%.2f", self.Price) end
      self.Tabs = {}
      self.Tabs[1] = {
         Radio = true,
         Tab_Text = "Crust",
         --Radio Buttons
         Options = {
            {
               Name = "Cheese", 
               Image = Image{src="assets/Topping_Pepperoni.png"}, 
               Placement = All_Options.Placement.Entire,
               CoverageX = All_Options.Coverage.Regular,
               ToppingGroup = nil,
               Selected = 
                  function(itself)
                     itself:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
                     itself:get_model():notify()
                  end
            },
            {
               Name = "Sauce",
               Image = Image{src="assets/Topping_Pepperoni.png"},
               Radio = true,
               CoverageX = All_Options.Coverage.Regular,
               Sauce_Type = All_Options.Sauce_Type.Tomato,
               ToppingGroup = nil,
               Selected = 
                  function(self)
                     print("Selection not yet handled")
                  end
            },
            {
               Name = "Crust",
               Image = Image{src="assets/Topping_Pepperoni.png"},
               Radio = true,
               Crust_Style = All_Options.Crust_Style.Handtossed,
               ToppingGroup = nil,
               Selected = 
                  function(self)
                     print("Selection not yet handled")
                  end
            },
            {
               Name = "Size",
               Image = Image{src="assets/Topping_Pepperoni.png"},
               Radio = true,
               Size = All_Options.Size.Large,
               ToppingGroup = nil,
               Selected = 
                  function(self)
                     print("Selection not yet handled")
                  end
            }
         }
      }
      --Meat Toppings
      self.Tabs[2] = {
         Radio = false,
         Tab_Text = "Meat",
         Options = {}
      }
      --Veggie Toppings
      self.Tabs[3] = {
         Radio = false,
         Tab_Text = "Veggie",
         Options = {}
      }
      --[[
      --Add to Order
      self.Tabs[4] = {
         Tab_Text = "Add"
         --Options = {}??
      }
      --Back to Food Menu
      self.Tabs[5] = {
         Tab_Text = "Back"
         --Options = {}??
      }
      --]]
      local name, image
      for i =1,#Meat_Toppings do
         if type(Meat_Toppings[i]) == "table" then
            name = Meat_Toppings[i].name
            image = Meat_Toppings[i].image
         else
            name = Meat_Toppings[i]
            image = Image{src=PEP_IMG_PATH}
         end
         self.Tabs[2].Options[i] = {
            Name  = name,
            Image = image,
            CoverageX  = All_Options.CoverageX.None,
            Placement = All_Options.Placement.None,
            ToppingGroup = nil,
            Selected = 
               function(itself,y)
                  itself:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
                  itself:get_model():get_active_controller():set_y(y)
                  itself:get_model():notify()
               end
         }
      end
      for i =1,#Veggie_Toppings do
         -- TODO stop hacking and change the Veggie_Toppings table to contain the image, same with Meat
         if type(Veggie_Toppings[i]) == "table" then
            name = Veggie_Toppings[i].name
            image = Veggie_Toppings[i].image
         else
            name = Veggie_Toppings[i]
            image = Image{src=PEP_IMG_PATH}
         end


         self.Tabs[3].Options[i] = {
            Name  = name,
            Image = image,
            CoverageX  = All_Options.CoverageX.None,
            Placement = All_Options.Placement.None,
            ToppingGroup = nil,
            Selected = 
               function(itself,y)
                  itself:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
                  itself:get_model():get_active_controller():set_y(y)
                  itself:get_model():notify()
               end
         }
      end
      local cheese = Image{
         position = {0, 0},
         src = "assets/Cheese_Normal.png"
      }
      local sauce = Clone{source=SAUCE_ROBUST}
      --sauce:unparent()
      sauce:show()
      sauce.opacity=255
      local crust = Clone{source=CRUST_HANDTOSSED}
      --crust:unparent()
      crust:show()
      crust.opacity=255
      
      self.pizzagroup = Group{position = {960,480},clip={0,0,960,480}}


      self.pizzagroup:add(crust)
      self.pizzagroup:add(sauce)
      self.pizzagroup:add(cheese)
      --screen:add(self.pizzagroup)
      
      local coverage_lut = {
         [All_Options.CoverageX.None] = nil,
         [All_Options.CoverageX.Light] = Coverage.LIGHT,
         [All_Options.CoverageX.Regular] = Coverage.NORMAL,
         [All_Options.CoverageX.Extra] = Coverage.EXTRA
      }

      local placement_lut = {
         [All_Options.Placement.None] = nil,
         [All_Options.Placement.Left] = Placement.LEFT,
         [All_Options.Placement.Right] = Placement.RIGHT,
         [All_Options.Placement.Entire] = Placement.WHOLE
      }

      local crust_lut = {
         [All_Options.Crust_Style["Handtossed"]] = Crusts.HAND_TOSSED,
         [All_Options.Crust_Style["Deep Dish"]] = Crusts.DEEP_DISH,
         [All_Options.Crust_Style["Crunchy Thin"]] = Crusts.CRUNCHY_THIN,
         [All_Options.Crust_Style["Brooklyn Style"]] = Crusts.BROOKLYN_STYLE,
      }
      function self:get_crust()
         return crust_lut[self.Tabs[1].Options[3].Crust_Style]
      end


      local size_lut = {
         [All_Options.Size.Small] = Sizes.SMALL,
         [All_Options.Size.Medium] = Sizes.MEDIUM,
         [All_Options.Size.Large] = Sizes.LARGE,
         [All_Options.Size["Extra Large"]] = Sizes.XLARGE,
      }
      function self:get_size()
         return size_lut[self.Tabs[1].Options[4].Size]
      end

      local sauce_lut = {
         [All_Options.Sauce_Type.Tomato] = Sauces.ROBUST,
         [All_Options.Sauce_Type.White] = Sauces.WHITE,
         [All_Options.Sauce_Type.Marinara] = Sauces.MARINARA,
         [All_Options.Sauce_Type.Barbeque] = Sauces.BBQ,
      }
      function self:get_sauce_customization()
         local sauce_cust = self.Tabs[1].Options[2]
         local enabled = true
         local sauce = Sauces.ROBUST
         local coverage = Coverage.NORMAL
         if sauce_cust.CoverageX == All_Options.CoverageX.None then
            enabled = false
         else
            enabled = true
            sauce = sauce_lut[sauce_cust.Sauce_Type]
            coverage = coverage_lut[sauce_cust.CoverageX]
         end
         return {
            enabled=enabled,
            sauce=sauce,
            coverage=coverage
         }
      end

      function self:get_cheese_customization()
         local cheese_cust = self.Tabs[1].Options[1]
         local enabled = true
         local placement = Placement.WHOLE
         local coverage = Coverage.NORMAL
         if cheese_cust.CoverageX == All_Options.CoverageX.None or
            cheese_cust.Placement == All_Options.Placement.None then
            enabled = false
         else
            enabled = true
            placement = placement_lut[cheese_cust.Placement]
            coverage = coverage_lut[cheese_cust.CoverageX]
         end
         return {
            enabled=enabled,
            placement=placement,
            coverage=coverage
         }
      end
      
      local topping_lut = {
         ["Pepperoni"] = Toppings.PEPPERONI,
         ["XL Pepperoni"] = Toppings.XL_PEPPERONI,
         ["Sliced Italian Sausage"] = Toppings.SLICED_ITALIAN_SAUSAGE,
         ["Italian Sausage"] = Toppings.ITALIAN_SAUSAGE,
         ["Beef"] = Toppings.BEEF,
         ["Ham"] = Toppings.HAM,
         ["Bacon"] = Toppings.BACON,
         ["Premium Chicken"] = Toppings.CHICKEN,
         ["Salami"] = Toppings.SALAMI,
         ["Philly Steak"] = Toppings.PHILLY_STEAK,
         ["Green Peppers"] = Toppings.GREEN_PEPPERS,
         ["Black Olives"] = Toppings.BLACK_OLIVES,
         ["Pineapple"] = Toppings.PINEAPPLE,
         ["Mushrooms"] = Toppings.MUSHROOMS,
         ["Onions"] = Toppings.ONIONS,
         ["Jalapeno Peppers"] = Toppings.JALAPENOS,
         ["Banana Peppers"] = Toppings.BANANA_PEPPERS,
         ["Spinach"] = Toppings.SPINACH,
         ["Roasted Red Peppers"] = Toppings.RED_PEPPERS,
         ["Cheddar Cheese"] = Toppings.CHEDDAR_CHEESE,
         ["Shredded Provolone Cheese"] = Toppings.PROVOLONE,
         ["Shredded Parmesan"] = Toppings.PARMESAN,
         ["Feta Cheese"] = Toppings.FETA,
         ["Garlic"] = Toppings.GARLIC,
         ["Sliced Tomatoes"] = Toppings.TOMATOES,
         ["Hot Sauce"] = Toppings.HOT_SAUCE,
         ["Parsley"] = nil
      }
      function self:get_toppings()
         local TOPPING_LIMIT = 10
         local toppings = {}
         local topping, coverage, placement

         local left_topping_count = 0
         local right_topping_count = 0
         local new_left_topping_count = 0
         local new_right_topping_count = 0
         -- handle meats
         for i, topping_cust in ipairs(self.Tabs[2].Options) do
            if topping_cust.CoverageX ~= All_Options.CoverageX.None and
               topping_cust.Placement ~= All_Options.Placement.None then
               topping = topping_lut[topping_cust.Name]
               coverage = coverage_lut[topping_cust.CoverageX]
               placement = placement_lut[topping_cust.Placement]

               assert(coverage, tostring(coverage) .. " and " .. tostring(topping_cust.CoverageX))
               assert(placement)
               print("coverage:", coverage)
               print("placement:", placement)
               if placement == Placement.WHOLE or placement == Placement.LEFT then
                  new_left_topping_count = left_topping_count + tonumber(coverage.qty)
               end
               if placement == Placement.WHOLE or placement == Placement.RIGHT then
                  new_right_topping_count = right_topping_count + tonumber(coverage.qty)
               end

               if new_left_topping_count > TOPPING_LIMIT then
                  print("\n\nLEFT SIDE TOPPING OVERFLOW! " .. topping.name .. " not added\n\n")
               elseif new_right_topping_count > TOPPING_LIMIT then
                  print("\n\nRIGHT SIDE TOPPING OVERFLOW! " .. topping.name .. " not added\n\n")
               else
                  left_topping_count = new_left_topping_count
                  right_topping_count = new_right_topping_count
                  print("Adding " .. topping.name)
                  toppings[topping] = {coverage=coverage, placement=placement}
               end
            end
         end

         -- handle unmeats
         for i, topping_cust in ipairs(self.Tabs[3].Options) do
            if topping_cust.CoverageX ~= All_Options.CoverageX.None and
               topping_cust.Placement ~= All_Options.Placement.None then
               topping = topping_lut[topping_cust.Name]
               coverage = coverage_lut[topping_cust.CoverageX]
               placement = placement_lut[topping_cust.Placement]

               if placement == Placement.WHOLE or placement == Placement.LEFT then
                  new_left_topping_count = left_topping_count + tonumber(coverage.qty)
               end
               if placement == Placement.WHOLE or placement == Placement.RIGHT then
                  new_right_topping_count = right_topping_count + tonumber(coverage.qty)
               end

               if new_left_topping_count > TOPPING_LIMIT then
                  print("\n\nLEFT SIDE TOPPING OVERFLOW! " .. topping.name .. " not added\n\n")
               elseif new_right_topping_count > TOPPING_LIMIT then
                  print("\n\nRIGHT SIDE TOPPING OVERFLOW! " .. topping.name .. " not added\n\n")
               else
                  left_topping_count = new_left_topping_count
                  right_topping_count = new_right_topping_count
                  print("Adding " .. topping.name)
                  toppings[topping] = {coverage=coverage, placement=placement}
               end
            end
         end

         for topping, tweaks in pairs(toppings) do
            print(topping.name)
            print(tweaks.coverage)
            print(tweaks.placement)
            --            print(topping.name .. " topping with " .. tweaks.coverage .. " coverage and " .. tweaks.placement .. " placement")
         end
         return toppings
      end

      function self:as_dominos_pizza()
         local pizza = DominosPizza(
            self:get_crust(),
            self:get_size(),
            self:get_cheese_customization(),
            self:get_sauce_customization(),
            self:get_toppings()
         )
         return pizza
      end

   end)







--[[
    Creates a group, "group", which holds the distribution of "topping" clones.
    side and amount are value constants, topping is an image. pizzagroup is a group
    containing all the different "topping" Images for this specific pizza
--]]
function distribute_topping(topping, side, amount, group, pizzagroup)
   --set up random variables
   local distribution = 1
   local slices = 8

   local range = 180/slices
   local toppingsPerSlice = 3
   --some image based constants
   local topping_center = {x = topping.base_size[1]/2, y = topping.base_size[2]/2}
   local pizza_center = {x = 960/2, y = 480}

   --Groups for the left and right side of the pizza && amount of topping
   local toppingLightRightGroup = Group{name = "topping_light_right"}
   local toppingNormalRightGroup = Group{name = "topping_normal_right"}
   local toppingExtraRightGroup = Group{name = "topping_extra_right"}
   local toppingRightGroup = Group{name = "right_side"}

   local toppingLightLeftGroup = Group{name = "topping_light_left"}
   local toppingNormalLeftGroup = Group{name = "topping_normal_left"}
   local toppingExtraLeftGroup = Group{name = "topping_extra_left"}
   local toppingLeftGroup = Group{name = "left_side"}

   toppingRightGroup:add(toppingLightRightGroup)
   toppingRightGroup:add(toppingNormalRightGroup)
   toppingRightGroup:add(toppingExtraRightGroup)

   toppingLeftGroup:add(toppingLightLeftGroup)
   toppingLeftGroup:add(toppingNormalLeftGroup)
   toppingLeftGroup:add(toppingExtraLeftGroup)

   group:add(toppingRightGroup)
   group:add(toppingLeftGroup)

   pizzagroup:add(group)

   --determine distribution
   for slice = 1, slices do
      for top = 1, toppingsPerSlice do
         local seed = math.random(toppingsPerSlice+1-top)
         local radius = top * 140 * (seed+toppingsPerSlice+1)/(toppingsPerSlice+4)
         local degrees = math.random(range)
         local angle = (degrees + range*(slice-1)) * math.pi/180

         local clone = Clone{source = topping}
         local x = radius*math.cos(angle) + pizza_center.x - topping_center.x
         local y = -1*radius*math.sin(angle)+pizza_center.y - topping_center.y
         clone.position = {x, y}
         clone.z_rotation = {math.random(360), topping_center.x, topping_center.y}
         print("radians: "..angle..", degrees: "..degrees..", radius: "..radius)
         local groupseed = math.random(2,4)
         if(All_Options.CoverageX.Light == groupseed) then
            if(slice <= 4) then
               toppingLightRightGroup:add(clone)
            else
               toppingLightLeftGroup:add(clone)
            end
            elseif(All_Options.CoverageX.Regular == groupseed) then
            if(slice <= 4) then
               toppingNormalRightGroup:add(clone)
            else
               toppingNormalLeftGroup:add(clone)
            end
            elseif(All_Options.CoverageX.Extra == groupseed) then
            if(slice <= 4) then
               toppingExtraRightGroup:add(clone)
            else
               toppingExtraLeftGroup:add(clone)
            end
         else
            error("error: a topping was not added correctly!")
         end
      end
   end
   --TODO: add one in the very center

end
function topping_dropping(topping, side, amount, toppinggroup, pizzagroup)
   assert(topping)
   assert(side)
   assert(amount)
   assert(pizzagroup)
   if(All_Options.Placement.NONE == side) then
      amount = All_Options.CoverageX.NONE
   end
   --add group for type
   if(not toppinggroup) then
      toppinggroup = Group()
      distribute_topping(topping, side, amount, toppinggroup, pizzagroup)
   end
   --add topping to screen to make it clonable
   if not topping.parent then
      screen:add(topping)
      topping:hide()
   end

   
   --determine how many should be shown
   toppinggroup:find_child("right_side"):hide_all()
   toppinggroup:find_child("left_side"):hide_all()
   --show the correct side of the pizza
   if(All_Options.Placement.Right == side or All_Options.Placement.Entire == side) then
      toppinggroup:find_child("right_side"):show()
   end
   if(All_Options.Placement.Left == side or All_Options.Placement.Entire == side) then
      toppinggroup:find_child("left_side"):show()
   end
   --show the correct amount
   if(All_Options.CoverageX.Light == amount) then
      toppinggroup:find_child("topping_light_left"):show()
      toppinggroup:find_child("topping_light_right"):show()
      elseif(All_Options.CoverageX.Regular == amount) then
      toppinggroup:find_child("topping_light_left"):show()
      toppinggroup:find_child("topping_light_right"):show()
      toppinggroup:find_child("topping_normal_left"):show()
      toppinggroup:find_child("topping_normal_right"):show()
      elseif(All_Options.CoverageX.Extra == amount) then
      toppinggroup:find_child("topping_light_left"):show()
      toppinggroup:find_child("topping_light_right"):show()
      toppinggroup:find_child("topping_normal_left"):show()
      toppinggroup:find_child("topping_normal_right"):show()
      toppinggroup:find_child("topping_extra_left"):show()
      toppinggroup:find_child("topping_extra_right"):show()
   end

   return toppinggroup
end
