function main()
-- GLOBAL SECTION
ui_element = dofile("/lib/ui_element.lua") --Load widget helper library
layout = {} --Table containing all the UIElements that make up each screen
groups = {} --Table of groups of the UIElements of each screen, each of which can then be ui_element.screen_add()ed

local collider_list = {}
local event_list = {}
--local players = {}
local explosion = {}

p = Image{src = "/assets/images/player.png", opacity = 0}
pspeed = Image{src = "assets/images/player_speed_2.png", opacity = 0}

b1 = Image{src = "/assets/images/bg_1_1.png", opacity = 0}
b2 = Image{src = "/assets/images/bg_2_1.png", opacity = 0}
b3 = Image{src = "/assets/images/bg_1_3.png", opacity = 0}
b4 = Image{src = "/assets/images/bg_2_2.png", opacity = 0}
b5 = Image{src = "/assets/images/bg_2_3.png", opacity = 0}

d0 = Image{src = "/assets/images/number_gameover_0.png", opacity = 0}
d1 = Image{src = "/assets/images/number_gameover_1.png", opacity = 0}
d2 = Image{src = "/assets/images/number_gameover_2.png", opacity = 0}
d3 = Image{src = "/assets/images/number_gameover_3.png", opacity = 0}
d4 = Image{src = "/assets/images/number_gameover_4.png", opacity = 0}
d5 = Image{src = "/assets/images/number_gameover_5.png", opacity = 0}
d6 = Image{src = "/assets/images/number_gameover_6.png", opacity = 0}
d7 = Image{src = "/assets/images/number_gameover_7.png", opacity = 0}
d8 = Image{src = "/assets/images/number_gameover_8.png", opacity = 0}
d9 = Image{src = "/assets/images/number_gameover_9.png", opacity = 0}

local numbers = {d0,d1,d2,d3,d4,d5,d6,d7,d8,d9}

screen:add(p)
screen:add(pspeed)
screen:add(b1,b2,b3,b4,b5)
screen:add(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9)
-- END GLOBAL SECTION

--  END SECTION
groups["end"] = Group() -- Create a Group for this screen
layout["end"] = {}
loadfile("/screens/end.lua")(groups["end"]) -- Load all the elements for this screen
ui_element.populate_to(groups["end"],layout["end"]) -- Populate the elements into the Group

local digits = {layout["end"].digit1, layout["end"].digit2, layout["end"].digit3, layout["end"].digit4, layout["end"].digit5}

-- END END SECTION

