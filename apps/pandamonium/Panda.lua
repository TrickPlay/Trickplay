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
}
local limb_properties = {
    density = 1 ,
    filter  = { group = -1 },
    sleeping_allowed = false -- the main character should never go to sleep
}

--the physics bodies
local body  = physics:Body( Clone{source = assets.torso}, torso_properties)
local head  = physics:Body( Clone{source = assets.head},  limb_properties)
local l_arm = physics:Body( Clone{source = assets.l_arm}, limb_properties)
local r_arm = physics:Body( Clone{source = assets.r_arm}, limb_properties)
local l_leg = physics:Body( Clone{source = assets.l_leg}, limb_properties)
local r_leg = physics:Body( Clone{source = assets.r_leg}, limb_properties)

--positioning of the physics bodies
body.position  = {screen.w/2,                           0}
r_leg.position = {body.x+body.w/2-30,        10+r_leg.h/2}
l_leg.position = {body.x-body.w/2+30,        10+l_leg.h/2}
r_arm.position = {body.x+body.w/2,     r_arm.h/2-body.h/3}
l_arm.position = {body.x-body.w/2,     r_arm.h/2-body.h/3}
head.position  = {body.position[1]-10,       -20-body.h/2}

--attaching all the physics bodies as Revolute (Hinge) Joints
r_leg:RevoluteJoint( body , { r_leg.x, 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
l_leg:RevoluteJoint( body, { l_leg.x , 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
r_arm:RevoluteJoint( body, { r_arm.x-r_arm.w/2, 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
l_arm:RevoluteJoint( body, { l_arm.x+ l_arm.w/2, 0 },
	{ enable_limit = true , lower_angle = -20, upper_angle = 20 }
)
head:RevoluteJoint( body, { head.position[1], head.position[2]+head.h/2 },
    { enable_limit = true, lower_angle = -10, upper_angle =  10 }
)

--The Bouncing function
do
	--The target upward velocity to be reached when bouncing back up
    local HOPPER_TARGET_VY      = -10
    
	--upval for y velocity
    local vy
	
	--upval for the mass of the whole panda
    local panda_mass = body.mass + l_leg.mass + r_leg.mass +
		l_arm.mass + r_arm.mass + head.mass
    
    panda.bounce = function( self , contact )
        --dumptable(contact)
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
			
            return true
        end
        
		return false
		
    end
    
    ----attach the callback to the hooks
    --l_leg.on_begin_contact = panda.bounce
    --r_leg.on_begin_contact = panda.bounce
end


screen:add(
	
	floor,
	l_leg,
	r_leg,
	l_arm,
	r_arm,
	head,
	body
)
--body:remove_joint(j)
--l_leg:unparent()
--l = l_leg

panda.keys = {
    [keys.Left] = function()
        body:apply_linear_impulse( { -5 , 0 } , body.position )
    end,
    [keys.Right] = function()
        body:apply_linear_impulse( {  5 , 0 } , body.position )
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
panda.on_key_down = function(_,k)
    if panda.keys[k] then panda.keys[k]() end
end

panda.get_y = function()
	return body.y
end
panda.get_vy = function()
	return body.linear_velocity[2]
end

panda.scroll_by = function(self,dy)
	body.y  = body.y  + dy
	l_leg.y = l_leg.y + dy
	r_leg.y = r_leg.y + dy
	l_arm.y = l_arm.y + dy
	r_arm.y = r_arm.y + dy
	head.y  = head.y  + dy
	
end

panda.raise_to_top = function()
	l_leg:raise_to_top()
	r_leg:raise_to_top()
	l_arm:raise_to_top()
	r_arm:raise_to_top()
	head:raise_to_top()
	body:raise_to_top()
end


return panda