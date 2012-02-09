local g = ... 


local image4 = Image
	{
		src = "/assets/images/fish-blue.png",
		clip = {0,0,150.00006103516,110},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image4",
		position = {1023,222,0},
		size = {150,110},
		opacity = 255,
		reactive = true,
	}

image4.extra.focus = {}

function image4:on_key_down(key)
	if image4.focus[key] then
		if type(image4.focus[key]) == "function" then
			image4.focus[key]()
		elseif screen:find_child(image4.focus[key]) then
			if image4.clear_focus then
				image4.clear_focus(key)
			end
			screen:find_child(image4.focus[key]):grab_key_focus()
			if screen:find_child(image4.focus[key]).set_focus then
				screen:find_child(image4.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image4.extra.reactive = true


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


g:add(image4,image3)