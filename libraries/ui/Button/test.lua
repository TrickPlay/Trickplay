dofile("__UTILITIES/OverrideMetatable.lua")
dofile("__CORE/ColorScheme.lua")
dofile("__CORE/Style.lua")
dofile("__CORE/Widget.lua")
dofile("Button/Button.lua")
dofile("Button/ToggleButton.lua")
---[[
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
--]]
screen:show()

b1 = ToggleButton()
b12 = ToggleButton{y=100,style = style,selected = true}

--b1.style.text.x_offset = 300
--b1.style.text.y_offset = 800
---[[
b2 = Button{x = 100,y = 200, label = "LABEL",style = style}

b2.label = "label"
b3 = Button{x = 100,y = 400, label = "LABEL",style = style, h = 100}

b3.w = 400

b4 = Button{
    x = 600,y = 200,
    images = {
        default = "button3.png",
        focus   = "button-focus.png"
    },
}
style.text.font = "Sans Bold 40px"

--]]
screen:add(Rectangle{size = screen.size, color = "222222"},b1,b12,b2,b3,b4)

controllers:start_pointer()