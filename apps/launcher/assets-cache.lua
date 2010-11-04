
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

local group = nil

mt.__index = mt

function mt.__call( t , k , f )
    local print = function() end
    print( "ASKING FOR" , k )
    local asset = rawget( list , k )
    if not asset then
        asset = ( f or make_image )( k )
        if type( asset ) == "string" then
            print( "  ASK AGAIN" )
            return t( asset )
        end
        assert( asset , "Failed to create asset "..k )
        rawset( list , k , asset )
        if not group then
            group = Group{ name = "assets" }
            screen:add( group )
            group:hide()
        end
        group:add( asset )
        print( "  MISS" )
    else
        print( "  HIT" )
    end
    return Clone{ source = asset }
end


function mt.__newindex( t , k , v )
    assert( false , "You cannot add assets to the asset cache" )
end

return setmetatable( {} , mt )

