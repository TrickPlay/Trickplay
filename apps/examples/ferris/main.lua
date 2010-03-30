dofile("ferris.lua")

screen:show_all()

local trickplay_red = "960A04"

local items = {}

local make_tile = function(name)
	local item = Group { }
	local image = Image { src = "assets/"..name.."-off.png" }
	item:add(image)

	local label= Text { text = name, font="Graublau Web,DejaVu Sans,Sans 58px", color="FFFFFF" }
	label.x = (image.w - label.w) - 20
	label.y = (image.h - label.h) / 2
	label.z = 1

	item:add(label)

	return item
end

local games =
				{
					"Bedazzled",
					"Billiards",
					"Chess",
					"Frogger",
					"Games",
					"Rat Race",
					"Space Invaders",
					"Tetris",
				}

local game
for _,game in ipairs(games) do
	table.insert(items, make_tile(game))
end
for _,game in ipairs(games) do
	table.insert(items, make_tile(game))
end
for _,game in ipairs(games) do
	table.insert(items, make_tile(game))
end

local ferris = Ferris.new( 22*#items, items, -30 )

ferris.ferris.x = -(18*#items)*math.cos(math.rad(ferris.ferris.y_rotation[1]))
ferris.ferris.y = screen.h/2
ferris.ferris.z = (64*#items)*math.sin(math.rad(ferris.ferris.y_rotation[1]))

screen:add(ferris.ferris)

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer:load('jeopardy.mp4')

-- 1 is forward, -1 is backward
local direction = 1

function screen.on_key_down(screen, key)

	if key >= keys["1"] and key <= keys["9"] then
		ferris:rotate( direction * (key - keys["0"]) )
	elseif key == keys["minus"] then
		direction = -direction
	elseif key == keys["CHAN_UP"] then
		ferris:rotate( 3 )
	elseif key == keys["CHAN_DOWN"] then
		ferris:rotate( -3 )
	elseif key == keys["Up"] then
		ferris:rotate( 1 )
	elseif key == keys["Down"] then
		ferris:rotate( -1 )
	elseif key == keys["Return"] then
		print(ferris:get_active(),":",items[ferris:get_active()].children[2].text)
	end

end
