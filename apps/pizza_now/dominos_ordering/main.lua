if not Class then
   dofile("Class.lua")
end
dofile("Utils.lua")
dofile("Globals.lua")
dofile("DominosPizza.lua")
dofile("Navigator.lua")

NEXTHOUSE_ADDRESS = {"77 Massachusetts Avenue", "Cambridge", "MA"}
local ADDRESS, CITY, STATE = unpack(NEXTHOUSE_ADDRESS)

------------------------
-- TEST PIZZAS
------------------------

-----------------------
-- TEST CODE
-----------------------




Navigator:init_session()
Navigator:submit_address(ADDRESS, CITY, STATE)
Navigator:goto_build_pizza()
Navigator:add_pizza(CHEESE_PIZZA)
Navigator:add_pizza(PEPPERONI_PIZZA)
-- Navigator:add_pizza(MASSIVE_PIZZA)
-- print(to_string(MASSIVE_PIZZA))
Navigator:goto_sides()
local total = Navigator:get_total()
Navigator:goto_confirm()


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