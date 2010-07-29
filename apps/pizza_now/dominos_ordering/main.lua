if not Class then
   dofile("../Class.lua")
end
dofile("Utils.lua")

local CHEESE_PIZZA_TOPPINGS = {}

local ROOT = "https://order.dominos.com"
local LOGIN_URL = ROOT .. "/olo/faces/login/login.jsp"
local ADD_COUPON_URL = ROOT .. "/olo/faces/order/coupons.jsp"
local BUILD_PIZZA_URL = ROOT .. "/olo/faces/order/step2_choose_pizza.jsp"
local ADD_PIZZA_URL = ROOT .. "/olo/faces/order/step2_build_pizza.jsp"
local ADD_SIDES_URL = ADD_PIZZA_URL
local CHECKOUT_URL = ROOT .. "/olo/faces/order/step3_choose_drinks.jsp"
local SUBMIT_ORDER_URL = ROOT .. "/olo/faces/order/placeOrder.jsp"
local LOGOUT_URL = ROOT .. "/olo/servlet/init_servlet?target=logout"
local CALCULATE_TOTAL_URL = ROOT .. "/olo/servlet/ajax_servlet"
local CALCULATE_TOTAL_URL_POST_VARS = {
    cmd = "priceOrder",
    formName = "orderSummaryForm:",
    getFreeDeliveryOffer = "N",
    runCouponPicker = "N",
    runPriceOrder = "Y",
}

local USER_AGENT = {["User-agent"] = 'PizzaLuaParty'}

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



-------------------
-- GET COOKIE
-------------------
local request = URLRequest(LOGIN_URL)
local response = request:perform()
-- print("\n\n",
--       "code:", response.code, "\n",
--       "status:", response.status, "\n",
--       "failed:", response.failed, "\n",
--       "length:", response.length, "\n",
-- --      "headers:", to_string(response.headers), "\n",
--       "\n\n")
assert(not response.failed, request.method .. " request to url " .. request.url .. " failed: " .. response.status)

----------------
-- LOGIN
----------------
local name, value, cookie
for i,header in ipairs(response.headers) do
   name, value = unpack(header)
   if name == "Set-Cookie" then
      cookie = string.match(value, "^(.*); Path=/olo")
   end
end

local a,b,c,d = string.find(response.body,'<form(.-id="login".-)</form>')
-- print(to_string(response.headers))

local formdata = {}
local name, value
for input_elt in string.gmatch(c, '(<input.-/>)') do
   name = string.match(input_elt, 'name="(.-)"')
   value = string.match(input_elt, 'value="(.-)"')
   if not value then value = "" end
   formdata[name] = value
end

assert(formdata["login:usrName"])
assert(formdata["login:passwd"])

formdata["login:usrName"] = "dareonion"
formdata["login:passwd"] = "dareonion"
formdata["login:_idcl"] = "login:submitLink"

-- print("formdata:",to_string(formdata))

request = URLRequest{
   url=LOGIN_URL,
   method="POST",
   body=urlencode(formdata),
   headers={
--      Host="order.dominos.com",
--      Cookie=cookie
   }
}
-- debug code to print formdata in alphabetical order (by key)
-- temp_array = {}
-- for k,v in pairs(formdata) do
--    table.insert(temp_array, k)
-- end

-- table.sort(temp_array)
-- for i, k in ipairs(temp_array) do
--    print(k, "=", formdata[k])
-- end

-- error()

print("Making login request:\n" ..
   "url=" .. request.url .. "\n" ..
   "body=" .. request.body .. "\n\n")
print("logging in as dareonion")
response = request:perform()
--print("response.body:", response.body)


--print("Logged in as dareonion")

--------------------------------------------------
---- Starting to build pizza
--------------------------------------------------
-- local form_id = ""
-- local choose_pizza_contents
-- for a, b in string.gmatch(response.body,'(<form.->)(.-)</form>') do
--    form_id = string.match(a, 'id="(.-)"')
-- --   print("form_id:",form_id)
--    if form_id == "choose_pizza" then
--       choose_pizza_contents = b
--    end
-- end

if not response.body then
   error("Couldn't log in!")
end

formdata = {}
name, value, typefield, checked = nil, nil, nil, nil
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
-- print("formdata:",to_string(formdata))
--print("choose_pizza:", response.body)

formdata["choose_pizza:_idcl"] = "choose_pizza:goToBuildOwn"

