local img = Image{ src = "/assets/images/penguin-full-side-larger.png", position = {-80,220,0}, opacity = 0, name = "penguin"}
local vspeed = 0
local jspeed = -8
local jtime = 0
local jstart = 0
local jstate = 0
local jduration = -2*jspeed/gravity
local skating = Timeline{duration = 4000}
local a, b, c, r, t

local reset = function(jump,pos)
	if jump then
		vspeed = 0
		jstate = 0
		jduration = -jspeed / gravity * 2
	end
	if pos then
		img:complete_animation()
		img.opacity = 255
		img.position = {row == 2 and 1920 or -80, ground[row]}
		img.x_rotation = {0,0,0}
		img.y_rotation = {row == 2 and 180 or 0,img.w/2,0}
	end
end

local kill = function(block,ms)
	skating:stop()
	
	for k,v in pairs(explosion.children) do
		v.position = img.position
	end
	
	if block then
		a = {x = (2*(row%2)-1) * 2020/skating.duration,
			 y = jstate > 0 and vspeed/8 + gravity*(ms-jtime)/64 or 0}
		b = {x = (block.x + block.w*block.scale[1]/2) - (img.x + img.w/2),
			 y = (block.y + block.h*block.scale[2]/2) - (img.y + img.h/2)}
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
			c = img.x + -a.x*die.duration
			r = (a.x > 0) == (gravity > 0) and 0.5 or -0.5
		else
			dvy = a.y + 2*c*b.y
			c = img.x + (a.x + 2*c*b.x)*die.duration
			r = 0.5*(a.x*b.y - a.y*b.x)/(a.x*a.x + a.y*a.y)
		end
		
		t = img.z_rotation[1] + r*die.duration
		
		img:animate{duration = die.duration, x = c, z_rotation = t, opacity = 0}
	end
	
	screen:add(explosion)
	die.start(img.y,dvy)
	reset(1,0)
	
	die.count = die.count+1
	deaths.text = "Deaths: " .. die.count
end

function skating:on_started()
	reset(1,1)
	gravity = grav_orig
end

function skating:on_new_frame(ms,t)
	img.x = (row == 2 and 1920-2020*t or -80+2020*t)
	
	-- update jump
	a = gravity > 0

	if jstate > 0 then
		t = (ms - jtime)/8
		r = math.min(base + t/jduration,1)
		img.y = jstart + vspeed*t + gravity*t*t/2
		img.z_rotation = {360 * (a == (row ~= 2) and r or 1-r), img.w/2, img.h/2}
		if jstate == 2 then
			img.x_rotation = {180 * (a and 1-r or r), img.w/2, 0}
		end
	else
		jtime = ms
		img.z_rotation = {360, img.w/2, img.h/2}
	end
	
	b = img.y > ground[row]
	c = img.y < ground[row] - ground[1]
	
	if gravity ~= 0 and (b or c) then
		img.y = ground[row] - (c and ground[1] or 0)
		if a == b then
			jstate = 0
			vspeed = 0
			img.z_rotation = {360, img.w/2, img.h/2}
			img.x_rotation = {(a and 0 or 180), img.w/2, 0}
		else
			t = (ms - jtime)/8
			vspeed = -(vspeed + gravity*t)/2
			jstart = img.y
			base = base + t/jduration
		end
		jtime = ms
	end
	
	--update events
	if thislevel.events then
		for k,v in pairs(thislevel.events) do
			if not v.triggered and row == v.row and ms > v.time then
				do_event(v,ms)
			end
		end
	end
	
	--update collisions
	for k,v in pairs(thislevel.layout) do
		if v.opacity ~= 0 and v.collide == true and not
				(img.x > v.x + (v.w * v.scale[1]) - 20 or img.x + img.w < v.x + 20 or
				 img.y + (img.h-img.w)/2 > v.y + (v.h * v.scale[2]) - 15 or
				 img.y + (img.h+img.w)/2 < v.y + 15) then
			if v.extra.event  then
				do_event(v.extra.event,ms)
				v.opacity = 0
			else
				kill(v,ms)
				break
			end
		end
	end
end

function skating:on_completed()
	if row == 1 then
		row = 2
		thislevel:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD", on_completed = function() skating:start() end}
	else
		reset_level()
		next_level()
		row = 1
	end
end

local jump = function()
	if jstate == 0 and (row ~= 1 or img.x > 250) then
		vspeed = jspeed * (gravity > 0 and 1 or -1)
		jstart = img.y
		base = 0
		jstate = 1
		jduration = math.abs(jspeed / gravity * 2)
	end
end

return {img = img, reset = reset, skating = skating, jump = jump, kill = kill}