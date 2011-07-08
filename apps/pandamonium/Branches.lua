local old_branches = {}

local branch_properties = {
    density = .1 ,
    filter  = { group = -1 },
	shape   = physics:Box( {1400,40}  )
}

local branch_fixtures = {
	{ {926,144}, {1342,117} },
	{ {917,137}, {1316,108} },
	{ {509,167}, {1014,254} },
}

local angle_thresh = 7

local branch, rand_i, palm

local new_palm = function()
	
	return physics:Body(
		Group{
			name = "palm",
			size = {100,40}
		},
		{
			density = .1 ,
			filter  = { group = -1 },
		}
	)
	
end
local new_branch = function()
	
	rand_i = math.random(1,#assets.branches)
	
	branch = physics:Body(
		Clone{
			source = assets.branches[rand_i]
		},
		branch_properties
	)
	
	branch.rand_i = rand_i
	
	branch.palms = {}
	
	for i,pos in ipairs(branch_fixtures[rand_i]) do
		branch.palms[i] = new_palm()
	end
	--branch:remove_all_fixtures()
	--[[
	branch:add_fixture{
		shape = physics:Box( {100,40} , {50,20} ),
		position = {10,10}
	}
	--]]
	function branch:attach_to(wall)
		
		self.joint = self:RevoluteJoint(
			wall, {self.orientation*screen_w/2 + screen_w/2,self.y},
			{
				enable_limit     = true,
				lower_angle      =   -angle_thresh,
				upper_angle      =    angle_thresh,
				enable_motor     = true,
				motor_speed      =  -self.orientation*20,
				max_motor_torque =  100,
			}
		)
		
		for i,p in ipairs(self.palms) do
			if self.orientation == -1 then
				p.x = self.x + branch_fixtures[self.rand_i][i][1] - self.w/2
				p.y = self.y + branch_fixtures[self.rand_i][i][2] - self.h/2
			else
				p.x = self.x - (branch_fixtures[self.rand_i][i][1] - self.w/2)
				p.y = self.y +  branch_fixtures[self.rand_i][i][2] - self.h/2
			end
			---[[
			p.joint = p:RevoluteJoint(
				wall, {self.orientation*screen_w/2 + screen_w/2,self.y},
				{
					enable_limit = true,
					lower_angle  = -angle_thresh,
					upper_angle  =  angle_thresh,
					enable_motor = true,
					motor_speed  =	-200*self.orientation,
					max_motor_torque = 100
				}
			)
			--]]
			function p:on_pre_solve_contact(contact)
				contact.enabled = false
			end
			local b = self
			function p:on_begin_contact(contact)
				
				if panda:bounce(contact) then
					
					b:apply_angular_impulse(-7*b.orientation)
					
				end
				
				return false
			end
		end
	end
	
	function branch:recycle()
		
		assert(self.joint ~= nil and self:remove_joint(self.joint))
		
		for i,p in ipairs(self.palms) do
			
			assert(p.joint ~= nil and p:remove_joint(p.joint))
			
			p:unparent()
			
		end
		
		self:unparent()
		
		table.insert(old_branches,self)
		
	end
	
	function branch:on_pre_solve_contact(contact)
		contact.enabled = false
	end
	
	return branch
end

-- -1 == left side
local branch_constructor = function(orientation,y_offset,wall)
	
	assert(orientation == 1 or orientation == -1)
	
	branch = table.remove(old_branches) or new_branch()
	
	branch.angle = orientation*angle_thresh
	
	branch.y_rotation = {orientation*90+90,0,0}
	
	branch.x = orientation*screen_w/2 + screen_w/2 - orientation * math.random(0,branch.w/2)
	
	branch.y = y_offset+wall.y-wall.h/2
	
	branch.orientation = orientation
	
	for i,p in ipairs(branch.palms) do
		p.angle = 0
		screen:add(p)
	end
	
	branch:attach_to(wall)
	
	screen:add(branch)
	
	return branch
	
end

return branch_constructor