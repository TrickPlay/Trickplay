--[[
		Contains the gameloop functions
--]]
special_checks = {}
render_list = {}
function add_call (item, ...)
    if item then
        if item.setup then
            item:setup( ... )-- , item )
        end
        render_list[item] = item.render
    end
end
function add_to_render_list( item, ... )

    dolater(add_call, item, ... )
end

function remove_from_render_list( item )

    if  render_list[ item ] then
        if item.remove then item:remove() end
        render_list[ item ] = nil
        return true
    end

    return false

end

function remove_all_from_render_list( item )
--[[
    for i , v in ipairs( render_list ) do
    
        if v == item then
            table.remove( render_list , i )
            return true
        end
    end
    --]]
    local temp_list = {}
    for k,v in pairs(render_list) do
        temp_list[#temp_list+1] = k
    end
    
    local upper = #temp_list
    
    for i = 1,upper do
        if temp_list[i].remove then  temp_list[i]:remove() end
        render_list[ temp_list[i] ] = nil
        temp_list[i] = nil
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
                
                good_guy.obj:collision(bad_guy.obj,good_guy.p)
                bad_guy.obj:collision(good_guy.obj,bad_guy.p)
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
    for i = 1,#special_checks do
	for j,good_guy in ipairs(g_guys_air) do
            
            if special_checks[i].f(special_checks[i].p,good_guy) then
                
                good_guy.obj:collision(special_checks[i].p,good_guy.p)
                
                break
            end
            
        end

        
    end
    b_guys_air  = {}
    b_guys_land = {}
    g_guys_air  = {}
    g_guys_land = {}
    
end







