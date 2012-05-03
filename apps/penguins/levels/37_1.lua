local g = ... 


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
		position = {576,424,0},
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


local s2 = Clone
	{
		scale = {1,1,0,0},
		source = s1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s2",
		position = {847,423,0},
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


local s3 = Clone
	{
		scale = {1,1,0,0},
		source = s2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s3",
		position = {1117,424,0},
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


local s_s1_s_s2 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-40,150,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_s_s2",
		position = {1600,450,0},
		size = {128,128},
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


local s_s1_s_s3 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,40,150,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_s_s3",
		position = {1500,50,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s1_s_s3.extra.focus = {}

function s_s1_s_s3:on_key_down(key)
	if s_s1_s_s3.focus[key] then
		if type(s_s1_s_s3.focus[key]) == "function" then
			s_s1_s_s3.focus[key]()
		elseif screen:find_child(s_s1_s_s3.focus[key]) then
			if s_s1_s_s3.clear_focus then
				s_s1_s_s3.clear_focus(key)
			end
			screen:find_child(s_s1_s_s3.focus[key]):grab_key_focus()
			if screen:find_child(s_s1_s_s3.focus[key]).set_focus then
				screen:find_child(s_s1_s_s3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1_s_s3.extra.reactive = true


local s_s2_s_s3 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {40,0,150,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_s_s3",
		position = {1313,326,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s2_s_s3.extra.focus = {}

function s_s2_s_s3:on_key_down(key)
	if s_s2_s_s3.focus[key] then
		if type(s_s2_s_s3.focus[key]) == "function" then
			s_s2_s_s3.focus[key]()
		elseif screen:find_child(s_s2_s_s3.focus[key]) then
			if s_s2_s_s3.clear_focus then
				s_s2_s_s3.clear_focus(key)
			end
			screen:find_child(s_s2_s_s3.focus[key]):grab_key_focus()
			if screen:find_child(s_s2_s_s3.focus[key]).set_focus then
				screen:find_child(s_s2_s_s3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s2_s_s3.extra.reactive = true


g:add(s1,s2,s3,s_s1_s_s2,s_s1_s_s3,s_s2_s_s3)