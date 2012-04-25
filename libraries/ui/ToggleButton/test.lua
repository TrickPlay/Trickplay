
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not BUTTON            then dofile("Button/Button.lua")                 end
if not TOGGLEBUTTON      then dofile("ToggleButton/ToggleButton.lua")     end



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
--[[
for i,test in ipairs(button_tests) do
    
    if not test() then print("button_test "..i.." failed") end
    
end
--]]

button_test_group:unparent()






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

b0 = ToggleButton()

b0.x = 400
b1 = ToggleButton{x=400,y=100,style = style,selected = false, label = "text"}
b2 = ToggleButton{x=400,y=200,style = style,selected = true}

b3 = ToggleButton{
    name = "B2",
    x = 600,y = 0,
    images = {
        default = Group{ children={Image{src="Button/button3.png"},Image{src="Button/strike-off.png"}}},
        focus   = Group{children={Image{src="Button/button-focus.png"},Image{src="Button/strike-off.png"}}},
        selection = Image{src="Button/strike-on.png",x=-8,y=-8},
    },
}





screen:add(b0,b1,b2,b3)

controllers:start_pointer()










