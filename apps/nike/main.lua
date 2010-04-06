local opaque = 255*2/3

local images = {
		splash_image = Image { src = "assets/splash_image.png", keep_aspect_ratio = true, y = - 300, width = screen.w, opacity = 0 },
		main_bground = Image { src = "assets/unselected_players.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['1'] = Image { src = "assets/1_stephen_ames.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['2'] = Image { src = "assets/2_paul_casey.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['3'] = Image { src = "assets/3_stewart_cink.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['4'] = Image { src = "assets/4_david_duval.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['5'] = Image { src = "assets/5_anthony_kim.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['6'] = Image { src = "assets/6_justin_leonard.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['7'] = Image { src = "assets/7_carl_pettersson.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['8'] = Image { src = "assets/8_tiger_woods.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
}

local products = Group {
	children =
	{
		glove_off = Image { src = "assets/tiger-shop/NIKE-tiger-glove-off.png", position = { 0, 0 }, scale = { screen.h/1080, screen.h/1080 }},
		hat_off = Image { src = "assets/tiger-shop/NIKE-tiger-hat-off.png", position = { 0, screen.h / 3 }, scale = { screen.h/1080, screen.h/1080 } },
		more_off = Image { src = "assets/tiger-shop/NIKE-tiger-more.png", position = { 0 , 2 * screen.h / 3 }, scale = { screen.h/1080, screen.h/1080 } },
	},
	opacity = 0,
	x = 4*screen.w/5,
	y = screen.h / 5,
}

images.splash_image.y = -images.splash_image.h

local state =
	{
		next_state = "splash_image",
		off = function() end,
		splash_image = function( self )
							images.splash_image:animate( { duration = 500, opacity = opaque, y = 0, mode = "EASE_OUT_BACK" } )
							self.next_state = "main_bground"
						end,
		main_bground = function ( self )
							images.main_bground:animate( { duration = 250, opacity = opaque } )
							self.next_state = "1"
						end,
		['8'] = function ()
						images['8']:animate( { duration = 250, opacity = opaque } )
						products:animate( { duration = 250, opacity = opaque } )
				end,
	}
setmetatable(state, {
	__index = function (table,key)
		print("key:",key)
		rawset(table,"next_state",tostring(tonumber(key)+1))
		print("next_state:",rawget(table,"next_state"))
		return function () images[key]:animate( { duration = 250, opacity = opaque } ) end
	end
})

local name,image
for name,image in pairs(images) do
	screen:add(image)
end
screen:add(products)

screen:show_all()

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
mediaplayer:load("assets/golf_game.mp4")


function screen.on_key_down ( screen, key )
	local name,image
	for name,image in pairs(images) do
		if name ~= state.next_state then
			print("Fading "..name)
			image:animate( { duration = 250, opacity = 0 } )
		end
	end
	print("Next state:",state.next_state)
	state[state.next_state](state)
end
