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
function distribute_topping(topping, side, amount, group)
    --set up random variables
    local distribution = 1
    local slices = 8
    if(side == Sides.RIGHT or side == Sides.LEFT) then
        distribution = .5
    end

    slices = slices * distribution
    local range = 180*distribution/slices
    local toppingsPerSlice = 3
    local toppingLightGroup = Group{name = "topping_light"}
    local toppingNormalGroup = Group{name = "topping_normal"}
    local toppingExtraGroup = Group{name = "topping_extra"}
    group:add(toppingLightGroup)
    group:add(toppingNormalGroup)
    group:add(toppingExtraGroup)
    pizzagroup:add(group)

    --determine distribution
    for slice = 1, slices do
        for top = 1, toppingsPerSlice do
            local seed = math.random(toppingsPerSlice+1-top)
            local radius = top * 140 * (seed+toppingsPerSlice+1)/(toppingsPerSlice+4)
            local degrees = math.random(range)
            local angle = (degrees + range*(slice-1)) * math.pi/180
            if(side == Sides.LEFT) then
                angle = angle + math.pi * .5
            end
            local clone = Clone{source = topping}
            local x = radius*math.cos(angle)+400
            local y = -1*radius*math.sin(angle)+400
            clone.position = {x, y}
            print("radians: "..angle..", degrees: "..degrees..", radius: "..radius)
            local groupseed = math.random(3)
            if(Amount.LIGHT == groupseed) then
                toppingLightGroup:add(clone)
            elseif(Amount.NORMAL == groupseed) then
                toppingNormalGroup:add(clone)
            elseif(Amount.EXTRA == groupseed) then
                toppingExtraGroup:add(clone)
            else
                error("error: a topping was not added correctly!")
            end
        end
    end
    --TODO: add one in the very center

end
function topping_dropping(topping, side, amount, group)
    assert(topping)
    assert(side)
    assert(amount)
    --add group for type
    if(not group) then
        group = Group()
        distribute_topping(topping, side, amount, group)
    end
    --add topping to screen to make it clonable
    if not topping.parent then
        screen:add(topping)
        topping:hide()
    end

        
    --determine how many should be shown
    group:hide_all()
    group:show()
    if(Amount.LIGHT == amount) then
        assert(group:find_child("topping_light"))
        group:find_child("topping_light"):show()
    elseif(Amount.NORMAL == amount) then
        group:find_child("topping_light"):show()
        group:find_child("topping_normal"):show()
    elseif(Amount.EXTRA == amount) then
        group:show_all()
    end
end

pepporonigroup = nil
topping_dropping(topping, Sides.LEFT, Amount.NORMAL, pepporonigroup)
screen:show()
