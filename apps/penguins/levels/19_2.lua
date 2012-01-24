local g = ... 


local image17 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,0,475.00006103516,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image17",
		position = {1072,423,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

image17.extra.focus = {}

function image17:on_key_down(key)
	if image17.focus[key] then
		if type(image17.focus[key]) == "function" then
			image17.focus[key]()
		elseif screen:find_child(image17.focus[key]) then
			if image17.clear_focus then
				image17.clear_focus(key)
			end
			screen:find_child(image17.focus[key]):grab_key_focus()
			if screen:find_child(image17.focus[key]).set_focus then
				screen:find_child(image17.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image17.extra.reactive = true


local clone8 = Clone
	{
		scale = {1,1,0,0},
		source = image17,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {63,426,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

clone8.extra.focus = {}

function clone8:on_key_down(key)
	if clone8.focus[key] then
		if type(clone8.focus[key]) == "function" then
			clone8.focus[key]()
		elseif screen:find_child(clone8.focus[key]) then
			if clone8.clear_focus then
				clone8.clear_focus(key)
			end
			screen:find_child(clone8.focus[key]):grab_key_focus()
			if screen:find_child(clone8.focus[key]).set_focus then
				screen:find_child(clone8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone8.extra.reactive = true


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,500,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {286,536,0},
		size = {500,55},
		opacity = 255,
		reactive = true,
	}

image8.extra.focus = {}

function image8:on_key_down(key)
	if image8.focus[key] then
		if type(image8.focus[key]) == "function" then
			image8.focus[key]()
		elseif screen:find_child(image8.focus[key]) then
			if image8.clear_focus then
				image8.clear_focus(key)
			end
			screen:find_child(image8.focus[key]):grab_key_focus()
			if screen:find_child(image8.focus[key]).set_focus then
				screen:find_child(image8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image8.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image17,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {726,181,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

clone10.extra.focus = {}

function clone10:on_key_down(key)
	if clone10.focus[key] then
		if type(clone10.focus[key]) == "function" then
			clone10.focus[key]()
		elseif screen:find_child(clone10.focus[key]) then
			if clone10.clear_focus then
				clone10.clear_focus(key)
			end
			screen:find_child(clone10.focus[key]):grab_key_focus()
			if screen:find_child(clone10.focus[key]).set_focus then
				screen:find_child(clone10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone10.extra.reactive = true


local image11 = Image
	{
		src = "/assets/images/seal-down.png",
		clip = {0,0,131,151},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {65.5,0},
		name = "image11",
		position = {586,440,0},
		size = {131,151},
		opacity = 255,
		reactive = true,
	}

image11.extra.focus = {}

function image11:on_key_down(key)
	if image11.focus[key] then
		if type(image11.focus[key]) == "function" then
			image11.focus[key]()
		elseif screen:find_child(image11.focus[key]) then
			if image11.clear_focus then
				image11.clear_focus(key)
			end
			screen:find_child(image11.focus[key]):grab_key_focus()
			if screen:find_child(image11.focus[key]).set_focus then
				screen:find_child(image11.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image11.extra.reactive = true


g:add(image17,clone8,image8,clone10,image11)