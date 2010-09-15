dofile("terrain.lua")

local TERRAIN_REFINE = 2
local EXPLOSION_SIZE = 20

make_terrain(TERRAIN_REFINE)
draw_terrain()

function screen:on_key_down(key)
    if key == keys.Right then trace_terrain() return
    elseif key == keys.Down then explode_terrain_at(math.random(), EXPLOSION_SIZE) draw_terrain() return
    elseif key == keys.Return then make_terrain(TERRAIN_REFINE) draw_terrain() return
    end
end
