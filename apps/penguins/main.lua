function main()

ui_element = dofile("/lib/ui_element.lua")
layout = {}
groups = {}

local colliders = {}
local events = {}
local explosion = {}

p = Image{src = "/assets/player.png", opacity = 0}
pspeed = Image{src = "assets/player_speed_2.png", opacity = 0}

b1 = Image{src = "/assets/bg_1_1.png", opacity = 0}
b2 = Image{src = "/assets/bg_2_1.png", opacity = 0}
b3 = Image{src = "/assets/bg_1_3.png", opacity = 0}
b4 = Image{src = "/assets/bg_2_2.png", opacity = 0}
b5 = Image{src = "/assets/bg_2_3.png", opacity = 0}

d0 = Image{src = "/assets/number_gameover_0.png", opacity = 0}
d1 = Image{src = "/assets/number_gameover_1.png", opacity = 0}
d2 = Image{src = "/assets/number_gameover_2.png", opacity = 0}
d3 = Image{src = "/assets/number_gameover_3.png", opacity = 0}
d4 = Image{src = "/assets/number_gameover_4.png", opacity = 0}
d5 = Image{src = "/assets/number_gameover_5.png", opacity = 0}
d6 = Image{src = "/assets/number_gameover_6.png", opacity = 0}
d7 = Image{src = "/assets/number_gameover_7.png", opacity = 0}
d8 = Image{src = "/assets/number_gameover_8.png", opacity = 0}
d9 = Image{src = "/assets/number_gameover_9.png", opacity = 0}

local numbers = {d0,d1,d2,d3,d4,d5,d6,d7,d8,d9}

screen:add(p)
screen:add(pspeed)
screen:add(b1,b2,b3,b4,b5)
screen:add(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9)

local levels = {"splash","level1","level2","level3","level3_2","level4","level5","level6","level7","level8"}

for key,value in ipairs(levels) do
	groups[value] = Group()
	layout[value] = {}
	colliders[value],events[value] = loadfile("/screens/"..value..".lua")(groups[value])
	ui_element.populate_to(groups[value],layout[value])
end

groups["end"] = Group()
layout["end"] = {}
loadfile("/screens/end.lua")(groups["end"])
ui_element.populate_to(groups["end"],layout["end"])

local digits = {layout["end"].digit1, layout["end"].digit2, layout["end"].digit3, layout["end"].digit4, layout["end"].digit5}

groups["explosion"] = Group()
layout["explosion"] = {}
explosion = loadfile("/screens/explosion.lua")(groups["explosion"])
ui_element.populate_to(groups["explosion"],layout["explosion"]) 

screen:show()
screen.reactive = true
screen:add(groups["splash"])
layout["splash"].button1:grab_key_focus()

ui_element.screen_add(groups[""])

local player = layout["splash"].player
local deaths = nil
local deathcounter = 0
local hat = nil
local gravity = 0.1
local ground = {315,675,1035}
local vspeed = 0
local jspeed = -5.5
local jtime = 0
local jstart = 0
local jstate = 0 -- [0] none [1] jumping [2] flipping
local jduration = -jspeed / gravity * 2
local base = 0
local level = 1
local is_grav = {up=1,down=1,reverse=1}
local a, b, c, r, t

skating = Timeline{duration = 5000}

local row = 1

local won = false

switch_levels = Timeline{duration = 250}

win = Timeline{duration = 10000}

