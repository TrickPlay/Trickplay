
RADIOBUTTONGROUP = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local radio_groups = setmetatable( {}, { __mode = "v" } )
RadioButtonGroup_nil = function()
	  radio_groups = setmetatable( {}, { __mode = "v" } )
end
RadioButtonGroup = function(parameters)
	
    if type(parameters) == "string" then
        
        if radio_groups[parameters] then
            
            return radio_groups[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	--input is either nil or a table
	parameters = is_table_or_nil("RadioButtonGroup",parameters)
	
	
	local selected, on_selection_change
	local instance, name
	local items = {}
	  
	  local  meta_setters = {
			items         = function(v)
				  if type(v) ~= "table" then
						
						error("RadioButtonGroup.items expected type 'table'. Received "..type(v),2)
						
				  end
				  for _,tb in pairs(v) do
						
						tb.group = instance -- relies on ToggleButton.group to insert itself
						
				  end
			end,
			selected = function(v)
				  print("RBG.set_selected")
				  if type(v) ~= "number" then
						
						error("RadioButtonGroup.selected expected type 'number'. Received "..type(v),2)
						
				  elseif v < 1 then
						
						error("RadioButtonGroup.selected expected positive number. Received "..v,2)
						
				  else--if v ~= selected then
						selected = v
						
                       for i,tb in ipairs(items) do
                            print("fff")
                           get_env(tb).tb_set_selected(tb,i == v)
                       end
						
				  end
				  
			end,
			name = function(v)
				  
				  if name ~= nil then radio_groups[name] = nil end
				  
				  name = check_name( radio_groups, instance, v, "RadioButtonGroup" )
				  
			end,
			on_selection_change = function(v)
				  on_selection_change = v
				  
			end,
	  }
	  local meta_getters = {
			items         = function() return recursive_overwrite({},items) end,
			selected      = function() return selected                      end,
			name          = function() return name                          end,
			type          = function() return "RadioButtonGroup"            end,
			on_selection_change =  function() return on_selection_change    end,
	  }
	  
	  local removing = false
	  
	  instance = setmetatable({
				insert = function(self,tb)
						
						if type(tb) ~= "userdata" then
							  
							  error("RadioButtonGroup:insert() expected ToggleButtons."..
									" Received "..type(tb) .." at index ",2)
							  
						end
						
						if tb.group ~= self then
							  tb.group = self
						else
							  table.insert(items, tb )
							  if tb.selected then
									
									self.selected = #items
									
							  end
						end
						
						
				end,
				remove = function(self,tb)
						
						if removing then return end
						
						removing = true
						
						if type(tb) ~= "userdata" then
							  
							  error("RadioButtonGroup:remove() expected ToggleButtons."..
									" Received "..type(tb) .." at index ",2)
							  
						end
						
						for i,v in pairs(items) do
							  
							  if v == tb then
									
									if tb.group == instance then tb.group = nil end
									
									table.remove(items,i)
									
									break
							  end
							  
						end
						
						selected = nil
						
						for i,v in pairs(items) do
							  
							  if tb.selected then
									
									selected = i
									
									break
							  end
							  
						end
						
						removing = false
						
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
			}
	  )
	  
	  --[[
	  instance.name  = parameters.name
	  if parameters.items then instance.items = parameters.items end
	  --]]
      instance:set(parameters)
      
	  return instance
	  
end

RadioButton = setmetatable(
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
                return function() return "RadioButton" end
            end,
            attributes = function(instance,_ENV)
                return function(oldf,self)
                    local t = oldf(self)
                    
                    t.group    = instance.group and instance.group.name
                    
                    t.type = "RadioButton"
                    
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
                    
                    
                    if v == nil then
                        
                        group = nil
                        
                        return
                        
                    elseif type(v) == "string" then
                        
                        group = RadioButtonGroup(v)
                        
                    elseif type(v) == "table" and v.type == "RadioButtonGroup" then
                        
                        group = v
                        
                    else
                        
                        error("RadioButton.group must receive string or RadioButtonGroup. Received "..type(v),2)
                        
                    end
                    
                    group:insert(self)
                    
                    if selected then
                        
                        selected = false
                        self.selected = true
                        
                    end
                    
                end
            end,
            selected = function(instance,_ENV)
                return nil, function(oldf,self,v)
                    --if the Radio Button has no group
                    if not group then
                        tb_set_selected(self,v)
                    --if the Radio Button has a group, and it being set to selected
                    elseif     v and not selected then
                        for i, b in ipairs(group.items) do
                            if b == instance then 
                                group.selected = i 
                            end
                        end
                    --if the Radio Button has a group, and it being set to un-selected
                    elseif not v and     selected then
                        group.selected = nil
                    end
                    --if the Radio Button has a group, and it being set to the same state
                    
                end 
            end,
        },
        
        functions = {
        }
    },
    declare = function(self,parameters)
        local instance, _ENV = ToggleButton:declare()
        
        tb_set_selected = getmetatable(instance).__setters__.selected
        group = false
        setup_object(self,instance,_ENV)
        
        return instance, _ENV
        
    end
})

external.RadioButton      = RadioButton
external.RadioButtonGroup = RadioButtonGroup