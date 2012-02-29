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
    
    
    local ring   = Group{
        name     = string.format( "%s-ring" , color ),
        position = RING_START[ color ],
        children = {
            Clone{
                source       = srcs[ color ],
                anchor_point = srcs[ color ].center,
            }
        }
    }
    
    ----------------------------------------------------------------------------
    -- Animation for flipping the ring
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
    
    
    ----------------------------------------------------------------------------
    -- Public method for moving the ring
    
    local xi = Interval(0,0)
    local yi = Interval(0,0)
    
    local function move(p)
        ring.x = xi:get_value( p )
        ring.y = yi:get_value( p )
    end
    
    function ring:move_to( position, callback )
        
        xi.from = ring.x
        xi.to   = position[1]
        yi.from = ring.y
        yi.to   = position[2]
        
        --move the ring to position
        add_step_func( RING_ANIMATE_IN_DURATION , move , callback )
        
    end
    
    
    background_layer:add(ring)
    
    return ring
    
end

-------------------------------------------------------------------------------
-- create a ring for each color
local rings = {}

for _,color in ipairs(COLORS) do
    
    rings[color] = make_ring( color )
    
end

return rings
