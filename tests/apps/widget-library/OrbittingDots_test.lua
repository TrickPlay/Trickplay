
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


screen:show()


od1 = WL.OrbittingDots()
od2 = WL.OrbittingDots{x = 200,image = "OrbittingDots/x.png",dot_size = 40,num_dots = 12, w = 100,h=100}
od3 = WL.OrbittingDots{x = 400, w = 300,h=300,num_dots = 12}


od3.image = "OrbittingDots/x.png"
od4 = WL.OrbittingDots{y = 200,num_dots = 40,animating = true}
od4.num_dots = 4
od4.num_dots = 12
od4.num_dots = 12
od4.size = {200,200}

od5 = WL.OrbittingDots{x = 400,y = 200,num_dots = 10,animating = true,style = style}
print(od1:to_json())
--[[
print(od2:to_json())
print(od3:to_json())
print(od4:to_json())
--]]
local r = Rectangle{
    size = od1.size,
    position = od1.position,
    opacity = 100
}
screen:add(r,od1,od2,od3,od4,od5)

