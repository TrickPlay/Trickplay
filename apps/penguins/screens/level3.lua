local g = ... 


local bg3 = Clone
	{
		source = b3,
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
		source = b2,
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
		source = b1,
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
		source = p,
		clip = {0,0,45,45},
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


local image3 = Image
	{
		src = "/assets/igloo.png",
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


local image5 = Image
	{
		src = "/assets/lvl1_ice.png",
		clip = {0,0,65,62},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image5",
		position = {590,326,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

image5.extra.focus = {}

function image5:on_key_down(key)
	if image5.focus[key] then
		if type(image5.focus[key]) == "function" then
			image5.focus[key]()
		elseif screen:find_child(image5.focus[key]) then
			if image5.on_focus_out then
				image5.on_focus_out()
			end
			screen:find_child(image5.focus[key]):grab_key_focus()
			if screen:find_child(image5.focus[key]).on_focus_in then
				screen:find_child(image5.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image5.extra.reactive = true


local clone7 = Clone
	{
		scale = {1,1,0,0},
		source = image5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone7",
		position = {592,264,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone7.extra.focus = {}

function clone7:on_key_down(key)
	if clone7.focus[key] then
		if type(clone7.focus[key]) == "function" then
			clone7.focus[key]()
		elseif screen:find_child(clone7.focus[key]) then
			if clone7.on_focus_out then
				clone7.on_focus_out()
			end
			screen:find_child(clone7.focus[key]):grab_key_focus()
			if screen:find_child(clone7.focus[key]).on_focus_in then
				screen:find_child(clone7.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone7.extra.reactive = true


local clone8 = Clone
	{
		scale = {1,1,0,0},
		source = image5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone8",
		position = {528,326,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone8.extra.focus = {}

function clone8:on_key_down(key)
	if clone8.focus[key] then
		if type(clone8.focus[key]) == "function" then
			clone8.focus[key]()
		elseif screen:find_child(clone8.focus[key]) then
			if clone8.on_focus_out then
				clone8.on_focus_out()
			end
			screen:find_child(clone8.focus[key]):grab_key_focus()
			if screen:find_child(clone8.focus[key]).on_focus_in then
				screen:find_child(clone8.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone8.extra.reactive = true


local clone9 = Clone
	{
		scale = {1,1,0,0},
		source = clone7,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone9",
		position = {924,298,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone9.extra.focus = {}

function clone9:on_key_down(key)
	if clone9.focus[key] then
		if type(clone9.focus[key]) == "function" then
			clone9.focus[key]()
		elseif screen:find_child(clone9.focus[key]) then
			if clone9.on_focus_out then
				clone9.on_focus_out()
			end
			screen:find_child(clone9.focus[key]):grab_key_focus()
			if screen:find_child(clone9.focus[key]).on_focus_in then
				screen:find_child(clone9.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone9.extra.reactive = true


local clone10 = Clone
	{
		scale = {1,1,0,0},
		source = clone9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone10",
		position = {654,326,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone10.extra.focus = {}

function clone10:on_key_down(key)
	if clone10.focus[key] then
		if type(clone10.focus[key]) == "function" then
			clone10.focus[key]()
		elseif screen:find_child(clone10.focus[key]) then
			if clone10.on_focus_out then
				clone10.on_focus_out()
			end
			screen:find_child(clone10.focus[key]):grab_key_focus()
			if screen:find_child(clone10.focus[key]).on_focus_in then
				screen:find_child(clone10.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone10.extra.reactive = true


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = clone9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {926,242,0},
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
		position = {1222,300,0},
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
		position = {1284,300,0},
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
		position = {1282,238,0},
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


local clone15 = Clone
	{
		scale = {1,1,0,0},
		source = clone12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone15",
		position = {1338,658,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone15.extra.focus = {}

function clone15:on_key_down(key)
	if clone15.focus[key] then
		if type(clone15.focus[key]) == "function" then
			clone15.focus[key]()
		elseif screen:find_child(clone15.focus[key]) then
			if clone15.on_focus_out then
				clone15.on_focus_out()
			end
			screen:find_child(clone15.focus[key]):grab_key_focus()
			if screen:find_child(clone15.focus[key]).on_focus_in then
				screen:find_child(clone15.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone15.extra.reactive = true


local clone16 = Clone
	{
		scale = {1,1,0,0},
		source = clone15,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone16",
		position = {1340,598,0},
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
		source = clone10,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {1014,660,0},
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
		position = {414,958,0},
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
		position = {478,958,0},
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
		position = {636,1018,0},
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
		position = {1088,1016,0},
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


local clone22 = Clone
	{
		scale = {1,1,0,0},
		source = clone21,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone22",
		position = {1062,956,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone22.extra.focus = {}

function clone22:on_key_down(key)
	if clone22.focus[key] then
		if type(clone22.focus[key]) == "function" then
			clone22.focus[key]()
		elseif screen:find_child(clone22.focus[key]) then
			if clone22.on_focus_out then
				clone22.on_focus_out()
			end
			screen:find_child(clone22.focus[key]):grab_key_focus()
			if screen:find_child(clone22.focus[key]).on_focus_in then
				screen:find_child(clone22.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone22.extra.reactive = true


local clone23 = Clone
	{
		scale = {1,1,0,0},
		source = clone22,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone23",
		position = {1322,1058,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone23.extra.focus = {}

function clone23:on_key_down(key)
	if clone23.focus[key] then
		if type(clone23.focus[key]) == "function" then
			clone23.focus[key]()
		elseif screen:find_child(clone23.focus[key]) then
			if clone23.on_focus_out then
				clone23.on_focus_out()
			end
			screen:find_child(clone23.focus[key]):grab_key_focus()
			if screen:find_child(clone23.focus[key]).on_focus_in then
				screen:find_child(clone23.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone23.extra.reactive = true


local head1 = Image
	{
		src = "/assets/lvl3_head_3.png",
		clip = {0,0,492,47},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "head1",
		position = {200,35,0},
		size = {492,47},
		opacity = 0,
		reactive = true,
	}

head1.extra.focus = {}

function head1:on_key_down(key)
	if head1.focus[key] then
		if type(head1.focus[key]) == "function" then
			head1.focus[key]()
		elseif screen:find_child(head1.focus[key]) then
			if head1.on_focus_out then
				head1.on_focus_out()
			end
			screen:find_child(head1.focus[key]):grab_key_focus()
			if screen:find_child(head1.focus[key]).on_focus_in then
				screen:find_child(head1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

head1.extra.reactive = true


local head2 = Image
	{
		src = "/assets/lvl7_head_4.png",
		clip = {0,0,286,49},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "head2",
		position = {702,395,0},
		size = {286,49},
		opacity = 0,
		reactive = true,
	}

head2.extra.focus = {}

function head2:on_key_down(key)
	if head2.focus[key] then
		if type(head2.focus[key]) == "function" then
			head2.focus[key]()
		elseif screen:find_child(head2.focus[key]) then
			if head2.on_focus_out then
				head2.on_focus_out()
			end
			screen:find_child(head2.focus[key]):grab_key_focus()
			if screen:find_child(head2.focus[key]).on_focus_in then
				screen:find_child(head2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

head2.extra.reactive = true


local head3 = Image
	{
		src = "/assets/zon_head_1.png",
		clip = {0,0,417,53},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "head3",
		position = {464,755,0},
		size = {417,53},
		opacity = 0,
		reactive = true,
	}

head3.extra.focus = {}

function head3:on_key_down(key)
	if head3.focus[key] then
		if type(head3.focus[key]) == "function" then
			head3.focus[key]()
		elseif screen:find_child(head3.focus[key]) then
			if head3.on_focus_out then
				head3.on_focus_out()
			end
			screen:find_child(head3.focus[key]):grab_key_focus()
			if screen:find_child(head3.focus[key]).on_focus_in then
				screen:find_child(head3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

head3.extra.reactive = true


local head4 = Image
	{
		src = "/assets/zon_head_2.png",
		clip = {0,0,317,47},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "head4",
		position = {1412,755,0},
		size = {317,47},
		opacity = 0,
		reactive = true,
	}

head4.extra.focus = {}

function head4:on_key_down(key)
	if head4.focus[key] then
		if type(head4.focus[key]) == "function" then
			head4.focus[key]()
		elseif screen:find_child(head4.focus[key]) then
			if head4.on_focus_out then
				head4.on_focus_out()
			end
			screen:find_child(head4.focus[key]):grab_key_focus()
			if screen:find_child(head4.focus[key]).on_focus_in then
				screen:find_child(head4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

head4.extra.reactive = true

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

g:add(bg3,bg2,bg1,player,image3,clone4,clone6,image5,clone7,clone8,clone9,clone10,clone11,clone12,clone13,clone14,
clone15,clone16,clone17,clone18,clone19,clone20,clone21,clone22,clone23,head1,head2,head3,head4,deaths)

local colliders = {image5,clone7,clone8,clone9,clone10,clone11,clone12,clone13,clone14,clone15,clone16,clone17,clone18,clone19,clone20,clone21,clone22,clone23}

local event1 =
	{
		row = 2,
		time = 3000,
		event_type = "move",
		ui = image5,
		position = {590,660},
		original = {590,326},
		triggered = false,
	}

local event2 =
	{
		row = 1,
		time = 0,
		event_type = "appear",
		ui = head1,
		triggered = false,
	}

local event3 =
	{
		row = 2,
		time = 3000,
		event_type = "appear",
		ui = head2,
		triggered = false,
	}

local event4 =
	{
		row = 3,
		time = 0,
		event_type = "appear",
		ui = head3,
		triggered = false
	}

local event5 =
	{
		row = 2,
		time = 0,
		event_type = "disappear",
		ui = head1,
		triggered = false,
	}

local event6 =
	{
		row = 3,
		time = 0,
		event_type = "disappear",
		ui = head2,
		triggered = false,
	}

local event7 =
	{
		row = 3,
		time = 3500,
		event_type = "appear",
		ui = head4,
		triggered = false
	}

local event8 =
	{
		row = 3,
		time = 3500,
		event_type = "disappear",
		ui = head3,
		triggered = false,
	}

local events = {event1,event2,event3,event4,event5,event6,event7,event8}

return colliders, events
