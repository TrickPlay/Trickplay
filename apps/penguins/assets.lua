_Image = Image
_Clone = Clone

local src = ""
local cubes = {"cube-128.png","cube-128-4.png"}
local a
factory = Group()
factory:hide()
screen:add(factory)

local f = function(src,state,func,bbox)
	local orig = _Image{src = "assets/" .. src, name = src .. "\t"}
	factory:add(orig)
	
	state = state or 0
	bbox = bbox or {l = 0, t = 0, r = 0, b = 0}
	local clones = {}
	
	return function(def)
		local ret
		for i=1,#clones do
			if clones[i].freed then
				ret = clones[i]
				break
			end
		end
		
		if not ret then
			clones[#clones+1] = _Clone{source = orig}
			ret = clones[#clones]
			ret.free = function(self)
				self.freed = true
				self:unparent()
			end
		end
		
		ret.state = state
		def.source = nil
		def.src = nil
		
		for k,v in pairs(def) do
			ret[k] = v
		end
		
		if func then
			func(ret)
		end
		
		if state > 0 then
			a = ret.anchor_point
			ret.bbox = {l = bbox.l-a[1], r = bbox.r-a[1] + ret.w*ret.scale[1],
						t = bbox.t-a[2], b = bbox.b-a[2] + ret.h*ret.scale[2]}
		end
		
		ret.freed = false
		ret.level = levels.this.id
		
		return ret
	end
end

cubedriver = function (obj)
	--local switch = obj.name:match("s_(%w+)")
	local move = obj.clip
	obj.clip = {0,0,obj.w,obj.h}
	if move and (move[1] ~= 0 or move[2] ~= 0) then
		--[[if switch then
			obj.insert = function()
				switch = level.this:find_child(switch)
			end
			-- animate to/from
			-- obj.reset()
		else]]
			obj.state = 2
			obj.vx, obj.vy = move[1], move[2]
			local ox = (obj.vx > 0 and -128 or 1921)
			
			local anim = Timeline{duration = 9001, loop = true,
				on_new_frame = function(self,ms,t)
					if obj.x == move[3] or (obj.x > move[3]) == (obj.vx > 0) then
						if 20 < obj.x and obj.x < 1920 then
							if obj.x == move[3] then
								fx.smash(obj)
								audio.play("ice-breaking")
								obj.x = ox
							else
								obj.x = move[3]
							end
						else
							obj.x = ox + obj.x - move[3]
						end
					else
						obj.x = obj.x + obj.vx*self.delta
					end
				end
			}
			anim:start()
			
			obj.free = function(self)
				obj.vx = nil
				obj.vy = nil
				if anim then
					anim:stop()
				end
				anim = nil
				self.freed = true
				self:unparent()
			end
		--end
	else
		local touching = {}
		obj.insert = function()
			for k,v in ipairs(levels.this.children) do
				if v.state == 3 and v ~= obj
					and obj.x + obj.bbox.l < v.x + v.bbox.r
					and obj.y + obj.bbox.t < v.y + v.bbox.b
					and obj.x + obj.bbox.r > v.x + v.bbox.l
					and obj.y + obj.bbox.b > v.y + v.bbox.t then
					touching[#touching+1] = v
				end
			end
		end
		
		obj.smash = function(now)
			obj.state = 0
			obj:move_anchor_point(obj.w/2,obj.h/2)
			local d, vx, vy, vz, gr
			
			if now then
				fx.smash(obj)
				--audio.play("ice-breaking")
				obj:free()
			else
				obj.vx, obj.vy, obj.vz, obj.vo = nrand(0.4), nrand(0.2)-0.2, nrand(0.8), 0
				obj:unparent()
				overlay.effects:add(obj)
			end
			for k,v in ipairs(touching) do
				if v.parent ~= overlay.effects then
					v.smash(false)
				end
			end
		end
		obj.free = function(self)
			if obj.parent == overlay.effects then
				fx.smash(obj)
				audio.play("ice-breaking")
			end
			self.freed = true
			self:unparent()
		end
	end
end

local make = {
	["splash.jpg"]		= f("splash.jpg"),
	["floor-btm"]		= f("floor-btm.png"),
	["ice-slice"]		= f("ice-slice.png"),
	["igloo-back"]		= f("igloo-back.png"),
	["bg-sun"]			= f("bg-sun.png"),
	["bg-slice-2"]		= f("bg-slice-2.png"),
	["tree-1"]			= f("tree-1.png"),
	["tree-2"]			= f("tree-2.png"),
	["tree-3"]			= f("tree-3.png"),
	["tree-4"]			= f("tree-4.png"),
	["tree-5"]			= f("tree-5.png"),
	["explode-16"]		= f("explode-16.png"),
	["explode-24"]		= f("explode-24.png"),
	["explode-32"]		= f("explode-32.png"),
	["explode-128"]		= f("explode-128.png"),
	["icechunk-1"]		= f("icechunk-1.png"),
	["icechunk-2"]		= f("icechunk-2.png"),
	["icechunk-3"]		= f("icechunk-3.png"),
	["icechunk-4"]		= f("icechunk-4.png"),
	["splash-1"]		= f("splash-1.png"),
	["splash-2"]		= f("splash-2.png"),
	["splash-3"]		= f("splash-3.png"),
	["snow-bank"]		= f("snow-bank.png"),
	["river-left"]		= f("river-left.png"),
	["river-right"]		= f("river-right.png"),
	["icicles.png"]		= f("icicles.png", 3),
	["cube-64.png"]		= f("cube-64.png", 3, cubedriver),
	["cube-128-4.png"]	= f("cube-128-4.png", 3, cubedriver),
	["cube-128.png"]	= f("cube-128.png", 3, cubedriver),
	["river-slice.png"]	= f("river-slice.png", 1,function (obj)
		obj.insert = function(self)
			local group = self.parent
			local x, y, w = group.ice.x, group.ice.y, group.ice.w
			obj.y = y
			group.ice.w = obj.x-34-x
			local img = Image{src = "river-left", position = {obj.x-34,y}}
			group:add(img)
			img:raise(group.ice)
			img = Image{src = "river-right", position = {obj.x+obj.w,y}}
			group:add(img)
			img:raise(group.ice)
			img = Image{src = "ice-slice", position = {obj.x+obj.w+42,y},w = w-(obj.x+obj.w+42-x)}
			group:add(img)
			img:raise(group.ice)
			group.ice = img
		end
		obj.collision = function()
			if (penguin.vx > 0 and penguin.x + penguin.w/2 < obj.bb.r) or
				(penguin.vx < 0 and penguin.x + penguin.w/2 > obj.bb.l) then
				penguin:sink()
			end
		end
	end),
	["beach-ball.png"]	= f("beach-ball.png", 2, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h/2)
		local amp = 25
		local y = obj.y
		local a, s, st = 0, 1, 0
		obj.z_rotation = {rand(360),0,0}
		
		local anim = Timeline{loop = true, duration = 1000,
			on_new_frame = function(self,ms,t)
				amp = amp/2^(self.delta/self.duration) + 0.02 + (nrand(0.2)+0.1)^2
				obj.y = y + math.cos(math.pi*2*t)*amp
				s = s^(1/(1+self.delta/300))
				st = st+math.pi*6*(self.delta/self.duration)
				obj.scale = {s^math.cos(st),s^-math.cos(st)}
			end}
			
		obj.insert = function()
			y = obj.y
			anim:start()
			anim:advance(rand(anim.duration))
		end
		
		obj.free = function(self)
			anim:stop()
			anim = nil
			self.freed = true
			self:unparent()
		end
		
		obj.collision = function()
			if penguin.y + penguin.h/2 > obj.y-64 then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				if anim.elapsed > anim.duration/2 then
					anim:advance(anim.duration-anim.elapsed)
				end
				a = math.atan2(obj.y-penguin.y-64,obj.x-penguin.x)
				a = -2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				penguin.jump(a)
				amp = amp - 10*a
				s = s - a/4
				st = 0
				anim:advance(math.asin((obj.y-y)/amp)*anim.duration)
				audio.play("ball")
			end
		end
	end),
	["seal-ball"]			= f("beach-ball.png", 2, function (obj)
		obj.anchor_point = {obj.w/2,obj.h/2}
		local fx, fy = obj.x, obj.y
		local ox, oy, oz, vx, vy, vz = fx, fy, 0, 0, -1.6, 0
		local a, s, st = 0, 1, 0
		
		local bouncing = Timeline{duration = -3*vy/gravity,
			on_new_frame = function(self,ms,t)
				obj.y = oy + vy*ms + gravity*ms*ms/3
				obj.z_rotation = {oz+vz*math.log10(ms/500+1),0,0}
				s = s^(1/(1+self.delta/250))
				st = st+math.pi*8*(self.delta/self.duration)
				obj.scale = {s^math.cos(st),s^-math.cos(st)}
			end,
			on_completed = function(self)
				vy = nrand(0.15)-0.9
				oz = obj.z_rotation[1]
				vz = nrand(500)
				s = s + 0.2
				st = 0
				self.duration = -3*vy/gravity
				self:start()
				obj.seal.switch(-vy)
				audio.play("ball")
			end}
		bouncing:start()
		bouncing:advance(bouncing.duration/2)
		
		local falling = Timeline{duration = 500,
			on_new_frame = function(self,ms,t)
				obj.x = ox + vx*ms
				obj.y = oy + vy*ms + gravity*ms*ms/3
				obj.z_rotation = {oz+vz*ms,0,0}
				obj.opacity = 255*(1-t)
				s = s^(1/(1+self.delta/300))
				st = st+math.pi*6*(self.delta/self.duration)
				obj.scale = {s^math.cos(st),s^-math.cos(st)}
			end,
			on_completed = function(self)
				obj.opacity = 255
				obj.z_rotation = {0,0,0}
				obj.x, obj.y = fx, fy-600
				ox, oy, oz, vx, vy, vz = fx, fy, 0, 0, -1.6, 0
				bouncing.duration = -3*vy/gravity
				bouncing:start()
				bouncing:advance(bouncing.duration/2)
			end}
		
		obj.fall = function(_vx,_vy,_vz)
			bouncing:stop()
			ox, oy, oz = fx, obj.y, obj.z_rotation[1]
			vx, vy, vz = _vx, _vy, _vz
			falling:start()
		end
		
		obj.collision = function()
			a = math.atan2(obj.y-penguin.y-64,obj.x-penguin.x)
			if penguin.y + penguin.h/2 > obj.y-64 then
				s = s + math.sqrt(penguin.vx^2 + penguin.vy^2)/2
				st = a
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = -2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				s = s - a/6
				st = 0
				penguin.jump(a)
				obj.fall(penguin.vx/2,math.max(vy,-a),-penguin.vx)
				audio.play("ball")
			end
		end
		
		obj.free = function(self)
			bouncing:stop()
			bouncing = nil
			falling:stop()
			falling = nil
			self.freed = true
			self:unparent()
		end
	end),
	["seal-up.png"]			= f("seal-up.png"),
	["seal-mid.png"]		= f("seal-mid.png"),
	["seal-down.png"]		= f("seal-down.png", 1, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h)
		local frames = {factory:find_child("seal-down.png\t"),
						factory:find_child("seal-mid.png\t"),
						factory:find_child("seal-up.png\t")}
		local frame = 1
		local s, st = 1, 0
		local oy
		
		obj.source = frames[1]
		
		local anim = Timeline{loop = true, duration = 2500,
			on_new_frame = function(self,ms,t)
				obj.y = oy + math.cos(math.pi*2*t)
				s = s^(1/(1+self.delta/150))
				st = st+math.pi*10*(self.delta/self.duration)
				obj.scale = {s^math.cos(st),s^-math.cos(st)}
			end}
		
		obj.insert = function(self)
			local ball = Image{src = "seal-ball", y = obj.y-obj.h-32,
				x = obj.x + (obj.y_rotation[1] == 180 and -30 or 30)}
			ball.seal = self
			self.parent:add(ball)
			oy = obj.y
			anim:start()
		end
		
		local timer = Timer{on_timer = function(self)
				frame = frame + 1
				if frame == 4 then
					frame = 5
				elseif frame == 6 then
					frame = 1
					self:stop()
				end
				obj.source = frames[(frame-1)%3+1]
			end}
		timer.interval = 40
		
		obj.switch = function()
			frame = 2
			obj.source = frames[2]
			timer:start()
		end
		
		obj.collision = function()
			if penguin.y + penguin.h/2 > obj.y-obj.h then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = math.atan2(obj.y-penguin.y-obj.h,obj.x-penguin.x)
				a = -1.2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				s = s + 0.5
				st = 0
				penguin.jump(a)
				audio.play("seal-2")
			end
		end
		
		obj.free = function(self)
			anim:stop()
			anim = nil
			timer:stop()
			time = nil
			self.freed = true
			self:unparent()
		end
	end),
	["sea-lion.png"]	= f("sea-lion.png", 1, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h)
		local s, st = 1, 0
		local oy
		local anim = Timeline{loop = true, duration = 2500,
			on_new_frame = function(self,ms,t)
				obj.y = oy + math.cos(math.pi*2*t)
				s = s^(1/(1+self.delta/150))
				st = st+math.pi*10*(self.delta/self.duration)
				obj.scale = {s^math.cos(st),s^-math.cos(st)}
			end}
		
		obj.insert = function(self)
			oy = obj.y
			anim:start()
		end
		
		obj.collision = function()
			if penguin.y + penguin.h/2 > obj.y then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = math.atan2(obj.y-penguin.y,obj.x-penguin.x)
				a = -1.6*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				s = s + 0.5
				st = 0
				penguin.jump(a)
				audio.play("seal-1")
			end
		end
		
		obj.free = function(self)
			anim:stop()
			anim = nil
			self.freed = true
			self:unparent()
		end
	end, {l = 20, t = 10, r = -20, b = 0}),
	["ice-bridge.png"]	= f("ice-bridge.png", 1, function (obj)
		obj.insert = function(self,top)
			if not top or self.x+self.w < 1920 then return end
			for k,v in pairs(self.parent.children) do
				if v.name and v.source.name == "ice-bridge.png\t" and
						v.x+v.w > 1920 and v.y == self.y+640 then
					self.parent.bridges[self.y-110] = v
					return
				end
			end
		end
		
		obj.collision = function()
			if penguin.bb.b - penguin.dy < obj.bb.t then
				penguin.land(obj.y-110,obj)
			else
				penguin.kill(obj)
			end
		end
	end),
	["snow-ledge.png"]	= f("snow-ledge.png", 1, function(obj)
		obj.insert = function(self,top)
			if not top or self.x+self.w < 1920 then return end
			for k,v in pairs(self.parent.children) do
				if v.name and v.source.name == "snow-ramp.png\t" and
						v.x+v.w >= 1920 and v.y == self.y+640-67 then
					self.parent.bridges[self.y-120] = v
					return
				end
			end
		end
		
		obj.collision = function()
			if penguin.bb.b - penguin.dy < obj.bb.t then
				penguin.land(obj.y-120,obj)
			else
				penguin.kill(obj)
			end
		end
	end,{l = 50, t = 0, r = 0, b = 0}),
	["snow-ramp.png"]	= f("snow-ramp.png", 1, function(obj)
		obj.flip = true
		obj.boost = true
		obj.collision = function()
			penguin.land(obj.y-53,obj)
		end
	end,{l = 180, t = 80, r = 200, b = 0}),
	["fish-blue.png"]   = f("fish-blue.png", 1, function(obj)
		obj.collision = function()
			local streak = Image{src = "streak", anchor_point = {0,65}, scale = {0.6,1}, opacity = 255}
			local group = Group{x = penguin.x+(row==2 and penguin.w or 0), y = penguin.y+penguin.h*3/5, 
				y_rotation = {row==2 and 180 or 0,0,0}, z_rotation = {row==2 and 10 or -10,0,0}}
			group.state = 0
			group:add(streak)
			overlay:add(group)
			streak:animate{scale = {1.5,1}, opacity = 0, duration = 400,
				mode = "EASE_OUT_QUAD", on_completed = function() streak:free() end}
			penguin:boost()
			obj:hide()
		end
	end, {l = 50, t =50, r = -50, b = -50}),
	["streak"]			= f("streak.png"),
	["armor-1"]			= f("armor-1.png"),
	["armor-2"]			= f("armor-2.png"),
	["armor-2.png"]		= f("armor-2.png", 1, function(obj)
		obj:move_anchor_point(-34,-43)
		local armor, a = 2, {}
		local b
		local anim = Timeline{duration = 1000, loop = true,
			on_new_frame = function(self,ms,t)
				a[2].position = penguin.position
				a[2].y_rotation = penguin.y_rotation
				if armor == 2 then
					a[1].position = penguin.position
					a[1].y_rotation = penguin.y_rotation
				end
			end}
		
		obj.insert = function(self,top)
			a[1] = Image{src = "armor-1", x = obj.x, y = obj.y, opacity = 0,
						 scale = {top and 1 or -1,1}, anchor_point = {12,17},
						 y_rotation = {top and 0 or 180,penguin.w/2,0}, z_rotation = {30,40,60}}
			a[2] = Image{src = "armor-2", x = obj.x, y = obj.y, opacity = 0,
						 scale = {top and 1 or -1,1}, anchor_point = {-34,-43},
						 y_rotation = {top and 0 or 180,penguin.w/2,0}, z_rotation = {0,0,0}}
			overlay.armor:add(a[2],a[1])
			obj.opacity = 1
		end
		
		obj.collision = function()
			anim:start()
			a[1].z_rotation = {0,0,0}
			a[2]:raise_to_top()
			penguin.armor = obj
			audio.play("armor-pickup")
			obj:free()
		end
		
		obj.drop = function()
			b = a[3-armor]
			b:move_anchor_point(b.w/2,b.h/2)
			b.y_rotation = {penguin.y_rotation[1],0,0}
			b.vx, b.vy, b.vz, b.vo = row == 2 and 0.1 or -0.1, -0.4, row == 2 and 0.3 or -0.3, -0.33
			b:unparent()
			overlay.effects:add(b)
			armor = armor-1
			if armor == 0 then
				a = nil
				anim:stop()
				anim = nil
				penguin.armor = nil
				obj:free()
			end
			audio.play("armor-drop")
		end
	end, {l = 24, t = 0, r = -24, b = 0}),
}

recycle = function(i,src)
	src = src:sub((src:find('/',10,true) or src:find('/',0,true) or 0)+1,-1)
	
	if src == cubes[1] then
		return make[cubes[rand(#cubes)]](i)
	end
	
	if make[src] then
		return make[src](i)
	end
end

Image = function(i)
	return recycle(i,i.src) or _Image(i)
end

Clone = function(i)
	while i.source.source do
		i.source = i.source.source
	end
	
	return recycle(i,i.source.src) or _Clone(i)
end