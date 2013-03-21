
-- This thing lets us load and clone assets more easily.
-- When you ask for an asset, it returns a clone if the asset already exists,
-- otherwise, it loads the asset (as an image) and sticks it in the cache,
-- returning a clone. If you pass a function as the second parameter, it will
-- use that function to create the asset if it doesn't exist.

   
local function make_image( k )
    return Image{ src = k }
end

local list = {}

local mt = {}

mt.__index = mt

function mt.__call( t , k , f , ... )
    local asset = rawget( list , k )
    if not asset then
        asset = ( f or make_image )( k , ... )
        assert( asset , "Failed to create asset "..k )
        asset:set{ opacity = 0 }
        rawset( list , k , asset )
        screen:add( asset )
    end
    return Clone{ source = asset , opacity = 255 }
end


function mt.__newindex( t , k , v )
    assert( false , "You cannot add assets to the asset cache" )
end

return setmetatable( {} , mt )

