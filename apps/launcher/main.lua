dofile("ferris.lua")

screen:show_all()

local trickplay_red = "960A04"

local items = {}

local make_tile = function(id,name)
	local item = Group { }
	local image = Image { src = "assets/"..name.."-off.png", scale = { 0.5, 0.5 } }
	item:add(image)

	local label= Text { text = name, font="Graublau Web,DejaVu Sans,Sans 24px", color="FFFFFF" }
	label.x = (image.w/2 - label.w) - 20
	label.y = (image.h/2 - label.h) / 2
	label.z = 1

	item.extra.id = id
	item:add(label)

	return item
end

local app
for i = 1,5 do
	for _,app in pairs(apps:get_all()) do
		if(app.id ~= "com.trickplay.launcher") then
			table.insert(items, make_tile(app.id,app.name))
		end
	end
end

local ferris = Ferris.new( 11*#items, items, -30 )


ferris.ferris.x = -25*#items
ferris.ferris.y = screen.h/2
ferris.ferris.z = (16*#items)*math.sin(math.rad(ferris.ferris.y_rotation[1]))

local ferris_group = Group { children = { ferris.ferris }, z = 1 }

local backdrop = Image { src = "assets/background-1.png", z = 0,  size = { screen.w, screen.h}, opacity = 0 }
local playLabel = Text { text = "play", font="Graublau Web,DejaVu Sans,Sans 48px", color="FFFFFF", opacity = 0, y = 5, z=1 }
local getLabel  = Text { text = "get",  font="Graublau Web,DejaVu Sans,Sans 48px", color="FFFFFF", opacity = 0, y = 5, z=1 }

screen:add(backdrop)
screen:add(playLabel)
screen:add(getLabel)
screen:add(ferris_group)

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
mediaplayer:load('jeopardy.mp4')

-- 1 is forward, -1 is backward
local direction = 1

local state = "offscreen"

function screen.on_key_down(screen, key)

	-- Stuff to rotate the wheel and choose items
	if( state == "onscreen" or state == "fullscreen" ) then
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
			local active = ferris:get_active()
			-- Would launch the app here!
			print(active,":",items[active].extra.id)
			apps:launch(items[active].extra.id)
		end
	end


	-- Stuff to transition between states
	if( state == "onscreen") then
		if key == keys["Left"] or key == keys["Exit"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 500,
										x = -50*#items,
										mode = "EASE_IN_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "offscreen"
		elseif key == keys["Right"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -90,
										x = screen.w - 20,
										y = screen.h/2+70,
										z = -12*#items,
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() mediaplayer:pause() end,
									}
								)
			backdrop:animate(
								{
									duration = 1000,
									opacity = 255,
									mode = "EASE_OUT_SINE",
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-playLabel.w) - 150,
									mode = "EASE_OUT_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-getLabel.w) - 480,
									mode = "EASE_OUT_SINE",
								}
							)
			state = "fullscreen"
		end

	elseif (state == "offscreen") then
		if key == keys["Left"] or key == keys["Right"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 500,
										x = 80,
										mode = "EASE_OUT_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "onscreen"
		end

	elseif (state == "fullscreen") then
		if key == keys["Left"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -30,
										x = 80,
										z = (16*#items)*math.sin(math.rad(-30)),
										y = screen.h/2,
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() ferris:highlight() mediaplayer:play() end,
									}
								)
			backdrop:animate(
								{
									duration = 1000,
									opacity = 0,
									mode = "EASE_IN_SINE",
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 30,
									mode = "EASE_IN_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 30,
									mode = "EASE_IN_SINE",
								}
							)
			state = "onscreen"
		end
	end

end
