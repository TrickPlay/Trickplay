local g = ... 


local bg = Image
	{
		src = "/assets/bg_gameover_half.png",
		clip = {0,0,960,540},
		scale = {2,2,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg",
		position = {0,0,0},
		size = {960,540},
		opacity = 255,
		reactive = true,
	}

bg.extra.focus = {}

function bg:on_key_down(key)
	if bg.focus[key] then
		if type(bg.focus[key]) == "function" then
			bg.focus[key]()
		elseif screen:find_child(bg.focus[key]) then
			if bg.on_focus_out then
				bg.on_focus_out()
			end
			screen:find_child(bg.focus[key]):grab_key_focus()
			if screen:find_child(bg.focus[key]).on_focus_in then
				screen:find_child(bg.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg.extra.reactive = true


local ice = Image
	{
		src = "/assets/ice.png",
		clip = {0,0,413,309},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "ice",
		position = {1853,795,0},
		size = {413,309},
		opacity = 255,
		reactive = true,
	}

ice.extra.focus = {}

function ice:on_key_down(key)
	if ice.focus[key] then
		if type(ice.focus[key]) == "function" then
			ice.focus[key]()
		elseif screen:find_child(ice.focus[key]) then
			if ice.on_focus_out then
				ice.on_focus_out()
			end
			screen:find_child(ice.focus[key]):grab_key_focus()
			if screen:find_child(ice.focus[key]).on_focus_in then
				screen:find_child(ice.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

ice.extra.reactive = true


local player = Image
	{
		src = "/assets/end_penguin.png",
		clip = {0,0,192,211},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "player",
		position = {1965,650,0},
		size = {192,211},
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


local image5 = Image
	{
		src = "/assets/wave.png",
		clip = {0,0,1261,184},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image5",
		position = {658,896,0},
		size = {1261,184},
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


local image6 = Image
	{
		src = "/assets/back.png",
		clip = {0,0,481,80},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image6",
		position = {1400,990,0},
		size = {481,80},
		opacity = 255,
		reactive = true,
	}

image6.extra.focus = {}

function image6:on_key_down(key)
	if image6.focus[key] then
		if type(image6.focus[key]) == "function" then
			image6.focus[key]()
		elseif screen:find_child(image6.focus[key]) then
			if image6.on_focus_out then
				image6.on_focus_out()
			end
			screen:find_child(image6.focus[key]):grab_key_focus()
			if screen:find_child(image6.focus[key]).on_focus_in then
				screen:find_child(image6.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image6.extra.reactive = true


local image7 = Image
	{
		src = "/assets/button_again_glow.png",
		clip = {0,0,786,400},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image7",
		position = {602,590,0},
		size = {786,400},
		opacity = 255,
		reactive = true,
	}

image7.extra.focus = {}

function image7:on_key_down(key)
	if image7.focus[key] then
		if type(image7.focus[key]) == "function" then
			image7.focus[key]()
		elseif screen:find_child(image7.focus[key]) then
			if image7.on_focus_out then
				image7.on_focus_out()
			end
			screen:find_child(image7.focus[key]):grab_key_focus()
			if screen:find_child(image7.focus[key]).on_focus_in then
				screen:find_child(image7.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image7.extra.reactive = true


local image8 = Image
	{
		src = "/assets/button_again.png",
		clip = {0,0,424,93},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image8",
		position = {780,735,0},
		size = {424,93},
		opacity = 255,
		reactive = true,
	}

image8.extra.focus = {}

function image8:on_key_down(key)
	if image8.focus[key] then
		if type(image8.focus[key]) == "function" then
			image8.focus[key]()
		elseif screen:find_child(image8.focus[key]) then
			if image8.on_focus_out then
				image8.on_focus_out()
			end
			screen:find_child(image8.focus[key]):grab_key_focus()
			if screen:find_child(image8.focus[key]).on_focus_in then
				screen:find_child(image8.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image8.extra.reactive = true


local digit1 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "digit1",
		position = {1400,490,0},
		size = {130,130},
		opacity = 255,
		reactive = true,
	}

digit1.extra.focus = {}

function digit1:on_key_down(key)
	if digit1.focus[key] then
		if type(digit1.focus[key]) == "function" then
			digit1.focus[key]()
		elseif screen:find_child(digit1.focus[key]) then
			if digit1.on_focus_out then
				digit1.on_focus_out()
			end
			screen:find_child(digit1.focus[key]):grab_key_focus()
			if screen:find_child(digit1.focus[key]).on_focus_in then
				screen:find_child(digit1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

digit1.extra.reactive = true


local digit2 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "digit2",
		position = {1270,490,0},
		size = {130,130},
		opacity = 255,
		reactive = true,
	}

digit2.extra.focus = {}

function digit2:on_key_down(key)
	if digit2.focus[key] then
		if type(digit2.focus[key]) == "function" then
			digit2.focus[key]()
		elseif screen:find_child(digit2.focus[key]) then
			if digit2.on_focus_out then
				digit2.on_focus_out()
			end
			screen:find_child(digit2.focus[key]):grab_key_focus()
			if screen:find_child(digit2.focus[key]).on_focus_in then
				screen:find_child(digit2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

digit2.extra.reactive = true


local digit4 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "digit4",
		position = {1010,490,0},
		size = {130,130},
		opacity = 255,
		reactive = true,
	}

digit4.extra.focus = {}

function digit4:on_key_down(key)
	if digit4.focus[key] then
		if type(digit4.focus[key]) == "function" then
			digit4.focus[key]()
		elseif screen:find_child(digit4.focus[key]) then
			if digit4.on_focus_out then
				digit4.on_focus_out()
			end
			screen:find_child(digit4.focus[key]):grab_key_focus()
			if screen:find_child(digit4.focus[key]).on_focus_in then
				screen:find_child(digit4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

digit4.extra.reactive = true


local digit5 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "digit5",
		position = {880,490,0},
		size = {130,130},
		opacity = 255,
		reactive = true,
	}

digit5.extra.focus = {}

function digit5:on_key_down(key)
	if digit5.focus[key] then
		if type(digit5.focus[key]) == "function" then
			digit5.focus[key]()
		elseif screen:find_child(digit5.focus[key]) then
			if digit5.on_focus_out then
				digit5.on_focus_out()
			end
			screen:find_child(digit5.focus[key]):grab_key_focus()
			if screen:find_child(digit5.focus[key]).on_focus_in then
				screen:find_child(digit5.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

digit5.extra.reactive = true


local digit3 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "digit3",
		position = {1140,490,0},
		size = {130,130},
		opacity = 255,
		reactive = true,
	}

digit3.extra.focus = {}

function digit3:on_key_down(key)
	if digit3.focus[key] then
		if type(digit3.focus[key]) == "function" then
			digit3.focus[key]()
		elseif screen:find_child(digit3.focus[key]) then
			if digit3.on_focus_out then
				digit3.on_focus_out()
			end
			screen:find_child(digit3.focus[key]):grab_key_focus()
			if screen:find_child(digit3.focus[key]).on_focus_in then
				screen:find_child(digit3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

digit3.extra.reactive = true


g:add(bg,ice,player,image5,image6,image7,image8,digit1,digit2,digit4,digit5,digit3)