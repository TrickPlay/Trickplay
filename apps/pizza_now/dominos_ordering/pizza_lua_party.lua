#!/usr/bin/lua

local http = require("socket.http")

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
local TOPPING_CHEESE, TOPPING_SAUCE = {"toppingC", "toppingX"}

-- http.request{
--   url = string,
--   [sink = LTN12 sink,]
--   [method = string,]
--   [headers = header-table,]
--   [source = LTN12 source],
--   [step = LTN12 pump step,]
--   [proxy = string,]
--   [redirect = boolean,]
--   [create = function]
-- }

local function getLoginPage()
   page = http.request(LOGIN_URL)
   return page
end

local function login(username, password)
   b,c,h = http.request(LOGIN_URL, "login:usrName=trickplay2&login:passwd=trickplay&login:_idcl=login:submitLink")
   print("b:", b)
   print("c:", c)
   print("h:", h)
end

local page = getLoginPage()
print(page)
-- login()