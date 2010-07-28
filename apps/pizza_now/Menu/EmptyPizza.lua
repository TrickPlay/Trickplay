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

   Placement  = {
       NONE   = 1,
       LEFT   = 2,
       RIGHT  = 3,
       ENTIRE = 4
   },
   Placement_r  = {
       "NONE",
       "LEFT",
       "RIGHT",
       "ENTIRE"
   },
   CoverageX  = {
      NONE    = 1,
      LIGHT   = 2,
      REGULAR = 3,
      EXTRA   = 4
   },
   CoverageX_r  = {
      "NONE"    ,
      "LIGHT"   ,
      "REGULAR" ,
      "EXTRA"   
   },  
   Coverage   = {
      NONE    = 1,
      LIGHT   = 2,
      REGULAR = 3
   },
   Size      = {
      SMALL  = 1,
      MEDIUM = 2,
      LARGE  = 3,
      XLARGE = 4
   },
   Crust_Style = {
      HANDTOSSED     = 1,
      DEEP_DISH      = 2,
      CRUNCHY_THIN   = 3,
      BROOKLYN_STYLE = 4
   },
   Sauce_Type = {
      TOMATO   = 1,
      WHITE    = 2,
      MARINARA = 3,
      BBQ      = 4
   },
   Size_r = {"SMALL","MEDIUM","LARGE","XLARGE"},

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
   self.Tabs = {}
   self.Tabs[1] = {
      Tab_Text = "Crust",
      --Radio Buttons
      Options = {
         {Name = "Cheese", Image = "", 
                       Placement = All_Options.Placement.ENTIRE,
                       CoverageX = All_Options.Coverage.REGULAR,
                        Selected = 
                         function(self)
                            print("Selection not yet handled")
                         end},
         {Name = "Sauce",  Image = "", 
                       CoverageX = All_Options.Coverage.REGULAR,
                      Sauce_Type = All_Options.Sauce_Type.TOMATO,
                        Selected = 
                         function(self)
                            print("Selection not yet handled")
                         end},
         {Name = "Crust",  Image = "", 
                     Crust_Style = All_Options.Crust_Style.HANDTOSSED,
                        Selected = 
                         function(self)
                            print("Selection not yet handled")
                         end},
         {Name = "Size",   Image = "",
                            Size = All_Options.Size.LARGE,
                        Selected = 
                         function(self)
                            print("Selection not yet handled")
                         end}
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

   for i =1,#Meat_Toppings do
      self.Tabs[2].Options[i] = {
         Name  = Meat_Toppings[i],
         Image = "",
         CoverageX  = All_Options.Coverage.REGULAR,
         Placement = All_Options.Placement.NONE,
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
         Image = "",
         CoverageX  = All_Options.Coverage.REGULAR,
         Placement = All_Options.Placement.NONE,
         Selected = 
            function(self)
             self:get_model():set_active_component(Components.CUSTOMIZE_ITEM)
             self:get_model():notify()
            end
      }
   end
end)

function print_empty_pizza()
   pzza = Empty_Pizza()
   print("Empty Pizza Item:",pzza.Name)
      for tab_index,tab in ipairs(pzza.Tabs) do
         --display options.image
         print("\n"..tab.Tab_Text..": choose\n")
         if tab.Options ~= nil then
            for opt_index,option in ipairs(tab.Options) do
               print(option.Name,": ")
               for item, selection in pairs(option) do
                  if item ~= "Name" and item ~= "Image" then
                     print("\t"..item,":")
                     for pick, val in pairs(All_Options[item]) do
                        print("\t",pick)
                     end
                     print("\tcurrently selected:", selection)
                  end
               end
            end
         end
      end
-- until item.IsReady()
   return true
end
--print_empty_pizza()
