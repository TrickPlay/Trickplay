
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local check_groups = setmetatable( {}, { __mode = "v" } )
CheckBoxGroup_nil = function()
    check_groups = setmetatable( {}, { __mode = "v" } )
end
CheckBoxGroup = function(parameters)
    
    if type(parameters) == "string" then
    
        if check_groups[parameters] then
        
            return check_groups[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	--input is either nil or a table
	parameters = is_table_or_nil("CheckBoxGroup",parameters)
	
	
	local instance, name, on_selection_change
	local items = {}
    local  meta_setters = {
        items = function(v)
            
            
            for b,unsubscribe in ipairs(items) do
                b.group = nil
            end
            for _,b in ipairs(v) do
                b.group = instance
            end
				  
        end,
        selected = function(v)
            
            setting_selected =true
            for b,v in ipairs(v) do
                b.selected = v
            end
            setting_selected =false
            
        end,
        name = function(v)
            
            if name ~= nil then check_groups[name] = nil end
            
            name = check_name( check_groups, instance, v, "CheckBoxGroup" )
            
        end,
        on_selection_change = function(v)
            on_selection_change = v
            
        end,
    }
    local meta_getters = {
        items         = function() 
            local retval = {}
            for b,sel in pairs(items) do
                table.insert(retval,b)
            end
            return retval                      
        end,
        selected      = function() 
            local selected = {}
            for b,_ in pairs(items) do
                selected[b] = b.selected
            end
            return selected                      
        end,
        name          = function() return name                          end,
        type          = function() return "CheckBoxGroup"            end,
        on_selection_change =  function() return on_selection_change    end,
    }
    
    local removing = false
    
    instance = setmetatable({
        insert = function(self,tb)
            
            if type(tb) ~= "userdata" then
                
                error("CheckBoxGroup:insert() expected CheckBoxes."..
                    " Received "..type(tb) .." at index ",2)
                
            end
            
            if tb.group ~= self then
                tb.group = self
            elseif not items[tb] then
							  
                items[tb] = tb:subscribe_to("selected",function() 
                    if not setting_selected and on_selection_change then on_selection_change(instance) end
                end)
            end
            
            
        end,
        remove = function(self,tb)
            
            if type(tb) ~= "userdata" then
                
                error("CheckBoxGroup:remove() expected CheckBoxes."..
                    " Received "..type(tb) .." at index ",2)
                
            end
            
            if  items[tb] then
                items[tb]()
                items[tb] = nil
            end
        end,
        set = function(self,t)
            if type(t) ~= "table" then
                error("Expected table. Received "..type(t),2) 
            end
            
            for k,v in pairs(t) do   self[k] = v   end
        end,
    },
    {
        __index = function(t,k,v)
            
            return meta_getters[k] and meta_getters[k]()
            
        end,
        __newindex = function(t,k,v)
            
            return meta_setters[k] and meta_setters[k](v)
            
        end,
    })
	  
    --[[
    instance.name  = parameters.name
    if parameters.items then instance.items = parameters.items end
    --]]
    instance:set(parameters)
    
    return instance
    
end
CheckBox = setmetatable(
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
            widget_type = function(instance,_ENV)
                return function() return "CheckBox" end
            end,
            attributes = function(instance,_ENV)
                return function(oldf,self)
                    local t = oldf(self)
                    
                    t.group    = instance.group and instance.group.name
                    
                    t.type = "CheckBox"
                    
                    return t
                end
            end,
            group = function(instance,_ENV)
                return function() return group end,
                function(oldf,self,v)
                    
                    if group then
                        if group == v or group.name == v then
                            
                            return
                            
                        else
                            
                            group:remove(self)
                            
                        end
                    end
                    
                    
                    if v == nil or v == false then
                        
                        group = nil
                        
                        return
                        
                    elseif type(v) == "string" then
                        
                        group = CheckBoxGroup(v)
                        
                    elseif type(v) == "table" and v.type == "CheckBoxGroup" then
                        
                        group = v
                        
                    else
                        
                        error("CheckBox.group must receive string or CheckBoxGroup. Received "..type(v),2)
                        
                    end
                    
                    group:insert(self)
                    
                end
            end,
            selected = function(instance,_ENV)
                return nil, function(oldf,self,v)
                    
                    if v ~= selected then
                        oldf(self,v)
                    end
                    if not group then
                        tb_set_selected(self,v)
                    elseif     v and not selected then
                        for i, b in ipairs(group.items) do
                            if b == instance then group.selected = i end
                        end
                    elseif not v and     selected then
                        group.selected = nil
                    end
                    
                end 
            end,
        },
        
        functions = {
        }
    },
    private = {
        default_empty_icon = function(instance,_ENV)
            return function()
                return Clone{source=instance.style.empty_toggle_icon.default}
            end
        end,
        default_filled_icon = function(instance,_ENV)
            return function()
                return Clone{source=instance.style.filled_toggle_icon.default}
            end
        end,
    },
    declare = function(self,parameters)
        local instance, _ENV = ToggleButton:declare()
        
        tb_set_selected = getmetatable(instance).__setters__.selected
        group = false
        setup_object(self,instance,_ENV)
        
        return instance, _ENV
        
    end
})


external.CheckBox      = CheckBox
external.CheckBoxGroup = CheckBoxGroup