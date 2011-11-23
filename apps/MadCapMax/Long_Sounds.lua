
local ls = {}

function mediaplayer:on_loaded()
    
    mediaplayer:play()
    
end

function ls:play(song)
    
    if mediaplayer.state ~= "IDLE" then
        mediaplayer:reset()
    end
    
    mediaplayer:load(song)
    
end

function ls:stop()
    
    mediaplayer:stop()
    
end


local fade_out = {
    
    duration = 1,
    
    on_step  = function(s,p)
        
        mediaplayer.volume = (1-p)
        
    end,
    on_completed = function()
        
        ls:stop()
        
    end
}

function ls:fade_out(dur)
    
    fade_out.duration =
        (mediaplayer.duration - mediaplayer.position  <  dur) and
        (mediaplayer.duration - mediaplayer.position) or dur
    
    if Animation_Loop:has_animation(fade_out) then
        
        error("already fading out",2)
        
    end
    
    Animation_Loop:add_animation(fade_out)
    
end

return ls