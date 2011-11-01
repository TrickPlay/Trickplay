local img = Image{ src = "/assets/images/penguin-full-side-larger.png", position = {-80,220,0}, opacity = 0, name = "penguin"}
local vspeed = 0
local jspeed = -8
local jtime = 0
local jstart = 0
local jstate = 0
local jduration = -2*jspeed/gravity
local skating = Timeline{duration = 4000}
local bb = {}
local a, b, c, r, t, msp
local imgw2, imgh2 = img.w/2, img.h/2

local reset = function(jump,pos)
	if jump == 1 then
		vspeed = 0
		jstate = 0
		jduration = -jspeed / gravity * 2
	end
	if pos == 1 then
		img.opacity = 255
		img.position = {row == 2 and 1920 or -80, ground[row]}
		img.x_rotation = {0,0,0}
		img.y_rotation = {row == 2 and 180 or 0,imgw2,0}
	end
end

local kill = function(block,ms)
	skating:stop()
	
	if block then
		a = {x = (2*(row%2)-1) * 2020/skating.duration,
			 y = jstate > 0 and vspeed/8 + gravity*(ms-jtime)/64 or 0}
		b = {x = (block.bb.l + block.bb.r - bb.l - bb.r)/2,
			 y = (block.bb.t + block.bb.b - bb.t - bb.b)/2}
		t = math.atan2(b.y/block.scale[2],b.x/block.scale[1])
		t = t + math.sin(4*t-math.pi)/4
		b = {x = math.cos(t), y = math.sin(t)}
		c = -(a.x*b.x + a.y*b.y)
		if block.vx and block.vy then
			c = c + block.vx*b.x/2 + block.vy*b.y/2
		end
		
		if a.y == 0 and img.y == ground[row] - (gravity > 0 and 0 or ground[1]) then
			gravity = 0
			dvy = 0
			c = -a.x
			r = (a.x > 0) == (gravity > 0) and 0.5 or -0.5
		else
			dvy = a.y + 2*c*b.y
			c = a.x + 2*c*b.x
			r = 0.5*(a.x*b.y - a.y*b.x)/(a.x*a.x + a.y*a.y)
		end
        die.start(img.x,c,img.y,dvy,img.z_rotation[1],r)
        explode()
	end
	
	reset(1,0)
    
	die.count = die.count+1
	deaths.text = "Deaths: " .. die.count
end

function skating:on_started()
	reset(1,1)
	gravity = grav_orig
	msp = 0
end

function skating:on_new_frame(ms,t)
	img.xp = img.x
	img.x = (row == 2 and 1920-2020*t or -80+2020*t)
	
	-- update jump
	a = gravity > 0

	if jstate > 0 then
		t = (ms - jtime)/8
		img.yp = img.y
		img.y = jstart + vspeed*t + gravity*t*t/2
		r = (0.4 + 0.4/2^(t/100)) ^ ((ms-msp)/100)
		img.z_rotation = {r * img.z_rotation[1], imgw2, imgh2}
		--if jstate == 3 then
		--	img.x_rotation = {180 * (a and 1-r or r), img.w/2, 0}
		--end
	else
		jtime = ms
		img.z_rotation = {360, imgw2, imgh2}
	end
	
	b = img.y > ground[row]
	c = img.y < ground[row] - ground[1]
	
	if gravity ~= 0 and (b or c) then
		img.y = ground[row] - (c and ground[1] or 0)
		if a == b then
			jstate = 0
			vspeed = 0
			img.z_rotation = {0, imgw2, imgh2}
			img.x_rotation = {a and 0 or 180, imgw2, 0}
		else
			t = (ms - jtime)/8
			vspeed = -(vspeed + gravity*t)/2
			jstart = img.y
			--base = base + t/jduration
		end
		jtime = ms
	end
	
	--update events
	--[[if thislevel.events then
		for k,v in pairs(thislevel.events) do
			if not v.triggered and row == v.row and ms > v.time then
				do_event(v,ms)
			end
		end
	end]]
	
	--update collisions
	bb = {l = img.x + 20,         t = img.y + imgh2-imgw2 + 15,
		  r = img.x - 20 + img.w, b = img.y + imgh2+imgw2 - 15}
		  
	for k,v in pairs(thislevel.layout) do
		if v.opacity ~= 0 and v.collide == true and
				bb.l < v.bb.r and bb.r > v.bb.l and
				bb.t < v.bb.b and bb.b > v.bb.t then
			if v.extra.event  then
				do_event(v.extra.event,ms)
				v.opacity = 0
			else
				kill(v,ms)
				break
			end
		end
	end
	
	msp = ms
end

function skating:on_completed()
	if row == 1 then
		row = 2
        thislevel.text2:animate{y = 670, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		thislevel:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD", on_completed = function()
            skating:start() 
        end}
	else
		reset_level()
		next_level()
		row = 1
	end
end

local jump = function(ms)
	if row == 1 and img.x < 250 then return end
	if jstate == 0 then
		jstate = 1
		vspeed = jspeed * (gravity > 0 and 1 or -1)
		jstart = img.y
		--base = 0
		jduration = math.abs(jspeed/gravity*2)
		img.z_rotation = {(a == (row ~= 2) and -360 or 360), imgw2, imgh2}
	elseif jstate == 1 then
		jstate = 2
		vspeed = jspeed * 0.7 * (gravity > 0 and 1 or -1)
		jstart = img.y
		--base = base + (skating.elapsed - jtime)/jduration
		jtime = skating.elapsed
		img.z_rotation = {img.z_rotation[1] + (a == (row ~= 2) and -360 or 360), imgw2, imgh2}
	end
end

return {img = img, reset = reset, skating = skating, jump = jump, kill = kill}