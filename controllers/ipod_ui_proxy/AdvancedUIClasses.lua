

--=============================================================================

local function UIElement()
    
    local get = {}
    local set = {}
    local call = {}
    local event = {}

    function get:parent( )
        local parent = self( "get_parent" )
        return self.factory:create_local( parent.id , parent.type )
    end

    function call:set(properties)
        assert(type(properties) == "table")
        self("set", properties)
    end

    function call:hide()
        self("hide")
    end

    function call:hide_all()
        self("hide_all")
    end

    function call:show()
        self("show")
    end

    function call:show_all()
        self("show_all")
    end

    function call:move_by(dx, dy)
        self("move_by", dx, dy)
    end

    function call:unparent()
        self("unparent")
    end

    function call:raise()
        self("raise")
    end

    function call:raise_to_top()
        self("raise_to_top")
    end

    function call:lower()
        self("lower")
    end

    function call:lower_to_bottom()
        self("lower_to_bottom")
    end

    function call:move_anchor_point(x, y)
        self("move_anchor_point", x, y)
    end

    function call:transform_point(ancestor, x, y, z)
        self("transform_point", ancestor, x, y, z)
    end

    return get , set , call , event
end


local function ImageClass()

    local get , set , call , event = UIElement()

    function get:async()
        return true
    end

    function set:async()
    end

    return get , set , call , event
end


local function RectangleClass()
    
    local get , set , call , event = UIElement()
    
    function call:speak( what , when )
        return self( "speak" , what , when )
    end

    -- This is an event filter function. When an event is received for this
    -- proxy, and a filter function is in place, the filter function is called
    -- before the real handler. The real handler is then called with the results
    -- of the filter function as its arguments.
    
    -- This gives us a chance to transform arguments received from the remote
    -- end into stuff that is friendly to the local handler. 
    
    function event:on_speak( what )
        if what == json.null then
            what = nil
        end
        return what , "~something added locally~"
    end
    
    return get , set , call , event
end


local function TextClass()
    
    local get , set , call , event = UIElement()

    function get:cursor_size()
        return -1
    end

    return get , set , call , event
end


local function GroupClass()

    local get , set , call , event = UIElement()
    
    function get:children( )
        
        -- Calling get_children on the remote object returns a list of objects
        -- each of which contains the id and type of the child. We have to
        -- convert this to proxy objects, so that you can do group.children[ 1 ].whatever
        
        local children = self( "get_children" )
        local result = {}
        for i = 1 , # children do
            local id = children[ i ].id
            local T = children[ i ].type
            table.insert( result , self.factory:create_local( id , T ) )
        end
        return result
    end
    
    function set:children( children )
        -- When setting the children, we have a table of proxy objects. All we
        -- need to tell the remote end is a list of ids.
        local result = {}
        for i = 1 , # children do
            local id = children[ i ].id
            local T = children[ i ].type
            if id and T then
                table.insert( result , id )
            end
        end
        self( "set_children" , result )
    end
    
    function call:add( ... )
        -- Adding is similar to setting children, except we get passed many
        -- proxies and we simply create an array of ids.
        local children = {...}
        local result = {}
        for i = 1 , # children do
            local id = children[ i ].id
            local T = children[ i ].type
            if id and T then
                table.insert( result , id )
            end
        end
        self( "add" , result )
    end
    
    function call:remove( ... )
        local children = {...}
        local result = {}
        for i = 1 , # children do
            local id = children[ i ].id
            local T = children[ i ].type
            if id and T then
                table.insert( result , id )
            end
        end
        self( "remove" , result )
    end
    
    function call:clear()
        self( "clear" )
    end
    
    function call:foreach_child( f )
        assert( type( f ) == "function" )
        local children = self.children
        for i = 1 , # children do
            f( children[ i ] )
        end
    end
    
    function call:find_child( name )
        assert( type( name ) == "string" )
        local result = self( "find_child" , name )
        if not result then
            return nil
        end
        local id = result.id
        local T = result.type
        if id and T then
            return self.factory:create_local( id , T )
        end
        return nil
    end
    
    function call:raise_child(child, sibling)
        assert( child )
        if not sibling then
            assert( child.raise_to_top )
            return child:raise_to_top()
        end

        if child.id and sibling.id then
            return self("raise_child", child.id, sibling.id)
        end
        return nil
    end

    function call:lower_child(child, sibling)
        assert( child )
        if not sibling then
            assert( child.lower_to_bottom )
            return child:lower_to_bottom()
        end

        if child.id and sibling.id then
            return self("lower_child", child.id, sibling.id)
        end
        return nil
    end

    return get , set , call , event
end

local class_table =
{
    Rectangle = RectangleClass,
    Image = ImageClass,
    Text = TextClass,
    Group     = GroupClass,
    Controller = GroupClass
}

return class_table


--=============================================================================
