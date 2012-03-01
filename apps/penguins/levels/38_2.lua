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
		position = {1394,307,0},
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


local image3 = Image
	{
		src = "/assets/images/river-slice.png",
		clip = {0,0,750,55},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {350,536,0},
		size = {750,55},
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
		position = {1452,183,0},
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


local image10 = Image
	{
		src = "/assets/images/fish-blue.png",
		clip = {0,0,150,110},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image10",
		position = {656,415,0},
		size = {150,110},
		opacity = 255,
		reactive = true,
	}

image10.extra.focus = {}

function image10:on_key_down(key)
	if image10.focus[key] then
		if type(image10.focus[key]) == "function" then
			image10.focus[key]()
		elseif screen:find_child(image10.focus[key]) then
			if image10.clear_focus then
				image10.clear_focus(key)
			end
			screen:find_child(image10.focus[key]):grab_key_focus()
			if screen:find_child(image10.focus[key]).set_focus then
				screen:find_child(image10.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image10.extra.reactive = true


local s_s2 = Image
	{
		src = "/assets/images/cube-128.png",
		clip = {0,-30,300,128},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "s_s2",
		position = {670,401,0},
		size = {128,128},
		opacity = 255,
		reactive = true,
	}

s_s2.extra.focus = {}

function s_s2:on_key_down(key)
	if s_s2.focus[key] then
		if type(s_s2.focus[key]) == "function" then
			s_s2.focus[key]()
		elseif screen:find_child(s_s2.focus[key]) then
			if s_s2.clear_focus then
				s_s2.clear_focus(key)
			end
			screen:find_child(s_s2.focus[key]):grab_key_focus()
			if screen:find_child(s_s2.focus[key]).set_focus then
				screen:find_child(s_s2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

s_s2.extra.reactive = true


g:add(image0,image3,s2,image10,s_s2)