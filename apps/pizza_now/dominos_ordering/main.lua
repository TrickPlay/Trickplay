if not Class then
   dofile("Class.lua")
end
dofile("Utils.lua")
dofile("Globals.lua")
dofile("Navigator.lua")
dofile("DominosPizza.lua")

NEXTHOUSE_ADDRESS = {"77 Massachusetts Avenue", "Cambridge", "MA"}
local ADDRESS, CITY, STATE = unpack(NEXTHOUSE_ADDRESS)

local sizes = {"small", "medium", "large", "x-large"}
local crusts = {"handtoss", "deepdish", "thin", "brooklyn"}
local TOPPING_CHEESE, TOPPING_SAUCE = unpack({"toppingC", "toppingX"})

TOPPINGS = {
   {"p", "pepperoni",        "P",  "Pepperoni"},
    {"x", "xlarge-pepperoni", "Pl", "Extra Large Pepperoni"},
    {"i", "italian-sausage",  "S",  "Italian Sausage"},
    {"b", "beef",             "B",  "Beef"},
    {"h", "ham",              "H",  "Ham"},
    {"c", "bacon",            "K",  "Bacon"},
    {"k", "chicken",          "Du", "Chicken"},
    {"s", "philly-steak",     "Pm", "Philly Steak"},
    {"g", "green-peppers",    "G",  "Green Peppers"},
    {"l", "black-olives",     "R",  "Black Olives"},
    {"a", "pineapple",        "N",  "Pineapple"},
    {"m", "mushrooms",        "M",  "Mushrooms"},
    {"o", "onions",           "O",  "Onions"},
    {"j", "jalapeno-peppers", "J",  "Jalapeno Peppers"},
    {"e", "banana-peppers",   "Z",  "Bananan Peppers"},
    {"d", "cheddar-cheese",   "E",  "Cheddar Cheese"},
    {"n", "provolone-cheese", "Cp", "Provolone Cheese"},
    {"v", "green-olives",     "V",  "Green Olives"},
    {"t", "tomatoes",         "Td", "Diced Tomatoes"},
}

TOPPING_CODES = {}
for i, topping in ipairs(TOPPINGS) do
   TOPPING_CODES[topping[3]] = true
end

------------------------
-- TEST PIZZAS
------------------------

-----------------------
-- TEST CODE
-----------------------




local page = Navigator.init_session()
page = Navigator.submit_address(page, ADDRESS, CITY, STATE)
page = Navigator.goto_build_pizza(page)
page = Navigator.add_pizza(page, CHEESE_PIZZA)
page = Navigator.add_pizza(page, PEPPERONI_PIZZA)
-- page = Navigator.goto_sides(page)
local total = Navigator.get_total()
page = Navigator.goto_confirm(page)


--local formdata = parse_form(page, nil, true)
error()



------------------------------------
-- GET CONFIRMATION PAGE
------------------------------------
if not response.body then
   print("\n\n",
         "code:", response.code, "\n",
         "status:", response.status, "\n",
         "failed:", response.failed, "\n",
         "length:", response.length, "\n",
         "headers:", to_string(response.headers), "\n",
         "\n\n")
   error("response body null")
end

formdata = {}
name, value, typefield, checked = nil,nil,nil,nil
for input_elt in string.gmatch(response.body, '(<input.->)') do
   name = string.match(input_elt, 'name="(.-)"')
   value = string.match(input_elt, 'value="(.-)"')
   typefield = string.match(input_elt, 'type="(.-)"')
   checked = string.match(input_elt, 'checked')
   if not value then value = "" end

   -- if name=="deliveryOrPickup" then
   --    print(input_elt)
   --    print("name:", name)
   --    print("value:", value)
   --    print("type:", type)
   --    print("checked:", checked)
   -- end
   if typefield == "radio" then
      if checked then
         formdata[name] = value
      end
   else
      formdata[name] = value
   end
end
for input_elt in string.gmatch(response.body, '(<select.->)') do
   name = string.match(input_elt, 'name="(.-)"')
   value = string.match(input_elt, 'value="(.-)"')
   if not value then value = "1" end
   formdata[name] = value
--   print(name, "=", value)
end

assert(formdata["orderSummaryForm:_idcl"])
formdata["orderSummaryForm:_idcl"] = "orderSummaryForm:osCheckout"

-- form_print(formdata)

request = URLRequest{
   url=CHECKOUT_URL,
   method="POST",
   body=urlencode(formdata)
}

print("Making confirmation page request:\n" ..
   "url=" .. request.url .. "\n" ..
   "body=" .. request.body .. "\n\n")

response = request:perform()
print(response.body)

------------------------------------
-- Confirm!
------------------------------------
if not response.body then
   print("\n\n",
         "code:", response.code, "\n",
         "status:", response.status, "\n",
         "failed:", response.failed, "\n",
         "length:", response.length, "\n",
         "headers:", to_string(response.headers), "\n",
         "\n\n")
   error("response body null")
end

formdata = {}
name, value, typefield, checked = nil,nil,nil,nil
for input_elt in string.gmatch(response.body, '(<input.->)') do
   name = string.match(input_elt, [=[name=['"](.-)["']]=])
   value = string.match(input_elt, [=[value=['"](.-)["']]=])
   typefield = string.match(input_elt,  [=[type=['"](.-)["']]=])
   checked = string.match(input_elt, 'checked')
   if not value then value = "" end

   -- if name=="deliveryOrPickup" then
   --    print(input_elt)
   --    print("name:", name)
   --    print("value:", value)
   --    print("type:", type)
   --    print("checked:", checked)
   -- end
   if not name then
      print("No name!")
      print("value:",value)
      print("typefield:",typefield)
      print("checked:",checked)
      print("input_elt:", input_elt)
   elseif typefield == "radio" then
      if checked then
         formdata[name] = value
         print("set", name, "=", value)
      end
   else
      formdata[name] = value
      print("set", name, "=", value)
   end
end
for input_elt in string.gmatch(response.body, '(<select.->)') do
   name = string.match(input_elt, 'name="(.-)"')
   value = string.match(input_elt, 'value="(.-)"')
   if not value then value = "1" end
   formdata[name] = value
--   print(name, "=", value)
end

assert(formdata["pricingEnabled:_idcl"])

-- form_print(formdata)

-- request = URLRequest{
--    url=SUBMIT_ORDER_URL,
--    method="POST",
--    body=urlencode(formdata)
-- }

-- print("Making submit order page request:\n" ..
--    "url=" .. request.url .. "\n" ..
--    "body=" .. request.body .. "\n\n")

-- response = request:perform()
-- print(response.body)


exit()