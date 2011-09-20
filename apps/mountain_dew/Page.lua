local bgs = {
	Image{src="assets/middle/1.png"},
	Image{src="assets/middle/2.png"},
	Image{src="assets/middle/3.png"},
	Image{src="assets/middle/4.png"},
	Image{src="assets/middle/5.png"},
	Image{src="assets/middle/6.png"},
	Image{src="assets/middle/7.png"},
	Image{src="assets/middle/8.png"},
}


--radii for the elliptical dosey doe
local r_x = screen_w/3
local r_z = 2*r_x
--how far out it rotates
local deg = 120

local rotate_in_l = function(self)
    self = self.parent
	self.x = -r_x*sin(deg*(1-self.mode.alpha))
	self.z =  r_z*cos(deg*(1-self.mode.alpha)) - r_z
end
local rotate_in_r = function(self)
	self = self.parent
    self.x =  r_x*sin(deg*(1-self.mode.alpha))
	self.z =  r_z*cos(deg*(1-self.mode.alpha)) - r_z
end

local rotate_out_l = function(self)
	self = self.parent
    self.x = -r_x*sin(deg*self.mode.alpha)
	self.z =  r_z*cos(deg*self.mode.alpha) - r_z
end
local rotate_out_r = function(self)
	self = self.parent
    self.x = r_x*sin(deg*self.mode.alpha)
	self.z = r_z*cos(deg*self.mode.alpha) - r_z
end


local bring_to_front = function(self)
    
    self.x=0
    
    self.z=0
    
    self.opacity=255
    
    --self:raise_to_top()
    
    --self.state:change_state_to("AT_FRONT")
    
    print("f", self)
    
end

local at_front = function(self)
    self = self.parent
    self.state:change_state_to("AT_FRONT")
    --GLOBAL_STATE:change_state_to("STOPPED")
end

local hidden = function(self)
    self.parent.state:change_state_to("HIDDEN")
end

--Constructor of Pages
return function(page_src)
    assert(type(page_src) == "string")
    
    local page = Image{src = page_src}
    
    page.anchor_point = {page.w/2,0}
    
    page.opacity = 0
    
    page.scale = {2*4/3,2*4/3}
    
    page.z = -2*r_z
    
    page.tl = Timeline{
        duration = TRANS_DUR
    }
    
    page.tl.parent = page
    
    page.mode = Alpha{
        mode     = "EASE_IN_OUT_SINE",
        timeline = page.tl
    }
    
    page.state = ENUM(
        {
            "HIDDEN",
            "ANIMATING_IN_FROM_LEFT",
            "ANIMATING_IN_FROM_RIGHT",
            "AT_FRONT",
            "ANIMATING_OUT_TO_LEFT",
            "ANIMATING_OUT_TO_RIGHT"
        }
    )
    --[[
    page.current_velocity = 0
    
    page.current_acceleration = 0
    
    page.stopping_distance = 0
    
    page.target_position = 0
    
    page.curr_deg = 0
    --]]
    
    page.bring_to_front = bring_to_front
    
    page.state:add_state_change_function(
        function(prev_state,new_state)
            if prev_state == "ANIMATING_IN_FROM_RIGHT" then
                --Idle_Loop:remove_function(rotate_in_r)
                page.tl:stop()
            elseif prev_state == "ANIMATING_IN_FROM_LEFT" then
                --Idle_Loop:remove_function(rotate_in_l)
                page.tl:stop()
            end
            --Idle_Loop:add_function(rotate_out_l,page,2000)
            page.tl.on_new_frame = rotate_out_l
            
            page.tl.on_completed = hidden
            
            page.tl:start()
        end,
        nil,
        "ANIMATING_OUT_TO_LEFT"
    )
    page.state:add_state_change_function(
        function(prev_state,new_state)
            if prev_state == "ANIMATING_IN_FROM_RIGHT" then
                --Idle_Loop:remove_function(rotate_in_r)
                page.tl:stop()
            elseif prev_state == "ANIMATING_IN_FROM_LEFT" then
                --Idle_Loop:remove_function(rotate_in_l)
                page.tl:stop()
            end
            --Idle_Loop:add_function(rotate_out_r,page,2000)
            page.tl.on_new_frame = rotate_out_r
            
            page.tl.on_completed = hidden
            
            page.tl:start()
        end,
        nil,
        "ANIMATING_OUT_TO_RIGHT"
    )
    
    page.state:add_state_change_function(
        function(prev_state,new_state)
            if prev_state == "ANIMATING_OUT_TO_RIGHT" then
                --Idle_Loop:remove_function(rotate_out_r)
                page.tl:stop()
            elseif prev_state == "ANIMATING_OUT_TO_LEFT" then
                --Idle_Loop:remove_function(rotate_out_l)
                page.tl:stop()
            end
            --Idle_Loop:add_function(rotate_in_l,page,2000)
            
            page.opacity = 255
            
            page.tl.on_new_frame = rotate_in_l
            
            page.tl.on_completed = at_front
            
            page.tl:start()
        end,
        nil,
        "ANIMATING_IN_FROM_LEFT"
    )
    page.state:add_state_change_function(
        function(prev_state,new_state)
            if prev_state == "ANIMATING_OUT_TO_RIGHT" then
                --Idle_Loop:remove_function(rotate_out_r)
                page.tl:stop()
            elseif prev_state == "ANIMATING_OUT_TO_LEFT" then
                --Idle_Loop:remove_function(rotate_out_l)
                page.tl:stop()
            end
            --Idle_Loop:add_function(rotate_in_r,page,2000)
            
            page.opacity = 255
            
            page.tl.on_new_frame = rotate_in_r
            
            page.tl.on_completed = at_front
            
            page.tl:start()
        end,
        nil,
        "ANIMATING_IN_FROM_RIGHT"
    )
    
    page.state:add_state_change_function(
        function(prev_state,new_state)
            
            page.opacity = 0
            
        end,
        nil,
        "HIDDEN"
    )
    
    return page
end