--dofile("Class.lua")
Meat_Toppings = {"Pepperoni","XL Pepperoni","Sliced Italian Sausage", 
    "Italian Sausage", "Beef", "Ham","Bacon","Premium Chicken","Salami",
    "Philly Steak"}
Veggie_Toppings = {"Green Peppers","Black Olives", "Pineapple", 
    "Mushrooms","Onions","Jalapeno Peppers","Banana Peppers","Spinach",
    "Roasted Red Peppers","Cheddar Cheese","Shredded Provolone Cheese",
    "Shredded Parmesan","Feta Cheese","Garlic","Sliced Tomatoes",
    "Hot Sauce", "Parsley"}

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

EmptyPizza = Class(--[[Menu_Item,]]function(self)
   --self._base.init(self)
   self.Name = "Build Your Own Pizza"
   self.Price = "$16.50"
   self.Tabs = {}
   self.Tabs[1] = {
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
                         function(self)
                            print("Selection not yet handled")
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
      Tab_Text = "Meat",
      Options = {}
   }
   --Veggie Toppings
   self.Tabs[3] = {
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
   for i =1,#Meat_Toppings do
      self.Tabs[2].Options[i] = {
         Name  = Meat_Toppings[i],
         Image = Image{src="assets/Topping_Pepperoni.png"},
         CoverageX  = All_Options.CoverageX.None,
         Placement = All_Options.Placement.None,
         ToppingGroup = nil,
         Selected = 
            function(itself)
             itself:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
             itself:get_model():notify()
            end
      }
   end
   for i =1,#Veggie_Toppings do
      self.Tabs[3].Options[i] = {
         Name  = Veggie_Toppings[i],
         Image = Image{src="assets/Topping_Pepperoni.png"},
         CoverageX  = All_Options.CoverageX.None,
         Placement  = All_Options.Placement.None,
         ToppingGroup = nil,
         Selected = 
            function(self)
             self:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
             self:get_model():notify()
            end
      }
   end


local pizza = Image{
    position = {0, 0},
    src = "assets/Crust_HandTossed.png",
    name = "pizza"
}
local cheese = Image{
    position = {0, 0},
    src = "assets/Cheese_Normal.png"
}
local sauce = Image{
    position = {0, 0},
    src = "assets/Sauce_Tomato.png"
}

self.pizzagroup = Group{position = {960,500}}


self.pizzagroup:add(pizza)
self.pizzagroup:add(sauce)
self.pizzagroup:add(cheese)
print("\n\n\n\nhererere")
--screen:add(self.pizzagroup)
end)








function distribute_topping(topping, side, amount, group, pizzagroup)
    --set up random variables
    local distribution = 1
    local slices = 8

    local range = 180/slices
    local toppingsPerSlice = 3
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
            local x = radius*math.cos(angle)+400
            local y = -1*radius*math.sin(angle)+400
            clone.position = {x, y}
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
                    print("here1")
                else
                    print("here2")
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
