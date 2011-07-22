local Effects = {}
Effects.active = {}
--shared upval
local effect

-----------------------------------------
-- Smoke Object
-----------------------------------------
local old_smoke  = {}

local new_smoke = function()
    local smoke = Clone{
        source=assets.smoke[
            math.random(  1,  # assets.smoke  )
        ],
    }
    
    smoke.anchor_point = {smoke.w/2,smoke.h/2}
    
    return smoke
end
local fade_out = {
    firework = function(smoke)
        return {
            duration = .7,
            on_step  = function(s,p)
                smoke:set{
                    opacity = 255 * (1 - p),
                    scale   = {1+1*p,1+1*p},
                }
                smoke.y = smoke.y + 50*s
            end,
            on_completed = function()
                
                smoke:unparent()
                
                old_smoke[# old_smoke + 1] = smoke
                
                Effects.active[smoke] = nil
                
            end
        }
    end,
    
    firecracker = function(smoke)
        return {
            duration = .7,
            on_step  = function(s,p)
                smoke:set{
                    opacity = 255 * (1 - p),
                    scale   = {1+2*p,1+2*p},
                }
            end,
            on_completed = function()
                
                smoke:unparent()
                
                old_smoke[# old_smoke + 1] = smoke
                
                Effects.active[smoke] = nil
                
            end
        }
    end
}
Effects.make_smoke = function(_,x,y,type)
    
    effect = table.remove(old_smoke) or new_smoke()
    
    effect.opacity = 255
    
    effect:set{
        opacity = 255,
        x       = x,
        y       = y,
        scale   = {1,1}
    }
    
    effect.fade = fade_out[type](effect)
    
    layers.items:add(effect)
    
    Animation_Loop:add_animation( effect.fade ) 
    
    Effects.active[effect] = effect
    
end


-----------------------------------------
-- Spark Object
-----------------------------------------
local old_sparks = {}

local new_spark = function()
    local spark = Clone{
        source=assets.spark[
            math.random(  1,  # assets.spark  )
        ],
    }
    
    spark.anchor_point = {spark.w/2,spark.h/2}
    
    spark.fade = {
        duration = .2,
        on_step  = function(s,p)
            spark:set{
                opacity = 255 * (1 - p),
                scale   = {1+1*p,1+1*p},
            }
            spark.x = spark.x + spark.vx*s
            spark.y = spark.y + spark.vy*s
        end,
        on_completed = function()
            
            spark:unparent()
            
            old_sparks[# old_sparks + 1] = spark
            
            Effects.active[spark] = nil
            
        end
    }
    
    return spark
end

Effects.make_spark = function(_,x,y,vx,vy)
    
    effect = table.remove(old_sparks) or new_spark()
    
    effect.opacity = 255
    
    effect:set{
        opacity = 255,
        x       = x,
        y       = y,
        scale   = {1,1}
    }
    
    effect.vx = vx
    effect.vy = vy
    
    layers.items:add(effect)
    
    Animation_Loop:add_animation( effect.fade ) 
    
    Effects.active[effect] = effect
    
end

-----------------------------------------
-- Sparkle Object
-----------------------------------------
local old_sparkles = {}

local new_sparkle = function()
    
    local sparkles = Clone{ source = sparkles_src, anchor_point = {sparkles_src.w/2,sparkles_src.h/2} }
    --[[Group{}
    
    for i = 1, # assets.sparkle do
        sparkles:add(
            Clone{
                source=assets.sparkle[i],
            }
        )
    end
    
    
    sparkles.anchor_point = {sparkles_src.w/2,sparkles_src.h/2}
    
    local a, e = 0,0
    --]]
    sparkles.fade = {
        duration = .7,
        on_step  = function(s,p)
            --[[
            e = e + s
            if e > .1 then
                a = ( a + 1 ) % ( # sparkles.children )
                e = 0
            end
            --]]
            sparkles.opacity      = 255 * (1 - p)
            --[[
            for i,s in pairs(sparkles.children) do
                if i == a + 1 then
                    s:show()
                else
                    s:hide()
                end
            end
            --]]
        end,
        on_completed = function()
            
            --a, e = 0,0
            
            sparkles:unparent()
            
            old_sparkles[# old_sparkles + 1] = sparkles
            
            Effects.active[sparkles] = nil
            
            --sparkles.coin = nil
        end
    }
    
    return sparkles
end

Effects.make_sparkles = function(_,x,y)
    
    effect = table.remove(old_sparkles) or new_sparkle()
    
    effect.opacity = 255
    
    effect.x    = x
    effect.y    = y
    
    layers.items:add(effect)
    
    Animation_Loop:add_animation( effect.fade ) 
    
    Effects.active[effect] = effect
    
end

function Effects:scroll_by(dy)
    
    for _,e in pairs(Effects.active) do
        
        e.y = e.y + dy
        
    end
    
end

--function Effects:fade_out_all

return Effects