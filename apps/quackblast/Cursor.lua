local cursor = {}

local reload_time = 100

local has_been_initialized = false

local imgs, duck_layer, cursor_layer, hud

function cursor:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    print("duck launcher has been initialized")
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    hud          = t.hud
    imgs         = t.imgs
    duck_layer   = t.duck_layer
    cursor_layer = t.cursor_layer
    
end

function cursor:make_cursor()
    
    if not has_been_initialized then error("Must initialize",2) end
    
    local instance = Clone()
    
    ----------------------------------------------------------------------------
    -- Aim                                                                    --
    ----------------------------------------------------------------------------
    local x_upval,y_upval, hovering_over
    
    local check_ducks = Timeline{
        loop = true,
        on_new_frame = function()
            
            x_upval = instance.x
            y_upval = instance.y
            
            hovering_over = nil
            
            for _,duck in pairs(duck_layer.children) do
                
                if   duck:contains(x_upval,y_upval) then print("got") if
                    (hovering_over == nil or hovering_over.z < duck.z) then
                    
                    hovering_over = duck
                    end
                end
                
            end
            if hovering_over then print("weeee") end
            instance.source =
                hovering_over and
                imgs.crosshair.target or
                imgs.crosshair.normal
            
        end
    }
    instance.source = imgs.crosshair.normal
    instance.anchor_point = {imgs.crosshair.normal.w/2,imgs.crosshair.normal.h/2}
    --check_ducks:start()
    
    ----------------------------------------------------------------------------
    -- Shoot                                                                  --
    ----------------------------------------------------------------------------
    
    local blink = Timer{
        interval = 200,
        on_timer = function()
            instance.opacity = instance.opacity ~= 255 and 255 or 100
        end
    }
    blink:stop()
    
    local reloading = false
    
    local reload_timer = Timer{
        
        interval = 200,
        
        on_timer = function(self)
            
            self:stop()
            
            reloading = false
            --instance.opacity = 255
            blink:stop()
        end
    }
    reload_timer:stop()
    
    function instance:highlight()
        instance.source = imgs.crosshair.target
    end
    
    function instance:unhighlight()
        instance.source = imgs.crosshair.normal
    end
    function instance:fire(hit)
        
        if reloading or not in_game then return false end
        
        hud:inc_shots_fired()
        
        --if hovering_over then
        --    
        --    hovering_over:kill()
        --    
        --    instance.player:inc_score(hovering_over)
        --    
        --end
        local r = imgs.crosshair.burst[hit and 2 or 1]--math.random(1,#imgs.crosshair.burst)]
        r = Clone{
            source = r,
            position = self.position,
            anchor_point = {r.w/2,r.h/2},
            z_rotation = {math.random(1,360),0,0}
        }
        
        dolater(100,function() r:unparent() end)
        self.parent:add(
            r
        )
        
        reloading = true
        --self.opacity = 100
        reload_timer:start()
        --blink:start()
        return true
        
    end
    
    
    ----------------------------------------------------------------------------
    -- Destructor                                                             --
    ----------------------------------------------------------------------------
    function instance:remove()
        
        self:unparent()
        
        check_ducks:stop()
        
        reload_timer:stop()
        
        hovering_over = nil
        
    end
    
    cursor_layer:add(instance)
    
    last_cursor = instance
    
    return instance
    
end





return cursor