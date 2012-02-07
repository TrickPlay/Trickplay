_Image = Image
_Clone = Clone

local rubberize = function(self,delta,spring,damp)
	self.s = self.s^(1/(1+delta/damp))
	self.st = self.st+pi*spring*(delta/1000)
	self.scale = {self.s^cos(self.st),self.s^-cos(self.st)}
end

local a, ms
local noop = function() end

evInsert = Event()
objectSet = Set()

Object = Class {
	extends = Sprite,
	public = {
		row = 0,
		level = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask = BBox(self)
		self.mask.dirty = 1
		objectSet[self] = true
	end
}

PenguinGhost = Class {
	extends = Sprite,
	shared = {
		on_frame = function(self,delta)
			if self.row == row and (self.row == 1) == (self.x > penguin.x) and penguin.skating.is_playing then
				self.opacity = self.op * (1-min(70,math.abs(600-math.abs(self.x-penguin.x)))/70)
			else
				self.opacity = 0
			end
		end
	},
	public = {
		row = 0,
		op = 255
	},
	new = function(self,t)
		t = t or {}
		self.op = t.opacity or 255
		t.src = "penguin.png"
		table.merge(self,t)
		evFrame[self] = self.on_frame
	end
}

CubeGhost = Class {
	extends = Sprite,
	shared = {
		on_frame = function(self,delta)
			if row == 2 and self.x < penguin.x and penguin.skating.is_playing then
				self.opacity = math.max(0,200-4*math.abs(50-math.abs(self.x+700-penguin.x)))
			else
				self.opacity = 0
			end
		end
	},
	public = {
		row = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self:move_anchor_point(36,36)
		self.scale = {1.1,1.1}
		evFrame[self] = self.on_frame
	end
}

SwitchPole = Class {
	extends = Object,
	shared = {
		on_collision = function(self,other,layer)
			for k,v in pairs(self.moves) do
				v:move()
			end
			self.anim.state = 0
			self.state = 0
			self.timer:start()
			objectSet[self] = nil
		end,
		on_insert = function(self,group)
			self.flag.y = self.y
			self.flag.scale = {self.row == 1 and 1 or -1,1}
			
			self.anim = AnimationState{duration = 128, mode = "EASE_OUT_QUAD", transitions = {
				{source = "*", target = 1, keys = {{self,"z_rotation",0},
					{self.flag,"z_rotation",0}, {self.flag,"y_rotation",0}}},
				{source = "*", target = 0, keys = {{self,"z_rotation",self.row == 1 and 20 or -20},
					{self.flag,"z_rotation",20},{self.flag,"y_rotation",180}}}
			}}
			self.anim:warp(1)
			
			group:add(self.flag,Sprite{src = "switch-snow.png", x = self.x, y = self.y+30, anchor_point = {60,32}})
			self.flag:raise(self)
		end,
		on_reset = function(self)
			if row == self.row and not objectSet[self] then
				self.anim.state = 1
				self.state = 1
				self.flag.src = "switch-red.png"
				objectSet[self] = true
			end
		end
	},
	public = {
		moves = false,
		flag = false,
		timer = false,
		anim = false
	},
	new = function(self,t)
		table.merge(self,t)
		self:move_anchor_point(4.5,126)
		
		self.moves = table.weak()
		self.flag = Sprite{src = "switch-red.png", x = self.x, anchor_point = {56,126}}
		
		self.timer = Timer{on_timer = function(this)
			self.flag.src = "switch-green.png"
			this:stop()
		end,interval = 64}
		self.timer:stop()
		
		evInsert[self] = self.on_insert
		penguin.reset[self] = self.on_reset
	end
}

local noclip = {0,0,0}

IceCube = Class {
	extends = Object,
	shared = {
		on_insert = function(self,group)
			if self.mx ~= 0 or self.my ~= 0 then
				self.mask.dirty = 2
				if self.name:match("s_(%w+)-?(%w+)") then
					for v in self.name:gmatch("s_(%w+)") do
						v = group:find_child((self.row == 1 and "" or "_") .. v)
						v.moves[#v.moves+1] = self
					end
					self.anim = AnimationState{duration = self.mt, mode = "EASE_IN_OUT_QUAD", transitions = {
						{source = "*", target = 0, keys = {{self,"x",self.x},{self,"y",self.y}}},
						{source = "*", target = 1, keys = {{self,"x",self.x+self.mx*10},{self,"y",self.y+self.my*10}}}
					}}
					self.anim:warp(0)
				else
					self.vx, self.vy = self.mx, self.my
					self.ox = self.vx > 0 and -128 or 1921
					evFrame[self] = self.on_frame
				end
			else
				self.touching = table.weak()
				for k,v in pairs(group.children) do
					if v ~= self and IceCube:is(v) and BBox.intersects(self.mask,v.mask) then
						self.touching[#self.touching+1] = v
					end
				end
			end
			
		end,
		on_frame = function(self,delta)
			if self.x == self.mt or (self.x > self.mt) == (self.vx > 0) then
				if 20 < self.x and self.x < 1920 then
					if self.x == self.mt then
						fx.smash(self)
						audio.play("ice-breaking")
						self.x = self.ox
					else
						self.x = self.mt
					end
				else
					self.x = self.ox + self.x - self.mt
				end
			else
				self.x = self.x + self.vx*delta
			end
		end,
		on_reset = function(self)
			if row == self.row and self.anim then
				self.anim.state = 0
			end
		end,
		move = function(self)
			if self.anim then
				self.anim.state = 1-tonumber(self.anim.state)
			end
		end,
		smash = function(self,now)
			objectSet:drop(self)
			self:move_anchor_point(self.w/2,self.h/2)
			self:unparent()
			
			for k,v in ipairs(self.touching) do
				if v.parent and v.parent ~= overlay.effects then
					v:smash()
				end
			end
			
			if now then
				fx.smash(self)
				self:free()
			else
				self.vx, self.vy, self.vz, self.vo = nrand(0.4), nrand(0.2)-0.2, nrand(0.8), 0
				overlay.effects:add(self)
				Event(self,'free'):add(fx.smash)
			end
		end
	},
	public = {
		anim = false,
		touching = false,
		mx = 0,
		my = 0,
		mt = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self.mx, self.my, self.mt = unpack(self.clip or noclip)
		self.clip = self.source.clip
		self.mask.dirty = 1
		
		evInsert[self] = self.on_insert
		penguin.reset[self] = self.on_reset
	end
}

IceBridge = Class {
	extends = Object,
	shared = {
		on_collision = function(self,other,layer)
			if penguin.mask.y + penguin.mask.h - penguin.dy < self.mask.y then
				penguin.land(self.y-110,self)
			else
				penguin.kill(self)
			end
		end,
		on_insert = function(self,group)
			if self.name:match("s_(%w+)") and (self.mx ~= 0 or self.my ~= 0) then
				self.mask.dirty = 2
				for v in self.name:gmatch("s_(%w+)") do
					v = group:find_child((self.row == 1 and "" or "_") .. v)
					v.moves[#v.moves+1] = self
				end
				 self.anim = AnimationState{duration = self.mt, mode = "EASE_IN_OUT_QUAD", transitions = {
					{source = "*", target = 0, keys = {{self,"x",self.x},{self,"y",self.y}}},
					{source = "*", target = 1, keys = {{self,"x",self.x+self.mx*10},{self,"y",self.y+self.my*10}}}
				}}
				self.anim:warp(0)
			end
			
			if self.row ~= 1 or self.x+self.w < 1920 then return end
			
			for k,v in pairs(group.children) do
				if IceBridge:is(v) and v.x+v.w > 1920 and v.y == self.y+640 then
					group.bridges[self.y-110] = v
					return
				end
			end
		end,
		on_reset = function(self)
			if self.anim then
				self.anim.state = 0
			end
		end,
		move = function(self)
			if self.anim then
				self.anim.state = 1-tonumber(self.anim.state)
			end
		end,
	},
	public = {
		anim = false,
		mx = 0,
		my = 0,
		mt = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self.mx, self.my, self.mt = unpack(self.clip or noclip)
		self.clip = self.source.clip
		self.mask:set(nil,{0,0,0,-30})
		
		evInsert[self] = self.on_insert
		penguin.reset[self] = self.on_reset
	end
}

River = Class {
	extends = Object,
	shared = {
		on_collision = function(self,other,layer)
			if penguin.x + penguin.w/2 < self.mask.x + self.mask.w and penguin.x + penguin.w/2 > self.mask.x then
				penguin:sink()
			end
		end,
		on_insert = function(self,group)
			local x, y, w = group.ice.x, group.ice.y, group.ice.w
			self.y = y
			group.ice.w = self.x-34-x
			local img = Sprite{src = "river-left.png", position = {self.x-34,y}}
				group:add(img)
				img:raise(group.ice)
			img = Sprite{src = "river-right.png", position = {self.x+self.w,y}}
				group:add(img)
				img:raise(group.ice)
			img = Sprite{src = "ice-slice.png", position = {self.x+self.w+42,y},w = w-(self.x+self.w+42-x)}
				group:add(img)
				img:raise(group.ice)
				group.ice = img
		end
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask.dirty = 1
		evInsert[self] = self.on_insert
	end
}

BeachBall = Class {
	extends = Object,
	shared = {
		on_frame = function(self,delta)
			self.amp = self.amp/2^(delta/1000) + 0.02 + (nrand(0.2)+0.1)^2
			self.time = (self.time+delta/1000)%1
			self.y = self.oy + cos(pi*2*self.time)*self.amp
			rubberize(self,delta,6,300)
			a = max(0,sqrt(1-(2*(self.y-self.ring.y)/self.h)^2))
			self.ring.scale = {a*self.scale[1],a*self.scale[2]}
		end,
		on_collision = function(self,other,layer)
			if self.x-96 > penguin.x+penguin.w/2 or penguin.x+penguin.w/2 > self.x+96 then
				penguin.kill(self)
			elseif penguin.vy > 0 then
				if self.time > 0.5 then
					self.time = 1-self.time
				end
				
				a = atan2(self.oy-penguin.y-64,self.x-penguin.x)
				a = -2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				penguin.jump(a)
				self.amp = self.amp - 10*a
				self.s = self.s - a/4
				self.st = 0
				self.time = asin((self.y-self.oy)/self.amp)/pi/2
				audio.play("ball")
			end
		end,
		on_insert = function(self,group)
			self.oy = self.y
			group:add(self.ring,self.fade)
			self.fade.y = 536 + (self.row == 1 and 0 or 640)
			self.ring.y = self.fade.y + 25
			self.ring:raise(self)
			self.fade:raise(self)
		end
	},
	public = {
		fade = false,
		ring = false,
		amp = 0,
		time = 0,
		s = 1,
		st = 0,
		oy = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self:move_anchor_point(64,64)
		self.z_rotation = {rand(360),0,0}
		self.mask.dirty = 1
		
		self.fade = Sprite{src = "river-slice-2.png", x = self.x-self.w*3/4, w = self.w*1.5}
		self.ring = Sprite{src = "water-ring.png", x = self.x, w = 131*1.5, h = 35*1.5, anchor_point = {105,15}}
		self.time = rand()
		
		evFrame[self] = self.on_frame
		evInsert[self] = self.on_insert
	end
}

SealBall = Class {
	extends = Object,
	shared = {
		on_frame = function(self,delta)
			if self.off then return end
			
			self.time = min(self.time+delta/self.dur,1)%1
			ms = self.time*self.dur
			
			if self.state == 1 then
				self.x = self.ox + self.vx*ms
				self.opacity = 255*(1-self.time)
			else
				self.opacity = 255
			end
			
			if self.time == 0 then
				if self.state == 2 then
					self.state = 0
					self.oy, self.oz, self.vx, self.vy, self.vz = self.fy, 0, 0, -1.6, 0
					self.time = 0.5
					self.dur = -3*self.vy/gravity
				elseif self.state == 1 then
					self:on_reset()
				elseif self.state == 0 then
					self.seal:switch()
					self.oz, self.vz = self.z_rotation[1], nrand(500)
					if self.vspd then
						if not penguin.skating.is_playing or penguin.skating.elapsed < self.wait + 2.4/gravity then
							self.vy = self.wait + 2.4/gravity + (penguin.skating.is_playing and -penguin.skating.elapsed
								or penguin.falling.duration - penguin.falling.elapsed)
							self.vy = -self.vy/math.ceil(self.vy*gravity/3) * gravity/3
						else
							self.vy = -tonumber(self.vspd)/100
						end
					else
						self.vy = self.high and -0.95 or -0.75
						self.high = not self.high
					end
					
					self.s = self.s + 0.2
					self.st = 0
					self.time = 0.001
					self.dur = -3*self.vy/gravity
				end
				ms = self.time*self.dur
			end
			
			if self.state ~= 2 then
				self.y = self.oy + self.vy*ms + gravity*ms*ms/3
				rubberize(self,delta,self.state == 1 and 6 or 8,self.state == 1 and 300 or 250)
				self.z_rotation = {self.oz+self.vz*(self.state == 1 and ms or log10(ms/500+1)),0,0}
			end
		end,
		on_collision = function(self,other,layer)
			if row ~= self.row then return end
			a = atan2(self.y-penguin.y-64,self.x-penguin.x)
			if penguin.y + penguin.h/2 > self.y-64 then
				self.s = self.s + sqrt(penguin.vx^2 + penguin.vy^2)/2
				self.st = a
				penguin.kill(self)
			elseif penguin.vy > 0 then
				a = -2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				self.s = self.s - a/6
				self.st = 0
				penguin.jump(a)
				self:fall(penguin.vx/2,max(self.vy,-a),-penguin.vx)
				audio.play("ball")
			end
		end,
		on_reset = function(self)
			self.off = false
			self.x = self.ox
			if self.state == 1 then
				self.state = 2
				self.time = 0.001
				self.dur = self.wait
				self.y = self.fy - 800
			end
		end,
		init = function(self,v,w)
			self.vspd, self.wait = v or false, w or 1
			self.time = 0.001
			self.dur = self.wait
		end,
		fall = function(self,_vx,_vy,_vz)
			self.oy, self.oz = self.y, self.z_rotation[1]
			self.vx, self.vy, self.vz = _vx, _vy, _vz
			self.dur = 500
			self.state = 1
			self.time = 0.001
		end
	},
	public = {
		state = 1,
		amp = 0,
		time = 0,
		s = 1,
		st = 0,
		ox = 0,
		oy = 0,
		fy = 0,
		vx = 0,
		vy = -1.6,
		vz = 0,
		dur = 4.8*gravity,
		wait = 1,
		vspd = false,
		high = true,
		off = true,
		seal = false
	},
	new = function(self,t)
		t = t or {}
		t.src = "beach-ball.png"
		table.merge(self,t)
		self.anchor_point = {64,64}
		self.mask.dirty = 2
		
		self.ox = self.x
		self.fy = self.y
		self.oy = self.y
		self.y = self.fy - 800
		
		evFrame[self] = self.on_frame
		penguin.reset[self] = self.on_reset
		--Event(self,'free'):add(function() print(Class:echo(self)) end)
	end
}

Seal = Class {
	extends = Object,
	shared = {
		on_frame = function(self,delta,ms)
			rubberize(self,delta,10,150)
			self.y = self.oy + cos(pi*2*ms/2500)
			if self.frame < 5 then
				self.src = self.srcs[floor(self.frame)]
				self.frame = self.frame+delta/40
			end
		end,
		on_insert = function(self,group)
			local ball = SealBall{src = "seal-ball", x = self.x + 30 - self.y_rotation[1]/3, y = self.y-self.h-32}
			ball.seal = self
			ball.row = self.row
			group:add(ball)
			ball:init(self.name:match("v_(%d+)_(%d*)"))
			self.oy = self.y
		end,
		on_collision = function(self,other,layer)
			if penguin.y + penguin.h/2 > self.y-self.h then
				penguin.kill(self)
			elseif penguin.vy > 0 then
				a = atan2(self.y-penguin.y-self.h,self.x-penguin.x)
				a = -1.2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				self.s = self.s + 0.5
				self.st = 0
				penguin.jump(a)
				audio.play("seal-2")
			end
		end,
		switch = function(self)
			self.frame = 1
			audio.play("ball")
		end
	},
	public = {
		frame = 4,
		srcs = {"seal-mid.png","seal-up.png","seal-mid.png","seal-down.png"},
		s = 1,
		st = 0,
		oy = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self:move_anchor_point(self.w/2,self.h)
		self.mask.dirty = 1
		
		evFrame[self] = self.on_frame
		evInsert[self] = self.on_insert
	end
}

SealLion = Class {
	extends = Object,
	shared = {
		on_frame = function(self,delta,ms)
			rubberize(self,delta,10,150)
			self.y = self.oy + cos(pi*2*ms/2500)
		end,
		on_insert = function(self,group)
			self.oy = self.y
		end,
		on_collision = function(self,other,layer)
			if penguin.y + penguin.h/2 > self.y then
				penguin.kill(self)
			elseif penguin.vy > 0 then
				a = atan2(self.y-penguin.y-self.h,self.x-penguin.x)
				a = -1.2*max(penguin.vy,0.8)*sin(a + sin(4*a-pi)/4)
				self.s = self.s + 0.5
				self.st = 0
				penguin.jump(a)
				audio.play("seal-1")
			end
		end
	},
	public = {
		s = 1,
		st = 0,
		oy = 0
	},
	new = function(self,t)
		table.merge(self,t)
		self:move_anchor_point(self.w/2,self.h)
		self.mask:set(nil,{20,10,-20,0})
		
		evFrame[self] = self.on_frame
		evInsert[self] = self.on_insert
	end
}

SnowLedge = Class {
	extends = Object,
	shared = {
		on_insert = function(self,group)
			if self.row == 2 or self.x+self.w < 1920 then return end
			for k,v in pairs(group.children) do
				if SnowRamp:is(v) and
						v.x+v.w >= 1920 and v.y == self.y+640-67 then
					group.bridges[self.y-120] = v
					return
				end
			end
		end,
		on_collision = function(self,other,layer)
			if penguin.mask.y + penguin.mask.h - penguin.dy < self.mask.y then
				penguin.land(self.y-120,self)
			else
				penguin.kill(self)
			end
		end
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask:set(nil,{50,0,0,0})
		evInsert[self] = self.on_insert
	end
}

SnowRamp = Class {
	extends = Object,
	shared = {
		on_collision = function(self,other,layer)
			penguin.land(self.y-53,self)
		end,
		flip = true,
		boost = true
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask:set(nil,{180,80,200,0})
	end
}

BlueFish = Class {
	extends = Object,
	shared = {
		on_free = function(self)
			self.layer:free()
		end,
		on_reset = function(self)
			if row == self.row then
				self:show()
			end
		end,
		on_collision = function(self)
			self.layer:show()
			self.streak:set{scale = {0.6,1}, opacity = 255}
			self.streak:animate{scale = {1.5,1}, opacity = 0, duration = 400,
				mode = "EASE_OUT_QUAD", on_completed = function() self.layer:hide() end}
			self.layer:set{x = penguin.x+(self.row == 2 and penguin.w or 0), y = penguin.y+penguin.h*3/5,
				y_rotation = {self.row == 2 and 180 or 0,0,0}, z_rotation = {self.row == 2 and 10 or -10,0,0}}
			penguin:boost()
			self:hide()
		end
	},
	public = {
		streak = false,
		layer = false
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask:set(nil,{50,50,-50,-50})
		
		self.streak = Sprite{src = "streak.png", anchor_point = {0,65}}
		self.layer = Layer{name = "streak"}
		self.layer:add(self.streak)
		self.layer:hide()
		overlay:add(self.layer)
		
		penguin.reset[self] = self.on_reset
		Event(self,'free'):add(self.on_free)
	end
}

Armor = Class {
	extends = Object,
	shared = {
		on_frame = function(self)
			a = {x = penguin.x, y = penguin.y, y_rotation = penguin.y_rotation}
			for i=1,self.has do
				self.pieces[3-i]:set(a)
			end
		end,
		on_insert = function(self,group)
			a = {y = self.y, scale = {self.row == 1 and 1 or -1,1}, y_rotation = {self.row == 1 and 0 or 180,penguin.w/2,0}}
			self.pieces[1]:set(a)
			self.pieces[2]:set(a)
			self.pieces[1].level = self.level
			self.pieces[2].level = self.level
			overlay.armor:add(self.pieces[2],self.pieces[1])
			self.opacity = 1
		end,
		on_collision = function(self,other,layer)
			evFrame[self] = self.on_frame
			self.pieces[1].z_rotation = {0,0,0}
			self.pieces[2]:raise_to_top()
			penguin.armor = self
			audio.play("armor-pickup")
			self.y = -200
		end,
		drop = function(self)
			a = self.pieces[3-self.has]
			a:move_anchor_point(a.w/2,a.h/2)
			a.y_rotation = {penguin.y_rotation[1],0,0}
			a.vx, a.vy, a.vz, a.vo = self.row == 2 and 0.1 or -0.1, -0.4, self.row == 2 and 0.3 or -0.3, -0.33
			a:unparent()
			overlay.effects:add(a)
			self.has = self.has-1
			if self.has == 0 then
				self.pieces[2]:free()
				evFrame[self] = nil
				penguin.armor = nil
				self:free()
			end
			audio.play("armor-drop")
		end
	},
	public = {
		has = 2,
		pieces = false
	},
	new = function(self,t)
		table.merge(self,t)
		self.mask:set(nil,{24,0,-24,0})
		self:move_anchor_point(-34,-43)
		
		self.pieces = {Sprite{src = "armor-1.png", x = self.x, opacity = 0, anchor_point = {12,17}, z_rotation = {30,40,60}},
			Sprite{src = "armor-2.png", x = self.x, opacity = 0, anchor_point = {-34,-43}, z_rotation = {0,0,0}} }
		
		evInsert[self] = self.on_insert
	end
}

Monster = Class {
	extends = Object,
	shared = {
		on_reset = function(self)
			self.x = rand(900)
		end
	},
	new = function(self,t)
		table.merge(self,t)
		self.scale = {1.3,1.3}
		self.mask:set(nil,{0,40,-80,0})
		self.mask.dirty = 2
		penguin.reset[self] = self.on_reset
	end
}

local make = {
	["penguin-ghost.png"]	= PenguinGhost,
	["cube-64-glow.png"]	= CubeGhost,
	["switch-pole.png"]		= SwitchPole,
	["icicles.png"]			= Object,
	["cube-64.png"]			= IceCube,
	["cube-128.png"]		= IceCube,
	["ice-bridge.png"]		= IceBridge,
	["river-slice.png"]		= River,
	["beach-ball.png"]		= BeachBall,
	["seal-ball.png"]		= SealBall,
	["seal-down.png"]		= Seal,
	["sea-lion.png"]		= SealLion,
	["snow-ledge.png"]		= SnowLedge,
	["snow-ramp.png"]		= SnowRamp,
	["fish-blue.png"]		= BlueFish,
	["armor-2.png"]			= Armor,
	["monster.png"]			= Monster
}

local normalize = function(src)
	return src:sub((src:find('/',10,true) or src:find('/',0,true) or 0)+1,-1)
end

Image = function(t)
	t.src = normalize(t.src)
	return (make[t.src] or Sprite)(t)
end

Clone = function(t)
	while t.source.source do
		t.source = t.source.source
	end
	t.src = normalize(t.source.src)
	return (make[t.src] or _Clone)(t)
end