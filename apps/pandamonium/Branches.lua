--recylced branches
local old_branches = {}

local branch_properties = {
    density = .1 ,
    filter  = uncollidable_filter,
}

--the hardcoded locations of the relative palm locations within:
local branch_fixtures = {
	{ {926,144}, {1342,117} }, --branch-1.png
	{ {917,137}, {1316,108} }, --branch-2.png
	{ {509,167}, {1014,254} }, --branch-3.png
}

local angle_thresh = 7


----------------------------------------------------
--Revolute Joint Parameters
----------------------------------------------------
local joint_hinge = function(self)
	return {
			(self.orientation + 1)*screen_w/2,
			self.y
		}
end
local joint_properties = function(self,orientation)

	--print(orientation,-angle_thresh/2+orientation*angle_thresh/2,angle_thresh/2+orientation*angle_thresh/2)
	return {
			enable_limit     = true,
			lower_angle      = -angle_thresh/2+orientation*angle_thresh/2,
			upper_angle      =  angle_thresh/2+orientation*angle_thresh/2,
			enable_motor     = true,
			motor_speed      = -self.orientation*20,
			max_motor_torque = 100,
		}
end

----------------------------------------------------
--Function Upvals for the branch methods
----------------------------------------------------
local attach_branch_to_wall = function(branch,wall,orientation)
	
	--attach the branch to the wall
	branch.joint = branch:RevoluteJoint(
		wall,
		joint_hinge(branch),
		joint_properties(branch,orientation)
	)
	
	--for each palm
	for i,p in ipairs(branch.palms) do
		
		--position them according to the hard-coded positioning table
		if branch.orientation == -1 then
			p.x = branch.x +  branch_fixtures[branch.rand_i][i][1] - branch.w/2
			p.y = branch.y +  branch_fixtures[branch.rand_i][i][2] - branch.h/2
		else
			p.x = branch.x - (branch_fixtures[branch.rand_i][i][1] - branch.w/2)
			p.y = branch.y +  branch_fixtures[branch.rand_i][i][2] - branch.h/2
		end
		
		--attach the palm to the wall
		p.joint = p:RevoluteJoint(
			wall,
			joint_hinge(branch),
			joint_properties(branch,orientation)
		)
	end
end

local recycle_branch = function(branch)
	
	--remove the branch joint
	assert(branch.joint ~= nil and branch:remove_joint(branch.joint))
	
	--remove the palm joints and unparent them
	for i,p in ipairs(branch.palms) do
		
		assert(p.joint ~= nil and p:remove_joint(p.joint))
		
		p:unparent()
		
	end
	
	branch:unparent()
	branch.stub:unparent()
	--mark the branch as recycled
	table.insert(old_branches,branch)
	
end

local scroll_by = function(branch,dy)
	
	--move the branch down
	branch.y      = branch.y      + dy
	branch.stub.y = branch.stub.y + dy
	
	--move the palms down
	for _,p in pairs(branch.palms) do
		
		p.y = p.y + dy
		
	end
	
end

--ignore the collisions
local ignore_collision = function(_,contact) contact.enabled = false end


----------------------------------------------------
--Palm Object
----------------------------------------------------
local palm

local new_palm = function(branch)
	
	palm = physics:Body(
		Group{
			name = "palm",
			size = {100,40}
		},
		{
			density = .1 ,
			filter  = {category = CATEGORY_PLATFORM, mask = {CATEGORY_PANDA_FEET} },
		}
	)
	
	palm.on_pre_solve_contact = ignore_collision
		
	function palm:on_begin_contact(contact)
		
		if panda:bounce(contact) then
			
			branch:apply_angular_impulse(
				
				-12*branch.orientation
				
			)
			mediaplayer:play_sound("audio/bounce2.mp3")
		end
		
	end
	
	return palm
	
end


----------------------------------------------------
--Branch object
----------------------------------------------------
--reused upvals
local branch, rand_i

local new_branch = function()
	
	rand_i = math.random(1,#assets.branches)
	
	branch = physics:Body(
		
		Clone{
			name   = "Branch",
			source = assets.branches[rand_i]
		},
		
		branch_properties
	)
	
	branch.stub = physics:Body(
		
		Group{
			name = "Branch-Wall Hinge",
			size = { 10,10 }
		},
		
		{
			type = "static",
			filter = uncollidable_filter,
		}
	)
	
	--store its index for palm positioning later
	branch.rand_i = rand_i
	
	branch.palms = {}
	
	--create the branches palms
	for i,pos in ipairs(branch_fixtures[rand_i]) do
		branch.palms[i] = new_palm(branch)
	end
	
	--link object methods to function upvals (above)
	branch.attach_to            = attach_branch_to_wall
	
	branch.recycle              = recycle_branch
	
	branch.scroll_by            = scroll_by
	
	branch.on_pre_solve_contact = ignore_collision
	
	--branch.on_begin_contact = print
	--branch.on_end_contact = print
	
	return branch
end

--branch constructor/recycler/initializer
local branch_constructor = function(
		
		orientation,
		
		y_pos,
		
		dist_from_wall
		
	)
	
	--print(dist_from_wall)
	
	assert(orientation == 1 or orientation == -1)
	
	--grab an old branch or make a new one
	branch = table.remove(old_branches) or new_branch()
	
	--reset its angle, incase it continued to rotate after the joint was deleted
	branch.angle = orientation*angle_thresh
	
	--flip it around if necessary
	branch.y_rotation = {orientation*90+90,0,0}
	
	--place it at on the correct side of the sceen
	branch.x      = orientation*screen_w/2 + screen_w/2 -
		orientation * dist_from_wall --math.random(branch.w/5,2*branch.w/5)
	
	branch.stub.x = orientation*screen_w/2 + screen_w/2
	
	--position it at the proper y_offset from the top of the wall
	branch.y      = y_pos-branch.h/2
	branch.stub.y = y_pos
	
	--save its orientation
	branch.orientation = orientation
	
	--reset the angle of its palms and add them to screen
	for i,p in ipairs(branch.palms) do
		p.angle = 0
		layers.branches:add(p)
	end
	
	layers.branches:add(branch)
	layers.branches:add(branch.stub)
	
	--attach the branch to the wall
	branch:attach_to(branch.stub,orientation)	
	
	--stop the animation in case there was an existing animation on it
	branch:complete_animation()
	
	branch.opacity = 255
	
	branch:show()
	
	return branch
	
end

return branch_constructor
