local g = ... 


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,400,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1200,536,0},
		size = {400,55},
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


local image5 = Image
	{
		src = "/assets/images/monster.png",
		clip = {0,0,222,231},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {0,0,0},
		anchor_point = {111,231},
		name = "image5",
		position = {451,585,0},
		size = {222,231},
		opacity = 255,
		reactive = true,
	}

image5.extra.focus = {}

function image5:on_key_down(key)
	if image5.focus[key] then
		if type(image5.focus[key]) == "function" then
			image5.focus[key]()
		elseif screen:find_child(image5.focus[key]) then
			if image5.clear_focus then
				image5.clear_focus(key)
			end
			screen:find_child(image5.focus[key]):grab_key_focus()
			if screen:find_child(image5.focus[key]).set_focus then
				screen:find_child(image5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image5.extra.reactive = true


g:add(image3,image5)