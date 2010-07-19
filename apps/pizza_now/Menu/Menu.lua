dofile("class.lua")
dofile("MenuObjects.lua")
dofile("ExampleFood.lua")
menu = {}
cart = {}
local total = 0

function isTopping(ingredient)
   if All_Options.Pizza_Toppings[ingredient] ~= nil then
      return true
   else
      return false
   end
end

function CustomizeItem(item)
   print("Customize "..item.Name..":")
   assert(item.Items == nil,"CustomizeItem() called on a container of items")
   for ingredient,options in pairs(item.Ingredients) do
      --display options.image
      print("\n"..ingredient..": choose\n")
      for choice,amount in pairs(options) do
         if amount == -1 then
            print(choice..": ")
            for pick, val in pairs(All_Options[choice]) do
               print(pick.." ")
            end
         elseif choice ~= "image" then
            print(choice..": ")
            print(" "..All_Options[choice.."_r"][amount]..
                        " Pre-selected")
         end
      end
   end
end

function CustomizeDeal(deal)
   print("Customize "..deal.Name..":\n")
   assert(deal.Items ~= nil,"CustomizeDeal() called on an item")
   repeat
      for i = 1,#deal.Items do
         CustomizeItem(deal.Items[i])
      end
   until deal.Limitations()
end
function LoadMenu() 
   
   --make a default menu
   menu = {}
   for i=1,10 do
      if i <= 3 then
         menu[i] = FiveFiveFive
      else
         menu[i] = Pizza()
      end
   end
   menu[11] = Sandwiches
end

function PrintMenu()
   print("\n\nMenu\t\t\t\t\t\tCHECKOUT\n\t\t\t\t\t\tCart:")
   local length
   if #menu > #cart then
      length = #menu
   else
      length = #cart
   end

   for i=1,length do
      if menu[i] ~= nil then
         print(" "..menu[i].Name)
         if menu[i].Items ~= nil then
            for j = 1,#menu[i].Items do
                print("\t"..menu[i].Items[j].Name)
            end
         end
      end
      if cart[i] ~= nil then
         print("\t\t\t\t\t"..cart[i].name)
      end
   end

   print("\t\t\t\t\tTotal:\n\n")
end
function Test_the_menu()
    while true do
       PrintMenu()
       SelectItem()
       
    end
end

LoadMenu()
PrintMenu()
CustomizeDeal(menu[2])
