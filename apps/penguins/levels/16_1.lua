local g = ... 


local image16 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image16",
		position = {1839,458,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image16.extra.focus = {}

function image16:on_key_down(key)
	if image16.focus[key] then
		if type(image16.focus[key]) == "function" then
			image16.focus[key]()
		elseif screen:find_child(image16.focus[key]) then
			if image16.clear_focus then
				image16.clear_focus(key)
			end
			screen:find_child(image16.focus[key]):grab_key_focus()
			if screen:find_child(image16.focus[key]).set_focus then
				screen:find_child(image16.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image16.extra.reactive = true


local clone17 = Clone
	{
		scale = {1,1,0,0},
		source = image16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {1745,462,0},
		size = {128,128},
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


local clone18 = Clone
	{
		scale = {1,1,0,0},
		source = clone17,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone18",
		position = {1463,270,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone18.extra.focus = {}

function clone18:on_key_down(key)
	if clone18.focus[key] then
		if type(clone18.focus[key]) == "function" then
			clone18.focus[key]()
		elseif screen:find_child(clone18.focus[key]) then
			if clone18.clear_focus then
				clone18.clear_focus(key)
			end
			screen:find_child(clone18.focus[key]):grab_key_focus()
			if screen:find_child(clone18.focus[key]).set_focus then
				screen:find_child(clone18.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone18.extra.reactive = true


local clone19 = Clone
	{
		scale = {1,1,0,0},
		source = clone18,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone19",
		position = {1368,268,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone19.extra.focus = {}

function clone19:on_key_down(key)
	if clone19.focus[key] then
		if type(clone19.focus[key]) == "function" then
			clone19.focus[key]()
		elseif screen:find_child(clone19.focus[key]) then
			if clone19.clear_focus then
				clone19.clear_focus(key)
			end
			screen:find_child(clone19.focus[key]):grab_key_focus()
			if screen:find_child(clone19.focus[key]).set_focus then
				screen:find_child(clone19.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone19.extra.reactive = true


local clone20 = Clone
	{
		scale = {1,1,0,0},
		source = clone19,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone20",
		position = {1109,458,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone20.extra.focus = {}

function clone20:on_key_down(key)
	if clone20.focus[key] then
		if type(clone20.focus[key]) == "function" then
			clone20.focus[key]()
		elseif screen:find_child(clone20.focus[key]) then
			if clone20.clear_focus then
				clone20.clear_focus(key)
			end
			screen:find_child(clone20.focus[key]):grab_key_focus()
			if screen:find_child(clone20.focus[key]).set_focus then
				screen:find_child(clone20.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone20.extra.reactive = true


local clone22 = Clone
	{
		scale = {1,1,0,0},
		source = image16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone22",
		position = {917,459,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone22.extra.focus = {}

function clone22:on_key_down(key)
	if clone22.focus[key] then
		if type(clone22.focus[key]) == "function" then
			clone22.focus[key]()
		elseif screen:find_child(clone22.focus[key]) then
			if clone22.clear_focus then
				clone22.clear_focus(key)
			end
			screen:find_child(clone22.focus[key]):grab_key_focus()
			if screen:find_child(clone22.focus[key]).set_focus then
				screen:find_child(clone22.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone22.extra.reactive = true


local clone24 = Clone
	{
		scale = {1,1,0,0},
		source = image16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone24",
		position = {729,461,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone24.extra.focus = {}

function clone24:on_key_down(key)
	if clone24.focus[key] then
		if type(clone24.focus[key]) == "function" then
			clone24.focus[key]()
		elseif screen:find_child(clone24.focus[key]) then
			if clone24.clear_focus then
				clone24.clear_focus(key)
			end
			screen:find_child(clone24.focus[key]):grab_key_focus()
			if screen:find_child(clone24.focus[key]).set_focus then
				screen:find_child(clone24.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone24.extra.reactive = true


local clone26 = Clone
	{
		scale = {1,1,0,0},
		source = image16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone26",
		position = {541,461,0},
		size = {127,128},
		opacity = 255,
		reactive = true,
	}

clone26.extra.focus = {}

function clone26:on_key_down(key)
	if clone26.focus[key] then
		if type(clone26.focus[key]) == "function" then
			clone26.focus[key]()
		elseif screen:find_child(clone26.focus[key]) then
			if clone26.clear_focus then
				clone26.clear_focus(key)
			end
			screen:find_child(clone26.focus[key]):grab_key_focus()
			if screen:find_child(clone26.focus[key]).set_focus then
				screen:find_child(clone26.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone26.extra.reactive = true


local image27 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image27",
		position = {1042,492,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image27.extra.focus = {}

function image27:on_key_down(key)
	if image27.focus[key] then
		if type(image27.focus[key]) == "function" then
			image27.focus[key]()
		elseif screen:find_child(image27.focus[key]) then
			if image27.clear_focus then
				image27.clear_focus(key)
			end
			screen:find_child(image27.focus[key]):grab_key_focus()
			if screen:find_child(image27.focus[key]).set_focus then
				screen:find_child(image27.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image27.extra.reactive = true


local clone28 = Clone
	{
		scale = {1,1,0,0},
		source = image27,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone28",
		position = {855,492,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

clone28.extra.focus = {}

function clone28:on_key_down(key)
	if clone28.focus[key] then
		if type(clone28.focus[key]) == "function" then
			clone28.focus[key]()
		elseif screen:find_child(clone28.focus[key]) then
			if clone28.clear_focus then
				clone28.clear_focus(key)
			end
			screen:find_child(clone28.focus[key]):grab_key_focus()
			if screen:find_child(clone28.focus[key]).set_focus then
				screen:find_child(clone28.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone28.extra.reactive = true


local clone29 = Clone
	{
		scale = {1,1,0,0},
		source = image27,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone29",
		position = {667,492,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

clone29.extra.focus = {}

function clone29:on_key_down(key)
	if clone29.focus[key] then
		if type(clone29.focus[key]) == "function" then
			clone29.focus[key]()
		elseif screen:find_child(clone29.focus[key]) then
			if clone29.clear_focus then
				clone29.clear_focus(key)
			end
			screen:find_child(clone29.focus[key]):grab_key_focus()
			if screen:find_child(clone29.focus[key]).set_focus then
				screen:find_child(clone29.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone29.extra.reactive = true


g:add(image16,clone17,clone18,clone19,clone20,clone22,clone24,clone26,image27,clone28,clone29)