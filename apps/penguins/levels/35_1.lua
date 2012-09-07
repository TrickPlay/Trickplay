local g = ... 


local image7 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image7",
		position = {1136,456,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image7.extra.focus = {}

function image7:on_key_down(key)
	if image7.focus[key] then
		if type(image7.focus[key]) == "function" then
			image7.focus[key]()
		elseif screen:find_child(image7.focus[key]) then
			if image7.clear_focus then
				image7.clear_focus(key)
			end
			screen:find_child(image7.focus[key]):grab_key_focus()
			if screen:find_child(image7.focus[key]).set_focus then
				screen:find_child(image7.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image7.extra.reactive = true


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
		position = {662,422,0},
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


local s_s3_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {30,0,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_b",
		position = {1231,256,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3_b.extra.focus = {}

function s_s3_b:on_key_down(key)
	if s_s3_b.focus[key] then
		if type(s_s3_b.focus[key]) == "function" then
			s_s3_b.focus[key]()
		elseif screen:find_child(s_s3_b.focus[key]) then
			if s_s3_b.clear_focus then
				s_s3_b.clear_focus(key)
			end
			screen:find_child(s_s3_b.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_b.focus[key]).set_focus then
				screen:find_child(s_s3_b.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_b.extra.reactive = true


local s_s3_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {30,0,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_a",
		position = {1230,152,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s3_a.extra.focus = {}

function s_s3_a:on_key_down(key)
	if s_s3_a.focus[key] then
		if type(s_s3_a.focus[key]) == "function" then
			s_s3_a.focus[key]()
		elseif screen:find_child(s_s3_a.focus[key]) then
			if s_s3_a.clear_focus then
				s_s3_a.clear_focus(key)
			end
			screen:find_child(s_s3_a.focus[key]):grab_key_focus()
			if screen:find_child(s_s3_a.focus[key]).set_focus then
				screen:find_child(s_s3_a.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s3_a.extra.reactive = true


local s_s2_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-10,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_b",
		position = {1137,360,0},
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
		clip = {0,10,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2_a",
		position = {1136,54,0},
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
		position = {904,422,0},
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


local image6 = Image
	{
		src = "/assets/images/icicles.png",
		clip = {0,0,161,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image6",
		position = {707,-23,0},
		size = {161,131},
		opacity = 255,
		reactive = true,
	}

image6.extra.focus = {}

function image6:on_key_down(key)
	if image6.focus[key] then
		if type(image6.focus[key]) == "function" then
			image6.focus[key]()
		elseif screen:find_child(image6.focus[key]) then
			if image6.clear_focus then
				image6.clear_focus(key)
			end
			screen:find_child(image6.focus[key]):grab_key_focus()
			if screen:find_child(image6.focus[key]).set_focus then
				screen:find_child(image6.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image6.extra.reactive = true


g:add(image7,s3,s_s3_b,s_s3_a,s_s2_b,s_s2_a,s2,image6)