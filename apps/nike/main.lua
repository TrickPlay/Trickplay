local opaque = 255*2/3

local images = {
		['2'] = Image { src = "assets/splash_image.png", keep_aspect_ratio = true, y = - 300, width = screen.w, opacity = 0 },
		['3'] = Image { src = "assets/unselected_players.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['4'] = Image { src = "assets/1_stephen_ames.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['5'] = Image { src = "assets/2_paul_casey.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['6'] = Image { src = "assets/3_stewart_cink.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['7'] = Image { src = "assets/4_david_duval.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['8'] = Image { src = "assets/5_anthony_kim.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['9'] = Image { src = "assets/6_justin_leonard.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['10'] = Image { src = "assets/7_carl_pettersson.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
		['11'] = Image { src = "assets/8_tiger_woods.png", keep_aspect_ratio = true, width = screen.w, opacity = 0 },
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

images['2'].y = -images['2'].h

local state =
	{
		state = "1",
		['0'] = function () end,
		['1'] = function()
					images['2']:animate( { duration = 500, opacity = 0, y = -images['2'].h, mode = "EASE_OUT_SINE" })
				end,
		['2'] = function( self )
							images['2']:animate( { duration = 500, opacity = opaque, y = 0, mode = "EASE_OUT_BACK" } )
							images['3']:animate( { duration = 250, opacity = 0 } )
							self.state = "2"
						end,
		['10'] = function ( self )
					images['9']:animate( { duration = 250, opacity = 0 } )
					images['10']:animate( { duration = 250, opacity = opaque } )
					images['11']:animate( { duration = 250, opacity = 0 } )
					products:animate( { duration = 250, opacity = 0 } )
					self.state = "10"
				end,
		['11'] = function ( self )
						images['10']:animate( { duration = 250, opacity = 0 } )
						images['11']:animate( { duration = 250, opacity = opaque } )
						products:animate( { duration = 250, opacity = opaque } )
						self.state = "11"
				end,
		['12'] = function ( self ) end,
	}
setmetatable(state, {
	__index = function (table,key)
		return function ( self, newstate )
			images[tostring(tonumber(key)-1)]:animate( { duration = 250, opacity = 0 } )
			images[tostring(key)]:animate( { duration = 250, opacity = opaque } )
			images[tostring(tonumber(key)+1)]:animate( { duration = 250, opacity = 0 } )
			rawset(self,"state",newstate)
		end
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
	if key == keys.Right then
		state[tostring(tonumber(state.state)+1)](state,tostring(tonumber(state.state)+1))
	elseif key == keys.Left then
		state[tostring(tonumber(state.state)-1)](state,tostring(tonumber(state.state)-1))
	end
end
