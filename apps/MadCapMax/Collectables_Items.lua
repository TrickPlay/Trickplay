local make_item

local g  = 10000
local vy = - 100

local item_type = {
    collectable = function(obj,pieces,initial_impact)
        
        return function()
            
            initial_impact()
            
            for i, p in ipairs(pieces) do
                
                local obj = Clone{
                    source = p,
                    x      = obj.x,
                    y      = obj.y,
                }
                
                layers.item:add(obj)
                
                local vx = math.random(-1,1)*15
                
                local start_x = obj.x
                local start_y = obj.y
                
                Animation_Loop:add_animation{
                    
                    duration = 2,
                    
                    on_step = function(s,p)
                        
                        obj:set{
                            x = start_x   +   vx * s,
                            y = start_y   +   vy * s   +   .5 * g * s * s,
                        }
                    end
                }
                
            end
            
        end
        
    end,
    
    knockdownable = function(obj,targ_y,initial_impact,floor_func)
        
        return function(_,vx)
            
            initial_impact()
            
            local start_x = obj.x
            local start_y = obj.y
            
            aaa, bbb = quadratic( .5 * g, vy, start_y - targ_y )
            
            Animation_Loop:add_animation{
                
                duration = aaa,
                
                on_step = function(s,p)
                    
                    obj:set{
                        x = start_x   +   vx * s,
                        y = start_y   +   vy * s   +   .5 * g * s * s,
                    }
                end,
                
                on_completed = floor_func
                
            }
            
        end
        
    end,
}

local rock_back_and_forth function(obj)
    
    return {
        loop = true,
        duration = 1,
        on_step = function(s,p)
            
            obj.z_rotation = {
                10 * math.sin(math.pi*2*p),
                0,
                0
            }
            
        end
    }
    
end

make_item = function(t)
    
    --Assertions
    if type(t.source) ~= "userdata" then
        
        error("must pass a UI Element for 'source'",2)
        
    end
    
    if type(t.item_type) ~= "string" then
        
        error("must pass a string for 'item_type'",2)
        
    end
    
    if item_type[t.item_type] == nil then
        
        error("invalid time_type: "..t.item_type,2)
        
    end
    
    if type(t.initial_impact) ~= "function" then
        
        error("'initial_impact' for item must be a function",2)
        
    end
    
    
    if t.type == "knockdownable" then
        
        if type(t.fall_type) ~= "string" then
            
            error("must pass a string for 'fall_type' if setting up a knockdownable item",2)
            
        elseif fall_type[t.targ_y] == nil then
            
            error("invalid target y for knockdownable item: "..t.fall_type,2)
            
        end
        
        t.source.initial_impact = item_type[t.item_type](t.source,t.targ_y,t.initial_impact,t.floor_func)
        
    else
        
        if type(t.pieces) ~= "table" then
            
            error("'pieces' for collectable item must be a table",2)
            
        end
        
        
        t.source.initial_impact = item_type[t.item_type](t.source,t.pieces,t.initial_impact)
        
        t.source.on_idle = rock_back_and_forth(t.source)
        
    end
    
    
    
    return t.source
    
end



return make_item