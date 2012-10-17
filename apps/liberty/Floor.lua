
local floor = Image{ src = "tronlight.png", tile = {true,true}}

local tile_w = floor.w
local tile_h = floor.h

floor:set{w = 2*screen_w, h = screen_h, scale = {2,2}}

tile_w = tile_w * floor.scale[1]
tile_h = tile_h * floor.scale[2]

floor.position     = {screen_w/2,screen_h*1.3}
floor.anchor_point = {floor.w/2,floor.h}
floor.x_rotation   = { 70,0,0}

floor.cycle_right = function()
    floor:animate{
        mode = "EASE_IN_QUAD",
        duration = 250,
        x = floor.x + tile_w,
        on_completed = function() floor.x = floor.x - tile_w end
    }
end
floor.cycle_left = function()
    floor:animate{
        mode = "EASE_IN_QUAD",
        duration = 250,
        x = floor.x - tile_w,
        on_completed = function() floor.x = floor.x + tile_w end
    }
end


screen:add(floor)

return floor