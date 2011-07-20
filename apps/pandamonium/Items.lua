local old_coins = {}

local coin, t, start_x

--the coin spins from -90 to 90, and then repeats
local radians = Interval(-math.pi/2,math.pi/2)

local function new_coin()
	local coin  = Group{name="Coin"}
	coin.state = Enum{"RECYCLED","SPINNING","SPARKLING"}
	local front = Clone{ source = assets.coin_front }
	local back  = Clone{ source = assets.coin_back  }
	local side  = Clone{ source = assets.coin_side  }
	
	coin:add(side,back,front)
	
	coin:foreach_child(
		function(c)
			c.anchor_point = {      c.w/2,    c.h/2}
			c.position     = {front.w/2+3,front.h/2}
		end
	)
	
	start_x = front.w/2+3
	
	coin.size = {
		front.w+6,
		front.h
	}

	coin.tl = {--Timeline{
		duration = 4,
		loop     = true,
		on_step  = function(_,p)
		--on_new_frame = function(self,msecs,p)
			--print(_,p)
			--t goes from -90 to 90
			t = radians:get_value(p)
			
			--the front moves from right to left
			front.x = start_x-3*math.sin(t)
			--the back moves from left to right
			back.x  = start_x+3*math.sin(t)
			
			--the front and back scale at the same rate
			front.scale = {math.cos(t),1}
			back.scale  = {math.cos(t),1}
			
			--theres probably a better way to do this
			if p < .1 or p > .9 then
				if not side.is_visible then
					side:show()
				end
			elseif side.is_visible then
				side:hide()
			end
			
		end,
	}
	
	coin.fade = {
		duration = .4,
		on_step  = function(_,p)
			coin.opacity = 255*(1-p)
		end,
		on_completed = function()
			coin.state:change_state_to("RECYCLED")
		end
	}
	
	coin = physics:Body(
		coin,
		{
			type    = "static",
		    density = .1 ,
			sensor  = true,
		    filter  = items_filter,
		}
	)
	
	function coin:recycle()
		--[[
		if self.state:current_state() == "RECYCLED" then
			error("coin is already marked as recycled", 2)
		end
		
		table.insert(old_coins,self)
		
		Animation_Loop:delete_animation(self.tl)
		
		self.opacity = 1
		
		self:unparent()
		--]]
		self.state:change_state_to("RECYCLED")
		
	end
	
	
	coin.state:add_state_change_function(
		function(old,new)
			
			if old == new then  error("coin is already marked as recycled")  end
			
			table.insert(old_coins,coin)
			
			Animation_Loop:delete_animation(coin.tl)
			
			coin.opacity = 1
			--print(coin)
			coin:unparent()
			--print("b")
			firework.World:remove(coin)
		end,
		nil,"RECYCLED"
	)
	
	coin.state:add_state_change_function(
		function(old,new)
			
			if old ~= "RECYCLED" then
				error("coin started spinning from this state "..old)
			end
			
			layers.items:add(coin)
			
			coin.opacity = 255
			
			Animation_Loop:add_animation(coin.tl)
		end,
		nil,"SPINNING"
	)
	
	coin.state:add_state_change_function(
		function(old,new)
			
			hud:add_to_score(1)
			
			Effects:make_sparkles(coin.x,coin.y)
			
			Animation_Loop:add_animation(   coin.fade   )
			
		end,
		nil,"SPARKLING"
	)
	
	function coin:on_begin_contact(contact)
		
		contact.enabled = false
		
		if coin.state:current_state() == "SPINNING" then
			
			coin.state:change_state_to("SPARKLING")
			
		end
	end
	
	coin.on_pre_solve_contact = function(_,contact) contact.enabled = false end
	
	function coin:scroll_by(dy)
		
		self.y = self.y + dy
		--[[
		if self.y > screen_h+100 and not self.recycled then
			print("coin scrolled off")
			self.state:change_state_to("RECYCLED")
			
			return false
			
		else
			
			return true
			
		end
		--]]
	end
	
	function coin:fade_out(p)
		self.opacity = 255*(1-p)
	end
	---[[
	function coin:fade_out_complete(p)
		self.state:change_state_to("RECYCLED")
	end
	--]]
	function coin:fade_in_prep()
		assert(self.state:current_state() == "SPINNING")
		--print(self)
		self.opacity = 0
		self.tl:on_step(.5)
	end
	function coin:fade_in(p)
		self.opacity = 255*(p)
	end
	function coin:fade_in_complete()
		if self.state:current_state() ~= "SPINNING" then
			--print(self.state:current_state())
			--print(self.opacity)
		end
		Animation_Loop:set_progress(self.tl,.5)
	end	
	return coin
end


local function make_coin(_,x,y)
	
	coin = table.remove(old_coins) or new_coin()
	
	coin.position = { x, y }
	
	coin.state:change_state_to("SPINNING")
	
	return coin
end

local Coin_Formations = {}

Coin_Formations.single = make_coin

function Coin_Formations:plus(x,y)
	
	local coins = {}
	
	table.insert(coins, self:single( x,                                             y))
	table.insert(coins, self:single( x - assets.coin_front.w,                       y))
	table.insert(coins, self:single( x + assets.coin_front.w,                       y))
	table.insert(coins, self:single( x,                       y - assets.coin_front.h))
	table.insert(coins, self:single( x,                       y + assets.coin_front.h))
	
	return coins
end

function Coin_Formations:three_in_a_row(x,y)
	
	local coins = {}
	
	table.insert(coins, self:single( x,                       y))
	table.insert(coins, self:single( x, y - assets.coin_front.h))
	table.insert(coins, self:single( x, y + assets.coin_front.h))
	
	return coins
end








local firework = {}


local firework_real = physics:Body(
	Clone{
		name = "firework",
		source = assets.firework,
		--z_rotation = {180,0,0}
	},
	{
		type    = "kinematic",
		density = 4 ,
		fixed_rotation = true,
		shape  = physics:Box({assets.firework.w/2,assets.firework.h}),
		filter = panda_body_filter
	}
)
firework_real.linear_velocity = {0,-12}
function firework_real:scroll_by(dy)
	--print(self.y)
	self.y = self.y + dy
	--print(self.y.."\n")
end
function firework_real:recycle()
	
	self:unparent()
	firework.on_screen = false
	firework.World:remove(self)
end

local firework_sensor = physics:Body(
	Clone{
		name = "firework sensor",
		source = assets.firework,
	},
	{
		type    = "static",
		density = 4 ,
		fixed_rotation = true,
		sensor = true,
		shape  = physics:Box({assets.firework.w/2,assets.firework.h}),
		filter = items_filter
	}
)

function firework_sensor:scroll_by(dy)
	self.y = self.y + dy
	
end
function firework_sensor:recycle()
	
	self:unparent()
	firework.on_screen = false
	firework.World:remove(self)
end

function firework_sensor:fade_out(p)
	self.opacity = 255*(1-p)
end
function firework_sensor:fade_out_complete(p)
	self:recycle()
end
function firework_sensor:fade_in_prep()
	self.opacity = 0
end
function firework_sensor:fade_in(p)
	self.opacity = 255*(p)
end	

function firework_sensor:scroll_by(dy)
	self.y = self.y + dy
end

function firework_sensor.on_pre_solve_contact(c) c.enabled = false end


local p_hand = panda:get_hand()
local dy,dx
function firework_sensor:on_begin_contact(contact)
	
	contact.enabled = false
	
	if self.moving then
		--print("ignoring impact")
		return
	end 
	--print("impacto")
	self.moving = true
		
	dx = self.x - p_hand.x
	dy = self.y - p_hand.y - firework_real.h/4
	
	--print(dx,dy)
	Animation_Loop:add_animation(
		
		firework.snap_to_arm
		
	)
	
end

firework.on_screen = false
firework.boost_timer = Timer{
	interval=1300,
	on_timer = function(self)
		if firework.joint then
			panda.rocket = nil
			firework_real:remove_joint(firework.joint)
			firework.joint = nil
		else
			firework.smoke_timer:stop()
			self:stop()
			firework_real:recycle()
			
		end
		
	end
}
firework.boost_timer:stop()
firework.smoke_timer = Timer{
	interval = 100,
	on_timer = function(self)
		
		Effects:make_smoke(firework_real.x,firework_real.y+60,"firework")
		
	end
}
firework.smoke_timer:stop()
firework.snap_to_arm = {
	duration = .3,
	on_step = function(s,p)
		firework_sensor.x = p_hand.x + dx*(1-p)
		firework_sensor.y = p_hand.y + dy*(1-p)
	end,
	on_completed = function()
		firework_sensor.moving = false
		firework_sensor:recycle()
		firework_real.x = p_hand.x
		firework_real.y = p_hand.y -firework_real.h/4
		firework_real.opacity = 255
		layers.items:add(firework_real)
		
		firework.joint =
			firework_real:RevoluteJoint(
				--{ firework_real.x, firework_real.y+ firework_real.h/4-2 },
				p_hand ,
				{ p_hand.x, p_hand.y },
				{ enable_limit = false }
			)
		--print("firework joint",firework.joint)
		--firework_real:apply_force({0,-1000},{0,0})
		panda.rocket = firework_real
		--physics:stop()
		firework.boost_timer:start()
		panda:set_vel_to(firework_real.linear_velocity)
		firework.smoke_timer:start()
	end
}

function firework:add_to_screen(x,y)
	
	firework_sensor.opacity = 255
	
	if  firework_sensor.parent ~= nil or
		firework_real.parent   ~= nil then
		
		return nil
		
	end
	
	firework_sensor.x = x
	firework_sensor.y = y
	
	layers.items:add(firework_sensor)
	
	return firework_sensor
	
end


local old_firecrackers = {}

local function new_firecracker()
	
	local firecracker = physics:Body(
		Clone{
			name = "firecracker",
			source = assets.firecracker,
		},
		{
			type    = "static",
			fixed_rotation = true,
			sensor = true,
			shape  = physics:Box({assets.firework.w/2,assets.firework.h}),
			filter = items_filter
		}
	)
	
	function firecracker:recycle()
		firecracker:unparent()
	end
	function firecracker:fade_out(p)
		self.opacity = 255*(1-p)
	end
	function firecracker:fade_out_complete(p)
		self:recycle()
	end
	function firecracker:fade_in_prep()
		self.opacity = 0
	end
	function firecracker:fade_in(p)
		self.opacity = 255*(p)
	end	
	
	function firecracker:scroll_by(dy)
		self.y = self.y + dy
	end
	
	function firecracker:on_pre_solve_contact(c) c.enabled = false end
	
	firecracker.count = 0
	firecracker.explode = Timer{
		interval = 100,
		on_timer = function(self)
			
			firecracker.count = firecracker.count + 1
			
			for i = 1,2 do
				Effects:make_smoke(
					firecracker.x+math.random(-20,20),
					firecracker.y+math.random(-5,5),
					"firecracker"
				)
			end
			
			for i = 1,4 do
				Effects:make_spark(
					firecracker.x+math.random(-20,20),
					firecracker.y+math.random(-5,5),
					math.random(-3,3)*6,
					math.random(-5,5)*6
				)
			end
			
			if firecracker.count > 2 then
				self:stop()
			end
			self:stop()
		end,
	}
	firecracker.explode:stop()
	
	function firecracker:on_begin_contact(c)
		c.enabled = false
		if panda.get_vy() < 0 then return end
		
		local dx = panda:get_x() - self.x
		local dy = panda:get_y() - self.y
		local mag = math.sqrt(dx*dx+dy*dy)
		dx = dx/mag
		dy = dy/mag
		
		if math.abs(math.atan(dx/dy) )*180/math.pi < 15 then
			
			
			
		end
		
		--print("EXPLODE",dx,dy)
		panda:impulse(100*dx,30*dy)
		dolater(self.recycle,self)
		
		firecracker.count = 0
		firecracker.explode:start()
	end
	
	return firecracker
end



function make_firecracker(x,y)
	
	local firecracker = table.remove(old_firecrackers) or new_firecracker()
	
	firecracker:set{
		opacity = 255,
		x       = x,
		y       = y,
	}
	
	layers.items:add(firecracker)
	
	return firecracker
	
end


return Coin_Formations, firework