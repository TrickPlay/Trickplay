dofile("terrain.lua")


local terrain_refine = 2

make_terrain(terrain_refine)
draw_terrain()

function screen:on_key_down(key)
	if key == keys.Down then terrain_refine = math.max(2,terrain_refine-1)
	elseif key == keys.Up then terrain_refine = math.min(100,terrain_refine+1)
	elseif key == keys.Right then trace_terrain() return
	elseif key ~= keys.Return then return
	end

	make_terrain(terrain_refine)
	draw_terrain()
end
