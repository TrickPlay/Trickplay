local g = ... 


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,1380,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {500,536,0},
		size = {1380,55},
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


local s_s1_s_s2 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,13,300,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_s_s2",
		position = {1744,223,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

s_s1_s_s2.extra.focus = {}

function s_s1_s_s2:on_key_down(key)
	if s_s1_s_s2.focus[key] then
		if type(s_s1_s_s2.focus[key]) == "function" then
			s_s1_s_s2.focus[key]()
		elseif screen:find_child(s_s1_s_s2.focus[key]) then
			if s_s1_s_s2.clear_focus then
				s_s1_s_s2.clear_focus(key)
			end
			screen:find_child(s_s1_s_s2.focus[key]):grab_key_focus()
			if screen:find_child(s_s1_s_s2.focus[key]).set_focus then
				screen:find_child(s_s1_s_s2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1_s_s2.extra.reactive = true


local image13 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,0,474,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image13",
		position = {795,217,0},
		size = {474,89},
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


local s_s1 = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,-13,300,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1",
		position = {1179,467,0},
		size = {474,89},
		opacity = 255,
		reactive = true,
	}

s_s1.extra.focus = {}

function s_s1:on_key_down(key)
	if s_s1.focus[key] then
		if type(s_s1.focus[key]) == "function" then
			s_s1.focus[key]()
		elseif screen:find_child(s_s1.focus[key]) then
			if s_s1.clear_focus then
				s_s1.clear_focus(key)
			end
			screen:find_child(s_s1.focus[key]):grab_key_focus()
			if screen:find_child(s_s1.focus[key]).set_focus then
				screen:find_child(s_s1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1.extra.reactive = true


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
		position = {1466,421,0},
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


local s2 = Image
	{
		src = "/assets/images/switch-pole.png",
		clip = {0,0,9,141},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s2",
		position = {1524,298,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s2.extra.focus = {}

function s2:on_key_down(key)
	if s2.focus[key] then
		if type(s2.focus[key]) == "function" then
			s2.focus[key]()
		elseif screen:find_child(s2.focus[key]) then
			if s2.clear_focus then
				s2.clear_focus(key)
			end
			screen:find_child(s2.focus[key]):grab_key_focus()
			if screen:find_child(s2.focus[key]).set_focus then
				screen:find_child(s2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s2.extra.reactive = true


local s1 = Clone
	{
		scale = {1,1,0,0},
		source = s2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s1",
		position = {1023,88,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s1.extra.focus = {}

function s1:on_key_down(key)
	if s1.focus[key] then
		if type(s1.focus[key]) == "function" then
			s1.focus[key]()
		elseif screen:find_child(s1.focus[key]) then
			if s1.clear_focus then
				s1.clear_focus(key)
			end
			screen:find_child(s1.focus[key]):grab_key_focus()
			if screen:find_child(s1.focus[key]).set_focus then
				screen:find_child(s1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s1.extra.reactive = true


g:add(image3,s_s1_s_s2,image13,s_s1,image0,s2,s1)