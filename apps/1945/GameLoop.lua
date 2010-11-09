--[[
		Contains the gameloop functions
--]]
render_list = {}
function add_to_render_list( item, ... )
    if item then
        if item.setup then
            item:setup( ... )-- , item )
        end
        render_list[item] = item.render
    end

end

function remove_from_render_list( item )
--[[
    for i , v in ipairs( render_list ) do
    
        if v == item then
            table.remove( render_list , i )
            return true
        end
    end
    --]]
    if  render_list[ item ] then
        render_list[ item ] = nil
        return true
    end

    return false

end





TYPE_MY_PLANE       = 1
TYPE_MY_BULLET      = 2
TYPE_ENEMY_PLANE    = 3
TYPE_ENEMY_BULLET   = 4
--[[
bad_guys_collision_list  = {}
good_guys_collision_list = {}
--]]
b_guys_air  = {}
b_guys_land = {}
g_guys_air  = {}
g_guys_land = {}

local collided = function(good_guy,bad_guy)

    --do box collision detection
    
    return not (                    --returns true if
        good_guy.x1 > bad_guy.x2 or -- good guy is   to the right of    bad guy
        good_guy.x2 < bad_guy.x1 or -- good guy is   to the left  of    bad guy
        good_guy.y1 > bad_guy.y2 or -- good guy is   behind             bad guy
        good_guy.y2 < bad_guy.y1    -- good guy is   ahead of           bad guy
    )
end

function process_collisions()
local bad_guy
    --check for collisions between the good guys and bad guys
    for     i, good_guy in ipairs(g_guys_air) do
        --for j,  bad_guy in ipairs( bad_guys_collision_list) do
        for j, bad_guy in ipairs(b_guys_air) do
            
            if collided(good_guy,bad_guy) then
                
                good_guy.obj:collision(bad_guy.obj)
                bad_guy.obj:collision(good_guy.obj)
                table.remove(b_guys_air,j)
                
                break
            end
            
        end
    end
    
    
    --check for collisions between the good guys and bad guys
    for     i, good_guy in ipairs(g_guys_land) do
        --for j,  bad_guy in ipairs( bad_guys_collision_list) do
        for j, bad_guy in ipairs(b_guys_land) do
            
            if collided(good_guy,bad_guy) then
                
                good_guy.obj:collision(bad_guy.obj)
                bad_guy.obj:collision(good_guy.obj)
                table.remove(b_guys_land,j)
                
                break
            end
            
        end
    end
    
    b_guys_air  = {}
    b_guys_land = {}
    g_guys_air  = {}
    g_guys_land = {}
    
end

--[[

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
                        
                        --pcall( source.item.collision , source.item , target.item )
                        --pcall( target.item.collision , target.item , source.item )
                        source.item.collision(source.item,target.item)
                        target.item.collision(target.item,source.item)
                        
                        -- Mark them as 'removed'
                        
                        removed[ source ] = true
                        removed[ target ] = true
                    
	end	end	end	end	end

    -- Clear the collision list
    collision_list = {}
end
--]]





