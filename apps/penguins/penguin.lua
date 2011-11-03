local img = Image{ src = "assets/penguin.png", position = {-80,220,0}, opacity = 0, name = "penguin"}
local vspeed = 0
local jspeed = -8
local jtime = 0
local jstart = 0
local jstate = 0
local deathcount = 0
local skating = Timeline{duration = 4000}
local bb = {}
local a, b, c, d, r, t, msp
local imgw2, imgh2 = img.w/2, img.h/2

local reset = function(j,p)
	if j == 1 then
		vspeed = 0
		jstate = 0
	end
	if p == 1 then
		img.opacity = 255
		img.position = {row == 2 and 1920 or -80, ground[row]}
		img.x_rotation = {0,0,0}
		img.y_rotation = {row == 2 and 180 or 0,imgw2,0}
		gravity = 0.13
	end
end

local die = dofile("die.lua")

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
		d = 0
		if block.vx ~= nil and block.vy ~= nil then
			d = block.vx*b.x/2 + block.vy*b.y/2
		end
		
		if a.y == 0 and img.y == ground[row] - (gravity > 0 and 0 or ground[1]) then
			gravity = 0
			dvy = 0
			c = -a.x-d
			r = (a.x > 0) == (gravity > 0) and 0.5 or -0.5
		else
			dvy = a.y + 2*(c+d)*b.y
			c = a.x + 2*(c+d)*b.x
			r = 0.5*(a.x*b.y - a.y*b.x)/(a.x*a.x + a.y*a.y)
		end
		die(c,dvy,r)
		explode()
	end
	
	reset(1,0)
	
	deathcount = deathcount+1
	overlay.deaths.text = "Deaths: " .. deathcount
end

local sink = function()
	die((2*(row%2)-1) * 2020/skating.duration,
		jstate > 0 and vspeed/8 + gravity*(skating.elapsed-jtime)/64 or 0,
		jstate > 0 and 0 or (row == 2 and -0.2 or 0.2), true)
	skating:stop()
	deathcount = deathcount+1
	overlay.deaths.text = "Deaths: " .. deathcount
end

local jump = function(speed)
	if row == 1 and img.x < 250 then return end
	if jstate < 2 or (speed and jstate < 3) then
		vspeed = (speed or jspeed) * (gravity > 0 and 1 or -1) * 2/(2+jstate)
		jstart = img.y
		jtime = skating.elapsed
		img.z_rotation = {(jstate > 0 and img.z_rotation[1] or 0) + (a == (row ~= 2) and -360 or 360), imgw2, imgh2}
		jstate = jstate + 1
	end
end

function skating:on_started()
	reset(1,1)
	msp = 0
end

function skating:on_new_frame(ms,t)
	-- update jump
	img.xp = img.x
	img.x = (row == 2 and 1920-2020*t or -80+2020*t)
	
	a = gravity > 0

	if jstate > 0 then
		t = (ms - jtime)/8
		img.yp = img.y
		img.y = jstart + vspeed*t + gravity*t*t/2
		r = (0.4 + 0.4/2^(t/100)) ^ ((ms-msp)/100)
		img.z_rotation = {r * img.z_rotation[1], imgw2, imgh2}
	else
		jtime = ms
		img.z_rotation = {360, imgw2, imgh2}
	end
	
	--update collisions
	bb = {l = img.x + 20,			t = img.y + imgh2-imgw2 + 13,
		  r = img.x - 20 + img.w,	b = img.y + imgh2+imgw2 - 13}
	
	for k,v in pairs(levels.this.children) do
		if v.collide == true and v.opacity ~= 0 then
			if v.moves then
				r = v.anchor_point
				v.bb = {l = v.x - r[1], r = v.x - r[1] + v.w*v.scale[1],
						t = v.y - r[2], b = v.y - r[2] + v.h*v.scale[2]}
			end
			if bb.l < v.bb.r and bb.r > v.bb.l and
			   bb.t < v.bb.b and bb.b > v.bb.t then
				if v.collision then
					v.collision()
				else
					kill(v,ms)
				end
				break
			end
		end
	end
	
	-- update ceiling collision
	b = img.y > ground[row]
	c = img.y < ground[row] - ground[1]
	
	if b or c then
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
		end
		jtime = ms
	end
	
	msp = ms
end

function skating:on_completed()
	if row == 1 then
		row = 2
		levels.this.text2:animate{y = 670, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		levels.this:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD", on_completed = function()
			skating:start() 
		end}
	else
		levels.next()
		row = 1
	end
end

function screen:on_key_down(key)
	if (key == keys["OK"]) then
		jump()
	elseif (key == keys["0"]) then
		kill()
	elseif (key == keys["5"]) then
		skating:stop()
		levels.next()
		row = 1
	end
end

img.reset = reset
img.skating = skating
img.kill = kill
img.sink = sink
img.jump = jump

return img