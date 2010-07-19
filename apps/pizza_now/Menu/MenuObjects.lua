
Menu = class(function(self)
   self.Selections = {}
   self.AddItem = function(item)
      Selections[#Selections] = item
   end
end)

Cart = class(function(self)
   self.Selections = {}
   self.AddItem = function(item)
      Selections[#Selections] = item
   end
   
end)

Menu_Group = class(function(self)
   self.Name  = "Default Menu Group"
   self.Items = {}
end)

Menu_Deal = class(function(self)
   self.Name = "Default Menu Deal"
   self.Items = {}
   self.Price = -1

   self.Select = function()
      CustomizeDeal(self)
   end
   self.Limitations = function()
      assert(false,"Limitation not set for pizza");
   end
end)

Menu_Item = class(function(self)
   self.Name = "Default Menu Item"
   self.Ingredients = {}
   self.Selected = {}
   self.Price = function()
   end
   self.Select = function()
      CustomizeItem(self)
   end
end)

