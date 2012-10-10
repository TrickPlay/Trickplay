
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
--]]
--[[
local rbg_group = Group()

local rbg_tests = {

    -- selected events
    function() -- checks that giving RBG a string pulls the existing RBG with that string as a name
        
        return RadioButtonGroup("Radio") == RadioButtonGroup("Radio") and
            RadioButtonGroup("Radio").name == "Radio"
        
    end,
    function() -- checks setting the .group attribute sets up an RBG
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        
        rbg_group:add(b1,b2)
        
        return b1.group == b2.group and b1.group.name == "Radio"and b2.group.name == "Radio"
        
    end,
    function() -- checks setting up RBG acutal links the .groups
        
        local b1 = ToggleButton()
        local b2 = ToggleButton()
        
        rbg_group:add(b1,b2)
        
        local rbg = RadioButtonGroup{items={b1,b2},name="Radio"}
        
        return b1.group == b2.group and b1.group.name == "Radio"and b2.group.name == "Radio"
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{selected = true, group = "Radio"}
        local b2 = ToggleButton{selected = true, group = "Radio"}
        
        rbg_group:add(b1,b2)
        
        return not b1.selected and b2.selected and
            RadioButtonGroup("Radio").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        
        rbg_group:add(b1,b2)
        
        b1.selected = false
        b2.selected = false
        
        b1.selected = true
        b2.selected = true
        
        return not b1.selected and b2.selected and
            RadioButtonGroup("Radio").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        
        rbg_group:add(b1,b2)
        
        b1.selected = false
        b2.selected = false
        
        RadioButtonGroup("Radio").selected = 2
        
        return not b1.selected and b2.selected
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton{group = "Radio"}
        
        rbg_group:add(b1,b2,b3)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        
        b2.group = nil
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        
        return not b1.selected and b2.selected and b3.selected and
            RadioButtonGroup("Radio").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton{group = "Radio"}
        
        rbg_group:add(b1,b2,b3)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        
        RadioButtonGroup("Radio"):remove(b2)
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        
        return not b1.selected and b2.selected and b3.selected and
            RadioButtonGroup("Radio").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton()
        
        rbg_group:add(b1,b2,b3)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        
        b3.group = "Radio"
        
        
        return not b1.selected and not b2.selected and b3.selected and
            RadioButtonGroup("Radio").selected == 3
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton()
        
        rbg_group:add(b1,b2,b3)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        
        RadioButtonGroup("Radio"):insert(b3)
        
        return not b1.selected and not b2.selected and b3.selected and
            RadioButtonGroup("Radio").selected == 3
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton{group = "Radio"}
        local b4 = ToggleButton{group = "Radio2"}
        
        rbg_group:add(b1,b2,b3,b4)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        b4.selected = false
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        b4.selected = true
        
        b3.group = "Radio2"
        
        return not b1.selected and not b2.selected  and not b4.selected and b3.selected and
            RadioButtonGroup("Radio2").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton{group = "Radio"}
        local b4 = ToggleButton{group = "Radio2"}
        
        rbg_group:add(b1,b2,b3,b4)
        
        b1.selected = false
        b2.selected = false
        b3.selected = false
        b4.selected = false
        
        b1.selected = true
        b2.selected = true
        b3.selected = true
        b4.selected = true
        
        RadioButtonGroup("Radio2"):insert(b3)
        
        return not b1.selected and not b2.selected  and not b4.selected and b3.selected and
            RadioButtonGroup("Radio2").selected == 2
        
    end,
    function() -- checks an RBG performs mutex toggling
        
        local b1 = ToggleButton{group = "Radio"}
        local b2 = ToggleButton{group = "Radio"}
        local b3 = ToggleButton{group = "Radio2"}
        local b4 = ToggleButton{group = "Radio2"}
        
        rbg_group:add(b1,b2,b3,b4)
        
        local rbg  = RadioButtonGroup("Radio")
        local rbg2 = RadioButtonGroup("Radio2")
        
        local temp = rbg.items
        rbg.items = rbg2.items
        rbg2.items = temp
        
        
        return b1.group == rbg2 and b2.group == rbg2 and
            b3.group == rbg and b4.group == rbg
        
    end,
}

screen:add(rbg_group)

for i,test in ipairs(rbg_tests) do
    
    if not test() then print("toggle_test "..i.." failed") end
    
    rbg_group:clear()
    collectgarbage("collect")
    RadioButtonGroup_nil()
end

rbg_group:unparent()

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

b0 = WL.ToggleButton{ label="b0", x = 1400,         group = "Radio"}
b1 = WL.ToggleButton{ label="b1", x = 1400, y= 100, group = "Radio"}


b2 = WL.ToggleButton{ label="b2",  x = 1600,         }
b3 = WL.ToggleButton{ label="b3",  x = 1600, y= 100, }
b4 = WL.ToggleButton{ label="b4",  x = 1600, y= 200, }

rbg = WL.RadioButtonGroup{items={b2,b3,b4}, name = "Radio"} -- should get renamed to Radio (1)
--rbg:remove(b3)
rbg.on_selection_change = print
b3.group = "Radio"


screen:add(b0,b1,b2,b3,b4)

controllers:start_pointer()










