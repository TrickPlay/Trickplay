local g = ... 


local image8 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,400,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {604,536,0},
		size = {400,55},
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


local v_60_250 = Image
	{
		src = "/assets/images/seal-down.png",
		clip = {0,0,131,151},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "v_60_250",
		position = {606,440,0},
		size = {131,151},
		opacity = 255,
		reactive = false,
	}

v_60_250.extra.focus = {}

function v_60_250:on_key_down(key)
	if v_60_250.focus[key] then
		if type(v_60_250.focus[key]) == "function" then
			v_60_250.focus[key]()
		elseif screen:find_child(v_60_250.focus[key]) then
			if v_60_250.clear_focus then
				v_60_250.clear_focus(key)
			end
			screen:find_child(v_60_250.focus[key]):grab_key_focus()
			if screen:find_child(v_60_250.focus[key]).set_focus then
				screen:find_child(v_60_250.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

v_60_250.extra.reactive = false


local image4 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image4",
		position = {487,459,0},
		size = {128,128},
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


local clone5 = Clone
	{
		scale = {1,1,0,0},
		source = image4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {486,364,0},
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
		source = image4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {139,62,0},
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
		position = {142,-33,0},
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


local clone9 = Clone
	{
		scale = {1,1,0,0},
		source = image4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {487,265,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone9.extra.focus = {}

function clone9:on_key_down(key)
	if clone9.focus[key] then
		if type(clone9.focus[key]) == "function" then
			clone9.focus[key]()
		elseif screen:find_child(clone9.focus[key]) then
			if clone9.clear_focus then
				clone9.clear_focus(key)
			end
			screen:find_child(clone9.focus[key]):grab_key_focus()
			if screen:find_child(clone9.focus[key]).set_focus then
				screen:find_child(clone9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone9.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {1190,210,0},
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


g:add(image8,v_60_250,image4,clone5,clone6,clone7,clone9,clone10)