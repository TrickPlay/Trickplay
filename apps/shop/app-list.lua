
-- Returns a function that creates an ordered app list.
-- You pass in a table that has app_ids as keys and app objects as values
-- (Like the one returned by apps:get_for_current_profile())
-- And a string key used to retrieve and store the ordered list from/to settings.
--
-- The table has the methods:
--   save - saves the ordered list to settings
--   make_first(app_id) - moves that app_id to the front of the list and saves it
--
-- The table also has the original 'all' list, so you can get the original
-- app object using its app_id

return
function ( all , settings_key , sorted )
    
    local result = {}

    local saved = sorted or ( settings_key and settings[ settings_key ] ) or {}
    
    local to_add = {}
    
    for app_id , _ in pairs( all ) do
        to_add[ app_id ] = true
    end
    
    for _ , app_id in ipairs( saved ) do
        if to_add[ app_id ] then
            table.insert( result , app_id )
            to_add[ app_id ] = nil
        end
    end
    
    for app_id , _ in pairs( to_add ) do
        table.insert( result , app_id )
    end
    
    local mt = {}
    
    mt.__index = mt
    
    mt.all = all
    
    function mt:save()
        if settings_key then
            settings[ settings_key ] = result
        end
    end
    
    function mt:make_first( app_id )
        if settings_key then
            local index = nil
            for i , j in ipairs( self ) do
                if j == app_id then
                    index = i
                    break
                end
            end
            if index and index > 1 then
                table.remove( self , index )
                table.insert( self , 1 , app_id )
                self:save()
            end
        end
    end

    return setmetatable( result , mt )
end
