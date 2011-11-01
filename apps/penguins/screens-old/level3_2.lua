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


local drop12 = Image
	{
		src = "/assets/obstacle_1.png",
		clip = {0,0,65,62},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop12",
		position = {350,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop12.extra.focus = {}

function drop12:on_key_down(key)
	if drop12.focus[key] then
		if type(drop12.focus[key]) == "function" then
			drop12.focus[key]()
		elseif screen:find_child(drop12.focus[key]) then
			if drop12.on_focus_out then
				drop12.on_focus_out()
			end
			screen:find_child(drop12.focus[key]):grab_key_focus()
			if screen:find_child(drop12.focus[key]).on_focus_in then
				screen:find_child(drop12.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop12.extra.reactive = true


local move1 = Clone
	{
		scale = {1,2,0,0},
		source = drop12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "move1",
		position = {1588,236,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

move1.extra.focus = {}

function move1:on_key_down(key)
	if move1.focus[key] then
		if type(move1.focus[key]) == "function" then
			move1.focus[key]()
		elseif screen:find_child(move1.focus[key]) then
			if move1.on_focus_out then
				move1.on_focus_out()
			end
			screen:find_child(move1.focus[key]):grab_key_focus()
			if screen:find_child(move1.focus[key]).on_focus_in then
				screen:find_child(move1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

move1.extra.reactive = true


local move2 = Clone
	{
		scale = {1,2,0,0},
		source = move1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "move2",
		position = {1652,180,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

move2.extra.focus = {}

function move2:on_key_down(key)
	if move2.focus[key] then
		if type(move2.focus[key]) == "function" then
			move2.focus[key]()
		elseif screen:find_child(move2.focus[key]) then
			if move2.on_focus_out then
				move2.on_focus_out()
			end
			screen:find_child(move2.focus[key]):grab_key_focus()
			if screen:find_child(move2.focus[key]).on_focus_in then
				screen:find_child(move2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

move2.extra.reactive = true


local move3 = Clone
	{
		scale = {1,2,0,0},
		source = move2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "move3",
		position = {1714,180,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

move3.extra.focus = {}

function move3:on_key_down(key)
	if move3.focus[key] then
		if type(move3.focus[key]) == "function" then
			move3.focus[key]()
		elseif screen:find_child(move3.focus[key]) then
			if move3.on_focus_out then
				move3.on_focus_out()
			end
			screen:find_child(move3.focus[key]):grab_key_focus()
			if screen:find_child(move3.focus[key]).on_focus_in then
				screen:find_child(move3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

move3.extra.reactive = true


local move4 = Clone
	{
		scale = {1,2,0,0},
		source = move3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "move4",
		position = {1778,236,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

move4.extra.focus = {}

function move4:on_key_down(key)
	if move4.focus[key] then
		if type(move4.focus[key]) == "function" then
			move4.focus[key]()
		elseif screen:find_child(move4.focus[key]) then
			if move4.on_focus_out then
				move4.on_focus_out()
			end
			screen:find_child(move4.focus[key]):grab_key_focus()
			if screen:find_child(move4.focus[key]).on_focus_in then
				screen:find_child(move4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

move4.extra.reactive = true


local drop13 = Clone
	{
		scale = {1,1,0,0},
		source = drop12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop13",
		position = {410,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop13.extra.focus = {}

function drop13:on_key_down(key)
	if drop13.focus[key] then
		if type(drop13.focus[key]) == "function" then
			drop13.focus[key]()
		elseif screen:find_child(drop13.focus[key]) then
			if drop13.on_focus_out then
				drop13.on_focus_out()
			end
			screen:find_child(drop13.focus[key]):grab_key_focus()
			if screen:find_child(drop13.focus[key]).on_focus_in then
				screen:find_child(drop13.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop13.extra.reactive = true


local drop14 = Clone
	{
		scale = {1,1,0,0},
		source = drop13,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop14",
		position = {470,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop14.extra.focus = {}

function drop14:on_key_down(key)
	if drop14.focus[key] then
		if type(drop14.focus[key]) == "function" then
			drop14.focus[key]()
		elseif screen:find_child(drop14.focus[key]) then
			if drop14.on_focus_out then
				drop14.on_focus_out()
			end
			screen:find_child(drop14.focus[key]):grab_key_focus()
			if screen:find_child(drop14.focus[key]).on_focus_in then
				screen:find_child(drop14.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop14.extra.reactive = true


local drop32 = Clone
	{
		scale = {1,1,0,0},
		source = drop14,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop32",
		position = {830,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop32.extra.focus = {}

function drop32:on_key_down(key)
	if drop32.focus[key] then
		if type(drop32.focus[key]) == "function" then
			drop32.focus[key]()
		elseif screen:find_child(drop32.focus[key]) then
			if drop32.on_focus_out then
				drop32.on_focus_out()
			end
			screen:find_child(drop32.focus[key]):grab_key_focus()
			if screen:find_child(drop32.focus[key]).on_focus_in then
				screen:find_child(drop32.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop32.extra.reactive = true


local drop31 = Clone
	{
		scale = {1,1,0,0},
		source = drop32,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop31",
		position = {770,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop31.extra.focus = {}

function drop31:on_key_down(key)
	if drop31.focus[key] then
		if type(drop31.focus[key]) == "function" then
			drop31.focus[key]()
		elseif screen:find_child(drop31.focus[key]) then
			if drop31.on_focus_out then
				drop31.on_focus_out()
			end
			screen:find_child(drop31.focus[key]):grab_key_focus()
			if screen:find_child(drop31.focus[key]).on_focus_in then
				screen:find_child(drop31.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop31.extra.reactive = true


local drop24 = Clone
	{
		scale = {1,1,0,0},
		source = drop31,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop24",
		position = {710,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop24.extra.focus = {}

function drop24:on_key_down(key)
	if drop24.focus[key] then
		if type(drop24.focus[key]) == "function" then
			drop24.focus[key]()
		elseif screen:find_child(drop24.focus[key]) then
			if drop24.on_focus_out then
				drop24.on_focus_out()
			end
			screen:find_child(drop24.focus[key]):grab_key_focus()
			if screen:find_child(drop24.focus[key]).on_focus_in then
				screen:find_child(drop24.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop24.extra.reactive = true


local drop23 = Clone
	{
		scale = {1,1,0,0},
		source = drop24,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop23",
		position = {650,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop23.extra.focus = {}

function drop23:on_key_down(key)
	if drop23.focus[key] then
		if type(drop23.focus[key]) == "function" then
			drop23.focus[key]()
		elseif screen:find_child(drop23.focus[key]) then
			if drop23.on_focus_out then
				drop23.on_focus_out()
			end
			screen:find_child(drop23.focus[key]):grab_key_focus()
			if screen:find_child(drop23.focus[key]).on_focus_in then
				screen:find_child(drop23.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop23.extra.reactive = true


local drop22 = Clone
	{
		scale = {1,1,0,0},
		source = drop23,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop22",
		position = {590,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop22.extra.focus = {}

function drop22:on_key_down(key)
	if drop22.focus[key] then
		if type(drop22.focus[key]) == "function" then
			drop22.focus[key]()
		elseif screen:find_child(drop22.focus[key]) then
			if drop22.on_focus_out then
				drop22.on_focus_out()
			end
			screen:find_child(drop22.focus[key]):grab_key_focus()
			if screen:find_child(drop22.focus[key]).on_focus_in then
				screen:find_child(drop22.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop22.extra.reactive = true


local drop21 = Clone
	{
		scale = {1,1,0,0},
		source = drop22,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop21",
		position = {530,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop21.extra.focus = {}

function drop21:on_key_down(key)
	if drop21.focus[key] then
		if type(drop21.focus[key]) == "function" then
			drop21.focus[key]()
		elseif screen:find_child(drop21.focus[key]) then
			if drop21.on_focus_out then
				drop21.on_focus_out()
			end
			screen:find_child(drop21.focus[key]):grab_key_focus()
			if screen:find_child(drop21.focus[key]).on_focus_in then
				screen:find_child(drop21.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop21.extra.reactive = true


local drop33 = Clone
	{
		scale = {1,1,0,0},
		source = drop32,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop33",
		position = {890,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop33.extra.focus = {}

function drop33:on_key_down(key)
	if drop33.focus[key] then
		if type(drop33.focus[key]) == "function" then
			drop33.focus[key]()
		elseif screen:find_child(drop33.focus[key]) then
			if drop33.on_focus_out then
				drop33.on_focus_out()
			end
			screen:find_child(drop33.focus[key]):grab_key_focus()
			if screen:find_child(drop33.focus[key]).on_focus_in then
				screen:find_child(drop33.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop33.extra.reactive = true


local drop43 = Clone
	{
		scale = {1,1,0,0},
		source = drop33,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop43",
		position = {1130,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop43.extra.focus = {}

function drop43:on_key_down(key)
	if drop43.focus[key] then
		if type(drop43.focus[key]) == "function" then
			drop43.focus[key]()
		elseif screen:find_child(drop43.focus[key]) then
			if drop43.on_focus_out then
				drop43.on_focus_out()
			end
			screen:find_child(drop43.focus[key]):grab_key_focus()
			if screen:find_child(drop43.focus[key]).on_focus_in then
				screen:find_child(drop43.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop43.extra.reactive = true


local drop53 = Clone
	{
		scale = {1,1,0,0},
		source = drop43,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop53",
		position = {1370,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop53.extra.focus = {}

function drop53:on_key_down(key)
	if drop53.focus[key] then
		if type(drop53.focus[key]) == "function" then
			drop53.focus[key]()
		elseif screen:find_child(drop53.focus[key]) then
			if drop53.on_focus_out then
				drop53.on_focus_out()
			end
			screen:find_child(drop53.focus[key]):grab_key_focus()
			if screen:find_child(drop53.focus[key]).on_focus_in then
				screen:find_child(drop53.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop53.extra.reactive = true


local drop54 = Clone
	{
		scale = {1,1,0,0},
		source = drop53,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop54",
		position = {1430,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop54.extra.focus = {}

function drop54:on_key_down(key)
	if drop54.focus[key] then
		if type(drop54.focus[key]) == "function" then
			drop54.focus[key]()
		elseif screen:find_child(drop54.focus[key]) then
			if drop54.on_focus_out then
				drop54.on_focus_out()
			end
			screen:find_child(drop54.focus[key]):grab_key_focus()
			if screen:find_child(drop54.focus[key]).on_focus_in then
				screen:find_child(drop54.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop54.extra.reactive = true


local drop52 = Clone
	{
		scale = {1,1,0,0},
		source = drop54,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop52",
		position = {1310,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop52.extra.focus = {}

function drop52:on_key_down(key)
	if drop52.focus[key] then
		if type(drop52.focus[key]) == "function" then
			drop52.focus[key]()
		elseif screen:find_child(drop52.focus[key]) then
			if drop52.on_focus_out then
				drop52.on_focus_out()
			end
			screen:find_child(drop52.focus[key]):grab_key_focus()
			if screen:find_child(drop52.focus[key]).on_focus_in then
				screen:find_child(drop52.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop52.extra.reactive = true


local drop42 = Clone
	{
		scale = {1,1,0,0},
		source = drop52,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop42",
		position = {1070,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop42.extra.focus = {}

function drop42:on_key_down(key)
	if drop42.focus[key] then
		if type(drop42.focus[key]) == "function" then
			drop42.focus[key]()
		elseif screen:find_child(drop42.focus[key]) then
			if drop42.on_focus_out then
				drop42.on_focus_out()
			end
			screen:find_child(drop42.focus[key]):grab_key_focus()
			if screen:find_child(drop42.focus[key]).on_focus_in then
				screen:find_child(drop42.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop42.extra.reactive = true


local drop41 = Clone
	{
		scale = {1,1,0,0},
		source = drop42,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop41",
		position = {1010,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop41.extra.focus = {}

function drop41:on_key_down(key)
	if drop41.focus[key] then
		if type(drop41.focus[key]) == "function" then
			drop41.focus[key]()
		elseif screen:find_child(drop41.focus[key]) then
			if drop41.on_focus_out then
				drop41.on_focus_out()
			end
			screen:find_child(drop41.focus[key]):grab_key_focus()
			if screen:find_child(drop41.focus[key]).on_focus_in then
				screen:find_child(drop41.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop41.extra.reactive = true


local drop34 = Clone
	{
		scale = {1,1,0,0},
		source = drop41,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop34",
		position = {950,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop34.extra.focus = {}

function drop34:on_key_down(key)
	if drop34.focus[key] then
		if type(drop34.focus[key]) == "function" then
			drop34.focus[key]()
		elseif screen:find_child(drop34.focus[key]) then
			if drop34.on_focus_out then
				drop34.on_focus_out()
			end
			screen:find_child(drop34.focus[key]):grab_key_focus()
			if screen:find_child(drop34.focus[key]).on_focus_in then
				screen:find_child(drop34.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop34.extra.reactive = true


local drop51 = Clone
	{
		scale = {1,1,0,0},
		source = drop34,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop51",
		position = {1250,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop51.extra.focus = {}

function drop51:on_key_down(key)
	if drop51.focus[key] then
		if type(drop51.focus[key]) == "function" then
			drop51.focus[key]()
		elseif screen:find_child(drop51.focus[key]) then
			if drop51.on_focus_out then
				drop51.on_focus_out()
			end
			screen:find_child(drop51.focus[key]):grab_key_focus()
			if screen:find_child(drop51.focus[key]).on_focus_in then
				screen:find_child(drop51.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop51.extra.reactive = true


local drop44 = Clone
	{
		scale = {1,1,0,0},
		source = drop51,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop44",
		position = {1190,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop44.extra.focus = {}

function drop44:on_key_down(key)
	if drop44.focus[key] then
		if type(drop44.focus[key]) == "function" then
			drop44.focus[key]()
		elseif screen:find_child(drop44.focus[key]) then
			if drop44.on_focus_out then
				drop44.on_focus_out()
			end
			screen:find_child(drop44.focus[key]):grab_key_focus()
			if screen:find_child(drop44.focus[key]).on_focus_in then
				screen:find_child(drop44.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop44.extra.reactive = true


local drop11 = Clone
	{
		scale = {1,1,0,0},
		source = drop12,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "drop11",
		position = {290,361,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

drop11.extra.focus = {}

function drop11:on_key_down(key)
	if drop11.focus[key] then
		if type(drop11.focus[key]) == "function" then
			drop11.focus[key]()
		elseif screen:find_child(drop11.focus[key]) then
			if drop11.on_focus_out then
				drop11.on_focus_out()
			end
			screen:find_child(drop11.focus[key]):grab_key_focus()
			if screen:find_child(drop11.focus[key]).on_focus_in then
				screen:find_child(drop11.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

drop11.extra.reactive = true


local follow = Clone
	{
		scale = {1,1,0,0},
		source = drop23,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "follow",
		position = {72,877,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

follow.extra.focus = {}

function follow:on_key_down(key)
	if follow.focus[key] then
		if type(follow.focus[key]) == "function" then
			follow.focus[key]()
		elseif screen:find_child(follow.focus[key]) then
			if follow.on_focus_out then
				follow.on_focus_out()
			end
			screen:find_child(follow.focus[key]):grab_key_focus()
			if screen:find_child(follow.focus[key]).on_focus_in then
				screen:find_child(follow.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

follow.extra.reactive = true

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

g:add(bg3,bg2,bg1,player,image3,clone4,clone6,drop12,move1,move2,move3,move4,drop13,drop14,drop32,drop31,drop24,drop23,drop22,
drop21,drop33,drop43,drop53,drop54,drop52,drop42,drop41,drop34,drop51,drop44,drop11,follow,deaths)

local colliders = {drop12,move1,move2,move3,move4,drop13,drop14,drop32,drop31,drop24,drop23,drop22,
drop21,drop33,drop43,drop53,drop54,drop52,drop42,drop41,drop34,drop51,drop44,drop11,follow}

local event1 = 
	{
		row = 1,
		time = 1000,
		event_type = "patrol",
		ui = move1,
		position = {0, 236},
		original = {1588, 236},
		duration = 2000,
		triggered = false,
	}

local event2 = 
	{
		row = 1,
		time = 2000,
		event_type = "patrol",
		ui = move2,
		position = {64, 180},
		original = {1652, 180},
		duration = 2000,
		triggered = false,
	}

local event3 = 
	{
		row = 1,
		time = 3000,
		event_type = "patrol",
		ui = move3,
		position = {128, 180},
		original = {1714, 180},
		duration = 2000,
		triggered = false,
	}

local event4 = 
	{
		row = 1,
		time = 4000,
		event_type = "patrol",
		ui = move4,
		position = {192, 236},
		original = {1778, 236},
		duration = 1750,
		triggered = false,
	}

local event5 = 
	{
		row = 2,
		time = 500,
		event_type = "rand patrol",
		ui = {drop44,drop51,drop52,drop53,drop54},
		y = 655,
		original = 361,
		duration = 200,
		triggered = false,
	}

local event6 = 
	{
		row = 2,
		time = 1000,
		event_type = "rand patrol",
		ui = {drop33,drop34,drop41,drop42,drop43},
		y = 655,
		original = 361,
		duration = 200,
		triggered = false,
	}

local event7 = 
	{
		row = 2,
		time = 1500,
		event_type = "rand patrol",
		ui = {drop22,drop23,drop24,drop31,drop32},
		y = 655,
		original = 361,
		duration = 200,
		triggered = false,
	}

local event8 = 
	{
		row = 2,
		time = 2000,
		event_type = "rand patrol",
		ui = {drop11,drop12,drop13,drop14,drop21},
		y = 655,
		original = 361,
		duration = 200,
		triggered = false,
	}

local event9 = 
	{
		row = 3,
		time = 300,
		event_type = "patrol",
		ui = follow,
		position = {72,1015},
		original = {72,877},
		duration = 200,
		triggered = false,
	}

local event10 = 
	{
		row = 3,
		time = 1000,
		event_type = "patrol",
		ui = follow,
		position = {1300,1015},
		original = {72,877},
		duration = 500,
		triggered = false,
	}

local event11 = 
	{
		row = 3,
		time = 1500,
		event_type = "patrol",
		ui = follow,
		position = {1500,770},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event12 = 
	{
		row = 3,
		time = 2000,
		event_type = "patrol",
		ui = follow,
		position = {800,1015},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event13 = 
	{
		row = 3,
		time = 2250,
		event_type = "patrol",
		ui = follow,
		position = {600,1015},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event14 = 
	{
		row = 3,
		time = 2500,
		event_type = "patrol",
		ui = follow,
		position = {500,860},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event15 = 
	{
		row = 3,
		time = 3000,
		event_type = "patrol",
		ui = follow,
		position = {1200,960},
		original = {72,877},
		duration = 500,
		triggered = false,
	}

local event16 = 
	{
		row = 3,
		time = 3500,
		event_type = "patrol",
		ui = follow,
		position = {1700,960},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event17 = 
	{
		row = 3,
		time = 4000,
		event_type = "patrol",
		ui = follow,
		position = {1700,860},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local event18 = 
	{
		row = 3,
		time = 4250,
		event_type = "patrol",
		ui = follow,
		position = {1700,1015},
		original = {72,877},
		duration = 250,
		triggered = false,
	}
local event19 = 
	{
		row = 3,
		time = 4700,
		event_type = "patrol",
		ui = follow,
		position = {2200,815},
		original = {72,877},
		duration = 250,
		triggered = false,
	}

local events = {event1,event2,event3,event4,event5,event6,event7,event8,event9,event10,event11,event12,event13,event14,event15,event16,event17,event18,event19}

return colliders, events
