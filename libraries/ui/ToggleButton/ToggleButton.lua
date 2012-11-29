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
            icon_x_offset = function(instance,_ENV)
                return function(oldf) return icon_x_offset end,
                function(oldf,self,v) 
                    icon_x_offset = v 
                    if empty_icon then
                        empty_icon.position = {icon_x_offset,instance.h/2+icon_y_offset}
                    end
                    if filled_icon then
                        filled_icon.position = {icon_x_offset,instance.h/2+icon_y_offset}
                    end
                end
            end,
            icon_y_offset = function(instance,_ENV)
                return function(oldf) return icon_y_offset end,
                function(oldf,self,v) 
                    icon_y_offset = v 
                    if empty_icon then
                        empty_icon.position = {icon_x_offset,instance.h/2+icon_y_offset}
                    end
                    if filled_icon then
                        filled_icon.position = {icon_x_offset,instance.h/2+icon_y_offset}
                    end
                end
            end,
            type = function(instance,_ENV)
                return function() return "TOGGLEBUTTON" end
            end,
            widget_type = function(instance,_ENV)
                return function() return "ToggleButton" end
            end,
            filled_icon = function(instance,_ENV)
                return function(oldf)
                    
                    return filled_icon
                    
                end,
                function(oldf,self,v)
                    
                    if filled_icon and filled_icon.parent then filled_icon:unparent() end
                    
                    new_filled_icon = true
                    filled_icon = v
                end
            end,
            empty_icon = function(instance,_ENV)
                return function(oldf)
                    
                    return empty_icon
                    
                end,
                function(oldf,self,v)
                    
                    if empty_icon and empty_icon.parent then empty_icon:unparent() end
                    new_empty_icon = true
                    empty_icon = v
                end
            end,
            hide_icon = function(instance,_ENV)
                return function(oldf)
                    
                    return hide_icon
                    
                end,
                function(oldf,self,v)
                    
                    if not v and hide_icon then 
                        if  empty_icon then add(instance, empty_icon) end
                        if filled_icon then add(instance,filled_icon) end
                    elseif v and not hide_icon then 
                        if  empty_icon and  empty_icon.parent then  empty_icon:unparent() end
                        if filled_icon and filled_icon.parent then filled_icon:unparent() end
                    end
                    hide_icon = v
                    
                end
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
                            if filled_icon then filled_icon:show() end
                            
                            if image_states.selection then image_states.selection.state = "ON"   end
                            
                            if on_selection then on_selection(self) end
                            
                        else
                            if filled_icon then filled_icon:hide() end
                            
                            if image_states.selection then image_states.selection.state = "OFF"  end
                            
                            if on_deselection then on_deselection(self) end
                            
                        end 
                        --]]
                    end 
            end,
        },
        
        functions = {
        }
    },
    private = {
            default_empty_icon = function(instance,_ENV)
                return function()
                    return Clone()--{source=instance.style.empty_toggle_icon.default}
                end
            end,
            default_filled_icon = function(instance,_ENV)
                return function()
                    return Clone()--{source=instance.style.filled_toggle_icon.default}
                end
            end,
            update = function(instance,_ENV)
                return function()
                    button_update()
                    --[[
                    if empty_icon_group.parent then
                        empty_icon_group:raise_to_top()
                    else
                        add(instance,empty_icon_group)
                    end
                    if filled_icon_group.parent then
                        filled_icon_group:raise_to_top()
                    else
                        add(instance,filled_icon_group)
                    end
                    --]]
                    if  new_empty_icon then
                        new_empty_icon = false
                        empty_icon = empty_icon or default_empty_icon()
                        
                        if empty_icon.parent then empty_icon:unparent() end
                        if not hide_icon then add(instance,empty_icon) end
                        empty_icon.anchor_point = {0,empty_icon.h/2}
                        empty_icon.position     = {icon_x_offset,instance.h/2+icon_y_offset}
                    elseif empty_icon and not hide_icon then
                        empty_icon:raise_to_top()
                    end
                    if  new_filled_icon then
                        new_filled_icon = false
                        print("filled_icon",instance.style.empty_toggle_icon.default)
                        filled_icon = filled_icon or default_filled_icon()
                        
                        if filled_icon.parent then filled_icon:unparent() end
                        if not hide_icon then add(instance,filled_icon) end
                        filled_icon[selected and"show"or"hide"](filled_icon)
                        filled_icon.anchor_point = {0,empty_icon.h/2}
                        filled_icon.position     = {icon_x_offset,instance.h/2+icon_y_offset}
                    elseif filled_icon and not hide_icon then
                        filled_icon:raise_to_top()
                    end
                    
                end
            end
    },
    declare = function(self,parameters)
        local instance, _ENV = Button:declare{
            on_pressed = function(self) 
                self.selected = not self.selected
            end
        }
        hide_icon = false
        new_empty_icon  = true
        new_filled_icon = true
        icon_x_offset = 0
        icon_y_offset = 0
        button_update = update
        --[[
        new_filled_icons = true
        filled_icons = false
        filled_icon_group = Widget_Group{name="filled_icon"}
        new_empty_icons = true
        empty_icons = false
        empty_icon_group = Widget_Group{name="empty_icon"}
        --]]
        radio_button_group = false
        on_deselection     = false
        on_selection       = false
        selected           = false
        --overwrite existing
        states             = {"default","focus","selection","activation"}
        --[[
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
        --]]
        for _,state in pairs(states) do
            if state ~= "default" then image_states[state] = {state = "OFF"} end
        end
        
        setup_object(self,instance,_ENV)
        
        return instance, _ENV
        
    end
})
external.ToggleButton = ToggleButton