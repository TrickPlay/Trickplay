local g = ... 


local s_s4 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,30,400,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4",
		position = {811,100,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

s_s4.extra.focus = {}

function s_s4:on_key_down(key)
	if s_s4.focus[key] then
		if type(s_s4.focus[key]) == "function" then
			s_s4.focus[key]()
		elseif screen:find_child(s_s4.focus[key]) then
			if s_s4.clear_focus then
				s_s4.clear_focus(key)
			end
			screen:find_child(s_s4.focus[key]):grab_key_focus()
			if screen:find_child(s_s4.focus[key]).set_focus then
				screen:find_child(s_s4.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4.extra.reactive = true


local image0 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128.00001525879,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {703,447,0},
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


local s4 = Image
	{
		src = "/assets/images/switch-pole.png",
		clip = {0,0,9,141},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s4",
		position = {1542,423,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s4.extra.focus = {}

function s4:on_key_down(key)
	if s4.focus[key] then
		if type(s4.focus[key]) == "function" then
			s4.focus[key]()
		elseif screen:find_child(s4.focus[key]) then
			if s4.clear_focus then
				s4.clear_focus(key)
			end
			screen:find_child(s4.focus[key]):grab_key_focus()
			if screen:find_child(s4.focus[key]).set_focus then
				screen:find_child(s4.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s4.extra.reactive = true


local s6 = Clone
	{
		scale = {1,1,0,0},
		source = s4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s6",
		position = {763,321,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s6.extra.focus = {}

function s6:on_key_down(key)
	if s6.focus[key] then
		if type(s6.focus[key]) == "function" then
			s6.focus[key]()
		elseif screen:find_child(s6.focus[key]) then
			if s6.clear_focus then
				s6.clear_focus(key)
			end
			screen:find_child(s6.focus[key]):grab_key_focus()
			if screen:find_child(s6.focus[key]).set_focus then
				screen:find_child(s6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s6.extra.reactive = true


local s_s6_b = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,-25,200,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s6_b",
		position = {187,350,0},
		size = {474,89},
		opacity = 255,
		reactive = true,
	}

s_s6_b.extra.focus = {}

function s_s6_b:on_key_down(key)
	if s_s6_b.focus[key] then
		if type(s_s6_b.focus[key]) == "function" then
			s_s6_b.focus[key]()
		elseif screen:find_child(s_s6_b.focus[key]) then
			if s_s6_b.clear_focus then
				s_s6_b.clear_focus(key)
			end
			screen:find_child(s_s6_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s6_b.focus[key]).set_focus then
				screen:find_child(s_s6_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s6_b.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {46,183,0},
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


local image13 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,400,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image13",
		position = {269,536,0},
		size = {400,55},
		opacity = 255,
		reactive = true,
	}

image13.extra.focus = {}

function image13:on_key_down(key)
	if image13.focus[key] then
		if type(image13.focus[key]) == "function" then
			image13.focus[key]()
		elseif screen:find_child(image13.focus[key]) then
			if image13.clear_focus then
				image13.clear_focus(key)
			end
			screen:find_child(image13.focus[key]):grab_key_focus()
			if screen:find_child(image13.focus[key]).set_focus then
				screen:find_child(image13.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image13.extra.reactive = true


local clone14 = Clone
	{
		scale = {1,1,0,0},
		source = clone10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {45,84,0},
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


g:add(s_s4,image0,s4,s6,s_s6_b,clone10,image13,clone14)