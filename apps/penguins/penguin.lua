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
local boosted = false
img.armor = nil

local reset = function()
	ovx = 2020*(row == 2 and -1 or 1)/4000
		img.vx = ovx
	img.vy = 0
	jstate = 0
	floor = nil
	img.opacity = 255
	img.position = row == 2 and {1920,levels.this.trans} or {-80,ground[1]}
	if row == 1 then
		img.armor = nil
		boosted = false
	elseif img.y ~= ground[1]+640 then
		floor = levels.this.bridges[img.y-640]
		img.vx = ovx*(boosted and floor.boost and 1.3 or 1)
	end
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
		if (self.duration == 200 and img.y > oy+40) or
			(levels.this.bank > 0 and img.y > ground[row]+30) then
			self:stop()
			self:on_completed()
		end
	end,
	on_completed = function(self)
		if self.duration == 200 then
			explode(levels.this.bank > 0 and rand(15,20) or nil,nil,true) 
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
	explode((levels.this.bank > 0 and img.vy == 0) and rand(15,20) or nil)
	skating:stop()
	
	a = {x = (obj.bb.l + obj.bb.r - img.bb.l - img.bb.r)/2,
		 y = (obj.bb.t + obj.bb.b - img.bb.t - img.bb.b)/2}
	t = math.atan2(a.y/obj.scale[2],a.x/obj.scale[1])
	t = t + math.sin(4*t-math.pi)/4
	a = {x = math.cos(t), y = math.sin(t)}
	d = obj.vx and obj.vy and obj.vx*a.x + obj.vy*a.y or 0
	
	if img.vy == 0 then
		img.vz = (img.vx > 0) == g and -0.5 or 0.5
		img.vx = -img.vx-d/2
		img.vy = 0
	else
		b = img.vx*a.x + img.vy*a.y
		t = (img.vx > 0) == g and 1 or -1
		img.vz = 0.5*(img.vx*a.y - img.vy*a.x)/(img.vx^2 + img.vy^2)
		img.vx = img.vx + a.x*d - (b > 0 and 2*a.x*b or -t*a.y*b)
		img.vy = img.vy + a.y*d - (b > 0 and 2*a.y*b or  t*a.x*b)
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
		if jstate == 0 and floor == nil and levels.this.bank > 0 then
			explode(12)
		end
		img.vy = math.min(img.vy,(vy or jvy) * (g and 1 or -1) * 2/(2+jstate))
		a = (g == (row ~= 2) and -1 or 1)
		b = img.z_rotation[1] % (a*360)
		img.z_rotation = {b + (b*a < 240 and 360*a or 0), imgw2, imgh2}
		jstate = jstate + (vy and 0.9 or 1)
	end
end

local boost = function()
	boosted = true
	img.vx = ovx*2
	if jstate == 0 then
		--
	else
		jstate = 2
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
	--img.vx = ovx - (ovx-img.vx)/2^(d/400)
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
	end
	
	img.bb = {l = img.x + 20,			t = img.y + imgh2-imgw2 + 13,
			  r = img.x - 20 + img.w,	b = img.y + imgh2+imgw2 - 13}
			  
	if jstate == 0 then
		a = img.z_rotation[1]
		if a ~= 0 then
			b = (a > 0 and 1 or -1)
			img.z_rotation = {math.max(0,a*b-d/2)*b, imgw2, imgh2}
		end
		if floor and (img.bb.l > floor.bb.r or img.bb.r < floor.bb.l) then
			if floor.flip then
				jump()
			end
			jstate = 1
			floor = nil
		end
	end
	
	--object collisions
	for k,v in pairs(levels.this.children) do
		if v.state > 0 and v.is_visible then
			if v.state == 2 then
				v.bb = {l = v.x + v.bbox.l, r = v.x + v.bbox.r,
						t = v.y + v.bbox.t, b = v.y + v.bbox.b}
			end
			if img.bb.l < v.bb.r and img.bb.t < v.bb.b and img.bb.r > v.bb.l and img.bb.b > v.bb.t then
				if v.collision then
					v.collision()
				else
					if v.state == 3 and img.armor then 
						v.smash(true)
						img.armor.drop()
					else
						kill(v)
					end
				end
				return
			end
		end
	end
	
	-- ceiling collisions
	if img.y > ground[row] or img.y < ground[row] - ground[1] then
		land(ground[row] - (img.y > ground[row] and 0 or ground[1]))
		if levels.this.bank > 0 then
			explode(12)
		end
	end
	
	if jstate == 0 and levels.this.bank > 0 and rand(4) == 1 then
		explode(1)
	end
end

function skating:on_completed()
	if row == 1 then
		a = ground[1]
		for k,v in pairs(levels.this.bridges) do
			if k >= img.y and k < a then
				a = k
			end
		end
		levels.this.trans = a+640
		row = 2
		levels.this:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		overlay:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD",
			on_completed = function() skating:start() end}
		if levels.this.bank > 0 then
			snowbank:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
		end
	else
		levels.next()
		row = 1
	end
end

function screen:on_key_down(key)
	if key >= keys["4"] and key <= keys["7"] then
		skating:rewind()
		skating:stop()
		if key == keys["4"] then
			levels.next(-1)
		elseif key == keys["5"] then
			skating:on_completed()
		elseif key == keys["6"] then
			levels.next(1)
		else
			levels.next(5)
		end
		row = 1
	elseif key >= keys["0"] and key <= keys["9"] then
		skating:rewind()
		reset()
	else
		if skating.is_playing and not img.armor then
			jump()
		elseif levels.this.id == 1 then
			levels.next()
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