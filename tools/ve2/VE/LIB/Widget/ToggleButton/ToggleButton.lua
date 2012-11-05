TOGGLEBUTTON = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

--[=[
local states = {"default","focus","selection","activation"}
--[[
local press = function(old_function,self)
    print("hfhfhf")
    self.selected = not self.selected
    
    old_function(self)
    
end
--]]
local create_canvas = function(self,state)
	print("ccc")
	local c = Canvas(self.w,self.h)
	
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
	c:stroke()
	
	--the X box
	c:rectangle(
		c.h/2-10,
		c.h/2-10,
		20,
		20
	)
	
	--the X
	if state == "selection" then
		
		c:move_to(c.h/2-10,c.h/2-10)
		c:line_to(c.h/2+10,c.h/2+10)
		
		c:move_to(c.h/2-10,c.h/2+10)
		c:line_to(c.h/2+10,c.h/2-10)
		
	end
	
	c:stroke(true)
	
	return c:Image()
	
end
--]=]
--------------------------------------------------------------------------------
-- Constructor - creates an instance of a toggle button
--------------------------------------------------------------------------------


ToggleButton = setmetatable(
    {},
    {
    __index = function(self,k)
        
        return getmetatable(self)[k]
        
    end,
    __call = function(self,p)
        
        return self:declare():set(p or {})
        
    end,
    
    public = {
        properties = {
            on_selection = function(instance,_ENV)
                return function(oldf) return on_selection end,
                function(oldf,self,v) on_selection = v end
            end,
            on_deselection = function(instance,_ENV)
                return function(oldf) return on_deselection end,
                function(oldf,self,v) on_deselection = v end
            end,
            type = function(instance,_ENV)
                return function() return "TOGGLEBUTTON" end
            end,
            widget_type = function(instance,_ENV)
                return function() return "ToggleButton" end
            end,
            attributes = function(instance,_ENV)
                return function(oldf,self)
                    local t = oldf(self)
                    
                    t.selected = instance.selected
                    
                    t.type = "ToggleButton"
                    
                    return t
                end
            end,
            selected = function(instance,_ENV)
                return function() return selected end,
                    function(oldf,self,v)
                        
                        if type(v) ~= "boolean" then
                            error("Widget.selected expected type 'boolean', received "..type(v),2)
                        end
                        
                        if selected == v then return end
                        
                        selected = v
                        ---[[
                        if selected then
                            
                            if image_states.selection then image_states.selection.state = "ON"   end
                            
                            if on_selection then on_selection() end
                            
                        else
                            
                            if image_states.selection then image_states.selection.state = "OFF"  end
                            
                            if on_deselection then on_deselection() end
                            
                        end 
                        --]]
                    end 
            end,
        },
        
        functions = {
        }
    },
    declare = function(self,parameters)
        local instance, _ENV = Button:declare{
            on_pressed = function(self) 
                self.selected = not self.selected
            end
        }
        
        radio_button_group = false
        on_deselection     = false
        on_selection       = false
        selected           = false
        --overwrite existing
        states             = {"default","focus","selection","activation"}
        create_canvas      = function(self,state)
            print("ccc")
            local c = Canvas(self.w,self.h)
            
            c.op = "SOURCE"
            
            c.line_width = self.style.border.width
            
            round_rectangle(c,self.style.border.corner_radius)
            
            c:set_source_color( self.style.fill_colors[state] or "0000aa" )
            
            c:fill(true)
            
            c:set_source_color( self.style.border.colors[state] or "ffffff" )
            
            c:stroke()
            
            --the X box
            c:rectangle(
                c.h/2-10,
                c.h/2-10,
                20,
                20
            )
            
            --the X
            if state == "selection" then
                
                c:move_to(c.h/2-10,c.h/2-10)
                c:line_to(c.h/2+10,c.h/2+10)
                
                c:move_to(c.h/2-10,c.h/2+10)
                c:line_to(c.h/2+10,c.h/2-10)
                
            end
            
            c:stroke(true)
            
            return c:Image()
            
        end
        
        for _,state in pairs(states) do
            if state ~= "default" then image_states[state] = {state = "OFF"} end
        end
        
        setup_object(self,instance,_ENV)
        
        return instance, _ENV
        
    end
})
external.ToggleButton = ToggleButton