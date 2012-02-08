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
		position = {1363,455,0},
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
		position = {1326,102,0},
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


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {846,118,0},
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


local clone22 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone22",
		position = {1360,357,0},
		size = {128,127},
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


local image24 = Image
	{
		src = "/assets/images/icicles.png",
		clip = {0,0,161,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image24",
		position = {1093,-19,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

image24.extra.focus = {}

function image24:on_key_down(key)
	if image24.focus[key] then
		if type(image24.focus[key]) == "function" then
			image24.focus[key]()
		elseif screen:find_child(image24.focus[key]) then
			if image24.clear_focus then
				image24.clear_focus(key)
			end
			screen:find_child(image24.focus[key]):grab_key_focus()
			if screen:find_child(image24.focus[key]).set_focus then
				screen:find_child(image24.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image24.extra.reactive = true


local clone25 = Clone
	{
		scale = {1,1,0,0},
		source = image24,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone25",
		position = {218,-2,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

clone25.extra.focus = {}

function clone25:on_key_down(key)
	if clone25.focus[key] then
		if type(clone25.focus[key]) == "function" then
			clone25.focus[key]()
		elseif screen:find_child(clone25.focus[key]) then
			if clone25.clear_focus then
				clone25.clear_focus(key)
			end
			screen:find_child(clone25.focus[key]):grab_key_focus()
			if screen:find_child(clone25.focus[key]).set_focus then
				screen:find_child(clone25.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone25.extra.reactive = true


local clone27 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone27",
		position = {476,452,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone27.extra.focus = {}

function clone27:on_key_down(key)
	if clone27.focus[key] then
		if type(clone27.focus[key]) == "function" then
			clone27.focus[key]()
		elseif screen:find_child(clone27.focus[key]) then
			if clone27.clear_focus then
				clone27.clear_focus(key)
			end
			screen:find_child(clone27.focus[key]):grab_key_focus()
			if screen:find_child(clone27.focus[key]).set_focus then
				screen:find_child(clone27.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone27.extra.reactive = true


local clone30 = Clone
	{
		scale = {1,1,0,0},
		source = clone22,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone30",
		position = {481,358,0},
		size = {128,127},
		opacity = 255,
		reactive = true,
	}

clone30.extra.focus = {}

function clone30:on_key_down(key)
	if clone30.focus[key] then
		if type(clone30.focus[key]) == "function" then
			clone30.focus[key]()
		elseif screen:find_child(clone30.focus[key]) then
			if clone30.clear_focus then
				clone30.clear_focus(key)
			end
			screen:find_child(clone30.focus[key]):grab_key_focus()
			if screen:find_child(clone30.focus[key]).set_focus then
				screen:find_child(clone30.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone30.extra.reactive = true


local clone29 = Clone
	{
		scale = {1,1,0,0},
		source = image15,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone29",
		position = {445,99,0},
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


local clone32 = Clone
	{
		scale = {1,1,0,0},
		source = clone6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone32",
		position = {848,21,0},
		size = {127,128},
		opacity = 255,
		reactive = true,
	}

clone32.extra.focus = {}

function clone32:on_key_down(key)
	if clone32.focus[key] then
		if type(clone32.focus[key]) == "function" then
			clone32.focus[key]()
		elseif screen:find_child(clone32.focus[key]) then
			if clone32.clear_focus then
				clone32.clear_focus(key)
			end
			screen:find_child(clone32.focus[key]):grab_key_focus()
			if screen:find_child(clone32.focus[key]).set_focus then
				screen:find_child(clone32.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone32.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {1263,458,0},
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
		source = clone22,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {1266,360,0},
		size = {128,127},
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
		source = clone27,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {382,455,0},
		size = {128,128},
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
		source = clone30,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {383,357,0},
		size = {128,127},
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


g:add(image0,image15,clone6,clone22,image24,clone25,clone27,clone30,clone29,clone32,clone10,clone11,clone12,clone13)