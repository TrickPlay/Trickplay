function override_property( object , name , getter , setter )
    assert( type( object ) == "userdata" )
    assert( type( name ) == "string" )
    assert( getter == nil or type( getter ) == "function" )
    assert( setter == nil or type( setter ) == "function" )
    
    local mt = getmetatable( object )
    
    if getter then
        local old_getter = mt.__getters__[name]
        mt.__getters__[ name ] =
            function( object )
                return getter( old_getter , object )
            end
    end
        
    if setter then
        local old_setter = mt.__setters__[name]
        mt.__setters__[name] =
            function( object , value )
                setter( old_setter , object , value )
            end
    end
end

function override_function( object , name , newf )
    assert( type( object ) == "userdata" )
    assert( type( name ) == "string" )
    assert( type( newf ) == "function" )
    
    local mt = getmetatable( object )
    
    local oldf = mt[ name ]
    
    mt[ name ] =
        function( ... )
            return newf( oldf , ... )
        end
end

function is_table_or_nil(name,input)
    
    return input == nil and {} or
        
        type(input) == "table" and input or 
        
        error(name.." requires a table or nil as input",3)
    
end


metatable_to_G = {
    __index    = function(t,k) return _G[k] end,
    __newindex = function(t,k,v) _G[k] = v end,
}