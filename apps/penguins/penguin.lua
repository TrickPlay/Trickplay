local img = Image{ src = "assets/penguin.png", position = {-80,220,0}, opacity = 0, name = "penguin"}
local jvy = -1
local g = gravity > 0
local jstate = 0
local deathcount = 0
local skating = Timeline{duration = 8000}
local floor
local a, b, d
local ovx = 2020/4000
local imgw2, imgh2 = img.w/2, img.h/2
local ox, oy, oz = 0, 0, 0

local reset = function()
	ovx = 2020*(row == 2 and -1 or 1)/4000
	img.vx = ovx
	img.vy = 0
	jstate = 0
	floor = nil
	img.opacity = 255
	img.position = {row == 2 and 1920 or -80, ground[row]}
	img.y_rotation = {row == 2 and 180 or 0,imgw2,0}
	img.z_rotation = {0,0,0}
	gravity = 0.002
	for k,v in pairs(levels.this.children) do
		v:show()
	end
end

local falling = Timeline{ duration = 500,
	on_new_frame = function(self,ms,t)
		img.x = ox + img.vx*ms
		img.y = oy + (img.vy ~= 0 and img.vy*ms + gravity*ms*ms/2 or 0)
		img.z_rotation = {oz + img.vz*ms,imgw2,imgh2}
		img.opacity = 255*(1-t)
		if self.duration == 200 and img.y > oy+40 then
			self:stop()
			self:on_completed()
		end
	end,
	on_completed = function(self)
		if self.duration == 200 then
			explode()
		end
		reset()
		deathcount = deathcount+1
		overlay.deaths.text = deathcount
		skating:start()
	end
}

local fall = function(sink)
	ox, oy, oz = img.x, img.y, img.z_rotation[1]
	falling.duration = sink and 200 or 500
	falling:start()
end

local sink = function()
	skating:stop()
	img.vz = jstate > 0 and 0 or (row == 2 and -0.2 or 0.2)
	fall(true)
	if img.vy == 0 then
		img.vy = 0.01
	end
end

local kill = function(obj)
	explode()
	skating:stop()
	
	a = {x = (obj.bb.l + obj.bb.r - img.bb.l - img.bb.r)/2,
		 y = (obj.bb.t + obj.bb.b - img.bb.t - img.bb.b)/2}
	t = math.atan2(a.y/obj.scale[2],a.x/obj.scale[1])
	t = t + math.sin(4*t-math.pi)/4
	a = {x = math.cos(t), y = math.sin(t)}
	d = obj.vx and obj.vy and obj.vx*a.x/2 + obj.vy*a.y/2 or 0
	
	if img.vy == 0 then
		img.vz = (img.vx > 0) == g and -0.5 or 0.5
		img.vx = -img.vx-d
		img.vy = 0
	else
		b = 2*(d-(img.vx*a.x + img.vy*a.y))
		img.vz = 0.5*(img.vx*a.y - img.vy*a.x)/(img.vx^2 + img.vy^2)
		img.vx = img.vx + a.x*b
		img.vy = img.vy + a.y*b
	end
	
	if obj.fall then
		obj.fall(-img.vx,-img.vy,-img.vz)
	end
	
	fall()
end

local jump = function(vy)
	floor = nil
	if row == 1 and img.x < 250 then return end
	if jstate < 2 or vy then
		img.vy = math.min(img.vy,(vy or jvy) * (g and 1 or -1)) * 2/(2+jstate)
		a = (g == (row ~= 2) and -1 or 1)
		b = img.z_rotation[1] % (a*360)
		img.z_rotation = {b + (b*a < 240 and 360*a or 0), imgw2, imgh2}
		jstate = jstate + (vy and 0.9 or 1)
	end
end

local boost = function()
	img.vx = img.vx*2
	if jstate == 0 then
		--
	else
		--jstate = 2
		img.vy = math.min(-0.3,img.vy)
		a = (g == (row ~= 2) and 1 or -1)
		b = img.z_rotation[1] % (a*360)
		img.z_rotation = {b + (b*a < 240 and 360*a or 0), imgw2, imgh2}
	end
end

local land = function(y,obj)
	img.y = y
	if (img.vy > 0) == g then
		img.vy = 0
		jstate = 0
	else
		img.vy = -img.vy/2
	end
	
	if obj then
		floor = obj
	end
end

skating.on_started = reset

function skating:on_new_frame(ms,t)
	d = self.delta
	--img.vx = ovx - (ovx-img.vx)/2^(d/100)
	img.x = img.x + img.vx*d
	
	if img.x > 1920 or img.x < -80 then
		skating:stop()
		skating:on_completed()
	end
	
	if jstate > 0 then
		img.dy = img.vy*d + gravity*d*d/2
		img.y = img.y + img.dy
		img.vy = img.vy + gravity*d
		img.z_rotation = {(0.4 + 0.4/(1+8^img.vy)) ^ (d/100) * img.z_rotation[1], imgw2, imgh2}
	else
		a = img.z_rotation[1]
		if a ~= 0 then
			b = (a > 0 and 1 or -1)
			img.z_rotation = {math.max(0,a*b-d/2)*b, imgw2, imgh2}
		end
		if floor and (img.bb.l > floor.bb.r or img.bb.r < floor.bb.l) then
			jstate = 1
			floor = nil
		end
	end
	
	--object collisions
	img.bb = {l = img.x + 20,			t = img.y + imgh2-imgw2 + 13,
			  r = img.x - 20 + img.w,	b = img.y + imgh2+imgw2 - 13}
	
	for k,v in pairs(levels.this.children) do
		if v.state > 0 and v.is_visible then
			if v.state == 2 then
				r = v.anchor_point
				v.bb = {l = v.x - r[1], r = v.x - r[1] + v.w*v.scale[1],
						t = v.y - r[2], b = v.y - r[2] + v.h*v.scale[2]}
			end
			if img.bb.l < v.bb.r and img.bb.t < v.bb.b and img.bb.r > v.bb.l and img.bb.b > v.bb.t then
				if v.collision then
					v.collision()
				else
					kill(v)
					if v.state == 3 then 
						-- armor, blocks breaking
					end
				end
				return
			end
		end
	end
	
	-- ceiling collisions
	if img.y > ground[row] or img.y < ground[row] - ground[1] then
		land(ground[row] - (img.y > ground[row] and 0 or ground[1]))
	end
end

function skating:on_completed()
	if row == 1 and levels.this.id > 1 then
		row = 2
		levels.this:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD",
			on_completed = function() skating:start() end}
	else
		levels.next()
		row = 1
	end
end

function screen:on_key_down(key)
	if key == keys["OK"] then
		if skating.is_playing then
			jump()
		elseif levels.this.id == 1 then
			levels.next()
		end
	else
		skating:rewind()
		if key == keys["4"] then
			skating:stop()
			levels.next(-1)
			row = 1
		elseif key == keys["5"] then
			skating:stop()
			skating:on_completed()
		else
			reset()
		end
	end
end

img.vx, img.vy, img.vz = 0, 0, 0
img.dy = 0
img.skating = skating
img.kill = kill
img.sink = sink
img.jump = jump
img.boost = boost
img.land = land
img.bb = {}

return img