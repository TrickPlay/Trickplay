--[[
	Panda Object
	
	This File defines the interface to the panda Class
--]]

--The Panda Object
local panda = {}

--Properties for the physics bodies
local torso_properties = {
    density  = 1 ,
    bounce   = 0,            -- bouncing is handled by the 'on_begin_contact' callback
    friction = 0 ,
    sleeping_allowed = false,-- the main character should never go to sleep
    fixed_rotation   = true, -- the panda doesn't rotate
	filter  = panda_body_filter,
	linear_damping = 1.5,
	--shape = physics:Box({100,assets.torso.h*3/2},{0,assets.torso.h/3})
}
local limb_properties = {
    density = 1 ,
    filter  = panda_body_filter,
    sleeping_allowed  = false -- the main character should never go to sleep
}

--the physics bodies
local body   = physics:Body( Clone{source = assets.torso }, torso_properties )
local head   = physics:Body( Clone{source = assets.head  }, limb_properties  )
local l_arm  = physics:Body( Clone{source = assets.l_arm }, limb_properties  )
local r_arm  = physics:Body( Clone{source = assets.r_arm }, limb_properties  )
local l_leg  = physics:Body( Clone{source = assets.l_leg }, limb_properties  )
local r_leg  = physics:Body( Clone{source = assets.r_leg }, limb_properties  )
local l_hand = physics:Body( Group{size   = { 10, 10 }   }, limb_properties  )
---[[
body:add_fixture(
	{
		shape = physics:Box({150,50},{0,assets.torso.h-55}),
		
		filter  = panda_hopper_surface_filter,
	}
)
--]]
layers.hopper:add(
	l_leg,
	r_leg,
	l_arm,
	r_arm,
	head,
	body,
	l_hand
)

--positioning of the physics bodies
panda.position = function(self,x,y)
	
	r_leg.angle  = 0
	l_leg.angle  = 0
	r_arm.angle  = 0
	l_arm.angle  = 0
	l_hand.angle = 0
	
	body.position   = {x,                                y}
	r_leg.position  = {x+body.w/2-30,       10+r_leg.h/2+y}
	l_leg.position  = {x-body.w/2+30,       10+l_leg.h/2+y}
	r_arm.position  = {x+body.w/2,    r_arm.h/2-body.h/3+y}
	l_arm.position  = {x-body.w/2,    l_arm.h/2-body.h/3+y}
	head.position   = {x-10,                -20-body.h/2+y}
	l_hand.position = {l_arm.x-l_arm.w/2,          l_arm.y+l_arm.h/2}
	
end

panda:position(screen.w/2,0)

