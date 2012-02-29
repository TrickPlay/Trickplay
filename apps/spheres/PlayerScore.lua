
local make_player_score_counter = function(color)

    local text   = Text{
        font     = SCORE_FONT ,
        color    = color ,
        text     = "0000" ,
        opacity  = 0
    }
    
    text.anchor_point = {text.w/2,text.h/2}
    
    
    ----------------------------------------------------------------------------
    -- Animation for flipping the score text
    
    local flips = 0
    
    local function flip( p )
        text.x_rotation = { 180 * p }
    end

    local function flip_done()
        text.x_rotation = { 0 }
        flips = flips - 1
    end
    
    local function flip_it()
        
        if flips ~= 0 then return false end
        
        flips = flips + 1
        
        add_step_func( SCORE_FLIP_DURATION , flip , flip_done )
        
    end
    
    ----------------------------------------------------------------------------
    -- public methods for changing the score
    
    local score = 0
    
    function text:update_score( value )
        score = value
        text.text = string.format( "%4.4d" , score )
        flip_it()        
    end
    
    function text:add_score( value )
        self:update_score( score + value )
    end
    
    
    ----------------------------------------------------------------------------
    -- public methods for fading the score in and out
    
    function text:fade_in()
        
        --fading the score in resets the score
        self:update_score( 0 )
        
        add_step_func(
            
            RING_ANIMATE_IN_DURATION ,
            
            function ( p )
                
                text.opacity = 255*p
                
            end
        )
        
    end
    
    function text:fade_out()
        add_step_func(
            
            RING_ANIMATE_IN_DURATION ,
            
            function ( p )
                
                text.opacity = 255*(1-p)
                
            end
        )
        
    end
    
    PLAYER_RINGS[color]:add(text)
    
    return text
    
end

-------------------------------------------------------------------------------
-- create a score counter for each color
local score_counters = {}

for _,color in ipairs(COLORS) do
    
    score_counters[color] = make_player_score_counter( color )
    
end

return score_counters