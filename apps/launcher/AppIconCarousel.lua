local IconCarousel = {}

local has_been_initialized = false

function IconCarousel:create(p)
    
    local instance = Group{} 
    
    local app_list = {}
    
    for id,img in pairs(p.launcher_icons or error("must pass 'launcher_icons'",2)) do
        
        table.insert(
            
            app_list,
            
            img
        )
        
    end
    
    
    
    local clones = {}
    
    local vis_w  = p.vis_w  or error("must pass 'vis_w'",  2)
    local icon_w = p.icon_w or error("must pass 'icon_w'", 2)
    
    
    local num_vis = math.ceil(vis_w/icon_w) + 1
    
    num_vis = num_vis > #app_list and #app_list or num_vis
    
    
    for i = 1, num_vis do table.insert( clones, Clone{ x = icon_w*(i-1), size = {480,270} } ) end
    
    local crossfade = Clone{x = clones[1].x}
    instance:add(crossfade)
    instance:add(unpack(clones))
    
    local curr_i = 0
    
    local wrap_i = function(i) return (i-1) % # app_list + 1 end
    
    local cycle_icons = Timeline{
        duration      = p.duration or error("must pass 'duration'", 2),
        loop          = true,
        on_new_frame  = function(tl,ms,p)  instance.x = -icon_w * p  end,
        on_completed  = function(tl)
            
            curr_i = wrap_i(curr_i + 1)
            
            instance.x = 0
            
            for i,c in ipairs(clones) do
                
                c.source = app_list[
                    
                    wrap_i(
                        
                        curr_i + i - 1
                        
                    )
                    
                ]
                
            end
            clones[1].opacity = 255
            clones[1]:animate{duration=800,opacity=0}
            crossfade.source = app_list[
                    
                    wrap_i(
                        
                        curr_i + math.ceil(#app_list/2)
                        
                    )
                    
                ]
                
                print(wrap_i(
                        
                        curr_i + math.ceil(#app_list/2)
                        
                    ))
        end,
    }
    
    cycle_icons:on_completed()
    
    
    local state = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*",  target = "SHOW", duration = 300,
                keys   = {    {instance, "opacity", 255},    },
            },
            {
                source = "*",  target = "HIDE", duration = 300,
                keys   = {    {instance, "opacity", 0},      },
            },
        },
    }
    
    local on_completed = {
        ["SHOW"] = function() --[[nothin 4 now]]  return true end,
        ["HIDE"] = function() cycle_icons:pause() return true end,
    }
    state.timeline.on_completed = function(tl)
        
        return on_completed[state.state] and on_completed[state.state]() or error("IMPOSSIBRUUUU !?!?!?!")
        
    end
    
    
    function instance:play()
        
        cycle_icons:start()
        
        state.state = "SHOW"
        
    end
    
    function instance:pause()
        
        state.state = "HIDE"
        
    end
    
    return instance
    
end

return IconCarousel