--  LEVEL8 SECTION
groups["level8"] = Group() -- Create a Group for this screen
layout["level8"] = {}
collider_list["level8"],event_list["level8"] = loadfile("/screens/level8.lua")(groups["level8"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level8"],layout["level8"]) -- Populate the elements into the Group

-- END LEVEL8 SECTION

--  LEVEL7 SECTION
groups["level7"] = Group() -- Create a Group for this screen
layout["level7"] = {}
collider_list["level7"],event_list["level7"] = loadfile("/screens/level7.lua")(groups["level7"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level7"],layout["level7"]) -- Populate the elements into the Group

-- END LEVEL7 SECTION

--  LEVEL6 SECTION
groups["level6"] = Group() -- Create a Group for this screen
layout["level6"] = {}
collider_list["level6"],event_list["level6"] = loadfile("/screens/level6.lua")(groups["level6"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level6"],layout["level6"]) -- Populate the elements into the Group

-- END LEVEL6 SECTION

--  LEVEL3_2 SECTION
groups["level3_2"] = Group() -- Create a Group for this screen
layout["level3_2"] = {}
collider_list["level3_2"],event_list["level3_2"] = loadfile("/screens/level3_2.lua")(groups["level3_2"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level3_2"],layout["level3_2"]) -- Populate the elements into the Group

-- END LEVEL3_2 SECTION

--  LEVEL5 SECTION
groups["level5"] = Group() -- Create a Group for this screen
layout["level5"] = {}
collider_list["level5"],event_list["level5"] = loadfile("/screens/level5.lua")(groups["level5"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level5"],layout["level5"]) -- Populate the elements into the Group

-- END LEVEL5 SECTION

--  SPLASH SECTION
groups["splash"] = Group() -- Create a Group for this screen
layout["splash"] = {}
loadfile("/screens/splash.lua")(groups["splash"]) -- Load all the elements for this screen
ui_element.populate_to(groups["splash"],layout["splash"]) -- Populate the elements into the Group

-- END SPLASH SECTION

--  LEVEL4 SECTION
groups["level4"] = Group() -- Create a Group for this screen
layout["level4"] = {}
collider_list["level4"],event_list["level4"] = loadfile("/screens/level4.lua")(groups["level4"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level4"],layout["level4"]) -- Populate the elements into the Group

-- END LEVEL4 SECTION

--  BASE_LEVEL SECTION
--groups["base_level"] = Group() -- Create a Group for this screen
--layout["base_level"] = {}
--loadfile("/screens/base_level.lua")(groups["base_level"]) -- Load all the elements for this screen
--ui_element.populate_to(groups["base_level"],layout["base_level"]) -- Populate the elements into the Group

-- END BASE_LEVEL SECTION

--  LEVEL3 SECTION
groups["level3"] = Group() -- Create a Group for this screen
layout["level3"] = {}
collider_list["level3"],event_list["level3"] = loadfile("/screens/level3.lua")(groups["level3"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level3"],layout["level3"]) -- Populate the elements into the Group

-- END LEVEL3 SECTION

--  EXPLOSION SECTION
groups["explosion"] = Group() -- Create a Group for this screen
layout["explosion"] = {}
explosion = loadfile("/screens/explosion.lua")(groups["explosion"]) -- Load all the elements for this screen
ui_element.populate_to(groups["explosion"],layout["explosion"]) -- Populate the elements into the Group

-- END EXPLOSION SECTION

--  LEVEL2 SECTION
groups["level2"] = Group() -- Create a Group for this screen
layout["level2"] = {}
collider_list["level2"],event_list["level2"] = loadfile("/screens/level2.lua")(groups["level2"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level2"],layout["level2"]) -- Populate the elements into the Group

-- END LEVEL2 SECTION

--  LEVEL1 SECTION
groups["level1"] = Group() -- Create a Group for this screen
layout["level1"] = {}
collider_list["level1"],event_list["level1"] = loadfile("/screens/level1.lua")(groups["level1"]) -- Load all the elements for this screen
ui_element.populate_to(groups["level1"],layout["level1"]) -- Populate the elements into the Group

-- END LEVEL1 SECTION

-- GLOBAL SECTION FOOTER 
--screen:grab_key_focus()
screen:show()
screen.reactive = true
screen:add(groups["splash"])
layout["splash"].button1:grab_key_focus()

ui_element.screen_add(groups[""])

local levels = {"splash","level1","level2","level3","level3_2","level4","level5","level6","level7","level8"}
--local levels = {"splash","level3_2","level4"}

local player = layout["splash"].player
local deaths = nil
local deathcounter = 0
local hat = nil
local jump_vel = -5.5
local gravity = 0.1
local ground1 = 315
local ground2 = 675
local ground3 = 1035
local up_speed = 0
local jump_time = 0
local jump_start = 0
local jumping = false
local flipping = false
local jump_dur = -jump_vel / gravity * 2
local base = 0
local current_level = 1
local ex_frame = 0
local update_ex = 0
local has_hat = false
local player_frame = 1

row1 = Timeline{duration = 5000}
row1:add_marker("spawn", 0)
--row1:start()
current_row = row1
current_ground = ground1

row2 = Timeline{duration = 5000}
row2:add_marker("spawn", 0)

row3 = Timeline{duration = 5000}
row3:add_marker("spawn", 0)

local rows = {row1,row2,row3}

local won = false

switch_levels = Timeline{duration = 250}

win = Timeline{duration = 10000}


function init()
	player = layout["splash"].player
	deathcounter = 0
	jumping = false
	flipping = false
	won = false
	jump_vel = -5.5
	row1.duration = 5000
	row2.duration = 5000
	row3.duration = 5000
	has_hat = false
	current_level = 1
	jump_dur = -jump_vel / gravity * 2
end

function update(ms)
	update_jump(ms)
	update_events(ms)
	update_collisions(ms)
	if (has_hat) then
		update_hat()
	end
	update_explosion()
end

function update_jump(ms)
	--print (ms)
	if (jumping) then
		elapsed = (ms - jump_time) / 8
		player.y = jump_start + (up_speed * elapsed) + ((gravity / 2) * (elapsed * elapsed))
		rot = (base + elapsed / jump_dur)
		if (rot > 1) then
			rot = 1
		end
		player.z_rotation = {rot * 360, 22.5, 22.5}
		if (flipping) then
			if (gravity > 0) then
				player.x_rotation = {180 - rot * 180, player.w / 2, 0}	
			elseif (gravity < 0) then
				player.x_rotation = {rot * 180, player.w / 2, 0}
			end	
		end
		--print(jump_time)
	else
		jump_time = ms
		player.z_rotation = {360, 22.5, 22.5}
	end
	if (gravity > 0) then
		if (player.y > current_ground) then
			player.y = current_ground
			jumping = false
			flipping = false
			up_speed = 0
			jump_time = ms
			player.z_rotation = {360, player.w / 2, player.h / 2}
			player.x_rotation = {0, player.w / 2,0}
		elseif (player.y < current_ground - 315) then
			player.y = current_ground - 315
			elapsed = (ms - jump_time) / 8
			up_speed = (up_speed + (gravity * elapsed)) * -.5
			jump_start = player.y
			jump_time = ms
			base = base + elapsed / jump_dur
		end
	elseif (gravity < 0) then
		if (player.y < current_ground - 315) then
			--print(jump_time)
			player.y = current_ground - 315
			jumping = false
			flipping = false
			up_speed = 0
			jump_time = ms
			player.z_rotation = {360, player.w / 2, player.h / 2}
			player.x_rotation = {180, player.w / 2, 0}
		elseif (player.y > current_ground) then
			player.y = current_ground
			elapsed = (ms - jump_time) / 8
			up_speed = (up_speed + (gravity * elapsed)) * -.5
			jump_start = player.y
			jump_time = ms
			base = base + elapsed / jump_dur
		end
	end
end

function update_collisions(ms)
	if (collider_list ~= nil) then
		for key,value in pairs(collider_list[levels[current_level]]) do
			if (value.opacity ~= 0 and check_collide(value)) then
				if(value.extra.event == nil) then
					kill()
					break
				else
					do_event(value.extra.event,ms)
					value.opacity = 0
				end
			end
		end
	else
		print("Bad collider list")
	end
end

function check_collide(block)
	if (player.x > block.x + (block.w * block.scale[1])) then
		return false
	elseif (player.x + player.w < block.x) then
		return false
	elseif (player.y > block.y + (block.h * block.scale[2])) then
		return false
	elseif (player.y + player.h < block.y) then
		return false
	end
	return true
end

function update_events(ms)
	if (event_list[levels[current_level]] ~= nil) then
		for key,value in pairs(event_list[levels[current_level]]) do
			if (not value["triggered"]) then
				if (rows[value["row"]] == current_row and ms > value["time"]) then
					do_event(value,ms)
				end
			end	
		end
	end
end

function update_reset()
	--reset patrolling blocks
	if (event_list[levels[current_level]] ~= nil) then
		for key,value in pairs(event_list[levels[current_level]]) do
			if (rows[value["row"]] == current_row) then
				if (value["event_type"] == "patrol") then
					--print("resetting")
					value["ui"]:complete_animation()
					for i = 1 , 10 do collectgarbage( "collect" ) end  
					value["ui"].x = value["original"][1]
					value["ui"].y = value["original"][2]
					value["triggered"] = false
					--print(value["ui"].x, value["ui"].y)
				elseif (value["event_type"] == "rand patrol") then
					for i = 1, #value["ui"] do
						if (value["ui"][i].is_animating) then
							value["ui"][i]:complete_animation()
							for i = 1 , 10 do collectgarbage( "collect" ) end
						end
						if (value["x"] ~= nil) then
							value["ui"][i].x = value["original"]
						else
							value["ui"][i].y = value["original"]
						end
					end
					value["triggered"] = false
				end
			end	
		end
	end

	--reset gravity changers
	for key,value in pairs(collider_list[levels[current_level]]) do
		if (value.y < current_ground and value.y > current_ground - 360) then
			if (value.extra.event ~= nil and (value.extra.event["event_type"] == "gravity up" or
			    value.extra.event["event_type"] == "gravity down" or value.extra.event["event_type"] == "gravity reverse")) then
				--print("resetting")
				value.opacity = 255
			end	
		end
	end
	player.x_rotation = {0,0,0}
	gravity = 0.1
end

function reset_level()
	for key,value in pairs(collider_list[levels[current_level]]) do
		if (value.extra.event ~= nil) then
			if(value.extra.event["event_type"] == "move" or 
			   value.extra.event["event_type"] == "patrol") then
				value.extra.event["ui"].x = value.extra.event["original"][1]
				value.extra.event["ui"].y = value.extra.event["original"][2]		
			end
			value.opacity = 255
		end	
	end
	if (event_list[levels[current_level]] ~= nil) then
		for key,value in pairs(event_list[levels[current_level]]) do
			if(value["event_type"] == "move" or
			   value["event_type"] == "patrol") then
				if (value["ui"].is_animating) then
					value["ui"]:complete_animation()
					for i = 1 , 10 do collectgarbage( "collect" ) end
				end
				value["ui"].x = value["original"][1]
				value["ui"].y = value["original"][2]
			elseif (value["event_type"] == "appear") then
				value["ui"].opacity = 0
			elseif (value["event_type"] == "rand patrol") then
				for i = 1, #value["ui"] do
					if (value["ui"][i].is_animating) then
						value["ui"][i]:complete_animation()
						for i = 1 , 10 do collectgarbage( "collect" ) end
					end
					if (value["x"] ~= nil) then
						value["ui"][i].x = value["original"]
					else
						value["ui"][i].y = value["original"]
					end
				end
			end
			value["triggered"] = false	
		end
	end
end

function update_player()
	for i = 1, #players do
		if (i == player_frame) then
			players[i].x = player.x
			players[i].y = player.y
			players[i].y_rotation = player.y_rotation
			players[i].z_rotation = player.z_rotation
			players[i].opacity = 255
		else
			players[i].opacity = 0
		end
	end
	player_frame = player_frame +1
	if player_frame > 4 then
		player_frame = 1
	end
end

function update_explosion()
	if (ex_frame > 0 and ex_frame < 12) then
		
		explosion[ex_frame].opacity = 255
		if (ex_frame > 1) then
			explosion[ex_frame - 1].opacity = 0
		end
		if (update_ex == 3) then
			ex_frame = ex_frame + 1
			update_ex = 1
		else
			update_ex = update_ex + 1
		end
	elseif (ex_frame == 12) then
		explosion[ex_frame - 1].opacity = 0
		ex_frame = 0
		screen:remove(groups["explosion"])
	end
end

function update_hat()
	hat.x = player.x
	hat.y = player.y
	hat.z_rotation = player.z_rotation
	hat.y_rotation = player.y_rotation
	hat.x_rotation = player.x_rotation
end

function do_event(event,ms)
	if (event["event_type"] == "appear") then
		event["ui"]:animate{duration = 500,opacity=255}
	elseif (event["event_type"] == "disappear") then
		event["ui"]:animate{duration = 500,opacity=0}
	elseif(event["event_type"] == "move") then
		dur = event["duration"]
		if (dur == nil) then
			dur = 250
		end
		event["ui"]:animate{duration = dur, x = event["position"][1], y = event["position"][2]}
	elseif(event["event_type"] == "patrol") then
		dur = event["duration"]
		if (dur == nil) then
			dur = 250
		end
		event["ui"]:animate{duration = dur, x = event["position"][1], y = event["position"][2]}
	elseif(event["event_type"] == "rand patrol") then
		dur = event["duration"]
		if (dur == nil) then
			dur = 250
		end
		math.randomseed(os.time())
		rand = event["ui"][math.random(#event["ui"])]
		if (event["x"] ~= nil) then
			rand:animate{duration = dur, x = event["x"]}
		else
			rand:animate{duration = dur, y = event["y"]}
		end
	elseif(event["event_type"] == "speed upgrade") then
		percent = ms / current_row.duration
		row1.duration = 3000
		row2.duration = 3000
		row3.duration = 3000
		time = current_row.duration * percent
		print (percent, time)
		current_row:add_marker("speed", time)
		current_row:advance_to_marker("speed")
		current_row:remove_marker("speed")
		player.source = pspeed
	elseif(event["event_type"] == "jump upgrade") then
		print("Jump upgrade!")
		jump_vel = -7
		jump_dur = -jump_vel / gravity * 2
		percent = ms / current_row.duration
		row1.duration = 5000
		row2.duration = 5000
		row3.duration = 5000
		time = current_row.duration * percent
		print (percent, time)
		current_row:add_marker("jump", time)
		current_row:advance_to_marker("jump")
		current_row:remove_marker("jump")
		has_hat = true
		hat = layout[levels[current_level]].hat
		hat.opacity = 255
		hat.x = player.x
		hat.y = player.y
	elseif(event["event_type"] == "gravity up") then
		if (jumping) then
			elapsed = (ms - jump_time) / 8
			up_speed = up_speed + (gravity * elapsed)
			jump_start = player.y
			jump_time = ms
			base = base + elapsed / jump_dur
		end
		if (gravity > 0) then
			gravity = gravity + 0.05
		elseif (gravity < 0) then
			gravity = gravity - 0.05
		end
		jump_dur = math.abs(-jump_vel / gravity * 2) * (1 - base)
	elseif(event["event_type"] == "gravity down") then
		if (jumping) then
			elapsed = (ms - jump_time) / 8
			up_speed = up_speed + (gravity * elapsed)
			jump_start = player.y
			jump_time = ms
			base = base + elapsed / jump_dur
		end
		if (gravity > 0) then
			gravity = gravity - 0.025
		elseif (gravity < 0) then
			gravity = gravity + 0.025
		end
		jump_dur = math.abs(-jump_vel / gravity * 2) * (1 - base)
	elseif (event["event_type"] == "gravity reverse") then
		if (jumping) then
			elapsed = (ms - jump_time) / 8
			up_speed = up_speed + (gravity * elapsed)
			base = base + elapsed / jump_dur
			if (base > 0.5) then
				base = 1 - base			
			end
		else
			jumping = true
			up_speed = 0
			base = 0
		end
		flipping = true
		jump_start = player.y
		jump_time = ms
		gravity = gravity * -1
		jump_dur = math.abs(-jump_vel / gravity) * (1 - base)
	end
	if (event["triggered"] == false) then
		event["triggered"] = true
	end
end

function next_level()
	if (current_level < #levels) then
		current_level = current_level + 1
		groups[levels[current_level]].x = 1920
		groups[levels[current_level]].y = 720
		screen:add(groups[levels[current_level]])
		player = layout[levels[current_level]].player
		deaths = layout[levels[current_level]].deaths
		deaths.text = deathcounter
		if (has_hat) then
			hat = layout[levels[current_level]].hat
		end
		switch_levels:start()
	else
		groups["end"].opacity = 0
		screen:add(groups["end"])
		player = layout["end"].player
		tmpcounter = deathcounter
		for i = 1,5 do
			digits[i].source = numbers[(tmpcounter%10) + 1]
			tmpcounter = math.floor(tmpcounter / 10)
			print(tmpcounter)
		end
		win:start()
	end
end

local end_jumped = false

function win:on_new_frame(ms,progress)
	if (progress < 0.1) then
		groups[levels[current_level]].opacity = 255 - (progress * 2600)
		groups["end"].opacity = progress * 2600
		for i = 1,5 do
			digits[i].opacity = 0
		end
	elseif (progress < 0.15) then
		groups[levels[current_level]].opacity = 0
		groups["end"].opacity = 255
		for i = 1,4 do
			digits[i].opacity = 0
		end
		digits[5].opacity = (progress - 0.1) * 5200
	elseif (progress < 0.2) then
		digits[5].opacity = 255
		digits[4].opacity = (progress - 0.15) * 5200
	elseif (progress < 0.25) then
		digits[4].opacity = 255
		digits[3].opacity = (progress - 0.2) * 5200
	elseif (progress < 0.3) then
		digits[3].opacity = 255
		digits[2].opacity = (progress - 0.25) * 5200
	elseif (progress < 0.35) then
		digits[2].opacity = 255
		digits[1].opacity = (progress - 0.3) * 5200
	elseif (progress < 0.85) then
		digits[1].opacity = 255
		won = true
		layout["end"].ice.x = 1853 - ((progress - 0.35) * 2416)
		player.x = 1965 - ((progress - 0.35) * 2416)
	else
		layout["end"].ice.x = 645
		player.x = 757 - ((progress - 0.85) * 3700)
		if (not end_jumped) then
			current_ground = 750
			jumping = false
			jump_time = win.elapsed
			jump()
			end_jumped = true
		end
		update_jump(win.elapsed)
	end
	
end

function switch_levels:on_new_frame(ms,progress)
	groups[levels[current_level]].x = 1920 - (1920 * progress)
	groups[levels[current_level]].y = 720 - (720 * progress)
	groups[levels[current_level - 1]].x = 0 - (1920 * progress)
	groups[levels[current_level - 1]].y = 0 - (720 * progress)
end

function switch_levels:on_completed()
	screen:remove(groups[levels[current_level - 1]])
	row1:start()
end
	

function jump()
	if (jumping == false) then
		if (gravity > 0) then
			up_speed = jump_vel
			jump_start = player.y
		elseif (gravity < 0) then
			up_speed = -jump_vel
			jump_start = player.y
			
		end
		base = 0
		jumping = true
		jump_dur = math.abs(jump_vel / gravity * 2)
	end
end

function kill()
	up_speed = 0
	jumping = false
	flipping = false
	for key, value in pairs(explosion) do
		value.x = player.x
		value.y = player.y
	end
	screen:add(groups["explosion"])
	ex_frame = 1
	if (current_row == row2) then
		player.x = 1920
	else
		player.x = 0
	end
	player.y = current_ground
	current_row:advance_to_marker("spawn")
	update_reset()
	deathcounter = deathcounter + 1
	deaths.text = deathcounter
	--deaths.text = "bob"
end

function row1:on_new_frame(ms, progress)
	--print(ms)
	player.x = progress * 1845
	update(row1.elapsed)
end

function row1:on_started()
	player.x = 0
	player.y = ground1
	up_speed = 0
	jumping = false
	player.y_rotation = {0,0,0}
	player.x_rotation = {0,0,0}
end

function row1:on_completed()
	row2:start()
	current_row = row2
	current_ground = ground2
	gravity = 0.1
end

function row2:on_new_frame(ms, progress)
	player.x = 1885 - (progress * 1845)
	update(row2.elapsed)
end

function row2:on_started()
	player.x = 1920
	player.y = ground2
	up_speed = 0
	jumping = false
	player.y_rotation = {180,player.w / 2,0}
	player.x_rotation = {0,0,0}
end

function row2:on_completed()
	row3:start()
	current_row = row3
	current_ground = ground3
	gravity = 0.1
end

function row3:on_new_frame(ms, progress)
	player.x = progress * 1845
	update(row3.elapsed)
end

function row3:on_started()
	player.x = 0
	player.y = ground3
	up_speed = 0
	jumping = false
	player.y_rotation = {0,0,0}
	player.x_rotation = {0,0,0}
end

function row3:on_completed()
	reset_level()
	next_level()
	--row1:start()
	current_row = row1
	current_ground = ground1
	gravity = 0.1
end

-- SCREEN ON_KEY_DOWN SECTION
function screen:on_key_down(key)
	if (key == keys["OK"]) then
		if (not won) then
			jump()
		else
			win:stop()
			groups[levels[current_level]].opacity = 255
			layout["end"].ice.x = 1853
			layout["end"].ice.y = 795
			layout["end"].player.x = 1965
			layout["end"].player.y = 650
			screen:remove(groups[levels[current_level]])
			screen:remove(groups["end"])
			screen:add(groups["splash"])
			layout["splash"].player.x = 880
			layout["splash"].player.y = 925
			layout["splash"].player.y_rotation = {0, 77.5, 0}
			groups["splash"].x = 0
			groups["splash"].y = 0
			init()
			layout["splash"].button2:grab_key_focus()
		end
	elseif (key == keys["0"]) then
		kill()
	elseif (key == keys["5"]) then
		row1:stop()
		row2:stop()
		row3:stop()
		reset_level()
		next_level()
		current_row = row1
		current_ground = ground1
		gravity = 0.1
		if (current_level > 6) then
			do_event({event_type = "speed upgrade"}, 0)
		end
		if (current_level > 8) then
			do_event({event_type = "jump upgrade"}, 0)
		end
	end
end
-- END SCREEN ON_KEY_DOWN SECTION

-- SCREEN ON_BUTTON_UP SECTION
function screen:on_button_up()
	if dragging then
		dragging = nil
	end
end
-- END SCREEN ON_BUTTON_UP SECTION

-- END GLOBAL SECTION FOOTER 


end

dolater( main )
