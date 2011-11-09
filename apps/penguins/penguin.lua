local img = Image{ src = "assets/penguin.png", position = {-80,220,0}, opacity = 0, name = "penguin"}
local vspeed = 0
local jspeed = -1
local jtime = 0
local jstart = 0
local jstate = 0
local deathcount = 0
local skating = Timeline{duration = 4000}
local bb = {}
local a, b, c, d, r, t
local imgw2, imgh2 = img.w/2, img.h/2
local ox, oy, oz, vx, vy, vz = 0, 0, 0, 0, 0, 0
local sinking

local reset = function(j,p)
	if j == 1 then
		vspeed = 0
		jstate = 0
	end
	if p == 1 then
		sinking = false
		ox, oy, oz, vx, vy, vz = 0, 0, 0, 0, 0, 0
		img.opacity = 255
		img.position = {row == 2 and 1920 or -80, ground[row]}
		img.x_rotation = {0,0,0}
		img.y_rotation = {row == 2 and 180 or 0,imgw2,0}
		gravity = 0.002
	end
end

local falling = Timeline{ duration = 500,
	on_new_frame = function(self,ms,t)
		img.x = ox + vx*ms
		img.y = oy + vy*ms + gravity*ms*ms/2
		img.z_rotation = {oz + vz*ms,imgw2,imgh2}
		img.opacity = 255*(1-t)
		if sinking and img.y > oy+40 then
			self:stop()
			self.on_completed()
		end
	end,
	on_completed = function(self)
		if sinking then
			explode()
		end
		reset(1,1)
		deathcount = deathcount+1
		overlay.deaths.text = deathcount
		skating:start()
	end
}

local fall = function()
	falling.duration = sinking and 200 or 500
	falling:rewind()
	falling:start()
end

local kill = function(obj,ms)
	explode()
	if obj then
		skating:stop()
		a = {x = (2*(row%2)-1) * 2020/skating.duration,
			 y = jstate > 0 and vspeed + gravity*(ms-jtime) or 0}
		b = {x = (obj.bb.l + obj.bb.r - bb.l - bb.r)/2,
			 y = (obj.bb.t + obj.bb.b - bb.t - bb.b)/2}
		t = math.atan2(b.y/obj.scale[2],b.x/obj.scale[1])
		t = t + math.sin(4*t-math.pi)/4
		b = {x = math.cos(t), y = math.sin(t)}
		c = -(a.x*b.x + a.y*b.y)
		d = 0
		if obj.vx ~= nil and obj.vy ~= nil then
			d = obj.vx*b.x/2 + obj.vy*b.y/2
		end
		
		if a.y == 0 and img.y == ground[row] - (gravity > 0 and 0 or ground[1]) then
			gravity = 0
			vx = -a.x-d
			vy = 0
			vz = (a.x > 0) == (gravity > 0) and 0.5 or -0.5
		else
			vx = a.x + 2*(c+d)*b.x
			vy = a.y + 2*(c+d)*b.y
			vz = 0.5*(a.x*b.y - a.y*b.x)/(a.x*a.x + a.y*a.y)
		end
		if obj.fall then
			obj.fall(-vx,-vy,-vz)
		end
		ox, oy, oz = img.x, img.y, img.z_rotation[1]
		fall()
		reset(1,0)
	else
		reset(1,1)
		skating:rewind()
	end
end

local sink = function()
	vx = (2*(row%2)-1) * 2020/skating.duration
	vy = jstate > 0 and vspeed + gravity*(skating.elapsed-jtime) or 0
	vz = jstate > 0 and 0 or (row == 2 and -0.2 or 0.2)
	ox, oy, oz = img.x, img.y, img.z_rotation[1]
	
	skating:stop()
	sinking = true
	fall()
end

local jump = function(speed)
	if row == 1 and img.x < 250 then return end
	if jstate < 2 or (speed and jstate < 3) then
		vspeed = (speed or jspeed) * (gravity > 0 and 1 or -1) * 2/(2+jstate)
		jstart = img.y
		jtime = skating.elapsed
		img.z_rotation = {(jstate > 0 and img.z_rotation[1] or 0) + (a == (row ~= 2) and -360 or 360), imgw2, imgh2}
		jstate = math.min(2,jstate + 1)
	end
end

function skating:on_started()
	reset(1,1)
end

function skating:on_new_frame(ms,t)
	-- update jump
	img.xp = img.x
	img.x = (row == 2 and 1920-2020*t or -80+2020*t)
	
	a = gravity > 0

	if jstate > 0 then
		t = ms-jtime
		img.yp = img.y
		img.y = jstart + vspeed*t + gravity*t*t/2
		img.vy = vspeed + gravity*t
		r = (0.4 + 0.4/2^(t/800)) ^ (self.delta/100)
		img.z_rotation = {r * img.z_rotation[1], imgw2, imgh2}
	else
		jtime = ms
		img.z_rotation = {360, imgw2, imgh2}
	end
	
	--update collisions
	bb = {l = img.x + 20,			t = img.y + imgh2-imgw2 + 13,
		  r = img.x - 20 + img.w,	b = img.y + imgh2+imgw2 - 13}
	
	for k,v in pairs(levels.this.children) do
		if v.collides and v.opacity then
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
			vspeed = -(vspeed + gravity*(ms-jtime))/2
			jstart = img.y
		end
		jtime = ms
	end
end

function skating:on_completed()
	if row == 1 then
		row = 2
		--levels.this.text2:animate{y = 670, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
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
		if row == 1 and levels.this.id > 1 then
			row = 2
			--levels.this.text2:animate{y = 670, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
			levels.this:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
			overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD", on_completed = function()
				skating:start() 
			end}
		else
			skating:rewind()
			levels.next()
			row = 1
		end
	end
end

img.reset = reset
img.skating = skating
img.kill = kill
img.sink = sink
img.jump = jump
img.vy = 0

return img