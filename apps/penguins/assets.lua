_Image = Image
_Clone = Clone

local src = ""
local cubes = {"cube-128.png","cube-128-4.png"}
local index = {}
local a
factory = Group()
factory:hide()
screen:add(factory)

local f = function(src,state,func,bbox)
	local orig = _Image{src = "assets/" .. src, name = src .. "\t"}
	index[src] = orig
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
				if self.unload then
					self.unload()
				end
				step[self] = nil
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

local cubedriver = function (obj)
	local switch = obj.name:match("s_(%w+)-?(%w+)")
	local move = obj.clip
	obj.clip = {0,0,obj.source.w,obj.source.h}
	if move and (move[1] ~= 0 or move[2] ~= 0) then
		obj.state = 2
		if switch then
			local anim
			obj.insert = function(self,top)
				for v in obj.name:gmatch("s_(%w+)") do
					v = levels.this:find_child((top and "" or "_") .. v)
					v.moves[#v.moves+1] = obj
				end
				anim = AnimationState{duration = move[3], mode = "EASE_IN_OUT_QUAD", transitions = {
					{source = "*", target = 0, keys = {{obj,"x",obj.x},{obj,"y",obj.y}}},
					{source = "*", target = 1, keys = {{obj,"x",obj.x+move[1]*10},{obj,"y",obj.y+move[2]*10}}}
				}}
				anim:warp(0)
			end
			obj.move = function()
				anim.state = 1-tonumber(anim.state)
			end
			obj.reset = function()
				if anim then
					anim.state = 0
				end
			end
			obj.unload = function()
				anim = nil
			end
		else
			obj.vx, obj.vy = move[1], move[2]
			local ox = (obj.vx > 0 and -128 or 1921)
			
			step[obj] = function(d,ms)
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
					obj.x = obj.x + obj.vx*d
				end
			end
		end
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
		
		obj.unload = function(self)
			if obj.parent == overlay.effects then
				fx.smash(obj)
				audio.play("ice-breaking")
			end
		end
	end
end

local rubberize = function(obj,s,st,d,spring,damp)
	s = s^(1/(1+d/damp))
	st = st+pi*spring*(d/1000)
	obj.scale = {s^cos(st),s^-cos(st)}
	return s, st
end

local make = {
	["splash.png"]		= f("splash.png", 0, function(obj)
		obj:hide()
		local z, zwire = Image{src = "logo-z", y = 800}, Image{src = "logo-z-wire", y = 600, h = 200}
		local p, pwire = Image{src = "logo-p", y = 700}, Image{src = "logo-p-wire", y = 600, h = 100}
		local zg, pg = Group{scale = {2,2}, anchor_point = {256,0}, x = 940, y = -2420},
					   Group{scale = {2,2}, anchor_point = {188,0}, x = 960, y = -2400}
		local za, zt, pa, pt = 0, 0, 0, 0
		zg:add(z,zwire)
		pg:add(p,pwire)
		
		step[zg] = function(d,ms)
			zt = (zt+d/2000)%1
			if za > 0 then
				zg.z_rotation = {sin(2*pi*zt)*za,0,0}
				zg.scale = {2,2-sin(2*pi*zt)*za/150}
				za = za/2^(d/1000)+rand(3)/2000
			end
		end
		step[pg] = function(d,ms)
			pt = (pt+d/2000)%1
			if pa > 0 then
				pg.z_rotation = {-sin(2*pi*pt)*pa,0,0}
				pg.scale = {2,2+sin(2*pi*pt)*pa/150}
				pa = pa/2^(d/1000)+rand(3)/2000
			end
		end
		
		sign = function()
			audio.play("theme")
			zg:animate{y = -1420, duration = 1000, mode = "EASE_IN_QUAD", on_completed = function()
				zt, za = 0, 4
				zg:animate{y = -1450, duration = 200, mode = "EASE_OUT_QUAD", on_completed = function()
					zg:animate{y = -1420, duration = 200, mode = "EASE_IN_QUAD"}
				end}
			end}
			
			Timer{interval = 200, on_timer = function(self)
				pg:animate{y = -1400, duration = 1000, mode = "EASE_IN_QUAD", on_completed = function()
					pt, pa = 0, 4
					pg:animate{y = -1430, duration = 200, mode = "EASE_OUT_QUAD", on_completed = function()
						pg:animate{y = -1400, duration = 200, mode = "EASE_IN_QUAD"}
					end}
				end}
				self:stop()
			end}
		end
		
		local moving = Group()
		for i=20,30 do
			a = Image{src = "tree-" .. rand(5), position = {rand(20,2200),922}, opacity = 255}
			a.anchor_point = {a.w/2,a.h}
			a.scale = {(i-10)/rand(19,20)*(rand(2)==1 and 1 or -1),(i-10)/rand(19,20)}
			a.vx = -i/200
			a.nx = nrand(0.02)
			moving:add(a)
		end
		
		step[moving] = function(d,ms)
			for k,v in ipairs(moving.children) do
				v.x = v.x + (v.vx+v.nx)*d
				if v.x+v.w < 0 then
					v.x = 2000+rand(400)
					v.nx = nrand(0.02)
				end
			end
		end
		
		local peng = Image{ src = "penguin", position = {-500,820}}
		local bubble
		
		obj.insert = function()
			local par = obj.parent
			t = 0
			par:add(Image{src = "bg-slice-2", y = 0, size = {1920,1080}, tile = {true,false}})
			par:add(Image{src = "bg-sun", position = {200,100}})
			par:add(moving)
			par:add(Image{src = "ice-slice", position = {0,916}, size = {1920,55}, tile = {true,false}})
			par:add(Image{src = "floor-btm", position = {0,971}},
				  Image{src = "floor-btm", position = {1920,971}, scale = {-1,1}})
			par:add(peng)
			par:add(zg,pg)
			if levels.cycle then
				audio.play("applause")
				peng.x = 760
				bubble = Group{x = 500, y = 40}
				bubble:add(Image{src = "thought-bubble", scale = {2,2}},
						Text{x = 50, y = 70, w = 800, alignment = "CENTER", font = "Sigmar 80px", text = "You Killed Me"},
						Text{x = 150, y = 110, w = 600, alignment = "CENTER", font = "Sigmar 200px", text = penguin.deaths},
						Text{x = 150, y = 350, w = 600, alignment = "CENTER", font = "Sigmar 80px",
							text = "Time" .. (penguin.deaths == 1 and "!" or "s!")})
				par:add(bubble)
				par.swap = function()
					bubble:animate{y = 80, opacity = 0, duration = 300}
					sign()
					par.swap = nil
				end
			else
				peng:animate{x = 1040, mode = "EASE_OUT_BACK", duration = 15000}
				sign()
			end
			par:add(Image{src = "start-sign", position = {1470,700}})
			par:add(Image{src = "snow-bank", position = {2200,940}, scale = {-1.4,1.05}})
		end
		
		obj.unload = function()
			z:free()
			zwire:free()
			zg:unparent()
			step[zg] = nil
			p:free()
			pwire:free()
			pg:unparent()
			step[pg] = nil
			step[moving] = nil
			moving:unparent()
			for k,v in ipairs(moving.children) do
				if v.free then
					v:free()
				end
			end
			moving = nil
			if bubble then
				bubble:unparent()
				for k,v in ipairs(bubble.children) do
					if v.free then
						v:free()
					else
						v:unparent()
					end
				end
				bubble = nil
			end
		end
	end),
	["start-sign"]		= f("start-sign.png"),
	["thought-bubble"]	= f("thought-bubble.png"),
	["penguin"]			= f("penguin.png"),
	["penguin-l"]		= f("penguin-lantern.png"),
	["logo-z"]			= f("logo-z.png"),
	["logo-z-wire"]		= f("logo-z-wire.png"),
	["logo-p"]			= f("logo-p.png"),
	["logo-p-wire"]		= f("logo-p-wire.png"),
	["floor-btm"]		= f("floor-btm.png"),
	["ice-slice"]		= f("ice-slice.png"),
	["igloo-back"]		= f("igloo-back.png"),
	["bg-sun"]			= f("bg-sun.png"),
	["bg-slice-2"]		= f("bg-slice-2.png"),
	["bg-slice-3"]		= f("bg-slice-3.png"),
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
	["switch-pole.png"]	= f("switch-pole.png", 1, function(obj)
		obj.moves = {}
		obj:move_anchor_point(obj.w/2,obj.h-15)
		local flag, snow, anim, timer, trow
		
		obj.insert = function(self,top)
			trow = top and 1 or 2
			flag = Image{src = "switch-red", x = obj.x, y = obj.y}
			flag.anchor_point = {flag.w-4,obj.h-15}
			flag.scale = {top and 1 or -1,1}
			local zr = top and 20 or -20
			anim = AnimationState{duration = 128, mode = "EASE_OUT_QUAD", transitions = {
				{source = "*", target = 1, keys = {{obj,"z_rotation",0}, {flag,"z_rotation",0}, {flag,"y_rotation",0}}},
				{source = "*", target = 0, keys = {{obj,"z_rotation",zr},{flag,"z_rotation",20},{flag,"y_rotation",180}}}
			}}
			timer = Timer{on_timer = function(self)
				flag.source = index['switch-green.png']
				self:stop()
			end}
			timer.interval = 64
			anim:warp(1)
			snow = Image{src = "switch-snow", x = obj.x, y = obj.y+15}
			snow.anchor_point = {snow.w/2,snow.h/2}
			obj.parent:add(flag,snow)
			flag:raise(obj)
		end
		obj.collision = function()
			for k,v in pairs(obj.moves) do
				v.move()
			end
			anim.state = 0
			obj.state = 0
			timer:start()
		end
		obj.reset = function(self,row)
			if row == trow and obj.state == 0 then
				anim.state = 1
				obj.state = 1
				flag.source = index['switch-red.png']
			end
		end
		obj.unload = function()
			flag.source = index['switch-red.png']
			anim = nil
		end
	end),
	["switch-red"]		= f("switch-red.png"),
	["switch-green"]	= f("switch-green.png"),
	["switch-snow"]		= f("switch-snow.png"),
	["icicles.png"]		= f("icicles.png", 1--[[, function (obj)
		obj.insert = function()
			obj:free()
		end
	end]]),
	["cube-64.png"]		= f("cube-64.png", 3, cubedriver),
	["cube-128-4.png"]	= f("cube-128-4.png", 3, cubedriver),
	["cube-128.png"]	= f("cube-128.png", 3, cubedriver),
	["river-slice.png"]	= f("river-slice.png", 1, function (obj)
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
	["river-slice-2"]	= f("river-slice-2.png"),
	["water-ring"]		= f("water-ring.png"),
	["beach-ball.png"]	= f("beach-ball.png", 1, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h/2)
		local amp = 25
		local y = obj.y
		local a, r, s, st = 0, 0, 1, 0
		local t = 0
		local fade = Image{src = "river-slice-2", x = obj.x-obj.w*3/4, w = obj.w*1.5}
		local ring = Image{src = "water-ring", x = obj.x, w = 131*1.5, h = 35*1.5, anchor_point = {105,15}}
		obj.z_rotation = {rand(360),0,0}
		
		step[obj] = function(d,ms)
			amp = amp/2^(d/1000) + 0.02 + (nrand(0.2)+0.1)^2
			t = (t+d/1000)%1
			obj.y = y + cos(pi*2*t)*amp
			s, st = rubberize(obj,s,st,d,6,300)
			r = max(0,sqrt(1-(2*(obj.y-ring.y)/obj.h)^2))
			ring.scale = {r*obj.scale[1],r*obj.scale[2]}
		end
			
		obj.insert = function(self,top)
			y = obj.y
			t = rand()
			obj.parent:add(fade,ring)
			fade:raise(obj)
			ring:raise(fade)
			fade.y = 536 + (top and 0 or 640)
			ring.y = fade.y+25
		end
		
		obj.collision = function()
			if obj.x-96 > penguin.x+penguin.w/2 or penguin.x+penguin.w/2 > obj.x+96 then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				if t > 0.5 then
					t = 1-t
				end
				a = atan2(y-penguin.y-64,obj.x-penguin.x)
				a = -2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				penguin.jump(a)
				amp = amp - 10*a
				s = s - a/4
				st = 0
				t = asin((obj.y-y)/amp)/pi/2
				audio.play("ball")
			end
		end
	end),
	["seal-ball"]		= f("beach-ball.png", 2, function (obj)
		obj.anchor_point = {obj.w/2,obj.h/2}
		local ox, fy, oy, oz, vx, vy, vz = obj.x, obj.y, obj.y, 0, 0, -1.6, 0
		local a, s, st = 0, 1, 0
		local falling = false
		local dur = -3*vy/gravity
		local t = 0.5
		local high = true
		
		step[obj] = function(d,ms)
			t = min(t+d/dur,1)%1
			ms = t*dur
			
			if falling then
				obj.x = ox + vx*ms
				obj.opacity = 255*(1-t)
			end
			if t == 0 then
				if falling then
					falling = false
					oy, oz, vx, vy, vz = fy, 0, 0, -1.6, 0
					t = 0.5
				else
					obj.seal.switch()
					oz, vy, vz = obj.z_rotation[1], high and -0.95 or -0.75, nrand(500)
					high = not high
					s = s + 0.2
					st = 0
					t = 0.001
				end
				dur = -3*vy/gravity
				ms = t*dur
			end
			obj.y = oy + vy*ms + gravity*ms*ms/3
			s, st = rubberize(obj,s,st,d,falling and 6 or 8,falling and 300 or 250)
			obj.z_rotation = {oz+vz*(falling and ms or log10(ms/500+1)),0,0}
		end
		
		obj.fall = function(_vx,_vy,_vz)
			oy, oz = obj.y, obj.z_rotation[1]
			vx, vy, vz = _vx, _vy, _vz
			dur = 500
			falling = true
			t = 0.001
		end
		
		obj.collision = function()
			a = atan2(obj.y-penguin.y-64,obj.x-penguin.x)
			if penguin.y + penguin.h/2 > obj.y-64 then
				s = s + sqrt(penguin.vx^2 + penguin.vy^2)/2
				st = a
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = -2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				s = s - a/6
				st = 0
				penguin.jump(a)
				obj.fall(penguin.vx/2,max(vy,-a),-penguin.vx)
				audio.play("ball")
			end
		end
	end),
	["seal-up.png"]			= f("seal-up.png"),
	["seal-mid.png"]		= f("seal-mid.png"),
	["seal-down.png"]		= f("seal-down.png", 1, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h)
		local frames = {index["seal-mid.png"],
						index["seal-up.png"],
						index["seal-mid.png"],
						index["seal-down.png"]}
		local frame = 0
		local s, st = 1, 0
		local oy
		
		obj.source = frames[4]
		
		step[obj] = function(d,ms)
			obj.y = oy + cos(pi*2*ms/2500)
			s, st = rubberize(obj,s,st,d,10,150)
			if frame < 5 then
				obj.source = frames[math.floor(frame)]
				frame = frame+d/40
			end
		end
		
		obj.insert = function(self)
			local ball = Image{src = "seal-ball", y = obj.y-obj.h-32,
				x = obj.x + (obj.y_rotation[1] == 180 and -30 or 30)}
			ball.seal = self
			self.parent:add(ball)
			oy = obj.y
		end
		
		obj.switch = function()
			frame = 1
			audio.play("ball")
		end
		
		obj.collision = function()
			if penguin.y + penguin.h/2 > obj.y-obj.h then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = atan2(obj.y-penguin.y-obj.h,obj.x-penguin.x)
				a = -1.2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				s = s + 0.5
				st = 0
				penguin.jump(a)
				audio.play("seal-2")
			end
		end
	end),
	["sea-lion.png"]	= f("sea-lion.png", 1, function (obj)
		obj:move_anchor_point(obj.w/2,obj.h)
		local s, st = 1, 0
		local oy
		
		step[obj] = function(d,ms)
			obj.y = oy + cos(pi*2*ms/2500)
			s, st = rubberize(obj,s,st,d,10,150)
		end
		
		obj.insert = function(self)
			oy = obj.y
		end
		
		obj.collision = function()
			if penguin.y + penguin.h/2 > obj.y then
				penguin.kill(obj)
			elseif penguin.vy > 0 then
				a = atan2(obj.y-penguin.y,obj.x-penguin.x)
				a = -1.6*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				s = s + 0.5
				st = 0
				penguin.jump(a)
				audio.play("seal-1")
			end
		end
	end, {l = 20, t = 10, r = -20, b = 0}),
	["ice-bridge.png"]	= f("ice-bridge.png", 1, function (obj)
		local switch = obj.name:match("s_(%w+)")
		local move = obj.clip
		local anim
		obj.clip = {0,0,obj.w,obj.h}
		
		obj.insert = function(self,top)
			if switch and move and (move[1] ~= 0 or move[2] ~= 0) then
				obj.state = 2
				for v in obj.name:gmatch("s_(%w+)") do
					v = levels.this:find_child((top and "" or "_") .. v)
					v.moves[#v.moves+1] = obj
				end
				anim = AnimationState{duration = move[3], mode = "EASE_IN_OUT_QUAD", transitions = {
					{source = "*", target = 0, keys = {{obj,"x",obj.x},{obj,"y",obj.y}}},
					{source = "*", target = 1, keys = {{obj,"x",obj.x+move[1]*10},{obj,"y",obj.y+move[2]*10}}}
				}}
				anim:warp(0)
				obj.move = function()
					anim.state = 1-tonumber(anim.state)
				end
				obj.reset = function()
					if anim then
						anim.state = 0
					end
				end
				obj.unload = function()
					anim = nil
				end
			end
			
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
	end, {l = 0, t = 0, r = 0, b = -30}),
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
		obj.reset = function()
			obj:show()
		end
	end, {l = 50, t =50, r = -50, b = -50}),
	["streak"]			= f("streak.png"),
	["armor-1"]			= f("armor-1.png"),
	["armor-2"]			= f("armor-2.png"),
	["armor-2.png"]		= f("armor-2.png", 1, function(obj)
		obj:move_anchor_point(-34,-43)
		local armor, a = 2, {}
		local b
		
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
			step[obj] = function(d,ms)
				a[2].position = penguin.position
				a[2].y_rotation = penguin.y_rotation
				if armor == 2 then
					a[1].position = penguin.position
					a[1].y_rotation = penguin.y_rotation
				end
			end
			a[1].z_rotation = {0,0,0}
			a[2]:raise_to_top()
			penguin.armor = obj
			audio.play("armor-pickup")
			obj.y = -200
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
				step[obj] = nil
				penguin.armor = nil
				obj:free()
			end
			audio.play("armor-drop")
		end
	end, {l = 24, t = 0, r = -24, b = 0}),
	["monster.png"]			= f("monster.png", 2, function(obj)
		obj.scale = {1.3,1.3}
		
		obj.reset = function()
			obj.x = rand(900)
		end
	end, {l = 0, t = -40, r = -80, b = 0}),
}

pengsrcs = {index["penguin.png"],index["penguin-lantern.png"]}

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