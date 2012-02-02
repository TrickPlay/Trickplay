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
		position = {886,450,0},
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


local clone1 = Clone
	{
		scale = {1,1,0,0},
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone1",
		position = {885,355,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone1.extra.focus = {}

function clone1:on_key_down(key)
	if clone1.focus[key] then
		if type(clone1.focus[key]) == "function" then
			clone1.focus[key]()
		elseif screen:find_child(clone1.focus[key]) then
			if clone1.clear_focus then
				clone1.clear_focus(key)
			end
			screen:find_child(clone1.focus[key]):grab_key_focus()
			if screen:find_child(clone1.focus[key]).set_focus then
				screen:find_child(clone1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone1.extra.reactive = true


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,400,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1046,536,0},
		size = {400,55},
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


local image4 = Image
	{
		src = "/assets/images/beach-ball.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image4",
		position = {1184,491,0},
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
		source = image0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {1457,456,0},
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


local s_s1_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-20,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_b",
		position = {1457,360,0},
		size = {128,128},
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


local s_s1_a = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-20,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s1_a",
		position = {1457,264,0},
		size = {128,128},
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
		position = {940,231,0},
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


g:add(image0,clone1,image3,image4,clone5,s_s1_b,s_s1_a,s1)