local g = ... 


local image19 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {44.5,65.5},
		name = "image19",
		position = {1299,500,0},
		size = {89,131},
		opacity = 32,
		reactive = true,
	}

image19.extra.focus = {}

function image19:on_key_down(key)
	if image19.focus[key] then
		if type(image19.focus[key]) == "function" then
			image19.focus[key]()
		elseif screen:find_child(image19.focus[key]) then
			if image19.clear_focus then
				image19.clear_focus(key)
			end
			screen:find_child(image19.focus[key]):grab_key_focus()
			if screen:find_child(image19.focus[key]).set_focus then
				screen:find_child(image19.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image19.extra.reactive = true


local image17 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {50,0,0},
		anchor_point = {44.5,65.5},
		name = "image17",
		position = {1342,435,0},
		size = {89,131},
		opacity = 64,
		reactive = true,
	}

image17.extra.focus = {}

function image17:on_key_down(key)
	if image17.focus[key] then
		if type(image17.focus[key]) == "function" then
			image17.focus[key]()
		elseif screen:find_child(image17.focus[key]) then
			if image17.clear_focus then
				image17.clear_focus(key)
			end
			screen:find_child(image17.focus[key]):grab_key_focus()
			if screen:find_child(image17.focus[key]).set_focus then
				screen:find_child(image17.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image17.extra.reactive = true


local image2 = Image
	{
		src = "assets/images/cube-128.png",
		clip = {0,0,131,129},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image2",
		position = {1453,451,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

image2.extra.focus = {}

function image2:on_key_down(key)
	if image2.focus[key] then
		if type(image2.focus[key]) == "function" then
			image2.focus[key]()
		elseif screen:find_child(image2.focus[key]) then
			if image2.clear_focus then
				image2.clear_focus(key)
			end
			screen:find_child(image2.focus[key]):grab_key_focus()
			if screen:find_child(image2.focus[key]).set_focus then
				screen:find_child(image2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image2.extra.reactive = true


local image16 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {120,0,0},
		anchor_point = {44.5,65.5},
		name = "image16",
		position = {1386,388,0},
		size = {89,131},
		opacity = 96,
		reactive = true,
	}

image16.extra.focus = {}

function image16:on_key_down(key)
	if image16.focus[key] then
		if type(image16.focus[key]) == "function" then
			image16.focus[key]()
		elseif screen:find_child(image16.focus[key]) then
			if image16.clear_focus then
				image16.clear_focus(key)
			end
			screen:find_child(image16.focus[key]):grab_key_focus()
			if screen:find_child(image16.focus[key]).set_focus then
				screen:find_child(image16.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image16.extra.reactive = true


local image15 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {180,0,0},
		anchor_point = {44.5,65.5},
		name = "image15",
		position = {1426,346,0},
		size = {89,131},
		opacity = 128,
		reactive = true,
	}

image15.extra.focus = {}

function image15:on_key_down(key)
	if image15.focus[key] then
		if type(image15.focus[key]) == "function" then
			image15.focus[key]()
		elseif screen:find_child(image15.focus[key]) then
			if image15.clear_focus then
				image15.clear_focus(key)
			end
			screen:find_child(image15.focus[key]):grab_key_focus()
			if screen:find_child(image15.focus[key]).set_focus then
				screen:find_child(image15.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image15.extra.reactive = true


local image14 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {230,0,0},
		anchor_point = {44.5,65.5},
		name = "image14",
		position = {1479,317,0},
		size = {89,131},
		opacity = 160,
		reactive = true,
	}

image14.extra.focus = {}

function image14:on_key_down(key)
	if image14.focus[key] then
		if type(image14.focus[key]) == "function" then
			image14.focus[key]()
		elseif screen:find_child(image14.focus[key]) then
			if image14.clear_focus then
				image14.clear_focus(key)
			end
			screen:find_child(image14.focus[key]):grab_key_focus()
			if screen:find_child(image14.focus[key]).set_focus then
				screen:find_child(image14.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image14.extra.reactive = true


local image9 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89.000061035156,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {-90,0,0},
		anchor_point = {44.5,65.5},
		name = "image9",
		position = {1545,323,0},
		size = {89,131},
		opacity = 128,
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


local clone16 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {-30,0,0},
		anchor_point = {44.5,65.5},
		name = "clone16",
		position = {1614,363,0},
		size = {89,131},
		opacity = 96,
		reactive = true,
	}

clone16.extra.focus = {}

function clone16:on_key_down(key)
	if clone16.focus[key] then
		if type(clone16.focus[key]) == "function" then
			clone16.focus[key]()
		elseif screen:find_child(clone16.focus[key]) then
			if clone16.clear_focus then
				clone16.clear_focus(key)
			end
			screen:find_child(clone16.focus[key]):grab_key_focus()
			if screen:find_child(clone16.focus[key]).set_focus then
				screen:find_child(clone16.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone16.extra.reactive = true


local clone15 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {-5,0,0},
		anchor_point = {44.5,65.5},
		name = "clone15",
		position = {1661,431,0},
		size = {89,131},
		opacity = 64,
		reactive = true,
	}

clone15.extra.focus = {}

function clone15:on_key_down(key)
	if clone15.focus[key] then
		if type(clone15.focus[key]) == "function" then
			clone15.focus[key]()
		elseif screen:find_child(clone15.focus[key]) then
			if clone15.clear_focus then
				clone15.clear_focus(key)
			end
			screen:find_child(clone15.focus[key]):grab_key_focus()
			if screen:find_child(clone15.focus[key]).set_focus then
				screen:find_child(clone15.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone15.extra.reactive = true


local image18 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {44.5,65.5},
		name = "image18",
		position = {1687,501,0},
		size = {89,131},
		opacity = 32,
		reactive = true,
	}

image18.extra.focus = {}

function image18:on_key_down(key)
	if image18.focus[key] then
		if type(image18.focus[key]) == "function" then
			image18.focus[key]()
		elseif screen:find_child(image18.focus[key]) then
			if image18.clear_focus then
				image18.clear_focus(key)
			end
			screen:find_child(image18.focus[key]):grab_key_focus()
			if screen:find_child(image18.focus[key]).set_focus then
				screen:find_child(image18.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image18.extra.reactive = true


g:add(image19,image17,image2,image16,image15,image14,image9,clone16,clone15,image18)