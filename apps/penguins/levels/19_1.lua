local g = ... 


local image2 = Image
	{
		src = "/assets/images/fish-blue.png",
		clip = {0,0,94,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image2",
		position = {1051,251,0},
		size = {94,55},
		opacity = 255,
		reactive = true,
	}

image2.extra.focus = {}

function image2:on_key_down(key)
	if image2.focus[key] then
		if type(image2.focus[key]) == "function" then
			image2.focus[key]()
		elseif screen:find_child(image2.focus[key]) then
			if image2.clear_focus then
				image2.clear_focus(key)
			end
			screen:find_child(image2.focus[key]):grab_key_focus()
			if screen:find_child(image2.focus[key]).set_focus then
				screen:find_child(image2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image2.extra.reactive = true


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,1100,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {600,536,0},
		size = {1100,55},
		opacity = 255,
		reactive = true,
	}

image3.extra.focus = {}

function image3:on_key_down(key)
	if image3.focus[key] then
		if type(image3.focus[key]) == "function" then
			image3.focus[key]()
		elseif screen:find_child(image3.focus[key]) then
			if image3.clear_focus then
				image3.clear_focus(key)
			end
			screen:find_child(image3.focus[key]):grab_key_focus()
			if screen:find_child(image3.focus[key]).set_focus then
				screen:find_child(image3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image3.extra.reactive = true


g:add(image2,image3)