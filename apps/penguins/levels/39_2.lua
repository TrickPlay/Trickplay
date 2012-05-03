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
		position = {765,20,0},
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


local s_s10 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,40,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s10",
		position = {670,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s10.extra.focus = {}

function s_s10:on_key_down(key)
	if s_s10.focus[key] then
		if type(s_s10.focus[key]) == "function" then
			s_s10.focus[key]()
		elseif screen:find_child(s_s10.focus[key]) then
			if s_s10.clear_focus then
				s_s10.clear_focus(key)
			end
			screen:find_child(s_s10.focus[key]):grab_key_focus()
			if screen:find_child(s_s10.focus[key]).set_focus then
				screen:find_child(s_s10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s10.extra.reactive = true


local s_s4_s_s9 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,35,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4_s_s9",
		position = {574,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s4_s_s9.extra.focus = {}

function s_s4_s_s9:on_key_down(key)
	if s_s4_s_s9.focus[key] then
		if type(s_s4_s_s9.focus[key]) == "function" then
			s_s4_s_s9.focus[key]()
		elseif screen:find_child(s_s4_s_s9.focus[key]) then
			if s_s4_s_s9.clear_focus then
				s_s4_s_s9.clear_focus(key)
			end
			screen:find_child(s_s4_s_s9.focus[key]):grab_key_focus()
			if screen:find_child(s_s4_s_s9.focus[key]).set_focus then
				screen:find_child(s_s4_s_s9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4_s_s9.extra.reactive = true


local s_s5_s_s6 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,37,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s5_s_s6",
		position = {479,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s5_s_s6.extra.focus = {}

function s_s5_s_s6:on_key_down(key)
	if s_s5_s_s6.focus[key] then
		if type(s_s5_s_s6.focus[key]) == "function" then
			s_s5_s_s6.focus[key]()
		elseif screen:find_child(s_s5_s_s6.focus[key]) then
			if s_s5_s_s6.clear_focus then
				s_s5_s_s6.clear_focus(key)
			end
			screen:find_child(s_s5_s_s6.focus[key]):grab_key_focus()
			if screen:find_child(s_s5_s_s6.focus[key]).set_focus then
				screen:find_child(s_s5_s_s6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s5_s_s6.extra.reactive = true


local s_s3 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,44,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3",
		position = {384,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3.extra.focus = {}

function s_s3:on_key_down(key)
	if s_s3.focus[key] then
		if type(s_s3.focus[key]) == "function" then
			s_s3.focus[key]()
		elseif screen:find_child(s_s3.focus[key]) then
			if s_s3.clear_focus then
				s_s3.clear_focus(key)
			end
			screen:find_child(s_s3.focus[key]):grab_key_focus()
			if screen:find_child(s_s3.focus[key]).set_focus then
				screen:find_child(s_s3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3.extra.reactive = true


local s_s8 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,44,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s8",
		position = {289,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s8.extra.focus = {}

function s_s8:on_key_down(key)
	if s_s8.focus[key] then
		if type(s_s8.focus[key]) == "function" then
			s_s8.focus[key]()
		elseif screen:find_child(s_s8.focus[key]) then
			if s_s8.clear_focus then
				s_s8.clear_focus(key)
			end
			screen:find_child(s_s8.focus[key]):grab_key_focus()
			if screen:find_child(s_s8.focus[key]).set_focus then
				screen:find_child(s_s8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s8.extra.reactive = true


local s_s4_s_s7 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,38,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s4_s_s7",
		position = {193,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s4_s_s7.extra.focus = {}

function s_s4_s_s7:on_key_down(key)
	if s_s4_s_s7.focus[key] then
		if type(s_s4_s_s7.focus[key]) == "function" then
			s_s4_s_s7.focus[key]()
		elseif screen:find_child(s_s4_s_s7.focus[key]) then
			if s_s4_s_s7.clear_focus then
				s_s4_s_s7.clear_focus(key)
			end
			screen:find_child(s_s4_s_s7.focus[key]):grab_key_focus()
			if screen:find_child(s_s4_s_s7.focus[key]).set_focus then
				screen:find_child(s_s4_s_s7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s4_s_s7.extra.reactive = true


local s_s5 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,20,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s5",
		position = {98,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s5.extra.focus = {}

function s_s5:on_key_down(key)
	if s_s5.focus[key] then
		if type(s_s5.focus[key]) == "function" then
			s_s5.focus[key]()
		elseif screen:find_child(s_s5.focus[key]) then
			if s_s5.clear_focus then
				s_s5.clear_focus(key)
			end
			screen:find_child(s_s5.focus[key]):grab_key_focus()
			if screen:find_child(s_s5.focus[key]).set_focus then
				screen:find_child(s_s5.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s5.extra.reactive = true


local s_s6 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,42,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s6",
		position = {3,20,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s6.extra.focus = {}

function s_s6:on_key_down(key)
	if s_s6.focus[key] then
		if type(s_s6.focus[key]) == "function" then
			s_s6.focus[key]()
		elseif screen:find_child(s_s6.focus[key]) then
			if s_s6.clear_focus then
				s_s6.clear_focus(key)
			end
			screen:find_child(s_s6.focus[key]):grab_key_focus()
			if screen:find_child(s_s6.focus[key]).set_focus then
				screen:find_child(s_s6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s6.extra.reactive = true


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
		position = {1771,425,0},
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


local s4 = Clone
	{
		scale = {1,1,0,0},
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s4",
		position = {1647,425,0},
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
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s5",
		position = {1523,425,0},
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


local s6 = Clone
	{
		scale = {1,1,0,0},
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s6",
		position = {1399,425,0},
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


local s7 = Clone
	{
		scale = {1,1,0,0},
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s7",
		position = {1275,425,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s7.extra.focus = {}

function s7:on_key_down(key)
	if s7.focus[key] then
		if type(s7.focus[key]) == "function" then
			s7.focus[key]()
		elseif screen:find_child(s7.focus[key]) then
			if s7.clear_focus then
				s7.clear_focus(key)
			end
			screen:find_child(s7.focus[key]):grab_key_focus()
			if screen:find_child(s7.focus[key]).set_focus then
				screen:find_child(s7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s7.extra.reactive = true


local s9 = Clone
	{
		scale = {1,1,0,0},
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s9",
		position = {1027,425,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s9.extra.focus = {}

function s9:on_key_down(key)
	if s9.focus[key] then
		if type(s9.focus[key]) == "function" then
			s9.focus[key]()
		elseif screen:find_child(s9.focus[key]) then
			if s9.clear_focus then
				s9.clear_focus(key)
			end
			screen:find_child(s9.focus[key]):grab_key_focus()
			if screen:find_child(s9.focus[key]).set_focus then
				screen:find_child(s9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s9.extra.reactive = true


local s10 = Clone
	{
		scale = {1,1,0,0},
		source = s3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s10",
		position = {903,425,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s10.extra.focus = {}

function s10:on_key_down(key)
	if s10.focus[key] then
		if type(s10.focus[key]) == "function" then
			s10.focus[key]()
		elseif screen:find_child(s10.focus[key]) then
			if s10.clear_focus then
				s10.clear_focus(key)
			end
			screen:find_child(s10.focus[key]):grab_key_focus()
			if screen:find_child(s10.focus[key]).set_focus then
				screen:find_child(s10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s10.extra.reactive = true


local s8 = Clone
	{
		scale = {1,1,0,0},
		source = s7,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s8",
		position = {1151,425,0},
		size = {9,141},
		opacity = 255,
		reactive = true,
	}

s8.extra.focus = {}

function s8:on_key_down(key)
	if s8.focus[key] then
		if type(s8.focus[key]) == "function" then
			s8.focus[key]()
		elseif screen:find_child(s8.focus[key]) then
			if s8.clear_focus then
				s8.clear_focus(key)
			end
			screen:find_child(s8.focus[key]):grab_key_focus()
			if screen:find_child(s8.focus[key]).set_focus then
				screen:find_child(s8.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s8.extra.reactive = true


g:add(image0,s_s10,s_s4_s_s9,s_s5_s_s6,s_s3,s_s8,s_s4_s_s7,s_s5,s_s6,s3,s4,s5,s6,s7,s9,s10,s8)