
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not BUTTON            then dofile("Button/Button.lua")                 end


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

local parameters = {w = 300,h = 150,style = Style(),label = "testing",focused = true,selected=true}

s  = Style()
b  = Button()
b2 = Button(parameters)
button_test_group:add(b,b2)
local button_tests = {
    ----------------------------------------------------------------------------
    -- check the default setup of button
    function() return      b.reactive == true                 end,
    function() return      b.focused  == false                end,
    --function() return      b.type     == "BUTTON"             end,
    function() return type(b.style)   == "table"              end,
    function() return type(b.states)  == "table"              end,
    function() return type(b.w)       == "number" and b.w > 0 end,
    function() return type(b.h)       == "number" and b.w > 0 end,
    function() return type(b.label)   == "string"             end,
    ----------------------------------------------------------------------------
    -- check that initial parameters were set
    function() return b2.focused == parameters.focused end,
    function() return b2.style   == parameters.style   end,
    function() return b2.w       == parameters.w       end,
    function() return b2.h       == parameters.h       end,
    function() return b2.label   == parameters.label   end,
    ----------------------------------------------------------------------------
    -- check that overwriting intial parameters works
    function() b2.focused = true   return b2.focused == true             end,
    function() b2.style   = s      return b2.style   == s                end,
    function() b2.images  = images return b2.w       == images.default.w end,
    function() b2.w       = 400    return b2.w       == 400              end,
    function() b2.h       = 200    return b2.h       == 200              end,
    function() b2.label   = "new"  return b2.label   == "new"            end,
    function() b2.images  = nil    return b2.images  ~= images and b2.images  ~= nil end,
    ----------------------------------------------------------------------------
    -- key & key focus events
    function() -- checks that key events get set
        
        local flag = false
        
        b:add_key_handler(keys.A,function() flag = true end)
        
        b:on_key_down(keys.A)
        
        return flag
        
    end,
    function() -- checks that grabbing key focus sets focus
        screen:grab_key_focus()
        b:grab_key_focus()
        
        return b.focused
        
    end,
    function() -- checks that grabbing key focus sets focus
        b:grab_key_focus()
        screen:grab_key_focus()
        
        return not b.focused
        
    end,
    ----------------------------------------------------------------------------
    -- focus events
    function() -- checks that press calls the callback
        
        local flag = false
        
        function b:on_focus_in() flag = true end
        
        b.focused = false
        
        if flag then return false end
        
        b.focused = true
        
        return flag
        
    end,
    function() -- checks that press doesn't press if pressed
        
        local count = 0
        
        function b:on_focus_in() count = count + 1 end
        
        b.focused = false
        if count ~= 0 then return false end
        b.focused = true
        b.focused = true
        b.focused = true
        
        return count == 1
        
    end,
    function() -- checks that release calls the callback
        
        local flag = false
        
        function b:on_focus_out() flag = true end
        
        b.focused = true
        
        if flag then return false end
        
        b.focused = false
        
        return flag
        
    end,
    function() -- checks that release doesn't release if not pressed
        
        local count = 0
        
        function b:on_focus_out() count = count + 1 end
        
        b.focused = true
        if count ~= 0 then return false end
        b.focused = false
        b.focused = false
        b.focused = false
        
        return count == 1
        
    end,
    ----------------------------------------------------------------------------
    -- press events
    function() -- checks that press calls the callback
        
        local flag = false
        
        function b:on_pressed() flag = true end
        
        b:release()
        if flag then return false end
        b:press()
        
        return flag
        
    end,
    function() -- checks that press doesn't press if pressed
        
        local count = 0
        
        
        function b:on_pressed() count = count + 1 end
        
        b:release()
        if count ~= 0 then return false end
        b:press()
        b:press()
        b:press()
        
        return count == 1
        
    end,
    function() -- checks that release calls the callback
        
        local flag = false
        
        function b:on_released() flag = true end
        
        b:press()
        if flag then return false end
        b:release()
        
        return flag
        
    end,
    function() -- checks that release doesn't release if not pressed
        
        local count = 0
        
        
        function b:on_released() count = count + 1 end
        
        b:press()
        if count ~= 0 then return false end
        b:release()
        b:release()
        b:release()
        
        return count == 1
        
    end,
    --[[
    function() -- checks that click works
        
        local flag1 = false
        local flag2 = false
        
        
        b:release()
        
        function b:on_pressed()  flag1 = true end
        function b:on_released() flag2 = true end
        
        b:click()
        
        return flag1 and flag2
        
    end,
    --]]
}

for i,test in ipairs(button_tests) do
    
    if not test() then print("button_test "..i.." failed") end
    
end




button_test_group:unparent()




--------------------------------------------------------------------------------
-- Working example














---[[
local style = {
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
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
--]]
screen:show()


b1 = Button()

--------------------------------------------------------------------------------
b2 = Button{x = 100,y = 200, label = "LABEL"}--,style = style}
b2.style = style
b2.style.text.x_offset = 200
b2.style.text.y_offset = -50
b2.label = "lAbel"
--------------------------------------------------------------------------------
b3 = Button{x = 100,y = 400, label = "new_label",style = style, h = 100}

b3.w = 400
--------------------------------------------------------------------------------
b4 = Button{
    x = 200,y = 600,
    images = {
        default = "Button/button3.png",
        focus   = "Button/button-focus.png"
    },
    h = 150
}
b4.w = 300
print(b4.h)
--------------------------------------------------------------------------------
style.text.font = "Sans Bold 40px"
b5 = Button{y=900}

b5:from_json(    b3:to_json()   )
print(b3:to_json())
print(b5:to_json())
b5.y = 700
screen:add(Rectangle{size = screen.size, color = "000033"},b0,b1,b2,b3,b4,b5)

controllers:start_pointer()