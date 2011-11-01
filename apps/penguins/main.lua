--[[
Asset changes:
better explosion method and get rid of old one & images (5 MB)

Todo:
hint text animation
new explosion
loop to start screen
still some kind of problem where skating, or some animation? stops while dying
]]

function main()

math.randomseed(os.time())
rand = math.random
function nrand(n)
    return (2*rand()-1)*n
end

ui_element = dofile("/lib/ui_element.lua")

--[[p = Image{src = "/assets/player.png", opacity = 0}
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
screen:add(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9)]]

local base = 0
local is_grav = {up=1,down=1,reverse=1}
local won = false
local a, b, c, r, t

grav_orig = 0.13
gravity = grav_orig
ground = {440,1080}
row = 1

pieces = Group{opacity = 0}
igloo_back = Image{src = "/assets/images/igloo-back.png"}
igloo_front = Image{src = "/assets/images/igloo-front.png"}
bg_slice = Image{src = "/assets/images/bg-slice-2.png", size = {1920,536}, tile = {true,false}}
bg_floor = Image{src = "/assets/images/floor.png"}
bg_sun = Image{src = "/assets/images/sun.png"}
--bg_mountains = Image{src = "/assets/images/mountains.png"}
bg_trees = {Image{src = "/assets/images/tree-1.png"},
			Image{src = "/assets/images/tree-2.png"},
			Image{src = "/assets/images/tree-3.png"},
			Image{src = "/assets/images/tree-4.png"},
			Image{src = "/assets/images/tree-5.png"}}
pieces:add(igloo_back,igloo_front,bg_slice,bg_floor,bg_sun,--bg_mountains,
	bg_trees[1],bg_trees[2],bg_trees[3],bg_trees[4],bg_trees[5])
screen:add(pieces)

overlay = Group{name = "overlay", position = {0,-1200}}
deaths = Text{font = "Sigmar 68px", position = {24,569}, color = "FFFFFF"}
level = Text{font = "Sigmar 68px", position = {600,569}, color = "FFFFFF"}
penguin = dofile('penguin.lua')
overlay:add(penguin.img,Clone{source = igloo_front, position = {0,134,0}},deaths,level)

explode = dofile("explosion.lua")
dofile("cloner.lua")
	
function gentrees(g,y)
    for i=15,20 do
        if rand(2) == 1 then
            l = rand(5)
            g:add(Clone{source = bg_trees[l], position = {rand(20,1900),y},
                anchor_point = {bg_trees[l].w/2,bg_trees[l].h},
                scale = {i/rand(18,20),i/rand(18,20)},
                opacity = 255*i/20})
        end
    end
end

new_level = loadfile('level.lua')

local toload = { -- name, snow, row1, txt1, row2, txt2
	{"splash screen",2,		"splash",""},
	{"Penguin In Motion",1,	"level1_1","This is Penguin.",	"level1_2","Press [OK] to watch him soar!"},
	{"Evasive Action",1,	"level2_1","Can you make it?",	"level2_2","Watch your head"},
	{"Ice Trios",2,			"level3_1","I bet you can't.",	"level3_2","Don't Jump Too Far"},
	{"Double Jump!",2,		"level4_1","Mind the Gap",		"level4_2","Press [OK] in Midair!"},
	{"Tall Stuff",3,		"level5_1","Reach New Heights",	"level5_2","Almost There"}}

