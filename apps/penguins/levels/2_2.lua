local g = ... 


local image2 = Image
	{
		src = "assets/images/cube-128.png",
		clip = {0,0,131,129},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image2",
		position = {420,448,0},
		size = {131.00006103516,129},
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


local clone17 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {785,240,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone17.extra.focus = {}

function clone17:on_key_down(key)
	if clone17.focus[key] then
		if type(clone17.focus[key]) == "function" then
			clone17.focus[key]()
		elseif screen:find_child(clone17.focus[key]) then
			if clone17.clear_focus then
				clone17.clear_focus(key)
			end
			screen:find_child(clone17.focus[key]):grab_key_focus()
			if screen:find_child(clone17.focus[key]).set_focus then
				screen:find_child(clone17.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone17.extra.reactive = true


local clone5 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {781,144,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone5.extra.focus = {}

function clone5:on_key_down(key)
	if clone5.focus[key] then
		if type(clone5.focus[key]) == "function" then
			clone5.focus[key]()
		elseif screen:find_child(clone5.focus[key]) then
			if clone5.clear_focus then
				clone5.clear_focus(key)
			end
			screen:find_child(clone5.focus[key]):grab_key_focus()
			if screen:find_child(clone5.focus[key]).set_focus then
				screen:find_child(clone5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone5.extra.reactive = true


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = clone5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {783,52,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone11.extra.focus = {}

function clone11:on_key_down(key)
	if clone11.focus[key] then
		if type(clone11.focus[key]) == "function" then
			clone11.focus[key]()
		elseif screen:find_child(clone11.focus[key]) then
			if clone11.clear_focus then
				clone11.clear_focus(key)
			end
			screen:find_child(clone11.focus[key]):grab_key_focus()
			if screen:find_child(clone11.focus[key]).set_focus then
				screen:find_child(clone11.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone11.extra.reactive = true


local clone12 = Clone
	{
		scale = {1,1,0,0},
		source = clone11,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {784,-41,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone12.extra.focus = {}

function clone12:on_key_down(key)
	if clone12.focus[key] then
		if type(clone12.focus[key]) == "function" then
			clone12.focus[key]()
		elseif screen:find_child(clone12.focus[key]) then
			if clone12.clear_focus then
				clone12.clear_focus(key)
			end
			screen:find_child(clone12.focus[key]):grab_key_focus()
			if screen:find_child(clone12.focus[key]).set_focus then
				screen:find_child(clone12.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone12.extra.reactive = true


local clone13 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {1133,452,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone13.extra.focus = {}

function clone13:on_key_down(key)
	if clone13.focus[key] then
		if type(clone13.focus[key]) == "function" then
			clone13.focus[key]()
		elseif screen:find_child(clone13.focus[key]) then
			if clone13.clear_focus then
				clone13.clear_focus(key)
			end
			screen:find_child(clone13.focus[key]):grab_key_focus()
			if screen:find_child(clone13.focus[key]).set_focus then
				screen:find_child(clone13.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone13.extra.reactive = true


local clone14 = Clone
	{
		scale = {1,1,0,0},
		source = clone13,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {1415,216,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone14.extra.focus = {}

function clone14:on_key_down(key)
	if clone14.focus[key] then
		if type(clone14.focus[key]) == "function" then
			clone14.focus[key]()
		elseif screen:find_child(clone14.focus[key]) then
			if clone14.clear_focus then
				clone14.clear_focus(key)
			end
			screen:find_child(clone14.focus[key]):grab_key_focus()
			if screen:find_child(clone14.focus[key]).set_focus then
				screen:find_child(clone14.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone14.extra.reactive = true


g:add(image2,clone17,clone5,clone11,clone12,clone13,clone14)