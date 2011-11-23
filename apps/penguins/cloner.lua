_Image = Image
_Clone = Clone

local src = ""
local cubes = {"cube-128.png","cube-128-4.png"}
factory = Group()
factory:hide()
screen:add(factory)

local f = function(src,state,func)
	local orig = _Image{src = "assets/" .. src, name = src .. "\t"}
	factory:add(orig)
	
	prop = prop or {}
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
			ret.state = state or 0 -- 0 none 1 collides 2 moves 3 breaks
			ret.free = function(self)
				self.freed = true
				self:unparent()
			end
		end
		
		def.source = nil
		def.src = nil
		
		for k,v in pairs(def) do
			ret[k] = v
		end
		
		if func then
			func(ret)
		end
		
		ret.freed = false
		
		return ret
	end
end

local make = {
	["floor-btm"]			= f("floor-btm.png"),
	["ice-slice"]			= f("ice-slice.png"),
	["igloo-back"]			= f("igloo-back.png"),
	["bg-sun"]				= f("bg-sun.png"),
	["bg-slice-2"]			= f("bg-slice-2.png"),
	["tree-1"]				= f("tree-1.png"),
	["tree-2"]				= f("tree-2.png"),
	["tree-3"]				= f("tree-3.png"),
	["tree-4"]				= f("tree-4.png"),
	["tree-5"]				= f("tree-5.png"),
	["explode-16"]			= f("explode-16.png"),
	["explode-24"]			= f("explode-24.png"),
	["explode-32"]			= f("explode-32.png"),
	["explode-128"]			= f("explode-128.png"),
	["splash.jpg"]			= f("splash.jpg"),
	["river-left"]			= f("river-left.png"),
	["river-right"]			= f("river-right.png"),
	["icicles.png"]			= f("icicles.png", 3),
	["cube-64.png"]			= f("cube-64.png", 3),
	["cube-64-move.png"]	= f("cube-64.png", 2, function (obj)
		local dir = obj.x < 960 and 1 or -1
		obj.x = obj.x - 960*dir
		obj.vx, obj.vy = 0.8*dir, 0
		obj:animate{x = obj.x + 3000*dir, duration = 4000, loop = true}
	end),
	["cube-128-4.png"]		= f("cube-128-4.png", 3),
	["cube-128.png"]		= f("cube-128.png", 3),
	["cube-128-move.png"]	= f("cube-128.png", 2, function (obj)
		local dir = obj.x < 960 and 1 or -1
		obj.x = obj.x - 960*dir
		obj.vx, obj.vy = 0.8*dir, 0
		obj:animate{x = obj.x + 3000*dir, duration = 4000, loop = true}
	end),
	["river-slice.png"]		= f("river-slice.png", 1,function (obj)
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
		local amp = 25
		local y = obj.y
		local a
		obj.z_rotation = {rand(360),obj.w/2,obj.h/2}
		
		local anim = Timeline{loop = true, duration = 1000,
			on_new_frame = function(self,ms,t)
				amp = amp/2^(self.delta/self.duration) + 0.04
				obj.y = y + math.cos(math.pi*2*t)*amp
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
			if penguin.y + penguin.h/2 > obj.y then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				if anim.elapsed > anim.duration/2 then
					anim:advance(anim.duration-anim.elapsed)
				end
				a = math.atan2(obj.y-penguin.y,obj.x-penguin.x)
				a = -2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				penguin.jump(a)
				amp = amp - 10*a
				anim:advance(math.asin((obj.y-y)/amp)*anim.duration)
			end
		end
	end),
	["seal-ball"]			= f("beach-ball.png", 2, function (obj)
		local fx, fy, w2, h2 = obj.x, obj.y, obj.w/2, obj.h/2
		local ox, oy, oz, vx, vy, vz = fx, fy, 0, 0, -1.6, 0
		
		local bouncing = Timeline{duration = -3*vy/gravity,
			on_new_frame = function(self,ms,t)
				obj.y = oy + vy*ms + gravity*ms*ms/3
				obj.z_rotation = {oz+vz*math.log10(ms/500+1),w2,h2}
			end,
			on_completed = function(self)
				vy = nrand(0.15)-0.9
				oz = obj.z_rotation[1]
				vz = nrand(500)
				self.duration = -3*vy/gravity
				self:start()
				obj.seal.switch(-vy)
			end}
		bouncing:start()
		bouncing:advance(bouncing.duration/2)
		
		local falling = Timeline{duration = 500,
			on_new_frame = function(self,ms,t)
				obj.x = ox + vx*ms
				obj.y = oy + vy*ms + gravity*ms*ms/3
				obj.z_rotation = {oz+vz*ms,w2,h2}
				obj.opacity = 255*(1-t)
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
			if penguin.y + penguin.h/2 > obj.y then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = math.atan2(obj.y-penguin.y,obj.x-penguin.x)
				a = -2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				penguin.jump(a)
				obj.fall(penguin.vx/2,math.max(vy,-a),-penguin.vx)
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
		local frames = {factory:find_child("seal-down.png\t"),
						factory:find_child("seal-mid.png\t"),
						factory:find_child("seal-up.png\t")}
		local frame = 1
		local oy
		
		obj.source = frames[1]
		
		local anim = Timeline{loop = true, duration = 2500,
			on_new_frame = function(self,ms,t)
				obj.y = oy + math.cos(math.pi*2*t)
			end}
		
		obj.insert = function(self)
			local ball = Image{src = "seal-ball", x = obj.x-64 +
				(obj.y_rotation[1] == 180 and -30 or 30), y = obj.y-96}
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
			if penguin.y + penguin.h/2 > obj.y then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = math.atan2(obj.y-penguin.y,obj.x-penguin.x)
				a = -1.2*math.max(penguin.vy,0.8)*math.sin(a + math.sin(4*a-math.pi)/4)
				penguin.jump(a)
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
	["ice-bridge.png"]	= f("ice-bridge.png", 1, function (obj)
		obj.collision = function()
			if penguin.bb.b - penguin.dy < obj.bb.t then
				penguin.land(obj.y-110,obj)
			else
				penguin.kill(obj)
			end
		end
	end),
	["snow-ramp.png"]	= f("snow-ramp.png", 0),
	["fish-blue.png"]   = f("fish-blue.png", 1, function (obj)
		obj.collision = function()
			penguin:boost()
			obj:hide()
		end
	end)
}

recycle = function(i,src)
	src = src:sub((src:find('/',10,true) or src:find('/',0,true) or 0)+1,-1)
	
	if src == cubes[1] then
		i.breakable = true
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