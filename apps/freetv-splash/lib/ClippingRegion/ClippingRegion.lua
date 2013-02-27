CLIPPINGREGION = true

local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000}

ClippingRegion = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ClippingRegion",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ClippingRegion Object inherits from Widget
	
	local instance = Widget( parameters )
    local bg       = Rectangle{ name="Background"}
    local border   = Rectangle{ name="Border",color = "00000000"}
    local contents = Group{ name="Contents"}--,w=instance.virtual_w,h=instance.virtual_h}
	
    instance:add(bg,contents,border)
    
    ----------------------------------------------------------------------------
    
    local x_offset = 0
    local y_offset = 0
    
	override_property(instance,"virtual_w",
		function(oldf) return contents.w   end,
		function(oldf,self,v) 
            
            contents.w = v < instance.w  and instance.w or v 
            
        end
	)
	override_property(instance,"virtual_h",
		function(oldf) return contents.h     end,
		function(oldf,self,v) 
            
            contents.h = v < instance.h  and instance.h or v 
            
        end
	)
	override_property(instance,"virtual_x",
		function(oldf) return -contents.x - x_offset     end,
		function(oldf,self,v)  
            
            contents.x = bound_to(-(contents.w - instance.w),x_offset - v,0)
            
        end    
	)
	override_property(instance,"virtual_y",
		function(oldf) return -contents.y - y_offset     end,
		function(oldf,self,v)  
            
            contents.y = bound_to(-(contents.h - instance.h),y_offset - v,0)
            
        end 
	)
	override_property(instance,"sets_x_to",
		function(oldf) return x_offset     end,
		function(oldf,self,v) x_offset = v end
	)
	override_property(instance,"sets_y_to",
		function(oldf) return y_offset     end,
		function(oldf,self,v) y_offset = v end
	)
    
	override_property(instance,"contents",
		function(oldf) 
            local t = {}
            
            for i,child in pairs(contents.children) do
                a = child.attributes
                if a then
                    table.insert(t,a)
                end
                
            end
            
            return t     
        end,
		function(oldf,self,v) 
            
            for i,obj in ipairs(v) do
                
                if type(obj) == "table" and obj.type then 
                    
                    v[i] = _G[obj.type](obj)
                    
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                
                    error("Must be a UIElement or nil. Received "..obj,2) 
                    
                end
                
            end
            
            contents:clear()
            
            contents:add(unpack(v)) 
        end
	)
    
	override_property(instance,"widget_type",
		function() return "ClippingRegion" end, nil
	)
	override_function(instance,"add",
		function(oldf,self,...) contents:add(...) end
	)
    
	----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.virtual_x = self.virtual_x
            t.virtual_y = self.virtual_y
            t.virtual_w = self.virtual_w
            t.virtual_h = self.virtual_h
            t.sets_x_to = self.sets_x_to
            t.sets_y_to = self.sets_y_to
            
            t.contents = self.contents
            
            t.type = "ClippingRegion"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
	
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			
			bg.size     = instance.size
			border.size = instance.size
            
            instance.virtual_w = instance.virtual_w
            instance.virtual_h = instance.virtual_h
            instance.virtual_x = instance.virtual_x
            instance.virtual_y = instance.virtual_y
            
            contents.clip = {
                instance.virtual_x,
                instance.virtual_y,
                instance.w,
                instance.h,
            }
            
            
		end
	)
    
	instance:subscribe_to(
		{"virtual_x","virtual_y"},
		function()
            contents.clip = {
                instance.virtual_x,
                instance.virtual_y,
                instance.w,
                instance.h,
            }
        end
    )
	----------------------------------------------------------------------------
	
    local set_border_width = function() border.border_width = instance.style.border.width          end
    local set_border_color = function() border.border_color = instance.style.border.colors.default end
    local set_bg_color     = function() bg.color            = instance.style.fill_colors.default   end
    
    
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, set_border_width )
        instance.style.border.colors:subscribe_to(      nil, set_border_color )
        instance.style.fill_colors:subscribe_to( nil, set_bg_color )
        
		set_border_width()
		set_border_color()
		set_bg_color()
        
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	instance:set(parameters)
    
    contents.clip = {
        instance.virtual_x,
        instance.virtual_y,
        instance.w,
        instance.h,
    }
	return instance
	
end