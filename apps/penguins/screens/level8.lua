local g = ... 


local bg3 = Clone
	{
		source = b5,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg3",
		position = {0,720,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg3.extra.focus = {}

function bg3:on_key_down(key)
	if bg3.focus[key] then
		if type(bg3.focus[key]) == "function" then
			bg3.focus[key]()
		elseif screen:find_child(bg3.focus[key]) then
			if bg3.on_focus_out then
				bg3.on_focus_out()
			end
			screen:find_child(bg3.focus[key]):grab_key_focus()
			if screen:find_child(bg3.focus[key]).on_focus_in then
				screen:find_child(bg3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg3.extra.reactive = true


local bg2 = Clone
	{
		source = b4,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg2",
		position = {0,360,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg2.extra.focus = {}

function bg2:on_key_down(key)
	if bg2.focus[key] then
		if type(bg2.focus[key]) == "function" then
			bg2.focus[key]()
		elseif screen:find_child(bg2.focus[key]) then
			if bg2.on_focus_out then
				bg2.on_focus_out()
			end
			screen:find_child(bg2.focus[key]):grab_key_focus()
			if screen:find_child(bg2.focus[key]).on_focus_in then
				screen:find_child(bg2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg2.extra.reactive = true


local bg1 = Clone
	{
		source = b2,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg1",
		position = {0,0,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg1.extra.focus = {}

function bg1:on_key_down(key)
	if bg1.focus[key] then
		if type(bg1.focus[key]) == "function" then
			bg1.focus[key]()
		elseif screen:find_child(bg1.focus[key]) then
			if bg1.on_focus_out then
				bg1.on_focus_out()
			end
			screen:find_child(bg1.focus[key]):grab_key_focus()
			if screen:find_child(bg1.focus[key]).on_focus_in then
				screen:find_child(bg1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg1.extra.reactive = true


local player = Clone
	{
		source = pspeed,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "player",
		position = {0,315,0},
		size = {45,45},
		opacity = 255,
		reactive = true,
	}

player.extra.focus = {}

function player:on_key_down(key)
	if player.focus[key] then
		if type(player.focus[key]) == "function" then
			player.focus[key]()
		elseif screen:find_child(player.focus[key]) then
			if player.on_focus_out then
				player.on_focus_out()
			end
			screen:find_child(player.focus[key]):grab_key_focus()
			if screen:find_child(player.focus[key]).on_focus_in then
				screen:find_child(player.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

player.extra.reactive = true


local hat = Image
	{
		src = "/assets/images/player_jump_hat.png",
		clip = {0,0,63,63},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "hat",
		position = {74,230,0},
		size = {63,63},
		opacity = 255,
		reactive = true,
	}

hat.extra.focus = {}

function hat:on_key_down(key)
	if hat.focus[key] then
		if type(hat.focus[key]) == "function" then
			hat.focus[key]()
		elseif screen:find_child(hat.focus[key]) then
			if hat.on_focus_out then
				hat.on_focus_out()
			end
			screen:find_child(hat.focus[key]):grab_key_focus()
			if screen:find_child(hat.focus[key]).on_focus_in then
				screen:find_child(hat.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

hat.extra.reactive = true


local image3 = Image
	{
		src = "/assets/images/igloo.png",
		clip = {0,0,151,88},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1845,273,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

image3.extra.focus = {}

function image3:on_key_down(key)
	if image3.focus[key] then
		if type(image3.focus[key]) == "function" then
			image3.focus[key]()
		elseif screen:find_child(image3.focus[key]) then
			if image3.on_focus_out then
				image3.on_focus_out()
			end
			screen:find_child(image3.focus[key]):grab_key_focus()
			if screen:find_child(image3.focus[key]).on_focus_in then
				screen:find_child(image3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image3.extra.reactive = true


local clone4 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {1845,992,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

clone4.extra.focus = {}

function clone4:on_key_down(key)
	if clone4.focus[key] then
		if type(clone4.focus[key]) == "function" then
			clone4.focus[key]()
		elseif screen:find_child(clone4.focus[key]) then
			if clone4.on_focus_out then
				clone4.on_focus_out()
			end
			screen:find_child(clone4.focus[key]):grab_key_focus()
			if screen:find_child(clone4.focus[key]).on_focus_in then
				screen:find_child(clone4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone4.extra.reactive = true


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {75,634,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

clone6.extra.focus = {}

function clone6:on_key_down(key)
	if clone6.focus[key] then
		if type(clone6.focus[key]) == "function" then
			clone6.focus[key]()
		elseif screen:find_child(clone6.focus[key]) then
			if clone6.on_focus_out then
				clone6.on_focus_out()
			end
			screen:find_child(clone6.focus[key]):grab_key_focus()
			if screen:find_child(clone6.focus[key]).on_focus_in then
				screen:find_child(clone6.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone6.extra.reactive = true


local fish1 = Image
	{
		src = "/assets/images/collect_black.png",
		clip = {0,0,64,49},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish1",
		position = {618,308,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish1.extra.focus = {}

function fish1:on_key_down(key)
	if fish1.focus[key] then
		if type(fish1.focus[key]) == "function" then
			fish1.focus[key]()
		elseif screen:find_child(fish1.focus[key]) then
			if fish1.on_focus_out then
				fish1.on_focus_out()
			end
			screen:find_child(fish1.focus[key]):grab_key_focus()
			if screen:find_child(fish1.focus[key]).on_focus_in then
				screen:find_child(fish1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish1.extra.reactive = true


local image10 = Image
	{
		src = "/assets/images/obstacle_1.png",
		clip = {0,0,65,62},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image10",
		position = {932,297,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

image10.extra.focus = {}

function image10:on_key_down(key)
	if image10.focus[key] then
		if type(image10.focus[key]) == "function" then
			image10.focus[key]()
		elseif screen:find_child(image10.focus[key]) then
			if image10.on_focus_out then
				image10.on_focus_out()
			end
			screen:find_child(image10.focus[key]):grab_key_focus()
			if screen:find_child(image10.focus[key]).on_focus_in then
				screen:find_child(image10.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image10.extra.reactive = true


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = image10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {932,239,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone11.extra.focus = {}

function clone11:on_key_down(key)
	if clone11.focus[key] then
		if type(clone11.focus[key]) == "function" then
			clone11.focus[key]()
		elseif screen:find_child(clone11.focus[key]) then
			if clone11.on_focus_out then
				clone11.on_focus_out()
			end
			screen:find_child(clone11.focus[key]):grab_key_focus()
			if screen:find_child(clone11.focus[key]).on_focus_in then
				screen:find_child(clone11.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone11.extra.reactive = true


local clone12 = Clone
	{
		scale = {1,1,0,0},
		source = clone11,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone12",
		position = {932,181,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone12.extra.focus = {}

function clone12:on_key_down(key)
	if clone12.focus[key] then
		if type(clone12.focus[key]) == "function" then
			clone12.focus[key]()
		elseif screen:find_child(clone12.focus[key]) then
			if clone12.on_focus_out then
				clone12.on_focus_out()
			end
			screen:find_child(clone12.focus[key]):grab_key_focus()
			if screen:find_child(clone12.focus[key]).on_focus_in then
				screen:find_child(clone12.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone12.extra.reactive = true


local clone13 = Clone
	{
		scale = {1,1,0,0},
		source = clone12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone13",
		position = {932,122,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone13.extra.focus = {}

function clone13:on_key_down(key)
	if clone13.focus[key] then
		if type(clone13.focus[key]) == "function" then
			clone13.focus[key]()
		elseif screen:find_child(clone13.focus[key]) then
			if clone13.on_focus_out then
				clone13.on_focus_out()
			end
			screen:find_child(clone13.focus[key]):grab_key_focus()
			if screen:find_child(clone13.focus[key]).on_focus_in then
				screen:find_child(clone13.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone13.extra.reactive = true


local clone14 = Clone
	{
		scale = {1,1,0,0},
		source = clone13,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {932,64,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone14.extra.focus = {}

function clone14:on_key_down(key)
	if clone14.focus[key] then
		if type(clone14.focus[key]) == "function" then
			clone14.focus[key]()
		elseif screen:find_child(clone14.focus[key]) then
			if clone14.on_focus_out then
				clone14.on_focus_out()
			end
			screen:find_child(clone14.focus[key]):grab_key_focus()
			if screen:find_child(clone14.focus[key]).on_focus_in then
				screen:find_child(clone14.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone14.extra.reactive = true


local fish2 = Clone
	{
		scale = {1,1,0,0},
		source = fish1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish2",
		position = {1464,604,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish2.extra.focus = {}

function fish2:on_key_down(key)
	if fish2.focus[key] then
		if type(fish2.focus[key]) == "function" then
			fish2.focus[key]()
		elseif screen:find_child(fish2.focus[key]) then
			if fish2.on_focus_out then
				fish2.on_focus_out()
			end
			screen:find_child(fish2.focus[key]):grab_key_focus()
			if screen:find_child(fish2.focus[key]).on_focus_in then
				screen:find_child(fish2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish2.extra.reactive = true


local fish3 = Clone
	{
		scale = {1,1,0,0},
		source = fish2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish3",
		position = {1264,370,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish3.extra.focus = {}

function fish3:on_key_down(key)
	if fish3.focus[key] then
		if type(fish3.focus[key]) == "function" then
			fish3.focus[key]()
		elseif screen:find_child(fish3.focus[key]) then
			if fish3.on_focus_out then
				fish3.on_focus_out()
			end
			screen:find_child(fish3.focus[key]):grab_key_focus()
			if screen:find_child(fish3.focus[key]).on_focus_in then
				screen:find_child(fish3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish3.extra.reactive = true


local clone16 = Clone
	{
		scale = {1,1,0,0},
		source = image10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone16",
		position = {1856,593,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone16.extra.focus = {}

function clone16:on_key_down(key)
	if clone16.focus[key] then
		if type(clone16.focus[key]) == "function" then
			clone16.focus[key]()
		elseif screen:find_child(clone16.focus[key]) then
			if clone16.on_focus_out then
				clone16.on_focus_out()
			end
			screen:find_child(clone16.focus[key]):grab_key_focus()
			if screen:find_child(clone16.focus[key]).on_focus_in then
				screen:find_child(clone16.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone16.extra.reactive = true


local clone17 = Clone
	{
		scale = {1,1,0,0},
		source = clone16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {1792,593,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone17.extra.focus = {}

function clone17:on_key_down(key)
	if clone17.focus[key] then
		if type(clone17.focus[key]) == "function" then
			clone17.focus[key]()
		elseif screen:find_child(clone17.focus[key]) then
			if clone17.on_focus_out then
				clone17.on_focus_out()
			end
			screen:find_child(clone17.focus[key]):grab_key_focus()
			if screen:find_child(clone17.focus[key]).on_focus_in then
				screen:find_child(clone17.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone17.extra.reactive = true


local clone18 = Clone
	{
		scale = {1,1,0,0},
		source = clone17,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone18",
		position = {1730,593,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone18.extra.focus = {}

function clone18:on_key_down(key)
	if clone18.focus[key] then
		if type(clone18.focus[key]) == "function" then
			clone18.focus[key]()
		elseif screen:find_child(clone18.focus[key]) then
			if clone18.on_focus_out then
				clone18.on_focus_out()
			end
			screen:find_child(clone18.focus[key]):grab_key_focus()
			if screen:find_child(clone18.focus[key]).on_focus_in then
				screen:find_child(clone18.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone18.extra.reactive = true


local clone19 = Clone
	{
		scale = {1,1,0,0},
		source = clone18,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone19",
		position = {1666,593,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone19.extra.focus = {}

function clone19:on_key_down(key)
	if clone19.focus[key] then
		if type(clone19.focus[key]) == "function" then
			clone19.focus[key]()
		elseif screen:find_child(clone19.focus[key]) then
			if clone19.on_focus_out then
				clone19.on_focus_out()
			end
			screen:find_child(clone19.focus[key]):grab_key_focus()
			if screen:find_child(clone19.focus[key]).on_focus_in then
				screen:find_child(clone19.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone19.extra.reactive = true


local clone20 = Clone
	{
		scale = {1,1,0,0},
		source = clone19,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone20",
		position = {1538,595,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone20.extra.focus = {}

function clone20:on_key_down(key)
	if clone20.focus[key] then
		if type(clone20.focus[key]) == "function" then
			clone20.focus[key]()
		elseif screen:find_child(clone20.focus[key]) then
			if clone20.on_focus_out then
				clone20.on_focus_out()
			end
			screen:find_child(clone20.focus[key]):grab_key_focus()
			if screen:find_child(clone20.focus[key]).on_focus_in then
				screen:find_child(clone20.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone20.extra.reactive = true


local clone21 = Clone
	{
		scale = {1,1,0,0},
		source = clone20,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone21",
		position = {1602,593,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone21.extra.focus = {}

function clone21:on_key_down(key)
	if clone21.focus[key] then
		if type(clone21.focus[key]) == "function" then
			clone21.focus[key]()
		elseif screen:find_child(clone21.focus[key]) then
			if clone21.on_focus_out then
				clone21.on_focus_out()
			end
			screen:find_child(clone21.focus[key]):grab_key_focus()
			if screen:find_child(clone21.focus[key]).on_focus_in then
				screen:find_child(clone21.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone21.extra.reactive = true


local fish4 = Clone
	{
		scale = {1,1,0,0},
		source = fish3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish4",
		position = {1168,496,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish4.extra.focus = {}

function fish4:on_key_down(key)
	if fish4.focus[key] then
		if type(fish4.focus[key]) == "function" then
			fish4.focus[key]()
		elseif screen:find_child(fish4.focus[key]) then
			if fish4.on_focus_out then
				fish4.on_focus_out()
			end
			screen:find_child(fish4.focus[key]):grab_key_focus()
			if screen:find_child(fish4.focus[key]).on_focus_in then
				screen:find_child(fish4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish4.extra.reactive = true


local fish5 = Clone
	{
		scale = {1,1,0,0},
		source = fish4,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish5",
		position = {1008,496,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish5.extra.focus = {}

function fish5:on_key_down(key)
	if fish5.focus[key] then
		if type(fish5.focus[key]) == "function" then
			fish5.focus[key]()
		elseif screen:find_child(fish5.focus[key]) then
			if fish5.on_focus_out then
				fish5.on_focus_out()
			end
			screen:find_child(fish5.focus[key]):grab_key_focus()
			if screen:find_child(fish5.focus[key]).on_focus_in then
				screen:find_child(fish5.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish5.extra.reactive = true


local fish6 = Clone
	{
		scale = {1,1,0,0},
		source = fish5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish6",
		position = {920,574,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish6.extra.focus = {}

function fish6:on_key_down(key)
	if fish6.focus[key] then
		if type(fish6.focus[key]) == "function" then
			fish6.focus[key]()
		elseif screen:find_child(fish6.focus[key]) then
			if fish6.on_focus_out then
				fish6.on_focus_out()
			end
			screen:find_child(fish6.focus[key]):grab_key_focus()
			if screen:find_child(fish6.focus[key]).on_focus_in then
				screen:find_child(fish6.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish6.extra.reactive = true


local fish7 = Clone
	{
		scale = {1,1,0,0},
		source = fish6,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish7",
		position = {822,502,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish7.extra.focus = {}

function fish7:on_key_down(key)
	if fish7.focus[key] then
		if type(fish7.focus[key]) == "function" then
			fish7.focus[key]()
		elseif screen:find_child(fish7.focus[key]) then
			if fish7.on_focus_out then
				fish7.on_focus_out()
			end
			screen:find_child(fish7.focus[key]):grab_key_focus()
			if screen:find_child(fish7.focus[key]).on_focus_in then
				screen:find_child(fish7.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish7.extra.reactive = true


local clone28 = Clone
	{
		scale = {1,1,0,0},
		source = clone20,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone28",
		position = {1254,657,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone28.extra.focus = {}

function clone28:on_key_down(key)
	if clone28.focus[key] then
		if type(clone28.focus[key]) == "function" then
			clone28.focus[key]()
		elseif screen:find_child(clone28.focus[key]) then
			if clone28.on_focus_out then
				clone28.on_focus_out()
			end
			screen:find_child(clone28.focus[key]):grab_key_focus()
			if screen:find_child(clone28.focus[key]).on_focus_in then
				screen:find_child(clone28.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone28.extra.reactive = true


local clone29 = Clone
	{
		scale = {1,1,0,0},
		source = clone28,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone29",
		position = {1256,599,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone29.extra.focus = {}

function clone29:on_key_down(key)
	if clone29.focus[key] then
		if type(clone29.focus[key]) == "function" then
			clone29.focus[key]()
		elseif screen:find_child(clone29.focus[key]) then
			if clone29.on_focus_out then
				clone29.on_focus_out()
			end
			screen:find_child(clone29.focus[key]):grab_key_focus()
			if screen:find_child(clone29.focus[key]).on_focus_in then
				screen:find_child(clone29.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone29.extra.reactive = true


local clone30 = Clone
	{
		scale = {1,1,0,0},
		source = clone29,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone30",
		position = {1256,543,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone30.extra.focus = {}

function clone30:on_key_down(key)
	if clone30.focus[key] then
		if type(clone30.focus[key]) == "function" then
			clone30.focus[key]()
		elseif screen:find_child(clone30.focus[key]) then
			if clone30.on_focus_out then
				clone30.on_focus_out()
			end
			screen:find_child(clone30.focus[key]):grab_key_focus()
			if screen:find_child(clone30.focus[key]).on_focus_in then
				screen:find_child(clone30.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone30.extra.reactive = true


local clone31 = Clone
	{
		scale = {1,1,0,0},
		source = clone30,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone31",
		position = {1256,485,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone31.extra.focus = {}

function clone31:on_key_down(key)
	if clone31.focus[key] then
		if type(clone31.focus[key]) == "function" then
			clone31.focus[key]()
		elseif screen:find_child(clone31.focus[key]) then
			if clone31.on_focus_out then
				clone31.on_focus_out()
			end
			screen:find_child(clone31.focus[key]):grab_key_focus()
			if screen:find_child(clone31.focus[key]).on_focus_in then
				screen:find_child(clone31.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone31.extra.reactive = true


local clone32 = Clone
	{
		scale = {1,1,0,0},
		source = clone31,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone32",
		position = {1106,365,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone32.extra.focus = {}

function clone32:on_key_down(key)
	if clone32.focus[key] then
		if type(clone32.focus[key]) == "function" then
			clone32.focus[key]()
		elseif screen:find_child(clone32.focus[key]) then
			if clone32.on_focus_out then
				clone32.on_focus_out()
			end
			screen:find_child(clone32.focus[key]):grab_key_focus()
			if screen:find_child(clone32.focus[key]).on_focus_in then
				screen:find_child(clone32.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone32.extra.reactive = true


local clone33 = Clone
	{
		scale = {1,1,0,0},
		source = clone32,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone33",
		position = {1106,425,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone33.extra.focus = {}

function clone33:on_key_down(key)
	if clone33.focus[key] then
		if type(clone33.focus[key]) == "function" then
			clone33.focus[key]()
		elseif screen:find_child(clone33.focus[key]) then
			if clone33.on_focus_out then
				clone33.on_focus_out()
			end
			screen:find_child(clone33.focus[key]):grab_key_focus()
			if screen:find_child(clone33.focus[key]).on_focus_in then
				screen:find_child(clone33.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone33.extra.reactive = true


local clone34 = Clone
	{
		scale = {1,1,0,0},
		source = clone33,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone34",
		position = {694,657,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone34.extra.focus = {}

function clone34:on_key_down(key)
	if clone34.focus[key] then
		if type(clone34.focus[key]) == "function" then
			clone34.focus[key]()
		elseif screen:find_child(clone34.focus[key]) then
			if clone34.on_focus_out then
				clone34.on_focus_out()
			end
			screen:find_child(clone34.focus[key]):grab_key_focus()
			if screen:find_child(clone34.focus[key]).on_focus_in then
				screen:find_child(clone34.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone34.extra.reactive = true


local clone35 = Clone
	{
		scale = {1,1,0,0},
		source = clone34,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone35",
		position = {932,363,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone35.extra.focus = {}

function clone35:on_key_down(key)
	if clone35.focus[key] then
		if type(clone35.focus[key]) == "function" then
			clone35.focus[key]()
		elseif screen:find_child(clone35.focus[key]) then
			if clone35.on_focus_out then
				clone35.on_focus_out()
			end
			screen:find_child(clone35.focus[key]):grab_key_focus()
			if screen:find_child(clone35.focus[key]).on_focus_in then
				screen:find_child(clone35.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone35.extra.reactive = true


local clone36 = Clone
	{
		scale = {1,1,0,0},
		source = clone35,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone36",
		position = {932,425,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone36.extra.focus = {}

function clone36:on_key_down(key)
	if clone36.focus[key] then
		if type(clone36.focus[key]) == "function" then
			clone36.focus[key]()
		elseif screen:find_child(clone36.focus[key]) then
			if clone36.on_focus_out then
				clone36.on_focus_out()
			end
			screen:find_child(clone36.focus[key]):grab_key_focus()
			if screen:find_child(clone36.focus[key]).on_focus_in then
				screen:find_child(clone36.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone36.extra.reactive = true


local clone37 = Clone
	{
		scale = {1,1,0,0},
		source = clone36,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone37",
		position = {234,531,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone37.extra.focus = {}

function clone37:on_key_down(key)
	if clone37.focus[key] then
		if type(clone37.focus[key]) == "function" then
			clone37.focus[key]()
		elseif screen:find_child(clone37.focus[key]) then
			if clone37.on_focus_out then
				clone37.on_focus_out()
			end
			screen:find_child(clone37.focus[key]):grab_key_focus()
			if screen:find_child(clone37.focus[key]).on_focus_in then
				screen:find_child(clone37.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone37.extra.reactive = true


local clone38 = Clone
	{
		scale = {1,1,0,0},
		source = clone37,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone38",
		position = {464,657,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone38.extra.focus = {}

function clone38:on_key_down(key)
	if clone38.focus[key] then
		if type(clone38.focus[key]) == "function" then
			clone38.focus[key]()
		elseif screen:find_child(clone38.focus[key]) then
			if clone38.on_focus_out then
				clone38.on_focus_out()
			end
			screen:find_child(clone38.focus[key]):grab_key_focus()
			if screen:find_child(clone38.focus[key]).on_focus_in then
				screen:find_child(clone38.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone38.extra.reactive = true


local clone39 = Clone
	{
		scale = {1,1,0,0},
		source = clone38,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone39",
		position = {446,597,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone39.extra.focus = {}

function clone39:on_key_down(key)
	if clone39.focus[key] then
		if type(clone39.focus[key]) == "function" then
			clone39.focus[key]()
		elseif screen:find_child(clone39.focus[key]) then
			if clone39.on_focus_out then
				clone39.on_focus_out()
			end
			screen:find_child(clone39.focus[key]):grab_key_focus()
			if screen:find_child(clone39.focus[key]).on_focus_in then
				screen:find_child(clone39.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone39.extra.reactive = true


local clone40 = Clone
	{
		scale = {1,1,0,0},
		source = clone39,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone40",
		position = {296,533,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone40.extra.focus = {}

function clone40:on_key_down(key)
	if clone40.focus[key] then
		if type(clone40.focus[key]) == "function" then
			clone40.focus[key]()
		elseif screen:find_child(clone40.focus[key]) then
			if clone40.on_focus_out then
				clone40.on_focus_out()
			end
			screen:find_child(clone40.focus[key]):grab_key_focus()
			if screen:find_child(clone40.focus[key]).on_focus_in then
				screen:find_child(clone40.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone40.extra.reactive = true


local clone41 = Clone
	{
		scale = {1,1,0,0},
		source = clone40,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone41",
		position = {418,541,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone41.extra.focus = {}

function clone41:on_key_down(key)
	if clone41.focus[key] then
		if type(clone41.focus[key]) == "function" then
			clone41.focus[key]()
		elseif screen:find_child(clone41.focus[key]) then
			if clone41.on_focus_out then
				clone41.on_focus_out()
			end
			screen:find_child(clone41.focus[key]):grab_key_focus()
			if screen:find_child(clone41.focus[key]).on_focus_in then
				screen:find_child(clone41.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone41.extra.reactive = true


local clone42 = Clone
	{
		scale = {1,1,0,0},
		source = clone41,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone42",
		position = {358,533,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone42.extra.focus = {}

function clone42:on_key_down(key)
	if clone42.focus[key] then
		if type(clone42.focus[key]) == "function" then
			clone42.focus[key]()
		elseif screen:find_child(clone42.focus[key]) then
			if clone42.on_focus_out then
				clone42.on_focus_out()
			end
			screen:find_child(clone42.focus[key]):grab_key_focus()
			if screen:find_child(clone42.focus[key]).on_focus_in then
				screen:find_child(clone42.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone42.extra.reactive = true


local fish8 = Clone
	{
		scale = {1,1,0,0},
		source = fish7,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish8",
		position = {342,436,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish8.extra.focus = {}

function fish8:on_key_down(key)
	if fish8.focus[key] then
		if type(fish8.focus[key]) == "function" then
			fish8.focus[key]()
		elseif screen:find_child(fish8.focus[key]) then
			if fish8.on_focus_out then
				fish8.on_focus_out()
			end
			screen:find_child(fish8.focus[key]):grab_key_focus()
			if screen:find_child(fish8.focus[key]).on_focus_in then
				screen:find_child(fish8.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish8.extra.reactive = true


local clone44 = Clone
	{
		scale = {1,1,0,0},
		source = clone37,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone44",
		position = {610,429,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone44.extra.focus = {}

function clone44:on_key_down(key)
	if clone44.focus[key] then
		if type(clone44.focus[key]) == "function" then
			clone44.focus[key]()
		elseif screen:find_child(clone44.focus[key]) then
			if clone44.on_focus_out then
				clone44.on_focus_out()
			end
			screen:find_child(clone44.focus[key]):grab_key_focus()
			if screen:find_child(clone44.focus[key]).on_focus_in then
				screen:find_child(clone44.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone44.extra.reactive = true


local clone45 = Clone
	{
		scale = {1,1,0,0},
		source = clone44,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone45",
		position = {576,489,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone45.extra.focus = {}

function clone45:on_key_down(key)
	if clone45.focus[key] then
		if type(clone45.focus[key]) == "function" then
			clone45.focus[key]()
		elseif screen:find_child(clone45.focus[key]) then
			if clone45.on_focus_out then
				clone45.on_focus_out()
			end
			screen:find_child(clone45.focus[key]):grab_key_focus()
			if screen:find_child(clone45.focus[key]).on_focus_in then
				screen:find_child(clone45.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone45.extra.reactive = true


local fish9 = Clone
	{
		scale = {1,1,0,0},
		source = fish2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish9",
		position = {1362,604,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish9.extra.focus = {}

function fish9:on_key_down(key)
	if fish9.focus[key] then
		if type(fish9.focus[key]) == "function" then
			fish9.focus[key]()
		elseif screen:find_child(fish9.focus[key]) then
			if fish9.on_focus_out then
				fish9.on_focus_out()
			end
			screen:find_child(fish9.focus[key]):grab_key_focus()
			if screen:find_child(fish9.focus[key]).on_focus_in then
				screen:find_child(fish9.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish9.extra.reactive = true


local clone46 = Clone
	{
		scale = {1,1,0,0},
		source = clone37,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone46",
		position = {362,951,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone46.extra.focus = {}

function clone46:on_key_down(key)
	if clone46.focus[key] then
		if type(clone46.focus[key]) == "function" then
			clone46.focus[key]()
		elseif screen:find_child(clone46.focus[key]) then
			if clone46.on_focus_out then
				clone46.on_focus_out()
			end
			screen:find_child(clone46.focus[key]):grab_key_focus()
			if screen:find_child(clone46.focus[key]).on_focus_in then
				screen:find_child(clone46.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone46.extra.reactive = true


local clone47 = Clone
	{
		scale = {1,1,0,0},
		source = clone46,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone47",
		position = {426,951,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone47.extra.focus = {}

function clone47:on_key_down(key)
	if clone47.focus[key] then
		if type(clone47.focus[key]) == "function" then
			clone47.focus[key]()
		elseif screen:find_child(clone47.focus[key]) then
			if clone47.on_focus_out then
				clone47.on_focus_out()
			end
			screen:find_child(clone47.focus[key]):grab_key_focus()
			if screen:find_child(clone47.focus[key]).on_focus_in then
				screen:find_child(clone47.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone47.extra.reactive = true


local clone48 = Clone
	{
		scale = {1,1,0,0},
		source = clone47,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone48",
		position = {490,951,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone48.extra.focus = {}

function clone48:on_key_down(key)
	if clone48.focus[key] then
		if type(clone48.focus[key]) == "function" then
			clone48.focus[key]()
		elseif screen:find_child(clone48.focus[key]) then
			if clone48.on_focus_out then
				clone48.on_focus_out()
			end
			screen:find_child(clone48.focus[key]):grab_key_focus()
			if screen:find_child(clone48.focus[key]).on_focus_in then
				screen:find_child(clone48.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone48.extra.reactive = true


local fish10 = Clone
	{
		scale = {1,1,0,0},
		source = fish8,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish10",
		position = {260,956,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish10.extra.focus = {}

function fish10:on_key_down(key)
	if fish10.focus[key] then
		if type(fish10.focus[key]) == "function" then
			fish10.focus[key]()
		elseif screen:find_child(fish10.focus[key]) then
			if fish10.on_focus_out then
				fish10.on_focus_out()
			end
			screen:find_child(fish10.focus[key]):grab_key_focus()
			if screen:find_child(fish10.focus[key]).on_focus_in then
				screen:find_child(fish10.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish10.extra.reactive = true


local rfish1 = Image
	{
		src = "/assets/images/collect_red.png",
		clip = {0,0,64,49},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rfish1",
		position = {292,850,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

rfish1.extra.focus = {}

function rfish1:on_key_down(key)
	if rfish1.focus[key] then
		if type(rfish1.focus[key]) == "function" then
			rfish1.focus[key]()
		elseif screen:find_child(rfish1.focus[key]) then
			if rfish1.on_focus_out then
				rfish1.on_focus_out()
			end
			screen:find_child(rfish1.focus[key]):grab_key_focus()
			if screen:find_child(rfish1.focus[key]).on_focus_in then
				screen:find_child(rfish1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

rfish1.extra.reactive = true


local clone51 = Clone
	{
		scale = {1,1,0,0},
		source = clone48,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone51",
		position = {470,721,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone51.extra.focus = {}

function clone51:on_key_down(key)
	if clone51.focus[key] then
		if type(clone51.focus[key]) == "function" then
			clone51.focus[key]()
		elseif screen:find_child(clone51.focus[key]) then
			if clone51.on_focus_out then
				clone51.on_focus_out()
			end
			screen:find_child(clone51.focus[key]):grab_key_focus()
			if screen:find_child(clone51.focus[key]).on_focus_in then
				screen:find_child(clone51.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone51.extra.reactive = true


local clone52 = Clone
	{
		scale = {1,1,0,0},
		source = clone48,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone52",
		position = {554,949,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone52.extra.focus = {}

function clone52:on_key_down(key)
	if clone52.focus[key] then
		if type(clone52.focus[key]) == "function" then
			clone52.focus[key]()
		elseif screen:find_child(clone52.focus[key]) then
			if clone52.on_focus_out then
				clone52.on_focus_out()
			end
			screen:find_child(clone52.focus[key]):grab_key_focus()
			if screen:find_child(clone52.focus[key]).on_focus_in then
				screen:find_child(clone52.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone52.extra.reactive = true


local clone53 = Clone
	{
		scale = {1,1,0,0},
		source = clone51,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone53",
		position = {482,779,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone53.extra.focus = {}

function clone53:on_key_down(key)
	if clone53.focus[key] then
		if type(clone53.focus[key]) == "function" then
			clone53.focus[key]()
		elseif screen:find_child(clone53.focus[key]) then
			if clone53.on_focus_out then
				clone53.on_focus_out()
			end
			screen:find_child(clone53.focus[key]):grab_key_focus()
			if screen:find_child(clone53.focus[key]).on_focus_in then
				screen:find_child(clone53.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone53.extra.reactive = true


local gfish1 = Image
	{
		src = "/assets/images/collect_green.png",
		clip = {0,0,64,49},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gfish1",
		position = {386,1020,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

gfish1.extra.focus = {}

function gfish1:on_key_down(key)
	if gfish1.focus[key] then
		if type(gfish1.focus[key]) == "function" then
			gfish1.focus[key]()
		elseif screen:find_child(gfish1.focus[key]) then
			if gfish1.on_focus_out then
				gfish1.on_focus_out()
			end
			screen:find_child(gfish1.focus[key]):grab_key_focus()
			if screen:find_child(gfish1.focus[key]).on_focus_in then
				screen:find_child(gfish1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

gfish1.extra.reactive = true


local gfish2 = Clone
	{
		scale = {1,1,0,0},
		source = gfish1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gfish2",
		position = {470,1022,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

gfish2.extra.focus = {}

function gfish2:on_key_down(key)
	if gfish2.focus[key] then
		if type(gfish2.focus[key]) == "function" then
			gfish2.focus[key]()
		elseif screen:find_child(gfish2.focus[key]) then
			if gfish2.on_focus_out then
				gfish2.on_focus_out()
			end
			screen:find_child(gfish2.focus[key]):grab_key_focus()
			if screen:find_child(gfish2.focus[key]).on_focus_in then
				screen:find_child(gfish2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

gfish2.extra.reactive = true


local clone56 = Clone
	{
		scale = {1,1,0,0},
		source = clone52,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone56",
		position = {732,721,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone56.extra.focus = {}

function clone56:on_key_down(key)
	if clone56.focus[key] then
		if type(clone56.focus[key]) == "function" then
			clone56.focus[key]()
		elseif screen:find_child(clone56.focus[key]) then
			if clone56.on_focus_out then
				clone56.on_focus_out()
			end
			screen:find_child(clone56.focus[key]):grab_key_focus()
			if screen:find_child(clone56.focus[key]).on_focus_in then
				screen:find_child(clone56.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone56.extra.reactive = true


local clone57 = Clone
	{
		scale = {1,1,0,0},
		source = clone56,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone57",
		position = {770,1047,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone57.extra.focus = {}

function clone57:on_key_down(key)
	if clone57.focus[key] then
		if type(clone57.focus[key]) == "function" then
			clone57.focus[key]()
		elseif screen:find_child(clone57.focus[key]) then
			if clone57.on_focus_out then
				clone57.on_focus_out()
			end
			screen:find_child(clone57.focus[key]):grab_key_focus()
			if screen:find_child(clone57.focus[key]).on_focus_in then
				screen:find_child(clone57.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone57.extra.reactive = true


local fish11 = Clone
	{
		scale = {1,1,0,0},
		source = fish10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish11",
		position = {1202,728,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish11.extra.focus = {}

function fish11:on_key_down(key)
	if fish11.focus[key] then
		if type(fish11.focus[key]) == "function" then
			fish11.focus[key]()
		elseif screen:find_child(fish11.focus[key]) then
			if fish11.on_focus_out then
				fish11.on_focus_out()
			end
			screen:find_child(fish11.focus[key]):grab_key_focus()
			if screen:find_child(fish11.focus[key]).on_focus_in then
				screen:find_child(fish11.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish11.extra.reactive = true


local clone59 = Clone
	{
		scale = {1,1,0,0},
		source = clone52,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone59",
		position = {1470,721,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone59.extra.focus = {}

function clone59:on_key_down(key)
	if clone59.focus[key] then
		if type(clone59.focus[key]) == "function" then
			clone59.focus[key]()
		elseif screen:find_child(clone59.focus[key]) then
			if clone59.on_focus_out then
				clone59.on_focus_out()
			end
			screen:find_child(clone59.focus[key]):grab_key_focus()
			if screen:find_child(clone59.focus[key]).on_focus_in then
				screen:find_child(clone59.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone59.extra.reactive = true


local clone60 = Clone
	{
		scale = {1,1,0,0},
		source = clone59,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone60",
		position = {1472,783,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone60.extra.focus = {}

function clone60:on_key_down(key)
	if clone60.focus[key] then
		if type(clone60.focus[key]) == "function" then
			clone60.focus[key]()
		elseif screen:find_child(clone60.focus[key]) then
			if clone60.on_focus_out then
				clone60.on_focus_out()
			end
			screen:find_child(clone60.focus[key]):grab_key_focus()
			if screen:find_child(clone60.focus[key]).on_focus_in then
				screen:find_child(clone60.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone60.extra.reactive = true


local clone61 = Clone
	{
		scale = {1,1,0,0},
		source = clone60,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone61",
		position = {1472,845,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone61.extra.focus = {}

function clone61:on_key_down(key)
	if clone61.focus[key] then
		if type(clone61.focus[key]) == "function" then
			clone61.focus[key]()
		elseif screen:find_child(clone61.focus[key]) then
			if clone61.on_focus_out then
				clone61.on_focus_out()
			end
			screen:find_child(clone61.focus[key]):grab_key_focus()
			if screen:find_child(clone61.focus[key]).on_focus_in then
				screen:find_child(clone61.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone61.extra.reactive = true


local clone62 = Clone
	{
		scale = {1,1,0,0},
		source = clone61,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone62",
		position = {1476,1017,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone62.extra.focus = {}

function clone62:on_key_down(key)
	if clone62.focus[key] then
		if type(clone62.focus[key]) == "function" then
			clone62.focus[key]()
		elseif screen:find_child(clone62.focus[key]) then
			if clone62.on_focus_out then
				clone62.on_focus_out()
			end
			screen:find_child(clone62.focus[key]):grab_key_focus()
			if screen:find_child(clone62.focus[key]).on_focus_in then
				screen:find_child(clone62.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone62.extra.reactive = true


local rfish2 = Clone
	{
		scale = {1,1,0,0},
		source = rfish1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rfish2",
		position = {1200,770,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

rfish2.extra.focus = {}

function rfish2:on_key_down(key)
	if rfish2.focus[key] then
		if type(rfish2.focus[key]) == "function" then
			rfish2.focus[key]()
		elseif screen:find_child(rfish2.focus[key]) then
			if rfish2.on_focus_out then
				rfish2.on_focus_out()
			end
			screen:find_child(rfish2.focus[key]):grab_key_focus()
			if screen:find_child(rfish2.focus[key]).on_focus_in then
				screen:find_child(rfish2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

rfish2.extra.reactive = true


local clone63 = Clone
	{
		scale = {1,1,0,0},
		source = clone56,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone63",
		position = {1004,721,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone63.extra.focus = {}

function clone63:on_key_down(key)
	if clone63.focus[key] then
		if type(clone63.focus[key]) == "function" then
			clone63.focus[key]()
		elseif screen:find_child(clone63.focus[key]) then
			if clone63.on_focus_out then
				clone63.on_focus_out()
			end
			screen:find_child(clone63.focus[key]):grab_key_focus()
			if screen:find_child(clone63.focus[key]).on_focus_in then
				screen:find_child(clone63.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone63.extra.reactive = true

local deaths = Text
	{
		color = {0,0,0,255},
		font = "Soup of Justice 50px",
		text = "0",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "deaths",
		position = {20,20,0},
		size = {150,64},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

deaths.extra.focus = {}

function deaths:on_key_down(key)
	if deaths.focus[key] then
		if type(deaths.focus[key]) == "function" then
			deaths.focus[key]()
		elseif screen:find_child(deaths.focus[key]) then
			if deaths.on_focus_out then
				deaths.on_focus_out()
			end
			screen:find_child(deaths.focus[key]):grab_key_focus()
			if screen:find_child(deaths.focus[key]).on_focus_in then
				screen:find_child(deaths.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

deaths.extra.reactive = true

g:add(bg3,bg2,bg1,player,hat,image3,clone4,clone6,fish1,image10,clone11,clone12,clone13,clone14,fish2,fish3,clone16,clone17,clone18,
clone19,clone20,clone21,fish4,fish5,fish6,fish7,clone28,clone29,clone30,clone31,clone32,clone33,clone34,clone35,clone36,clone37,clone38,
clone39,clone40,clone41,clone42,fish8,clone44,clone45,fish9,clone46,clone47,clone48,fish10,rfish1,clone51,clone52,clone53,gfish1,gfish2,
clone56,clone57,fish11,clone59,clone60,clone61,clone62,rfish2,clone63,deaths)

local colliders = {fish1,image10,clone11,clone12,clone13,clone14,fish2,fish3,clone16,clone17,clone18,
clone19,clone20,clone21,fish4,fish5,fish6,fish7,clone28,clone29,clone30,clone31,clone32,clone33,clone34,clone35,clone36,clone37,clone38,
clone39,clone40,clone41,clone42,fish8,clone44,clone45,fish9,clone46,clone47,clone48,fish10,rfish1,clone51,clone52,clone53,gfish1,gfish2,
clone56,clone57,fish11,clone59,clone60,clone61,clone62,rfish2,clone63}

fish1.extra.event = {event_type = "gravity reverse"}
fish2.extra.event = {event_type = "gravity reverse"}
fish3.extra.event = {event_type = "gravity reverse"}
fish4.extra.event = {event_type = "gravity reverse"}
fish5.extra.event = {event_type = "gravity reverse"}
fish6.extra.event = {event_type = "gravity reverse"}
fish7.extra.event = {event_type = "gravity reverse"}
fish8.extra.event = {event_type = "gravity reverse"}
fish9.extra.event = {event_type = "gravity reverse"}
fish10.extra.event = {event_type = "gravity reverse"}
fish11.extra.event = {event_type = "gravity reverse"}
rfish1.extra.event = {event_type = "gravity up"}
rfish2.extra.event = {event_type = "gravity up"}
gfish1.extra.event = {event_type = "gravity down"}
gfish2.extra.event = {event_type = "gravity down"}


return colliders
