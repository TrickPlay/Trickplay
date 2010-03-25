dofile("ferris.lua")

screen:show_all()

local trickplay_red = "960A04"


local NUM_ITEMS = 27

local items = {}
for i = 1,NUM_ITEMS do
	table.insert( items, Image { size = { 160, 90 }, src = "trickplay_logo_dark_bg.png" } )
end

local ferris = Ferris.new( 300, items, -60 )

ferris.ferris.x = screen.w/3
ferris.ferris.y = screen.h/2

screen:add(ferris.ferris)

function screen.on_key_down(screen, key)
	ferris:rotate(3, 1500)
end
