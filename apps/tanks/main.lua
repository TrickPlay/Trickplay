dofile("terrain.lua")


local terrain_refine = 8

make_terrain(terrain_refine)
draw_terrain()

function screen:on_key_down(key)
	if key ~= keys.Return then return end

	make_terrain(terrain_refine)
	draw_terrain()
end
