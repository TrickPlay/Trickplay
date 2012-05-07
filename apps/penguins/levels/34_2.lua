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
		position = {1062,449,0},
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


local s_s1_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,12,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_b",
		position = {1076,257,0},
		size = {96,96},
		opacity = 255,
		reactive = true,
	}

s_s1_b.extra.focus = {}

function s_s1_b:on_key_down(key)
	if s_s1_b.focus[key] then
		if type(s_s1_b.focus[key]) == "function" then
			s_s1_b.focus[key]()
		elseif screen:find_child(s_s1_b.focus[key]) then
			if s_s1_b.clear_focus then
				s_s1_b.clear_focus(key)
			end
			screen:find_child(s_s1_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s1_b.focus[key]).set_focus then
				screen:find_child(s_s1_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1_b.extra.reactive = true


local image3 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {433,410,0},
		size = {128,128},
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


local s_s2_c = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {20,0,400,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_c",
		position = {431,311,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s2_c.extra.focus = {}

function s_s2_c:on_key_down(key)
	if s_s2_c.focus[key] then
		if type(s_s2_c.focus[key]) == "function" then
			s_s2_c.focus[key]()
		elseif screen:find_child(s_s2_c.focus[key]) then
			if s_s2_c.clear_focus then
				s_s2_c.clear_focus(key)
			end
			screen:find_child(s_s2_c.focus[key]):grab_key_focus()
			if screen:find_child(s_s2_c.focus[key]).set_focus then
				screen:find_child(s_s2_c.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s2_c.extra.reactive = true


local s_s2_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {20,0,400,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_b",
		position = {331,311,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s2_b.extra.focus = {}

function s_s2_b:on_key_down(key)
	if s_s2_b.focus[key] then
		if type(s_s2_b.focus[key]) == "function" then
			s_s2_b.focus[key]()
		elseif screen:find_child(s_s2_b.focus[key]) then
			if s_s2_b.clear_focus then
				s_s2_b.clear_focus(key)
			end
			screen:find_child(s_s2_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s2_b.focus[key]).set_focus then
				screen:find_child(s_s2_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s2_b.extra.reactive = true


local s_s2_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {20,0,400,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_a",
		position = {231,311,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s2_a.extra.focus = {}

function s_s2_a:on_key_down(key)
	if s_s2_a.focus[key] then
		if type(s_s2_a.focus[key]) == "function" then
			s_s2_a.focus[key]()
		elseif screen:find_child(s_s2_a.focus[key]) then
			if s_s2_a.clear_focus then
				s_s2_a.clear_focus(key)
			end
			screen:find_child(s_s2_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s2_a.focus[key]).set_focus then
				screen:find_child(s_s2_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s2_a.extra.reactive = true


local s1 = Image
	{
		src = "/assets/images/switch-pole.png",
		clip = {0,0,9,141},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s1",
		position = {1521,429,0},
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


local s_s1_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-12,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_a",
		position = {1076,182,0},
		size = {96,96},
		opacity = 255,
		reactive = true,
	}

s_s1_a.extra.focus = {}

function s_s1_a:on_key_down(key)
	if s_s1_a.focus[key] then
		if type(s_s1_a.focus[key]) == "function" then
			s_s1_a.focus[key]()
		elseif screen:find_child(s_s1_a.focus[key]) then
			if s_s1_a.clear_focus then
				s_s1_a.clear_focus(key)
			end
			screen:find_child(s_s1_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s1_a.focus[key]).set_focus then
				screen:find_child(s_s1_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1_a.extra.reactive = true


local image11 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image11",
		position = {486,270,0},
		size = {64,64},
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


local clone12 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {1064,-39,0},
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


local clone14 = Clone
	{
		scale = {1,1,0,0},
		source = image11,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {441,270,0},
		size = {64,64},
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
		position = {493,135,0},
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


g:add(image0,s_s1_b,image3,s_s2_c,s_s2_b,s_s2_a,s1,s_s1_a,image11,clone12,clone14,s2)