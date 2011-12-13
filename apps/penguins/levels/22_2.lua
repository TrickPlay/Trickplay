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
		position = {1835,279,0},
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


local clone1 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone1",
		position = {1741,280,0},
		size = {128,128},
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


local clone2 = Clone
	{
		scale = {1,1,0,0},
		source = clone1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone2",
		position = {1647,280,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone2.extra.focus = {}

function clone2:on_key_down(key)
	if clone2.focus[key] then
		if type(clone2.focus[key]) == "function" then
			clone2.focus[key]()
		elseif screen:find_child(clone2.focus[key]) then
			if clone2.clear_focus then
				clone2.clear_focus(key)
			end
			screen:find_child(clone2.focus[key]):grab_key_focus()
			if screen:find_child(clone2.focus[key]).set_focus then
				screen:find_child(clone2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone2.extra.reactive = true


local clone3 = Clone
	{
		scale = {1,1,0,0},
		source = clone2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone3",
		position = {1555,280,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone3.extra.focus = {}

function clone3:on_key_down(key)
	if clone3.focus[key] then
		if type(clone3.focus[key]) == "function" then
			clone3.focus[key]()
		elseif screen:find_child(clone3.focus[key]) then
			if clone3.clear_focus then
				clone3.clear_focus(key)
			end
			screen:find_child(clone3.focus[key]):grab_key_focus()
			if screen:find_child(clone3.focus[key]).set_focus then
				screen:find_child(clone3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone3.extra.reactive = true


local clone4 = Clone
	{
		scale = {1,1,0,0},
		source = clone3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {826,280,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone4.extra.focus = {}

function clone4:on_key_down(key)
	if clone4.focus[key] then
		if type(clone4.focus[key]) == "function" then
			clone4.focus[key]()
		elseif screen:find_child(clone4.focus[key]) then
			if clone4.clear_focus then
				clone4.clear_focus(key)
			end
			screen:find_child(clone4.focus[key]):grab_key_focus()
			if screen:find_child(clone4.focus[key]).set_focus then
				screen:find_child(clone4.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone4.extra.reactive = true


local clone5 = Clone
	{
		scale = {0.75,0.75,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {1184,482,0},
		size = {128,128},
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


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {734,280,0},
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
		position = {641,280,0},
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
		position = {366,480,0},
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
		position = {1161,-12,0},
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


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {64,280,0},
		size = {128,128},
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


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = clone10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {-29,280,0},
		size = {128,128},
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
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {330,-20,0},
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
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {1462,280,0},
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


g:add(image0,clone1,clone2,clone3,clone4,clone5,clone6,clone7,clone8,image9,clone10,clone11,clone12,clone13)