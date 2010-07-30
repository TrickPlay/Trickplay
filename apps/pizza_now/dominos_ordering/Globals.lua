GLOBALS_LOADED = true
Crusts = {
   HAND_TOSSED = {name="handtossed", canon="HANDTOSS"},
   DEEP_DISH = {name="deep dish", canon="DEEPDISH"},
   CRUNCHY_THIN = {name="crunchy thin", canon="THIN"},
   BROOKLYN_STYLE = {name="brooklyn style", canon="BK"}
}
Sizes = {
   SMALL = {name="small", diam=10},
   MEDIUM = {name="medium", diam=12},
   LARGE = {name="large", diam=14},
   XLARGE = {name="x-large", diam=16}
}

-- roughly a struct.
local function Topping(name, crypt_code)
   assert(name)
   assert(crypt_code)
   return {
      name=name,
      crypt_code=crypt_code,
      crypt_name="topping"..crypt_code,
      side_str="toppingSide"..crypt_code,
      amt_str="toppingAmount"..crypt_code,
      isTopping=true}
end

Toppings = {
   -- MEATS
   PEPPERONI = Topping("Pepperoni","P"),
   XL_PEPPERONI = Topping("Extra Large Pepperoni","Pl"),
   SLICED_ITALIAN_SAUSAGE = Topping("Sliced Italian Sausage","Sb"),
   ITALIAN_SAUSAGE = Topping("Italian Sausage","S"),
   BEEF = Topping("Beef", "B"),
   HAM = Topping("Ham","H"),
   BACON = Topping("Bacon","K"),
   CHICKEN = Topping("Premium Chicken","Du"),
   SALAMI = Topping("Salami","Sa"),
   PHILLY_STEAK = Topping("philly-steak","Pm"),
   -- UNMEATS
   GREEN_PEPPERS = Topping("Green Peppers","G"),
   BLACK_OLIVES = Topping("Black Olives","R"),
   PINEAPPLE = Topping("Pineapple","N"),
   MUSHROOMS = Topping("Mushrooms","M"),
   ONIONS = Topping("Onions","O"),
   JALAPENOS = Topping("Jalapeno Peppers","J"),
   BANANA_PEPPERS = Topping("Banana Peppers","Z"),
   SPINACH = Topping("Spinach", "Si"),
   RED_PEPPERS = Topping("Roasted Red Peppers","Rr"),
   CHEDDAR_CHEESE = Topping("Cheddar Cheese","E"),
   PROVOLONE = Topping("Shredded Provolone Cheese","Cp"),
   PARMESAN = Topping("Shredded Parmesan","Cs"),
   FETA = Topping("Feta Cheese","Fe"),
   GARLIC = Topping("Garlic","F"),
   TOMATOES = Topping("Diced Tomatoes","Td"),
   HOT_SAUCE = Topping("Hot Sauce","Ht")
}

local function Sauce(name,crypt_code)
   assert(name)
   assert(crypt_code)
   return {
      name=name,
      crypt_code=crypt_code,
      crypt_name="topping"..crypt_code,
      side_str="toppingSide"..crypt_code,
      amt_str="toppingAmount"..crypt_code,
      isSauce = true}
end

Sauces = {
   ROBUST = Sauce("Inspired Robust Sauce","X"),
   WHITE = Sauce("White Sauce","Xw"),
   MARINARA = Sauce("Hearty Marinara Sauce","Xm"),
   BBQ = Sauce("BBQ Sauce","Bq")
}

Placement = {
   WHOLE = "W",
   LEFT = "1",
   RIGHT = "2"
}

Coverage = {
   NORMAL = "1",
   EXTRA = "1.5",
   LIGHT = ".5"
}
