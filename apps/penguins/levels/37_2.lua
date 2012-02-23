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
		position = {1159,234,0},
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


local s_s3_s_s4_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,15,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_s_s4_b",
		position = {1098,287,0},
		size = {96,96},
		opacity = 255,
		reactive = true,
	}

s_s3_s_s4_b.extra.focus = {}

function s_s3_s_s4_b:on_key_down(key)
	if s_s3_s_s4_b.focus[key] then
		if type(s_s3_s_s4_b.focus[key]) == "function" then
			s_s3_s_s4_b.focus[key]()
		elseif screen:find_child(s_s3_s_s4_b.focus[key]) then
			if s_s3_s_s4_b.clear_focus then
				s_s3_s_s4_b.clear_focus(key)
			end
			screen:find_child(s_s3_s_s4_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_s_s4_b.focus[key]).set_focus then
				screen:find_child(s_s3_s_s4_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_s_s4_b.extra.reactive = true


local s_s3_s_s4_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,15,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_s_s4_a",
		position = {1098,212,0},
		size = {96,96},
		opacity = 255,
		reactive = true,
	}

s_s3_s_s4_a.extra.focus = {}

function s_s3_s_s4_a:on_key_down(key)
	if s_s3_s_s4_a.focus[key] then
		if type(s_s3_s_s4_a.focus[key]) == "function" then
			s_s3_s_s4_a.focus[key]()
		elseif screen:find_child(s_s3_s_s4_a.focus[key]) then
			if s_s3_s_s4_a.clear_focus then
				s_s3_s_s4_a.clear_focus(key)
			end
			screen:find_child(s_s3_s_s4_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_s_s4_a.focus[key]).set_focus then
				screen:find_child(s_s3_s_s4_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_s_s4_a.extra.reactive = true


local s_s3_s_s5_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {50,0,800,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_s_s5_a",
		position = {498,218,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3_s_s5_a.extra.focus = {}

function s_s3_s_s5_a:on_key_down(key)
	if s_s3_s_s5_a.focus[key] then
		if type(s_s3_s_s5_a.focus[key]) == "function" then
			s_s3_s_s5_a.focus[key]()
		elseif screen:find_child(s_s3_s_s5_a.focus[key]) then
			if s_s3_s_s5_a.clear_focus then
				s_s3_s_s5_a.clear_focus(key)
			end
			screen:find_child(s_s3_s_s5_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_s_s5_a.focus[key]).set_focus then
				screen:find_child(s_s3_s_s5_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_s_s5_a.extra.reactive = true


local s_s3_d = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-18,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_d",
		position = {411,445,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3_d.extra.focus = {}

function s_s3_d:on_key_down(key)
	if s_s3_d.focus[key] then
		if type(s_s3_d.focus[key]) == "function" then
			s_s3_d.focus[key]()
		elseif screen:find_child(s_s3_d.focus[key]) then
			if s_s3_d.clear_focus then
				s_s3_d.clear_focus(key)
			end
			screen:find_child(s_s3_d.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_d.focus[key]).set_focus then
				screen:find_child(s_s3_d.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_d.extra.reactive = true


local s_s3_c = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-18,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_c",
		position = {411,348,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3_c.extra.focus = {}

function s_s3_c:on_key_down(key)
	if s_s3_c.focus[key] then
		if type(s_s3_c.focus[key]) == "function" then
			s_s3_c.focus[key]()
		elseif screen:find_child(s_s3_c.focus[key]) then
			if s_s3_c.clear_focus then
				s_s3_c.clear_focus(key)
			end
			screen:find_child(s_s3_c.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_c.focus[key]).set_focus then
				screen:find_child(s_s3_c.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_c.extra.reactive = true


local s_s4_s_s5_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-30,1200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4_s_s5_a",
		position = {286,448,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s4_s_s5_a.extra.focus = {}

function s_s4_s_s5_a:on_key_down(key)
	if s_s4_s_s5_a.focus[key] then
		if type(s_s4_s_s5_a.focus[key]) == "function" then
			s_s4_s_s5_a.focus[key]()
		elseif screen:find_child(s_s4_s_s5_a.focus[key]) then
			if s_s4_s_s5_a.clear_focus then
				s_s4_s_s5_a.clear_focus(key)
			end
			screen:find_child(s_s4_s_s5_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s4_s_s5_a.focus[key]).set_focus then
				screen:find_child(s_s4_s_s5_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4_s_s5_a.extra.reactive = true


local s3 = Image
	{
		src = "/assets/images/switch-pole.png",
		clip = {0,0,9,141},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s3",
		position = {1514,427,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s3.extra.focus = {}

function s3:on_key_down(key)
	if s3.focus[key] then
		if type(s3.focus[key]) == "function" then
			s3.focus[key]()
		elseif screen:find_child(s3.focus[key]) then
			if s3.clear_focus then
				s3.clear_focus(key)
			end
			screen:find_child(s3.focus[key]):grab_key_focus()
			if screen:find_child(s3.focus[key]).set_focus then
				screen:find_child(s3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s3.extra.reactive = true


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
		position = {571,426,0},
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


local s5 = Clone
	{
		scale = {1,1,0,0},
		source = s4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s5",
		position = {1221,107,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s5.extra.focus = {}

function s5:on_key_down(key)
	if s5.focus[key] then
		if type(s5.focus[key]) == "function" then
			s5.focus[key]()
		elseif screen:find_child(s5.focus[key]) then
			if s5.clear_focus then
				s5.clear_focus(key)
			end
			screen:find_child(s5.focus[key]):grab_key_focus()
			if screen:find_child(s5.focus[key]).set_focus then
				screen:find_child(s5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s5.extra.reactive = true


local s_s4_s_s5_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-40,1600,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4_s_s5_b",
		position = {174,444,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s4_s_s5_b.extra.focus = {}

function s_s4_s_s5_b:on_key_down(key)
	if s_s4_s_s5_b.focus[key] then
		if type(s_s4_s_s5_b.focus[key]) == "function" then
			s_s4_s_s5_b.focus[key]()
		elseif screen:find_child(s_s4_s_s5_b.focus[key]) then
			if s_s4_s_s5_b.clear_focus then
				s_s4_s_s5_b.clear_focus(key)
			end
			screen:find_child(s_s4_s_s5_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s4_s_s5_b.focus[key]).set_focus then
				screen:find_child(s_s4_s_s5_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4_s_s5_b.extra.reactive = true


local s_s4_s_s5_c = Image
	{
		src = "/assets/images/ice-bridge.png",
		clip = {0,-40,1400,89},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4_s_s5_c",
		position = {-55,358,0},
		size = {475,89},
		opacity = 255,
		reactive = true,
	}

s_s4_s_s5_c.extra.focus = {}

function s_s4_s_s5_c:on_key_down(key)
	if s_s4_s_s5_c.focus[key] then
		if type(s_s4_s_s5_c.focus[key]) == "function" then
			s_s4_s_s5_c.focus[key]()
		elseif screen:find_child(s_s4_s_s5_c.focus[key]) then
			if s_s4_s_s5_c.clear_focus then
				s_s4_s_s5_c.clear_focus(key)
			end
			screen:find_child(s_s4_s_s5_c.focus[key]):grab_key_focus()
			if screen:find_child(s_s4_s_s5_c.focus[key]).set_focus then
				screen:find_child(s_s4_s_s5_c.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4_s_s5_c.extra.reactive = true


g:add(image0,s_s3_s_s4_b,s_s3_s_s4_a,s_s3_s_s5_a,s_s3_d,s_s3_c,s_s4_s_s5_a,s3,s4,s5,s_s4_s_s5_b,s_s4_s_s5_c)