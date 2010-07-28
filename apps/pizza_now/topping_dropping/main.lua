pizza = Image{
    position = {0, 0},
    src = "Crust_HandTossed.png",
    name = "pizza"
}
cheese = Image{
    position = {0, 0},
    src = "Cheese_Normal.png"
}
sauce = Image{
    position = {0, 0},
    src = "Sauce_Tomato.png"
}

pizzagroup = Group{position = {500,500}}
topping = Image{
    src = "Topping_Pepperoni.png",
    name = "pepperoni"
}

Sides = {
    LEFT = 1,
    WHOLE = 2,
    RIGHT = 3
}
Amount = {
    LIGHT = 1,
    NORMAL = 2,
    EXTRA = 3,
    NONE = 4
}

pizzagroup:add(pizza)
pizzagroup:add(sauce)
pizzagroup:add(cheese)
screen:add(pizzagroup)
function distribute_topping(topping, side, amount, group, pizzagroup)
    --set up random variables
    local distribution = 1
    local slices = 8

    local range = 180/slices
    local toppingsPerSlice = 3
    --Groups for the left and right side of the pizza && amount of topping
    local toppingLightRightGroup = Group{name = "topping_light_right"}
    local toppingNormalRightGroup = Group{name = "topping_normal_right"}
    local toppingExtraRightGroup = Group{name = "topping_extra_right"}
    local toppingRightGroup = Group{name = "right_side"}

    local toppingLightLeftGroup = Group{name = "topping_light_left"}
    local toppingNormalLeftGroup = Group{name = "topping_normal_left"}
    local toppingExtraLeftGroup = Group{name = "topping_extra_left"}
    local toppingLeftGroup = Group{name = "left_side"}

    toppingRightGroup:add(toppingLightRightGroup)
    toppingRightGroup:add(toppingNormalRightGroup)
    toppingRightGroup:add(toppingExtraRightGroup)

    toppingLeftGroup:add(toppingLightLeftGroup)
    toppingLeftGroup:add(toppingNormalLeftGroup)
    toppingLeftGroup:add(toppingExtraLeftGroup)

    group:add(toppingRightGroup)
    group:add(toppingLeftGroup)

    pizzagroup:add(group)

    --determine distribution
    for slice = 1, slices do
        for top = 1, toppingsPerSlice do
            local seed = math.random(toppingsPerSlice+1-top)
            local radius = top * 140 * (seed+toppingsPerSlice+1)/(toppingsPerSlice+4)
            local degrees = math.random(range)
            local angle = (degrees + range*(slice-1)) * math.pi/180

            local clone = Clone{source = topping}
            local x = radius*math.cos(angle)+400
            local y = -1*radius*math.sin(angle)+400
            clone.position = {x, y}
            print("radians: "..angle..", degrees: "..degrees..", radius: "..radius)
            local groupseed = math.random(3)
            if(Amount.LIGHT == groupseed) then
                if(slice <= 4) then
                    toppingLightRightGroup:add(clone)
                else
                    toppingLightLeftGroup:add(clone)
                end
            elseif(Amount.NORMAL == groupseed) then
                if(slice <= 4) then
                    toppingNormalRightGroup:add(clone)
                    print("here1")
                else
                    print("here2")
                    toppingNormalLeftGroup:add(clone)
                end
            elseif(Amount.EXTRA == groupseed) then
                if(slice <= 4) then
                    toppingExtraRightGroup:add(clone)
                else
                    toppingExtraLeftGroup:add(clone)
                end
            else
                error("error: a topping was not added correctly!")
            end
        end
    end
    --TODO: add one in the very center

end
function topping_dropping(topping, side, amount, toppinggroup, pizzagroup)
    assert(topping)
    assert(side)
    assert(amount)
    assert(pizzagroup)
    --add group for type
    if(not toppinggroup) then
        toppinggroup = Group()
        distribute_topping(topping, side, amount, toppinggroup, pizzagroup)
    end
    --add topping to screen to make it clonable
    if not topping.parent then
        screen:add(topping)
        topping:hide()
    end

        
    --determine how many should be shown
    toppinggroup:find_child("right_side"):hide_all()
    toppinggroup:find_child("left_side"):hide_all()
    --show the correct side of the pizza
    if(Sides.RIGHT == side or Sides.WHOLE == side) then
        toppinggroup:find_child("right_side"):show()
    end
    if(Sides.LEFT == side or Sides.WHOLE == side) then
        toppinggroup:find_child("left_side"):show()
    end
    --show the correct amount
    if(Amount.LIGHT == amount) then
        toppinggroup:find_child("topping_light_left"):show()
        toppinggroup:find_child("topping_light_right"):show()
    elseif(Amount.NORMAL == amount) then
        toppinggroup:find_child("topping_light_left"):show()
        toppinggroup:find_child("topping_light_right"):show()
        toppinggroup:find_child("topping_normal_left"):show()
        toppinggroup:find_child("topping_normal_right"):show()
    elseif(Amount.EXTRA == amount) then
        toppinggroup:find_child("topping_light_left"):show()
        toppinggroup:find_child("topping_light_right"):show()
        toppinggroup:find_child("topping_normal_left"):show()
        toppinggroup:find_child("topping_normal_right"):show()
        toppinggroup:find_child("topping_extra_left"):show()
        toppinggroup:find_child("topping_extra_right"):show()
    end
end

pepporonigroup = nil
topping_dropping(topping, Sides.RIGHT, Amount.EXTRA, pepporonigroup, pizzagroup)
screen:show()
