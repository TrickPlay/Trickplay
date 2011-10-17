local g = ... 


local image0 = Image
	{
		src = "/assets/splash_bg.png",
		clip = {0,0,1920,1080},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image0",
		position = {0,0,0},
		size = {1920,1080},
		opacity = 255,
		reactive = true,
	}

image0.extra.focus = {}

function image0:on_key_down(key)
	if image0.focus[key] then
		if type(image0.focus[key]) == "function" then
			image0.focus[key]()
		elseif screen:find_child(image0.focus[key]) then
			if image0.on_focus_out then
				image0.on_focus_out()
			end
			screen:find_child(image0.focus[key]):grab_key_focus()
			if screen:find_child(image0.focus[key]).on_focus_in then
				screen:find_child(image0.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image0.extra.reactive = true


local focus = Image
	{
		src = "/assets/focus.png",
		clip = {0,0,523,220},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "focus",
		position = {306,736,0},
		size = {523,220},
		opacity = 255,
		reactive = true,
	}

focus.extra.focus = {}

function focus:on_key_down(key)
	if focus.focus[key] then
		if type(focus.focus[key]) == "function" then
			focus.focus[key]()
		elseif screen:find_child(focus.focus[key]) then
			if focus.on_focus_out then
				focus.on_focus_out()
			end
			screen:find_child(focus.focus[key]):grab_key_focus()
			if screen:find_child(focus.focus[key]).on_focus_in then
				screen:find_child(focus.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

focus.extra.reactive = true

local player = Image
	{
		src = "/assets/splash_player.png",
		clip = {0,0,155,155},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "player",
		position = {880,925,0},
		size = {155,155},
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

local button2down = Image
	{
		src = "/assets/button_2_down.png",
		clip = {0,0,420,120},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "button2down",
		position = {1145,789,0},
		size = {420,120},
		opacity = 0,
		reactive = true,
	}

button2down.extra.focus = {}

function button2down:on_key_down(key)
	if button2down.focus[key] then
		if type(button2down.focus[key]) == "function" then
			button2down.focus[key]()
		elseif screen:find_child(button2down.focus[key]) then
			if button2down.on_focus_out then
				button2down.on_focus_out()
			end
			screen:find_child(button2down.focus[key]):grab_key_focus()
			if screen:find_child(button2down.focus[key]).on_focus_in then
				screen:find_child(button2down.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

button2down.extra.reactive = true


local button1down = Image
	{
		src = "/assets/button_1_down.png",
		clip = {0,0,420,120},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "button1down",
		position = {365,789,0},
		size = {420,120},
		opacity = 0,
		reactive = true,
	}

button1down.extra.focus = {}

function button1down:on_key_down(key)
	if button1down.focus[key] then
		if type(button1down.focus[key]) == "function" then
			button1down.focus[key]()
		elseif screen:find_child(button1down.focus[key]) then
			if button1down.on_focus_out then
				button1down.on_focus_out()
			end
			screen:find_child(button1down.focus[key]):grab_key_focus()
			if screen:find_child(button1down.focus[key]).on_focus_in then
				screen:find_child(button1down.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

button1down.extra.reactive = true

local button1press = Timeline{duration = 500}

function button1press:on_new_frame(ms, progress)
	player.x = 880 - (progress * 880)
end

function button1press:on_started()
	player.y_rotation = {180, 77.5, 0}
end

function button1press:on_completed()
	next_level()
	screen:grab_key_focus()
	row = 1
	skating:start()
end

local button1 = Image
	{
		src = "/assets/button_1.png",
		clip = {0,0,420,120},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "button1",
		position = {365,790,0},
		size = {420,120},
		opacity = 255,
		reactive = true,
	}

button1.extra.focus = {[65363] = "button2", }

function button1:on_key_down(key)
	if button1.focus[key] then
		if type(button1.focus[key]) == "function" then
			button1.focus[key]()
		elseif screen:find_child(button1.focus[key]) then
			if button1.on_focus_out then
				button1.on_focus_out()
			end
			screen:find_child(button1.focus[key]):grab_key_focus()
			if screen:find_child(button1.focus[key]).on_focus_in then
				screen:find_child(button1.focus[key]).on_focus_in(key)
			end
			end
	end
	if (key == keys.OK) then
		button1.opacity = 0
		button1down.opacity = 255
	end
	return true
end

function button1:on_key_up(key)
	if (key == keys.OK) then
		button1.opacity = 255
		button1down.opacity = 0
		button1press:start()
	end
end

button1.extra.reactive = true

function button1:on_key_focus_in()
	focus.x = 303
	focus.y = 733
end

local button2 = Image
	{
		src = "/assets/button_2.png",
		clip = {0,0,420,120},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "button2",
		position = {1145,790,0},
		size = {420,120},
		opacity = 255,
		reactive = true,
	}

button2.extra.focus = {[65361] = "button1", }

function button2:on_key_down(key)
	if button2.focus[key] then
		if type(button2.focus[key]) == "function" then
			button2.focus[key]()
		elseif screen:find_child(button2.focus[key]) then
			if button2.on_focus_out then
				button2.on_focus_out()
			end
			screen:find_child(button2.focus[key]):grab_key_focus()
			if screen:find_child(button2.focus[key]).on_focus_in then
				screen:find_child(button2.focus[key]).on_focus_in(key)
			end
			end
	end
	if (key == keys.OK) then
		button2.opacity = 0
		button2down.opacity = 255
	end
	return true
end

function button2:on_key_up(key)
	if (key == keys.OK) then
		button2.opacity = 255
		button2down.opacity = 0
	end
end

button2.extra.reactive = true

function button2:on_key_focus_in()
	focus.x = 1083
	focus.y = 733
end

local image3 = Image
	{
		src = "/assets/splash_finish.png",
		clip = {0,0,492,287},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1670,795,0},
		size = {492,287},
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
		y_rotation = {180,0,0},
		z_rotation = {0,0,0},
		anchor_point = {492,0},
		name = "clone4",
		position = {-235,795,0},
		size = {492,287},
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


g:add(image0,focus,button1,button2,player,image3,clone4,button2down,button1down)
