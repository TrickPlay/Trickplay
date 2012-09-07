local g = ... 


local image17 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-50,0,0},
		anchor_point = {44.5,65.5},
		name = "image17",
		position = {1047,423,0},
		size = {89,131},
		opacity = 32,
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


local image16 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-120,0,0},
		anchor_point = {44.5,65.5},
		name = "image16",
		position = {1020,371,0},
		size = {89,131},
		opacity = 64,
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
		z_rotation = {-180,0,0},
		anchor_point = {44.5,65.5},
		name = "image15",
		position = {1002,321,0},
		size = {89,131},
		opacity = 96,
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
		y_rotation = {180,0,0},
		z_rotation = {-230,0,0},
		anchor_point = {44.5,65.5},
		name = "image14",
		position = {973,276,0},
		size = {89,131},
		opacity = 128,
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
		y_rotation = {180,0,0},
		z_rotation = {100,0,0},
		anchor_point = {44.5,65.5},
		name = "image9",
		position = {933,252,0},
		size = {89,131},
		opacity = 160,
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
		position = {582,453,0},
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


local clone9 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {582,358,0},
		size = {131,129},
		opacity = 255,
		reactive = true,
	}

clone9.extra.focus = {}

function clone9:on_key_down(key)
	if clone9.focus[key] then
		if type(clone9.focus[key]) == "function" then
			clone9.focus[key]()
		elseif screen:find_child(clone9.focus[key]) then
			if clone9.clear_focus then
				clone9.clear_focus(key)
			end
			screen:find_child(clone9.focus[key]):grab_key_focus()
			if screen:find_child(clone9.focus[key]).set_focus then
				screen:find_child(clone9.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone9.extra.reactive = true


local clone5 = Clone
	{
		scale = {1,1,0,0},
		source = image2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone5",
		position = {581,261,0},
		size = {131,129},
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


local image13 = Image
	{
		src = "/assets/images/cube-64.png",
		clip = {0,0,64,64},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image13",
		position = {614,223,0},
		size = {64,64},
		opacity = 255,
		reactive = true,
	}

image13.extra.focus = {}

function image13:on_key_down(key)
	if image13.focus[key] then
		if type(image13.focus[key]) == "function" then
			image13.focus[key]()
		elseif screen:find_child(image13.focus[key]) then
			if image13.clear_focus then
				image13.clear_focus(key)
			end
			screen:find_child(image13.focus[key]):grab_key_focus()
			if screen:find_child(image13.focus[key]).set_focus then
				screen:find_child(image13.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image13.extra.reactive = true


local clone15 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {60,0,0},
		anchor_point = {44.5,65.5},
		name = "clone15",
		position = {875,229,0},
		size = {89,131},
		opacity = 160,
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


local clone16 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {20,0,0},
		anchor_point = {44.5,65.5},
		name = "clone16",
		position = {827,242,0},
		size = {89,131},
		opacity = 160,
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


local clone17 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-50,0,0},
		anchor_point = {44.5,65.5},
		name = "clone17",
		position = {785,194,0},
		size = {89,131},
		opacity = 160,
		reactive = true,
	}

clone17.extra.focus = {}

function clone17:on_key_down(key)
	if clone17.focus[key] then
		if type(clone17.focus[key]) == "function" then
			clone17.focus[key]()
		elseif screen:find_child(clone17.focus[key]) then
			if clone17.clear_focus then
				clone17.clear_focus(key)
			end
			screen:find_child(clone17.focus[key]):grab_key_focus()
			if screen:find_child(clone17.focus[key]).set_focus then
				screen:find_child(clone17.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone17.extra.reactive = true


local clone18 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-120,0,0},
		anchor_point = {44.5,65.5},
		name = "clone18",
		position = {742,161,0},
		size = {89,131},
		opacity = 160,
		reactive = true,
	}

clone18.extra.focus = {}

function clone18:on_key_down(key)
	if clone18.focus[key] then
		if type(clone18.focus[key]) == "function" then
			clone18.focus[key]()
		elseif screen:find_child(clone18.focus[key]) then
			if clone18.clear_focus then
				clone18.clear_focus(key)
			end
			screen:find_child(clone18.focus[key]):grab_key_focus()
			if screen:find_child(clone18.focus[key]).set_focus then
				screen:find_child(clone18.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone18.extra.reactive = true


local clone19 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-180,0,0},
		anchor_point = {44.5,65.5},
		name = "clone19",
		position = {695,132,0},
		size = {89,131},
		opacity = 128,
		reactive = true,
	}

clone19.extra.focus = {}

function clone19:on_key_down(key)
	if clone19.focus[key] then
		if type(clone19.focus[key]) == "function" then
			clone19.focus[key]()
		elseif screen:find_child(clone19.focus[key]) then
			if clone19.clear_focus then
				clone19.clear_focus(key)
			end
			screen:find_child(clone19.focus[key]):grab_key_focus()
			if screen:find_child(clone19.focus[key]).set_focus then
				screen:find_child(clone19.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone19.extra.reactive = true


local clone20 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {-230,0,0},
		anchor_point = {44.5,65.5},
		name = "clone20",
		position = {641,127,0},
		size = {89,131},
		opacity = 96,
		reactive = true,
	}

clone20.extra.focus = {}

function clone20:on_key_down(key)
	if clone20.focus[key] then
		if type(clone20.focus[key]) == "function" then
			clone20.focus[key]()
		elseif screen:find_child(clone20.focus[key]) then
			if clone20.clear_focus then
				clone20.clear_focus(key)
			end
			screen:find_child(clone20.focus[key]):grab_key_focus()
			if screen:find_child(clone20.focus[key]).set_focus then
				screen:find_child(clone20.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone20.extra.reactive = true


local clone11 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {90,0,0},
		anchor_point = {44.5,65.5},
		name = "clone11",
		position = {589,131,0},
		size = {89,131},
		opacity = 64,
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


local clone21 = Image
	{
		src = "/assets/images/penguin-ghost.png",
		clip = {0,0,89,131},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {60,0,0},
		anchor_point = {44.5,65.5},
		name = "clone21",
		position = {539,177,0},
		size = {89,131},
		opacity = 32,
		reactive = true,
	}

clone21.extra.focus = {}

function clone21:on_key_down(key)
	if clone21.focus[key] then
		if type(clone21.focus[key]) == "function" then
			clone21.focus[key]()
		elseif screen:find_child(clone21.focus[key]) then
			if clone21.clear_focus then
				clone21.clear_focus(key)
			end
			screen:find_child(clone21.focus[key]):grab_key_focus()
			if screen:find_child(clone21.focus[key]).set_focus then
				screen:find_child(clone21.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone21.extra.reactive = true


local image18 = Image
	{
		src = "/assets/images/cube-64-glow.png",
		clip = {0,0,72,72},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image18",
		position = {611,220,0},
		size = {72,72},
		opacity = 255,
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


g:add(image17,image16,image15,image14,image9,image2,clone9,clone5,image13,clone15,clone16,clone17,clone18,clone19,clone20,clone11,clone21,image18)