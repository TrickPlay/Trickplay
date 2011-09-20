local make_item

local g  = 4000
local vy = - 500

local item_type = {
    collectable = function(obj,pieces,initial_impact)
        
        return function()
            
            if obj.hit then return end
            
            initial_impact()
            
            Animation_Loop:delete_animation(obj.on_idle)
            
            obj:hide()
            
            obj.hit = true
            
            dumptable(pieces)
            
            for i, p in ipairs(pieces) do
                
                local piece = Clone{
                    source = p,
                    x      = obj.x-obj.anchor_point[1],
                    y      = obj.y-obj.anchor_point[2],
                }
                
                layers.items:add(piece)
                
                local vx = math.random(-1,1)*200
                
                local start_x = piece.x
                local start_y = piece.y
                
                
                Animation_Loop:add_animation{
                    
                    duration = 2,
                    
                    on_step = function(s,p)
                        piece:set{
                            x = start_x   +   vx * s,
                            y = start_y   +   vy * s   +   .5 * g * s * s,
                        }
                    end,
                    on_completed = function()
                        piece:unparent()
                    end
                }
                
            end
            
        end
        
    end,
    
    knockdownable = function(obj,targ_y,initial_impact,floor_func)
        
        return function(_,vx)
            
            if obj.hit then return end
            
            initial_impact()
            
            obj:hide()
            
            obj.hit = true
            
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

local function rock_back_and_forth(obj)
    
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
        
        t.source.collision = item_type[t.item_type](t.source,t.targ_y,t.initial_impact,t.floor_func)
        
    else
        
        if type(t.pieces) ~= "table" then
            
            error("'pieces' for collectable item must be a table",2)
            
        end
        
        
        t.source.collision = item_type[t.item_type](t.source,t.pieces,t.initial_impact)
        
        t.source.on_idle = rock_back_and_forth(t.source)
        
        Animation_Loop:add_animation(t.source.on_idle)
    end
    
    
    
    return t.source
    
end



return make_item