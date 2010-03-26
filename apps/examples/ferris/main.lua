dofile("ferris.lua")

screen:show_all()

local trickplay_red = "960A04"

local items = {}

local make_tile = function(name)
	local item = Group {}
	local image= Image { position = { 2, 2 }, src = "letters/"..name..".png" }
	item.size = { image.w+4, image.h+4 }
	local bground = Rectangle { size = { image.w+4, image.h+4 }, z = -1, color = trickplay_red }
	item:add(bground)
	item:add(image)
	return item
end

local letters = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
letters:gsub(".",	function(c)
						table.insert(items, make_tile(c))
					end)

local ferris = Ferris.new( 700, items, -60 )

ferris.ferris.x = screen.w/3
ferris.ferris.y = screen.h/2
ferris.ferris.z = -900

screen:add(ferris.ferris)

-- 1 is forward, -1 is backward
local direction = 1

function screen.on_key_down(screen, key)

	if key >= keys["1"] and key <= keys["9"] then
		ferris:rotate(direction*(key - keys["0"]), 1500)
	elseif key == keys["minus"] then
		direction = -direction
	end

end
