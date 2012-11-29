
--[[
local button_test_group = Group{}

screen:add( button_test_group )



images_src = {
    default = "Button/button3.png",
    focus   = "Button/button-focus.png"
}

images = {
    default = Image{src="Button/button3.png"},
    focus   = Image{src="Button/button-focus.png"}
}



--local b, b2, s

local parameters = {w = 300,h = 150,style = Style(),label = "testing",focused = true,selected=true}

s  = Style()
b = ToggleButton()
b2 = ToggleButton(parameters)
button_test_group:add(b,b2)

local toggle_tests = {
    ----------------------------------------------------------------------------
    -- check the default setup of button
    function() return      b.selected  == false                end,
    ----------------------------------------------------------------------------
    -- check that initial parameters were set
    function() return b2.selected == parameters.selected end,
    ----------------------------------------------------------------------------
    -- selected events
    function() -- checks that press calls the callback
        
        local flag = false
        
        function b:on_selection() flag = true end
        
        b.selected = false
        
        if flag then return false end
        
        b.selected = true
        
        return flag
        
    end,
    function() -- checks that press doesn't press if pressed
        
        local count = 0
        
        function b:on_selection() count = count + 1 end
        
        b.selected = false
        if count ~= 0 then return false end
        b.selected = true
        b.selected = true
        b.selected = true
        
        return count == 1
        
    end,
    function() -- checks that release calls the callback
        
        local flag = false
        
        function b:on_deselection() flag = true end
        
        b.selected = true
        
        if flag then return false end
        
        b.selected = false
        
        return flag
        
    end,
    function() -- checks that release doesn't release if not pressed
        
        local count = 0
        
        function b:on_deselection() count = count + 1 end
        
        b.selected = true
        if count ~= 0 then return false end
        b.selected = false
        b.selected = false
        b.selected = false
        
        return count == 1
        
    end,
}



for i,test in ipairs(toggle_tests) do
    
    if not test() then print("toggle_test "..i.." failed") end
    
end
--]]
--[[
for i,test in ipairs(button_tests) do
    
    if not test() then print("button_test "..i.." failed") end
    
end

button_test_group:unparent()
--]]






local style = {
    text = {
        font = "Sans 50px",
        colors = {
        default    = {255,255,155},
        focus      = {255,255,155},
        activation = {155,255,255}
    }
    },
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
}



screen:show()
print("ssssssssssssssssssssssssssssssssss")
---[[
b0 = WL.ToggleButton()
b0.x = 400

b1 = WL.ToggleButton{x=400,y=100,style = style,selected = false, label = "text",reactive=true}

b2 = WL.ToggleButton{x=400,y=200,style = style,selected = true,enabled = false,reactive=true}

--]]
b3 = WL.ToggleButton{
    name = "B2",
    x = 600,y = 0,
    empty_icon  = Image{src="Button/strike-off.png"},
    filled_icon = Image{src="Button/strike-on.png",x=-8,y=-8},
    images = {
        default = Image{src="Button/button3.png"},
        focus   = Image{src="Button/button-focus.png"},
    },
    reactive=true
}

--]]
print("tttttttttttttttttttttttttttttttttt")



screen:add(b0,b1,b2,b3)

b0.reactive = true
b1.reactive = true
b2.reactive = true
b3.reactive = true

controllers:start_pointer()










