local g = ... 


local image12 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,600,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image12",
		position = {300,536,0},
		size = {600,55},
		opacity = 255,
		reactive = true,
	}

image12.extra.focus = {}

function image12:on_key_down(key)
	if image12.focus[key] then
		if type(image12.focus[key]) == "function" then
			image12.focus[key]()
		elseif screen:find_child(image12.focus[key]) then
			if image12.clear_focus then
				image12.clear_focus(key)
			end
			screen:find_child(image12.focus[key]):grab_key_focus()
			if screen:find_child(image12.focus[key]).set_focus then
				screen:find_child(image12.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image12.extra.reactive = true


local s_s1_b = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,15,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {45,0,0},
		anchor_point = {64,64},
		name = "s_s1_b",
		position = {460,225,0},
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
		clip = {-10,-10,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {45,0,0},
		anchor_point = {64,64},
		name = "s_s1_a",
		position = {389,158,0},
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
		position = {1437,-11,0},
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


local s_s1_c = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {10,-10,200,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {45,0,0},
		anchor_point = {64,64},
		name = "s_s1_c",
		position = {530,153,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s1_c.extra.focus = {}

function s_s1_c:on_key_down(key)
	if s_s1_c.focus[key] then
		if type(s_s1_c.focus[key]) == "function" then
			s_s1_c.focus[key]()
		elseif screen:find_child(s_s1_c.focus[key]) then
			if s_s1_c.clear_focus then
				s_s1_c.clear_focus(key)
			end
			screen:find_child(s_s1_c.focus[key]):grab_key_focus()
			if screen:find_child(s_s1_c.focus[key]).set_focus then
				screen:find_child(s_s1_c.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s1_c.extra.reactive = true


local image7 = Image
	{
		src = "/assets/images/beach-ball.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image7",
		position = {617,440,0},
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


local image9 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,0,128,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image9",
		position = {973,451,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

image9.extra.focus = {}

function image9:on_key_down(key)
	if image9.focus[key] then
		if type(image9.focus[key]) == "function" then
			image9.focus[key]()
		elseif screen:find_child(image9.focus[key]) then
			if image9.clear_focus then
				image9.clear_focus(key)
			end
			screen:find_child(image9.focus[key]):grab_key_focus()
			if screen:find_child(image9.focus[key]).set_focus then
				screen:find_child(image9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image9.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {974,353,0},
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


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = clone10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {973,256,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

clone11.extra.focus = {}

function clone11:on_key_down(key)
	if clone11.focus[key] then
		if type(clone11.focus[key]) == "function" then
			clone11.focus[key]()
		elseif screen:find_child(clone11.focus[key]) then
			if clone11.clear_focus then
				clone11.clear_focus(key)
			end
			screen:find_child(clone11.focus[key]):grab_key_focus()
			if screen:find_child(clone11.focus[key]).set_focus then
				screen:find_child(clone11.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone11.extra.reactive = true


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
		position = {1029,126,0},
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


g:add(image12,s_s1_b,s_s1_a,image6,s_s1_c,image7,image9,clone10,clone11,s1)