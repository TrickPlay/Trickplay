local g = ... 


local image0 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {1332,453,0},
		size = {128,128},
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


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {826,447,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone6.extra.focus = {}

function clone6:on_key_down(key)
	if clone6.focus[key] then
		if type(clone6.focus[key]) == "function" then
			clone6.focus[key]()
		elseif screen:find_child(clone6.focus[key]) then
			if clone6.clear_focus then
				clone6.clear_focus(key)
			end
			screen:find_child(clone6.focus[key]):grab_key_focus()
			if screen:find_child(clone6.focus[key]).set_focus then
				screen:find_child(clone6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone6.extra.reactive = true


local clone7 = Clone
	{
		scale = {1,1,0,0},
		source = clone6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {224,429,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone7.extra.focus = {}

function clone7:on_key_down(key)
	if clone7.focus[key] then
		if type(clone7.focus[key]) == "function" then
			clone7.focus[key]()
		elseif screen:find_child(clone7.focus[key]) then
			if clone7.clear_focus then
				clone7.clear_focus(key)
			end
			screen:find_child(clone7.focus[key]):grab_key_focus()
			if screen:find_child(clone7.focus[key]).set_focus then
				screen:find_child(clone7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone7.extra.reactive = true


local clone8 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = clone7,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {845,122,0},
		size = {128,128},
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


local image9 = Image
	{
		src = "/assets/images/icicles.png",
		clip = {0,0,160,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image9",
		position = {1058,-10,0},
		size = {160,131},
		opacity = 255,
		reactive = true,
	}

image9.extra.focus = {}

function image9:on_key_down(key)
	if image9.focus[key] then
		if type(image9.focus[key]) == "function" then
			image9.focus[key]()
		elseif screen:find_child(image9.focus[key]) then
			if image9.clear_focus then
				image9.clear_focus(key)
			end
			screen:find_child(image9.focus[key]):grab_key_focus()
			if screen:find_child(image9.focus[key]).set_focus then
				screen:find_child(image9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image9.extra.reactive = true


local clone12 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {604,-15,0},
		size = {160,131},
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
		scale = {0.8,0.8,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {1349,380,0},
		size = {128,128},
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


local clone5 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {845,50,0},
		size = {128,127.99999237061},
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


local clone14 = Clone
	{
		scale = {0.8,0.8,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {1343,303,0},
		size = {128,128},
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


local image15 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image15",
		position = {1362,263,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image15.extra.focus = {}

function image15:on_key_down(key)
	if image15.focus[key] then
		if type(image15.focus[key]) == "function" then
			image15.focus[key]()
		elseif screen:find_child(image15.focus[key]) then
			if image15.clear_focus then
				image15.clear_focus(key)
			end
			screen:find_child(image15.focus[key]):grab_key_focus()
			if screen:find_child(image15.focus[key]).set_focus then
				screen:find_child(image15.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image15.extra.reactive = true


local clone16 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone16",
		position = {236,362,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone16.extra.focus = {}

function clone16:on_key_down(key)
	if clone16.focus[key] then
		if type(clone16.focus[key]) == "function" then
			clone16.focus[key]()
		elseif screen:find_child(clone16.focus[key]) then
			if clone16.clear_focus then
				clone16.clear_focus(key)
			end
			screen:find_child(clone16.focus[key]):grab_key_focus()
			if screen:find_child(clone16.focus[key]).set_focus then
				screen:find_child(clone16.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone16.extra.reactive = true


local clone17 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {219,290,0},
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


g:add(image0,clone6,clone7,clone8,image9,clone12,clone13,clone5,clone14,image15,clone16,clone17)