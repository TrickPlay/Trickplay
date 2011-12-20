local g = ... 


local image0 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,0,475.00012207031,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {863,201,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
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

image0.extra.reactive = true


local clone1 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone1",
		position = {1601,409,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

clone1.extra.focus = {}

function clone1:on_key_down(key)
	if clone1.focus[key] then
		if type(clone1.focus[key]) == "function" then
			clone1.focus[key]()
		elseif screen:find_child(clone1.focus[key]) then
			if clone1.clear_focus then
				clone1.clear_focus(key)
			end
			screen:find_child(clone1.focus[key]):grab_key_focus()
			if screen:find_child(clone1.focus[key]).set_focus then
				screen:find_child(clone1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone1.extra.reactive = true


g:add(image0,clone1)