levels = {}
for k,v in ipairs(toload) do
	levels[#levels+1] = new_level(v)
end

collectgarbage("collect")

thislevel = levels[1]
snow = dofile('snow.lua')
snow.set(thislevel.snow)

--[[groups["end"] = Group()
layout["end"] = {}
loadfile("/screens/end.lua")(groups["end"])
ui_element.populate_to(groups["end"],layout["end"])

local digits = {layout["end"].digit1, layout["end"].digit2, layout["end"].digit3, layout["end"].digit4, layout["end"].digit5}]]

--explosion = Group()
--loadfile("/screens/explosion.lua")(explosion)

screen:show()
screen:add(thislevel)
thislevel.layout.image0:grab_key_focus()

screen:add(overlay)
snow.raise()
overclone = Clone{source = overlay, name = "overclone"}

die = dofile('die.lua')

function update_reset(all)
	local evt, ui, orig
	if thislevel.events then
		for k,v in pairs(thislevel.events) do
			ui = v.ui
			orig = v.original
			if all or row == v.row then
				if v.event_type == "patrol" or
					(all and v.event_type == "move") then
					ui:complete_animation()
					ui.position = orig
					v.triggered = false
				elseif all and v.event_type == "appear" then
					ui.opacity = 0
				elseif v.event_type == "rand patrol" then
					for i = 1, #ui do
						ui[i]:complete_animation()
						if v.x then
							v.ui[i].x = orig
						else
							v.ui[i].y = orig
						end
					end
				end
				v.triggered = false
			end	
		end
	end
	collectgarbage("collect")

	--reset gravity changers
	if not all then
		for k,v in pairs(thislevel.layout) do
			if v.collide == true and v.y < ground[row] and v.y > ground[row] - 360 then
				evt = v.extra.event
				if evt and (is_grav[string.sub(evt.event_type,9)]) then
					v.opacity = 255
				end	
			end
		end
		penguin.img.x_rotation = {0,0,0}
		gravity = grav_orig
	end
end

function reset_level()
	--[[local evt
	for k,v in pairs(thislevel.layout) do
		if v.collide == true then
			evt = v.extra.event
			if evt then
				if evt.event_type == "move" or 
				   evt.event_type == "patrol" then
					evt.ui.position = evt.original	
					evt.ui.vx = 0
					evt.ui.vy = 0
				end
				v.opacity = 255
			end	
		end
	end]]
	update_reset(true)
end

--[[function do_event(evt,ms)
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
		percent = ms / penguin.skating.duration
		penguin.skating.duration = 2500
		penguin.skating:advance(penguin.skating.duration * percent)
		--player.source = pspeed
	elseif evttype == "jump upgrade" then
		jspeed = -7
		jduration = -jspeed/gravity*2
		percent = ms/skating.duration
		penguin.skating.duration = 4000
		penguin.skating:advance(penguin.skating.duration * percent)
	elseif evttype == "gravity up" then
		if jstate > 0 then
			t = (ms - jtime)/8
			vspeed = vspeed + (gravity * t)
			jstart = penguin.y
			jtime = ms
			base = base + t/jduration
		end
		gravity = gravity + (gravity > 0 and 1 or -1)*0.05
		jduration = math.abs(-jspeed/gravity*2) * (1-base)
	elseif evttype == "gravity down" then
		if jstate > 0 then
			t = (ms - jtime) / 8
			vspeed = vspeed + gravity*t
			jstart = penguin.y
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
		jstart = penguin.y
		jtime = ms
		gravity = -gravity
		jduration = math.abs(-jspeed/gravity) * (1-base)
	end
	evt.triggered = true
end]]

function next_level()
	local oldlevel = thislevel
	thislevel = thislevel.id == #levels and levels[1] or levels[thislevel.id+1]
    
    deaths.text = "Deaths: " .. die.count
    level:animate{opacity = 0, duration = 570, on_completed = function()
        level.text = "Level " .. (thislevel.id-1) .. ": " .. thislevel.name
        level:animate{opacity = 255, duration = 560}
    end}
    
    thislevel.y = 1120
    screen:add(thislevel)
    thislevel:lower_to_bottom()
    snow.raise()
    snow.set(thislevel.snow)
    
    if thislevel.id ~= 1 then
        screen:add(overclone)
        overclone.y = 1120
    end
    
    thislevel:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
    overclone:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
    
    oldlevel:animate{y = -1300, duration = 1140, mode = "EASE_IN_OUT_QUAD"}
    overlay:animate{y = -1300, duration = 1140, mode = "EASE_IN_OUT_QUAD", on_completed = function()
        screen:remove(oldlevel)
        if thislevel.id ~= 1 then
            screen:remove(overclone)
            thislevel.text1:animate{y = 20, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
            overlay.position = {0,0}
            row = 1
            penguin.skating:start()
            screen:grab_key_focus()
        else
            thislevel.layout.image0:grab_key_focus()
        end
    end}
		--deaths.opacity = 0
		--penguin.img.opacity = 0
		--groups["end"].opacity = 0
		--screen:add(groups["end"])
		--pengEnd = layout["end"].player
		--[[a = die.count
		for i = 1,5 do
			digits[i].source = numbers[(a%10) + 1]
			digits[i].opacity = 0
			a = math.floor(a/10)
		end
		
		pengEnd:move_anchor_point(96,106)
		local py = pengEnd.y
		local op = "opacity"

		local temp = {
			{groups[levels[level] ], op, {{0,255}, {.1,0}}},
			{groups["end"],	op, {{0,0}, {.1,255}}},

			{digits[5],	op,	{{0,0}, {.1,0}, {.15,255}}},
			{digits[4],	op,	{{0,0}, {.15,0}, {.2,255}}},
			{digits[3],	op,	{{0,0}, {.2,0},  {.3,255}}},
			{digits[2],	op,	{{0,0}, {.3,0},  {.4,255}}},
			{digits[1],	op,	{{0,0}, {.4,0},  {.5,255}}},

			{layout["end"].ice, "x", {{0,1853}, {.35,1853}, {.85,645}}},
			{pengEnd,			"x", {{0,2061}, {.35,2061}, {.85,853}, {1,296}}},
			{pengEnd,			"y", {{0,py}, {.85,py}, {.920,"EASE_OUT_QUAD",py-300}, {1,"EASE_IN_QUAD",856}}},
			{pengEnd,  "z_rotation", {{0,"LINEAR",0}, {.85,"LINEAR",0}, {1,"LINEAR",-360}}}}
			
		local prop = {}
		for k,v in ipairs(temp) do
			prop[k] = {source = v[1], name = v[2], keys = v[3]}
		end
		
		Animator{duration = 10000, properties = prop}:start()
		
		won = true
	end]]
end

function screen:on_key_down(key)
	if (key == keys["OK"]) then
		if (not won) then
			penguin.jump()
		else
			--groups[levels[level]].opacity = 255
			
			--layout["end"].ice.position = {1853,795}
			--layout["end"].penguin.position = {1965,650}
			
			--screen:remove(groups[levels[level]])
			--screen:remove(groups["end"])
			--screen:add(groups["splash"])
			
			--groups["splash"].position = {0,0}
			--layout["splash"].button2:grab_key_focus()
			
			--[[pengStart = layout["splash"].player
			pengStart.position = {880,925}
			pengStart.y_rotation = {0,77.5,0}
			die.count = 0
			won = false
			level = 1]]
			
			-- --penguin.skating.duration = 4000
			-- --penguin.reset(1,0)
		end
	elseif (key == keys["0"]) then
		penguin.kill()
	elseif (key == keys["5"]) then
        penguin.skating:stop()
		reset_level()
		next_level()
		row = 1
		gravity = grav_orig
		--[[if (level > 6) then
			do_event({event_type = "speed upgrade"}, 0)
		end
		if (level > 8) then
			do_event({event_type = "jump upgrade"}, 0)
		end]]
	end
end

end

dolater( main )