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
		position = {1230,390,0},
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
		position = {725,422,0},
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
		clip = {40,0,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_b",
		position = {1231,286,0},
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
		clip = {40,0,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s3_a",
		position = {1230,182,0},
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
		position = {1231,78,0},
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


g:add(image0,s3,s_s3_b,s_s3_a,image3)