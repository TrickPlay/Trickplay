local ROOT = "https://order.dominos.com"
local ADDRESS_INPUT = ROOT .. "/olo/index.jsp?loadingdone=Y"
local LANDING_PAGE = ROOT .. "/olo/faces/customer/currentLocation.jsp"
--local LOGIN_URL = ROOT .. "/olo/faces/login/login.jsp"
--local ADD_COUPON_URL = ROOT .. "/olo/faces/order/coupons.jsp"
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

Navigator = {}
function Navigator.init_session()
   local response = get_response(ADDRESS_INPUT)
   return response.body
end

function Navigator.submit_address(page, address, city, state)
   print("submitting address")
   local formdata = parse_form(page, "startOrder")
   
   -- assert(formdata["startOrder:tAddress1"])
   -- assert(formdata["startOrder:tCity"])
   -- assert(formdata["startOrder:tState"])
   formdata["startOrder:tAddress1"] = address
   formdata["startOrder:tCity"] = city
   formdata["startOrder:tState"] = state
   formdata["startOrder:_idcl"] = "startOrder:locationOrderNowBtn"

   local response = get_response(LANDING_PAGE, formdata)
   if string.find(response.body, "Please enter the street address") then
      error("Didn't enter a street address")
   elseif string.find(response.body, "Please enter City&#47;State or Zip Code") then
      error("Didn't enter a city/state or zip code")
   elseif string.find(response.body, "There is no store currently delivering to your address.&nbsp;Select any of the stores below to place an order online that you can carryout.") then
      error("Couldn't find a store that delivered to your address")
   elseif string.find(response.body, "YOUR STORE IS CURRENTLY CLOSED.") then
      error("Your store is currently closed.")
   end
   return response.body
end

function Navigator.goto_build_pizza(page)
   print("navigating to pizza builder")
   local formdata = parse_form(page, "choose_pizza")
   assert(formdata["choose_pizza:_idcl"])
   formdata["choose_pizza:_idcl"] = "choose_pizza:goToBuildOwn"
   local response = get_response(BUILD_PIZZA_URL, formdata)
   return response.body
end

function Navigator.add_pizza(page, pizza)
   print("adding pizza")
   local formdata = parse_form(page, "build_own")

   ---
   -- Set crust/size
   --
   formdata["builderCrust"] = pizza.crust.canon
   formdata["builderSize"] = pizza.size.diam

   ---
   -- Set cheese customization
   --
   local ch_cust = pizza.cheese_customization
   if ch_cust.enabled then
      formdata["toppingCHEESE"] = "C"
      formdata["toppingC"] = "C"
      formdata["toppingSideC"] = ch_cust.placement
      formdata["toppingAmountC"] = ch_cust.coverage
   else
      formdata["toppingCHEESE"] = nil
      formdata["toppingC"] = nil -- if this doesn't work, use empty string
      formdata["toppingSideC"] = "0"
   end

   ---
   -- Set sauce customization
   --
   local sa_cust = pizza.sauce_customization

   -- first disable all sauces
   for _, sauce in pairs(Sauces) do
      assert(formdata[sauce.side_str] and formdata[sauce.amt_str])
      formdata[sauce.side_str] = ""
      formdata[sauce.amt_str] = "1"
   end

   -- then enable the sauce (if needed)
   if sa_cust.enabled then
      formdata["toppingSAUCE"] = "SAUCE"
      local sauce = sa_cust.sauce
      local crypt_code = sauce.crypt_code
      local crypt_name = sauce.crypt_name
      local crypt_side = sauce.side_str
      local crypt_amt = sauce.amt_str
      assert(formdata[crypt_side] and formdata[crypt_amt])
      formdata[crypt_name] = sauce.crypt_code
      formdata[crypt_side] = "W"
      formdata[crypt_amt] = sauce.coverage
   else
      formdata["toppingSAUCE"] = nil
   end

   -- then enable the toppings (as needed)
   for topping, tweaks in pairs(pizza.toppings) do
      formdata[topping.crypt_name] = topping.crypt_code
      formdata[topping.side_str] = tweaks.placement
      formdata[topping.amt_str] = tweaks.coverage
   end

   -- then set the tag for the request
   assert(formdata["build_own:_idcl"])
   formdata["build_own:_idcl"] = "build_own:doAdd"
   local response = get_response(ADD_PIZZA_URL, formdata)
   return page
end

function Navigator.goto_sides(page)
   print("going to sides")
   local formdata = parse_form(page, "build_own")
   assert(formdata["build_own:_idcl"])
   formdata["build_own:_idcl"] = "build_own:navSidesLink"
   local response = get_response(ADD_SIDES_URL, formdata)
   return response.body
end

function Navigator.get_total()
   local MAX_ATTEMPTS = 5
   local total = nil
   local response
   local i = 1
   while i <= MAX_ATTEMPTS and total == nil do
      response = get_response(CALCULATE_TOTAL_URL, CALCULATE_TOTAL_URL_POST_VARS)
      print(response.body)
      total = tonumber(string.match(response.body, "<total>$(.-)</total>"))
      i = i+1
   end
   assert(total, "Couldn't get total!")
   return total
end

function Navigator.goto_confirm(page)
   print("heading to confirm page")
   local formdata = parse_form(page, "orderSummaryForm", true)
   assert(formdata["orderSummaryForm:_idcl"])
   formdata["orderSummaryForm:_idcl"] = "orderSummaryForm:osCheckout"
   local response = get_response(CHECKOUT_URL, formdata)
   return response.body
end

function Navigator.submit_order(page)
   print("submitting final order")
   local formdata = parse_form(page, "pricingEnabled", true)
   assert(formdata["pricingEnabled:_idcl"])
   formdata["pricingEnabled:_idcl"] = "pricingEnabled:placeOrdeLinkHIDDEN"
   print("Didn't actually submit order.")
end