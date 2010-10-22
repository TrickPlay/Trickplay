--[[
		Contains the gameloop functions
--]]
render_list = {}

function add_to_render_list( item, ... )
--t = { ... }
--print(unpack(t))
    if item then
        item:setup( ... )-- , item )
        table.insert( render_list , item )
    end

end

function remove_from_render_list( item )

    for i , v in ipairs( render_list ) do
    
        if v == item then
            table.remove( render_list , i )
            return true
        end

    end

    return false

end





TYPE_MY_PLANE       = 1
TYPE_MY_BULLET      = 2
TYPE_ENEMY_PLANE    = 3
TYPE_ENEMY_BULLET   = 4

collision_list = {}

function add_to_collision_list( item , start_point, end_point , size , other_type )

    table.insert( collision_list ,
        {
            item = item,
            start_point = start_point,
            end_point = end_point,
            size = size,
            other = other_type
        } )

end

function process_collisions( )

    -- This function uses two rectangles to do collision detection
    
    local function collided( source , target )
    
        local sx1 = math.min( source.start_point[ 1 ] - source.size[ 1 ] / 2 , source.end_point[ 1 ] - source.size[ 1 ] / 2 )
        local sy1 = math.min( source.start_point[ 2 ] - source.size[ 2 ] / 2 , source.end_point[ 2 ] - source.size[ 2 ] / 2 )
        local sx2 = math.max( source.start_point[ 1 ] + source.size[ 1 ] / 2 , source.end_point[ 1 ] + source.size[ 1 ] / 2 )
        local sy2 = math.max( source.start_point[ 2 ] + source.size[ 2 ] / 2 , source.end_point[ 2 ] + source.size[ 2 ] / 2 )
            
        local tx1 = math.min( target.start_point[ 1 ] - target.size[ 1 ] / 2 , target.end_point[ 1 ] - target.size[ 1 ] / 2 )
        local ty1 = math.min( target.start_point[ 2 ] - target.size[ 2 ] / 2 , target.end_point[ 2 ] - target.size[ 2 ] / 2 )
        local tx2 = math.max( target.start_point[ 1 ] + target.size[ 1 ] / 2 , target.end_point[ 1 ] + target.size[ 1 ] / 2 )
        local ty2 = math.max( target.start_point[ 2 ] + target.size[ 2 ] / 2 , target.end_point[ 2 ] + target.size[ 2 ] / 2 )
                
        return not ( sx1 > tx2 or sx2 < tx1 or sy1 > ty2 or sy2 < ty1  )
        
    end

    -- Track all the items we have already looked at

    local removed = {}

    for _ , source in ipairs( collision_list ) do
    
        if removed[ source ] == nil then
        
            for _ , target in ipairs( collision_list ) do
                
                if ( removed[ target ] == nil ) and
                    ( source ~= target ) and
                    ( source.other == target.item.type ) then
                
                    if collided( source , target ) then
                                        
                        -- Invoke the collision function on bothe the source and
                        -- the target, passing the other.
                        
                        pcall( source.item.collision , source.item , target.item )
                        pcall( target.item.collision , target.item , source.item )
                        
                        -- Mark them as 'removed'
                        
                        removed[ source ] = true
                        removed[ target ] = true
                    
	end	end	end	end	end

    -- Clear the collision list
    collision_list = {}
end