--attaching all the physics bodies as Revolute (Hinge) Joints
r_leg:RevoluteJoint( body , { r_leg.x, 0 },
	{ enable_limit = true , lower_angle = -7, upper_angle = 20,
	enable_motor = true, motor_speed = -60, max_motor_torque = 200}
)
l_leg:RevoluteJoint( body , { l_leg.x , l_leg.y-l_leg.h/2 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 7,
	enable_motor = true, motor_speed = 60, max_motor_torque = 200 }
)
r_arm:RevoluteJoint( body , { r_arm.x-r_arm.w/2, 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
l_arm:RevoluteJoint( body , { l_arm.x+ l_arm.w/2, 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
l_hand:RevoluteJoint( l_arm , { l_hand.x, l_hand.y },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
head:RevoluteJoint(  body , { head.position[1], head.position[2]+head.h/2 },
    { enable_limit = true , lower_angle = -10, upper_angle = 10 }
)

--upval for the mass of the whole panda
    local panda_mass =
		body.mass  +
		l_leg.mass +
		r_leg.mass +
		l_arm.mass +
		r_arm.mass +
		head.mass

--The Bouncing function
do
	--The target upward velocity to be reached when bouncing back up
    local HOPPER_TARGET_VY = -10
    
	--upval for y velocity
    local vy
	
	
    
    panda.bounce = function( self , contact )
        
        vy = body.linear_velocity[ 2 ]
		
		--don't bounce if you were travelling upward
        if vy >= 0 then
            
            body:apply_linear_impulse(
				{
					0,
					--Impulse = mass * change_in_velocity
					panda_mass * ( HOPPER_TARGET_VY - vy )
				} ,
				
				body.position
			)
			r_leg:apply_angular_impulse(-5)
			l_leg:apply_angular_impulse( 5)
			
            return true
        end
        
		return false
		
    end
    
end

local max_vx = 5

function panda:set_vx(vx)
	
	if vx >  max_vx then vx =  max_vx end
	if vx < -max_vx then vx = -max_vx end
	
	body.linear_velocity = {vx,body.linear_velocity[2]}
	
end




max_imp = 1
function panda:imp_x_by(m,dir)
	
	
	--if 
	
	if body.linear_velocity[ 1 ] < -max_vx then
		body:apply_linear_impulse(
			{ panda_mass * (dir*max_vx-body.linear_velocity[ 1 ]) , 0 } ,
			body.position
		)
	else
		body:apply_linear_impulse(
			{ dir*m , 0 } ,
			body.position
		)
	end
end


local keys = {
    [keys.Left] = function(s)
        --print(s)
		
		--panda_mass * (-max_vx-body.linear_velocity[ 1 ])
		if body.linear_velocity[ 1 ] < -max_vx then
			body:apply_linear_impulse(
				{ panda_mass * (-max_vx-body.linear_velocity[ 1 ]) , 0 } ,
				body.position
			)
		else
			body:apply_linear_impulse(
				{ -2 , 0 } ,
				body.position
			)
		end
    end,
    [keys.Right] = function(s)
        if body.linear_velocity[ 1 ] > max_vx then
			body:apply_linear_impulse(
				{ panda_mass * (max_vx-body.linear_velocity[ 1 ]) , 0 } ,
				body.position
			)
		else
			body:apply_linear_impulse(
				{ 2 , 0 } ,
				body.position
			)
		end
    end,
	[keys.Down] = function()
        physics:draw_debug()
		physics:stop()
    end,
	[keys.Up] = function()
		physics:clear_debug()
        physics:start()
    end,
}

panda.on_key_down = function(_,k,_,s) if keys[k] then keys[k](s) end end
panda.get_x       = function()  return body.x  end
panda.get_y       = function()  return body.y  end
panda.get_vy      = function()  return body.linear_velocity[2]  end
panda.get_hand    = function()  return l_hand end

panda.scroll_by = function(self,dy)
	
	body.y   = body.y   + dy
	l_leg.y  = l_leg.y  + dy
	r_leg.y  = r_leg.y  + dy
	l_arm.y  = l_arm.y  + dy
	r_arm.y  = r_arm.y  + dy
	head.y   = head.y   + dy
	l_hand.y = l_hand.y + dy
	--[[
	if self.rocket then
		self.rocket:scroll_by(dy)
	end]]
end

GameState:add_state_change_function(
	function()
		
		panda:position(1500,700)
		
		layers.hopper.opacity = 0
		
		body.linear_velocity = {0,0}
		
		layers.hopper:animate{
			duration = 500,
			opacity  = 255,
			on_completed = function()
				screen.on_key_down = panda.on_key_down
				physics:start()
			end
		}
		
	end,
	
	nil, "GAME"
)



function panda:impulse(x,y)
	
	body:apply_linear_impulse({x,y},{body.x,body.y})
	
end

function panda:set_vel_to(t)
	
	body.linear_velocity   = t 
	l_leg.linear_velocity  = t 
	r_leg.linear_velocity  = t  
	l_arm.linear_velocity  = t 
	r_arm.linear_velocity  = t 
	head.linear_velocity   = t 
	l_hand.linear_velocity = t 
end
panda.handles = {
	[body.handle]   = true,
	[l_leg.handle]  = true,
	[r_leg.handle]  = true,
	[l_arm.handle]  = true,
	[r_arm.handle]  = true,
	[head.handle]   = true,
	[l_hand.handle] = true,
}

return panda