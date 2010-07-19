Pizza = class(Menu_Item,function(self)
   self._base.init(self)
   self.Name = "Pizza"
   self.Ingredients.Sizes = {
      image = "",
      Size = -1
   }
   self.Ingredients.Sauce = {
      image = "",
      Coverage = -1
   }
   self.Ingredients.Cheese = {
      image = "",
      Coverage = -1
   }
   self.Ingredients.Pepperoni = {
       image = "",
       Placement = -1
   }
   self.Ingredients.Sausage = {
       image = "",
       Placement = -1
   }
   self.Ingredients.Bell_Peppers = {
       image = "",
       Placement = -1
   }
   self.Ingredients.Olives = {
       image = "",
       Placement = -1
   }
   self.Ingredients.Mushrooms = {
       image = "",
       Placement = -1
   }
   

   self.Price = function()
      return 10 + self.Selected.Size + #self.Selected.Toppings
   end
end)

--[[
Sandwiches 
--]]
Sandwiches = Menu_Group()
   ISP = Menu_Item()
   ISP.Name = "Italian Sasuage And Peppers"
   ISP.Price = function() return 5.50 end

   BC = Menu_Item()
   BC.Name = "Buffalo Chicken"
   BC.Price = function() return 5.50 end

   CH = Menu_Item()
   CH.Name = "Chicken Habanero"
   CH.Price = function() return 5.50 end

   MV = Menu_Item()
   MV.Name = "Mediterranean Veggie"
   MV.Price = function() return 5.50 end

   PC = Menu_Item()
   PC.Name = "Philly Cheesesteak"
   PC.Price = function() return 5.50 end

   CBR = Menu_Item()
   CBR.Name = "Chicken Bacon Ranch"
   CBR.Price = function() return 5.50 end

   I = Menu_Item() 
   I.Name = "Italian"
   I.Price = function() return 5.50 end

   CP = Menu_Item()
   CP.Name = "Chicken Parm"
   CP.Price = function() return 5.50 end
Sandwiches.Name = "Sandwiches"
Sandwiches.Items = {ISP,BC,CH,MV,PC,CBR,I,CP}
--[[
Five Five Five Deal
--]]
FiveFiveFive = Menu_Deal()
FiveFiveFive.Name = "Five-Five-Five Deal"
Med_Pza1 = Pizza()
Med_Pza1.Name = "One Medium Pizza"
Med_Pza1.Ingredients.Sizes = {}
Med_Pza1.Ingredients.Sizes.Size = All_Options.Size.MEDIUM
Med_Pza2 = Pizza()
Med_Pza2.Name = "One Medium Pizza"
Med_Pza2.Ingredients.Sizes = {}
Med_Pza2.Ingredients.Sizes.Size = All_Options.Size.MEDIUM
Med_Pza3 = Pizza()
Med_Pza3.Name = "One Medium Pizza"
Med_Pza3.Ingredients.Sizes = {}
Med_Pza3.Ingredients.Sizes.Size = All_Options.Size.MEDIUM

FiveFiveFive.Items = { Med_Pza1, Med_Pza2, Med_Pza3 }
FiveFiveFive.Limitations = function()
   for i=1,#self.Items do
      if self.Items[i].Ingredients.Sizes.Size ~= All_Options.Size.MEDIUM
                       then
         print("Pizza must be a Medium\n")
         return false
      end
   end
   return true
end
--[[
One Large One Topping Pizza
--]]
All_Options = {
Placement = {
       NONE   = 1,
       LEFT   = 2,
       RIGHT  = 3,
       ENTIRE = 4
},
Coverage  = {
      NONE    = 1,
      LIGHT   = 2,
      REGULAR = 3,
      EXTRA   = 4
},
Size      = {
      SMALL  = 1,
      MEDIUM = 2,
      LARGE  = 3,
      XLARGE = 4
},
Size_r = {"SMALL","MEDIUM","LARGE","XLARGE"},
Pizza_Toppings_r = {
    "Pepperoni","XL Pepperoni","Sliced Italian Sausage", 
    "Italian Sausage", "Beef", "Ham","Bacon","Premium Chicken","Salami",
    "Philly Steak", "Green Peppers","Black Olives", "Pineapple", 
    "Mushrooms","Onions","Jalapeno Peppers","Banana Peppers","Spinach",
    "Roasted Red Peppers","Cheddar Cheese","Shredded Provolone Cheese",
    "Shredded Parmesan","Feta Cheese","Garlic","Sliced Tomatoes",
    "Hot Sauce","Cheddar Cheese","Shredded Provolone Cheese",
    "Shredded Parmesan"},
Pizza_Toppings = {
    Pepperoni = 1, XL_Pepperoni = 1, Sliced_Italian_Sausage = 1, 
    Italian_Sausage = 1, Beef = 1, Ham = 1, Bacon = 1, Premium_Chicken = 1,
    Salami = 1, Philly_Steak = 1, Green_Peppers = 1, Black_Olives = 1, 
    Pineapple = 1, Mushrooms = 1,Onions = 1, Jalapeno_Peppers = 1, 
    Banana_Peppers = 1, Spinach = 1, Roasted_Red_Peppers = 1, 
    Cheddar_Cheese = 1, Shredded_Provolone_Cheese = 1, 
    Shredded_Parmesan = 1, Feta_Cheese = 1, Garlic = 1, Sliced_Tomatoes = 1,
    Hot_Sauce = 1, Cheddar_Cheese = 1, Shredded_Provolone_Cheese = 1,
    Shredded_Parmesan = 1}

}
Sandwich_Toppings = {
      Sauce                     = {image = "", coverage = -1},
      Onions                    = {image = "", coverage = -1},
      Roasted_Red_Peppers       = {image = "", coverage = -1},
      Green_Peppers             = {image = "", coverage = -1},
      Shredded_Provolone_Cheese = {image = "", coverage = -1},
      Banana_Peppers            = {image = "", coverage = -1},
      Sliced_Provolone          = {image = "", coverage = -1},
      Sliced_Italian_Sausage    = {image = "", coverage = -1}
      
}