-- form_print(formdata)
-- error()
-- debug code to print formdata in alphabetical order (by key)
-- temp_array = {}
-- for k,v in pairs(formdata) do
--    table.insert(temp_array, k .. " = " .. v)
-- end

-- table.sort(temp_array)
-- print("\n" .. table.concat(temp_array,"\n"))

assert(formdata["orderSummaryForm:breadsTable:0:descriptionI"])
assert(formdata["bannerProductCode"])
assert(formdata["sizeCodeSP"])
request = URLRequest{
   url=BUILD_PIZZA_URL,
   method="POST",
   body=urlencode(formdata),
}
print("going to build pizza page")
print("Making build pizza request:\n" ..
   "url=" .. request.url .. "\n" ..
   "body=" .. request.body .. "\n\n")
response = request:perform()
-- print("\n\n",
--       "code:", response.code, "\n",
--       "status:", response.status, "\n",
--       "failed:", response.failed, "\n",
--       "length:", response.length, "\n",
--       "headers:", to_string(response.headers), "\n",
--       "\n\n")

-- local build_own_contents
-- if response.body then
--    for a, b in string.gmatch(response.body,'(<form.->)(.-)</form>') do
--       -- print(a .. b .. "</form>")
--       form_id = string.match(a, 'id="(.-)"')
--       if form_id == "build_own" then
--          build_own_contents = b
--       end
--    end
-- else
--    error("Couldn't go to build pizza page!")
-- end

----------------------------
-- ADDING PIZZA
----------------------------

formdata = {}
name, value, typefield, checked = nil, nil, nil, nil
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

--print("formdata:",to_string(formdata))

local pizza_toppings = {
   S=true,
   P=true
}
local crypt
for name, value in pairs(formdata) do
   if name == TOPPING_CHEESE or name == TOPPING_SAUCE or string.find(name, "Side") or string.find(name, "Amount") then
--      print("name:", name)
--      print("donothing")
   else
      crypt = string.match(name, "topping(.-)$")
      if crypt then
         print("cryptic code:", crypt)
         if pizza_toppings[crypt] then
            formdata[name .. "Side" .. crypt] = "W"
         else
            print("Removed", name)
            formdata[name] = nil
         end
      end
      -- if crypt and TOPPING_CODES[crypt] then
      --    print("Removed", name)
      --    formdata[name] = nil
      -- end
   end
end

formdata["build_own:_idcl"] = "build_own:doAdd"
--print("NEW formdata:",to_string(formdata))
form_print(formdata)

request = URLRequest{
   url=ADD_PIZZA_URL,
   method="POST",
   body=urlencode(formdata),
}
print("adding pizza")
print("Making add pizza request:\n" ..
   "url=" .. request.url .. "\n" ..
   "body=" .. request.body .. "\n\n")
response = request:perform()
-- print(response.body)
print("added")

-------------------------------
-- GET SIDES
-------------------------------

-- build_own_contents = nil
-- if response.body then
--    for a, b in string.gmatch(response.body,'(<form.->)(.-)</form>') do
--       form_id = string.match(a, 'id="(.-)"')
--       if form_id == "build_own" then
--          build_own_contents = b
--       end
--    end
-- else
--    error("Couldn't go to build pizza page!")
-- end

-- if not build_own_contents then
--    error("Still couldn't make build pizza page")
-- end

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

formdata["build_own:_idcl"] = "build_own:navSidesLink"

-- form_print(formdata)

request = URLRequest{
   url=ADD_SIDES_URL,
   method="POST",
   body=urlencode(formdata)
}

print("Making add sides request:\n" ..
   "url=" .. request.url .. "\n" ..
   "body=" .. request.body .. "\n\n")

response = request:perform()



-------------------------------
-- CALCULATE TOTAL
-------------------------------

local totalRequest = URLRequest{
   url=CALCULATE_TOTAL_URL,
   method="POST",
   body=urlencode(CALCULATE_TOTAL_URL_POST_VARS)
}

print("Making calculate total request:\n" ..
   "url=" .. totalRequest.url .. "\n" ..
   "body=" .. totalRequest.body .. "\n\n")
local totalResponse = totalRequest:perform()
print(totalResponse.body)

if totalResponse.body then
   for total in string.gmatch(totalResponse.body, "<total>(.-)</total>") do
      print(total)
   end
end

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