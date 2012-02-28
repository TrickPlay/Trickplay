--Clone sources for the player ring
local srcs = {}

for i = 1 , # COLORS do
    
    local color = COLORS[i]
    srcs[ color ] = Image{ src = string.format( "assets/ring-%s.png" , color ) }
    clone_sources_layer:add( srcs[ color ] )
end

--------------------------------------------------------------------------------
-- RING
--    spawn location / score counter for a given player ball
--------------------------------------------------------------------------------


local function make_ring( color )
    
    local ring       = Clone{
        name         = string.format( "%s-ring" , color ),
        source       = srcs[ color ],
        position     = RING_START[ color ],
        anchor_point = srcs[ color ].center,
    }
    
    local flipping = false
    function ring:flip( callback )
        
        if flipping then return false end
        
        flipping = true
        
        --flips the ring after it moves to position
        
        local function flip( p )
            ring.y_rotation = { 180 * p }
        end
        
        local function flip_done()
            ring.y_rotation = { 0 }
            if callback then dolater( callback ) end
            
            flipping = false
        end
        
        --move the ring to position
        add_step_func( RING_ANIMATE_IN_DURATION , flip , flip_done )
        
        return true
        
    end
    
    function ring:animate_out( callback )
        
        local xi = Interval( ring.x , RING_START[ color ][1] )
        local yi = Interval( ring.y , RING_START[ color ][2] )
        
        -- moves the ring to position
        local function move( p )
            ring.x = xi:get_value( p )
            ring.y = yi:get_value( p )
        end
        
        
        --move the ring to position
        add_step_func( RING_ANIMATE_IN_DURATION , move , callback )
    end
    
    function ring:animate_in( callback )
        
        local xi = Interval( ring.x , SPAWN_LOCATION[color][1] )
        local yi = Interval( ring.y , SPAWN_LOCATION[color][2] )
        -- moves the ring to position
        local function move( p )
            ring.x = xi:get_value( p )
            ring.y = yi:get_value( p )
        end
        
        local function move_done()
            ring:flip()
            dolater( callback )
        end
        
        --move the ring to position
        add_step_func( RING_ANIMATE_IN_DURATION , move , move_done )
        
    end
    
    background_layer:add(ring)
    
    return ring
end

local rings = {}

for _,color in ipairs(COLORS) do
    
    rings[color] = make_ring( color )
    
end

return rings
