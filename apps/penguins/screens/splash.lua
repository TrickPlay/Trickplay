local g = ... 


local image0 = Image
	{
		src = "/assets/images/splash.jpg",
		clip = {0,0,1920,1080},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {0,0,0},
		size = {1920,1080},
		opacity = 255,
		reactive = false,
	}

image0.extra.focus = {}

function image0:on_key_down(key)
	if image0.focus[key] then
		if type(image0.focus[key]) == "function" then
			image0.focus[key]()
		elseif screen:find_child(image0.focus[key]) then
			if image0.clear_focus then
				image0.clear_focus(key)
			end
			screen:find_child(image0.focus[key]):grab_key_focus()
			if screen:find_child(image0.focus[key]).set_focus then
				screen:find_child(image0.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

function image0:on_key_down(key)
	if key == keys.OK then
		next_level()
		screen:grab_key_focus()
	end
end

image0.extra.reactive = false


g:add(image0)