die = {anim = Timeline{ duration = 40 * #explosion },
	timer = Timer(40,function(timer)
		if die.frame > #explosion then
			return false
		elseif die.frame > 1 then
			explosion[die.frame-1].opacity = 0
		end
		explosion[die.frame].opacity = 255
		die.frame = die.frame + 1
	end),
	frame = 1, y = 0, vy = 0 }
die.timer:stop()

function die.anim:on_new_frame(ms,t)
	player.y = die.y + die.vy*ms + gravity*ms*ms/128
	if hat then
		hat.y = player.y
	end
end

function die.anim:on_completed()
	die.timer:stop()
	player:complete_animation()
	player.opacity = 255
	
	if hat then
		hat:complete_animation()
		hat.opacity = 255
	end
	
	for k,v in pairs(explosion) do
		v.opacity = 0
	end
	screen:remove(groups["explosion"])
	die.frame = 1
	
	update_reset(false)
	skating:start()
end

function wrap_anim(temp)
	local anim = {}
	for k,v in ipairs(temp) do
		anim[k] = {source = v[1], name = v[2], keys = v[3]}
	end
	return anim
end

function update_jump(ms)
	a = gravity > 0

	if jstate > 0 then
		t = (ms - jtime)/8
		r = math.min(base + t/jduration,1)
		player.y = jstart + vspeed*t + gravity*t*t/2
		player.z_rotation = {360*r, player.w/2, player.h/2}
		if jstate == 2 then
			player.x_rotation = {180 * (a and 1-r or r), player.w/2, 0}
		end
	else
		jtime = ms
		player.z_rotation = {360, player.w/2, player.h/2}
	end
	
	b = player.y > ground[row]
	c = player.y < ground[row] - 315
	
	if gravity ~= 0 and (b or c) then
		player.y = ground[row] - (c and 315 or 0)
		if a == b then
			jstate = 0
			vspeed = 0
			player.z_rotation = {360, player.w/2, player.h/2}
			player.x_rotation = {(a and 0 or 180), player.w/2, 0}
		else
			t = (ms - jtime)/8
			vspeed = -(vspeed + gravity*t)/2
			jstart = player.y
			base = base + t/jduration
		end
		jtime = ms
	end
end

function update_collisions(ms)
	if colliders then
		for key,value in pairs(colliders[levels[level]]) do
			if value.opacity ~= 0 and check_collide(value) then
				if value.extra.event  then
					do_event(value.extra.event,ms)
					value.opacity = 0
				else
					kill(value,ms)
					break
				end
			end
		end
	else
		print("Bad collider list")
	end
end

function check_collide(block)
	return not (player.x + 5 > block.x + (block.w * block.scale[1]) or
		player.x + player.w - 5 < block.x or
		player.y + 5 > block.y + (block.h * block.scale[2]) or
		player.y + player.h - 5 < block.y)
end

function update_events(ms)
	if events[levels[level]] then
		for key,value in pairs(events[levels[level]]) do
			if not value.triggered and row == value.row and ms > value.time then
				do_event(value,ms)
			end
		end
	end
end

function update_reset(all)
	local evt, ui, orig
	if events[levels[level]] then
		for key,value in pairs(events[levels[level]]) do
			ui = value.ui
			orig = value.original
			if all or row == value.row then
				if value.event_type == "patrol" or
					(all and value.event_type == "move") then
					ui:complete_animation()
					ui.position = orig
					value.triggered = false
				elseif all and value.event_type == "appear" then
					ui.opacity = 0
				elseif value.event_type == "rand patrol" then
					for i = 1, #ui do
						ui[i]:complete_animation()
						if value.x then
							value.ui[i].x = orig
						else
							value.ui[i].y = orig
						end
					end
				end
				value.triggered = false
			end	
		end
	end
	collectgarbage("collect")

	--reset gravity changers
	if not all then
		for key,value in pairs(colliders[levels[level]]) do
			if value.y < ground[row] and value.y > ground[row] - 360 then
				evt = value.extra.event
				if evt and (is_grav[string.sub(evt.event_type,9)]) then
					value.opacity = 255
				end	
			end
		end
		player.x_rotation = {0,0,0}
		gravity = 0.1
	end
end

function reset_level()
	local evt
	for key,value in pairs(colliders[levels[level]]) do
		evt = value.extra.event
		if evt then
			if evt.event_type == "move" or 
			   evt.event_type == "patrol" then
				evt.ui.position = evt.original	
				evt.ui.vx = 0
				evt.ui.vy = 0
			end
			value.opacity = 255
		end	
	end
	update_reset(true)
end

function update_hat()
	hat.position = player.position
	hat.z_rotation = player.z_rotation
	hat.y_rotation = player.y_rotation
	hat.x_rotation = player.x_rotation
	--hat.scale = player.scale
end

function do_event(evt,ms)
	dur = evt["duration"] or 250
	ui = evt.ui
	evttype = evt.event_type
	if evttype == "appear" then
		ui:animate{duration = 500,opacity = 255}
	elseif evttype == "disappear" then
		ui:animate{duration = 500,opacity = 0}
	elseif evttype == "move" or evttype == "patrol" then
		ui:animate{duration = dur, position = evt.position, on_completed = function() ui.vx = 0; ui.vy = 0 end}
		ui.vx = (evt.position[1]-ui.position[1])/dur
		ui.vy = (evt.position[2]-ui.position[2])/dur
	elseif evttype == "rand patrol" then
		a = (evt.x and "x" or "y")
		math.randomseed(os.time())
		local u = ui[math.random(#ui)]
		u:animate{duration = dur, [a] = evt[a], on_completed = function() u.vx = 0; u.vy = 0 end}
		u.vx = 0
		u.vy = 0
		u["v"..a] = (evt[a]-u[a])/dur
	elseif evttype == "speed upgrade" then
		percent = ms / skating.duration
		skating.duration = 3000
		skating:advance(skating.duration * percent)
		player.source = pspeed
	elseif evttype == "jump upgrade" then
		jspeed = -7
		jduration = -jspeed/gravity*2
		percent = ms/skating.duration
		skating.duration = 5000
		skating:advance(skating.duration * percent)
		hat = layout[levels[level]].hat
		hat.opacity = 255
		hat.position = player.position
	elseif evttype == "gravity up" then
		if jstate > 0 then
			t = (ms - jtime)/8
			vspeed = vspeed + (gravity * t)
			jstart = player.y
			jtime = ms
			base = base + t/jduration
		end
		gravity = gravity + (gravity > 0 and 1 or -1)*0.05
		jduration = math.abs(-jspeed/gravity*2) * (1-base)
	elseif evttype == "gravity down" then
		if jstate > 0 then
			t = (ms - jtime) / 8
			vspeed = vspeed + gravity*t
			jstart = player.y
			jtime = ms
			base = base + t/jduration
		end
		gravity = gravity + (gravity > 0 and -1 or 1)*0.025
		jduration = math.abs(-jspeed/gravity*2) * (1-base)
	elseif evttype == "gravity reverse" then
		if jstate > 0 then
			t = (ms - jtime)/8
			vspeed = vspeed + gravity*t
			base = base + t/jduration
			if (base > 0.5) then
				base = 1-base
			end
		else
			vspeed = 0
			base = 0
		end
		jstate = 2
		jstart = player.y
		jtime = ms
		gravity = -gravity
		jduration = math.abs(-jspeed/gravity) * (1-base)
	end
	evt.triggered = true
end

function next_level()
	row = 1
	if (level < #levels) then
		level = level + 1
		local gl = groups[levels[level]]
		local ll = layout[levels[level]]
		gl.position = {1920,720}
		screen:add(gl)
		player = ll.player
		deaths = ll.deaths
		deaths.text = deathcounter
		if hat then
			hat = ll.hat
		end
		switch_levels:start()
	else
		groups["end"].opacity = 0
		screen:add(groups["end"])
		player = layout["end"].player
		tmpcounter = deathcounter
		for i = 1,5 do
			digits[i].source = numbers[(tmpcounter%10) + 1]
			digits[i].opacity = 0
			tmpcounter = math.floor(tmpcounter / 10)
		end
		
		player:move_anchor_point(96,106)
		local py = player.y
		local op = "opacity"
		
		anim = Animator{duration = 10000, properties = wrap_anim({
			{groups[levels[level]], op, {{0,255}, {.1,0}}},
			{groups["end"],	op, {{0,0}, {.1,255}}},

			{digits[5],	op,	{{0,0}, {.1,0}, {.15,255}}},
			{digits[4],	op,	{{0,0}, {.15,0}, {.2,255}}},
			{digits[3],	op,	{{0,0}, {.2,0},  {.3,255}}},
			{digits[2],	op,	{{0,0}, {.3,0},  {.4,255}}},
			{digits[1],	op,	{{0,0}, {.4,0},  {.5,255}}},

			{layout["end"].ice, "x", {{0,1853}, {.35,1853}, {.85,645}}},
			{player,			"x", {{0,2061}, {.35,2061}, {.85,853}, {1,296}}},
			{player,			"y", {{0,py}, {.85,py}, {.920,"EASE_OUT_QUAD",py-300}, {1,"EASE_IN_QUAD",856}}},
			{player,   "z_rotation", {{0,"LINEAR",0}, {.85,"LINEAR",0}, {1,"LINEAR",-360}}}
		})}
		anim:start()
		won = true
	end
end

function switch_levels:on_new_frame(ms,t)
    groups[levels[level]].position = {1920*(1-t), 720*(1-t)}
    groups[levels[level-1]].position = {-1920*t, -720*t}
end

function switch_levels:on_completed()
	screen:remove(groups[levels[level - 1]])
	row = 1
	skating:start()
end
	

function jump()
	if jstate == 0 then
		vspeed = jspeed * (gravity > 0 and 1 or -1)
		jstart = player.y
		base = 0
		jstate = 1
		jduration = math.abs(jspeed / gravity * 2)
	end
end

function kill(block,ms)
	screen:add(groups["explosion"])
	skating:stop()
	
	for k,v in pairs(explosion) do
		v.position = player.position
	end
	
	if block then
		die.y = player.y
		a = {x = (2*(row%2)-1) * 1920/skating.duration,
			 y = jstate > 0 and vspeed/8 + gravity*(ms-jtime)/64 or 0}
		b = {x = (block.x + block.w*block.scale[1]/2) - (player.x + player.w/2),
			 y = (block.y + block.h*block.scale[2]/2) - (player.y + player.h/2)}
		t = math.atan2(b.y/block.scale[2],b.x/block.scale[1])
		t = t + math.sin(4*t-math.pi)/4
		b = {x = math.cos(t), y = math.sin(t)}
		c = -(a.x*b.x + a.y*b.y)
		if block.vx and block.vy then
			c = c + block.vx*b.x/2 + block.vy*b.y/2
		end
		
		if a.y == 0 and player.y == ground[row] - (gravity > 0 and 0 or 315) then
			gravity = 0
			die.vy = 0
			r = (a.x > 0) == (gravity > 0) and 0.5 or -0.5
		else
			die.vy = a.y + 2*c*b.y
			r = 0.5*(a.x*b.y - a.y*b.x)/(a.x*a.x + a.y*a.y)
		end
		
		c = player.x + (a.x + 2*c*b.x)*die.anim.duration
		t = player.z_rotation[1] + r*die.anim.duration
		
		player:animate{duration = die.anim.duration, x = c, z_rotation = t, opacity = 0}
		if hat then
			hat:animate{duration = die.anim.duration, x = c, z_rotation = t, opacity = 0}
		end
	end
	
	die.anim:start()
	die.timer:start()
	vspeed = 0
	jstate = 0
	
	deathcounter = deathcounter+1
	deaths.text = deathcounter
end

function skating:on_new_frame(ms,t)
    player.x = (row == 2 and 1885-1845*t or 1845*t)
	update_jump(ms)
	update_events(ms)
	update_collisions(ms)
	if hat then
		update_hat()
	end
end

function skating:on_started()
	gravity = 0.1
    player.position = {row == 2 and 1920 or 0, ground[row]}
    vspeed = 0
    jstate = 0
	player.y_rotation = {0,0,0}
    if row == 2 then
        player.y_rotation = {180,player.w / 2,0}
    end
	player.x_rotation = {0,0,0}
end

function skating:on_completed()
    if row == 3 then
        reset_level()
        next_level()
		row = 1
    else
		row = row + 1
        skating:start()
    end
end

function screen:on_key_down(key)
	if (key == keys["OK"]) then
		if (not won) then
			jump()
		else
			win:stop()
			groups[levels[level]].opacity = 255
			
			layout["end"].ice.position = {1853,795}
			layout["end"].player.position = {1965,650}
			
			screen:remove(groups[levels[level]])
			screen:remove(groups["end"])
			screen:add(groups["splash"])
			
			groups["splash"].position = {0,0}
			layout["splash"].button2:grab_key_focus()
			
			player = layout["splash"].player
			player.position = {880,925}
			player.y_rotation = {0,77.5,0}
			deathcounter = 0
			jstate = 0
			won = false
			jspeed = -5.5
			skating.duration = 5000
			has_hat = false
			level = 1
			jduration = -jspeed / gravity * 2
		end
	elseif (key == keys["0"]) then
		kill()
	elseif (key == keys["5"]) then
        skating:stop()
		reset_level()
		next_level()
		row = 1
		gravity = 0.1
		if (level > 6) then
			do_event({event_type = "speed upgrade"}, 0)
		end
		if (level > 8) then
			do_event({event_type = "jump upgrade"}, 0)
		end
	end
end

function screen:on_button_up()
	dragging = nil
end

end

dolater( main )