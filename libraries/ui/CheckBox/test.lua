
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

b0 = WL.CheckBox{ label="b0", x = 1400,         group = "Radio",reactive = true}
b1 = WL.CheckBox{ label="b1", x = 1400, y= 100, group = "Radio",reactive = true}


b2 = WL.CheckBox{ label="b2",reactive = true,  x = 1600,         }
b3 = WL.CheckBox{ label="b3",reactive = true,  x = 1600, y= 100, }
b4 = WL.CheckBox{ label="b4",reactive = true,  x = 1600, y= 200, }

rbg = WL.CheckBoxGroup{items={b2,b3,b4}, name = "Radio"} -- should get renamed to Radio (1)
--rbg:remove(b3)
rbg.on_selection_change = print
b3.group = b0.group


screen:add(b0,b1,b2,b3,b4)