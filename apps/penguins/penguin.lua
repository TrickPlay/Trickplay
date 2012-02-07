local img = Sprite{src = "penguin.png", position = {-80,ground[1],0}, opacity = 0, name = "penguin"}
local jvy = -1
local g = gravity > 0
local jstate = 0
local skating = Timeline{duration = 8000}
local floor
local a, b, d
local ovx = 2020/4000
local imgw2, imgh2 = img.w/2, img.h/2
local ox, oy, oz = 0, 0, 0
local boosted = false
local landjump = 0
img.deaths = 0
img.armor = nil

img.mask = BBox(img,{20,imgh2-imgw2 + 13,-20,-imgh2+imgw2 - 13})

local reset = Event()

reset[img] = function()
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
	img.src = levels.this.bank == 2 and "penguin-lantern.png" or "penguin.png"
	if levels.this.bank == 2 then
		darkness.dark:warp(darkness.dark.state)
		darkness.dark.state = 0
	end
end

local falling = Timeline{ duration = 500,
	on_new_frame = function(self,ms,t)
		if self.duration == 200 and img.y > oy+40 then
			self.duration = 199
			img.opacity = 0
			fx.splash()
		elseif levels.this.bank == 1 and img.y > ground[row]+30 then
			self:stop()
			self:on_completed()
		elseif self.duration ~= 199 then
			img.x = ox + img.vx*ms
			img.y = oy + (img.vy ~= 0 and img.vy*ms + gravity*ms*ms/2 or 0)
			img.z_rotation = {oz + img.vz*ms,imgw2,imgh2}
			img.opacity = self.duration == 200 and max(0,255+(oy-img.y)*255/40) or 255*(1-t)
		end
	end,
	on_completed = function(self)
		if self.duration == 200 then
			fx.splash()
		end
		img.deaths = img.deaths+1
		settings.deaths = img.deaths
		overlay.deaths.text = img.deaths
		skating:start()
	end
}

local fall = function(sink)
	ox, oy, oz = img.x, img.y, img.z_rotation[1]
	falling.duration = sink and 200 or 500
	if levels.this.bank == 2 then
		darkness.dark.state = sink and 1 or 2
	end
	falling:start()
end

local sink = function()
	if img.vy >= 0 then
		skating:stop()
		img.vz = jstate > 0 and 0 or (row == 2 and -0.2 or 0.2)
		audio.play("splash-" .. (jstate > 0 and 2 or 1))
		fall(true)
		if img.vy == 0 then
			img.vy = 0.01
		end
	end
end

local kill = function(obj)
	fx.explode()
	skating:stop()
	a = obj.mask or obj
	a = {x = a.x + a.w/2 - img.mask.x - img.mask.w/2,
		 y = a.y + a.h/2 - img.mask.y - img.mask.h/2}
	t = math.atan2(a.y/obj.scale[2],a.x/obj.scale[1])
	t = t + math.sin(4*t-math.pi)/4
	a = {x = math.cos(t), y = math.sin(t)}
	d = obj.state == 2 and obj.vx and obj.vy and obj.vx*a.x + obj.vy*a.y or 0
	
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
		obj:fall(-img.vx,-img.vy,-img.vz)
	end
	
	fall()
	audio.play("crash")
end

local jump = function(vy)
	floor = nil
	if row == 1 and img.x < 250 then return end
	if jstate < 2 or vy then
		if not vy then
			audio.play("jump-" .. (jstate > 0 and 2 or 1))
		end
		if jstate == 0 and floor == nil and levels.this.bank == 1 then
			fx.explode(12)
		end
		img.vy = math.min(img.vy,(vy or jvy) * (g and 1 or -1) * 2/(2+jstate))
		a = (g == (row ~= 2) and -1 or 1)
		b = img.z_rotation[1] % (a*360)
		img.z_rotation = {b + (b*a < 240 and 360*a or 0), imgw2, imgh2}
		jstate = min(jstate,1) + (vy and 0.9 or 1)
	else
		landjump = 5
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
	audio.play("boost")
end

local land = function(y,obj,silent)
	img.y = y
	if (img.vy > 0) == g then
		img.vy = 0
		jstate = 0
		if not silent then
			audio.play("land")
		end
		if landjump > 0 then
			jump()
			landjump = 0
		end
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
	img.x = img.x + img.vx*d
	
	if img.x > 1920 or img.x < -80 then
		img.x = img.x > 960 and 2200 or -200
		skating:stop()
		skating:on_completed()
		return
	end
	
	if jstate > 0 then
		img.dy = img.vy*d + gravity*d*d/2
		img.y = img.y + img.dy
		img.vy = img.vy + gravity*d
		img.z_rotation = {(0.4 + 0.4/(1+8^img.vy)) ^ (d/100) * img.z_rotation[1], imgw2, imgh2}
	end
	
	img.mask.dirty = 1
	
	if jstate == 0 then
		a = img.z_rotation[1]
		if a ~= 0 then
			b = (a > 0 and 1 or -1)
			img.z_rotation = {math.max(0,a*b-d/2)*b, imgw2, imgh2}
		end
		if floor and (img.mask.x > floor.mask.x + floor.mask.w or img.mask.x + img.mask.w < floor.mask.x and img.x < 1900) then
			if floor.flip then
				jump()
			end
			jstate = 1
			floor = nil
		end
	end
	
	--object collisions
	if row == 1 and img.x < 250 then return end
	for k in pairs(objectSet) do
		if img.mask:intersects(k.mask) then
			if k.on_collision then
				k:on_collision()
			elseif k.smash and img.armor then 
				k:smash(true)
				audio.play("ice-blocks-fall")
				img.armor:drop()
			else
				img.kill(k)
			end
			return
		end
	end
	
	-- ceiling collisions
	if img.y > ground[row] or img.y < ground[row] - ground[1] then
		land(ground[row] - (img.y > ground[row] and 0 or ground[1]))
		if levels.this.bank == 1 then
			fx.explode(12)
		end
	end
	landjump = landjump-1
	
	if jstate == 0 and levels.this.bank == 1 and rand(4) == 1 then
		fx.flakes(1)
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
		overlay.lift()
		img:animate{y = ground[2], duration = 500, mode = "EASE_IN_OUT_QUAD",
			on_completed = function() skating:start() end}
	else
		audio.play("level")
		levels.next()
		img:animate{y = ground[1], duration = 1120, mode = "EASE_IN_OUT_QUAD"}
		row = 1
	end
end

function screen:on_key_down(key)
	---[[
	if levels.this.id == 1 and levels.this.anim and (key == keys["Up"] or key == keys["Down"]) then
		levels.this.anim.state = 1-tonumber(levels.this.anim.state)
	elseif key >= keys["4"] and key <= keys["7"] then
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
	elseif key >= keys["0"] and key <= keys["9"] then
		skating:rewind()
		reset()--]]
	elseif key == keys['BACK'] then
		skating:stop()
		levels.next(0)
	elseif levels.this.id == 1 then
		if levels.this.swap then
			levels.this.swap()
		elseif levels.this.anim and levels.this.anim.state == '0' then
			img.deaths = settings.deaths
			overlay.deaths.text = img.deaths
			levels.next(settings.level-1)
		else
			levels.next()
			img.deaths = 0
			overlay.deaths.text = img.deaths
		end
	elseif skating.is_playing and not img.armor then
		jump()
	end
	--
end

img.vx, img.vy, img.vz = 0, 0, 0
img.dy = 0
img.skating = skating
img.falling = falling
img.kill = kill
img.sink = sink
img.jump = jump
img.boost = boost
img.land = land
img.reset = reset

return img