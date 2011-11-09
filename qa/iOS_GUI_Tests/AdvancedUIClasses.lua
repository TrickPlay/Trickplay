local function pango_to_html(pango_string)
    
    local html_string = pango_string
    html_string = string.gsub(html_string, "<b>", "\\<b\\>")
    html_string = string.gsub(html_string, "</b>", "\\</b\\>")

    html_string = string.gsub(html_string, "<big>", "\\<big\\>")
    html_string = string.gsub(html_string, "</big>", "\\</big\\>")

    html_string = string.gsub(html_string, "<i>", "\\<i\\>")
    html_string = string.gsub(html_string, "</i>", "\\</i\\>")

    html_string = string.gsub(html_string, "<s>", "\\<s\\>")
    html_string = string.gsub(html_string, "</s>", "\\</s\\>")

    html_string = string.gsub(html_string, "<sub>", "\\<sub\\>")
    html_string = string.gsub(html_string, "</sub>", "\\</sub\\>")

    html_string = string.gsub(html_string, "<sup>", "\\<sup\\>")
    html_string = string.gsub(html_string, "</sup>", "\\</sup\\>")

    html_string = string.gsub(html_string, "<small>", "\\<small\\>")
    html_string = string.gsub(html_string, "</small>", "\\</small\\>")

    html_string = string.gsub(html_string, "<tt>", "\\<tt\\>")
    html_string = string.gsub(html_string, "</tt>", "\\</tt\\>")

    html_string = string.gsub(html_string, "<u>", "\\<u\\>")
    html_string = string.gsub(html_string, "</u>", "\\</u\\>")

    html_string = string.gsub(html_string, "<span(.-)>", "\\<div%1\\>")
    html_string = string.gsub(html_string, "</span>", "\\</div\\>")

    -- font_desc, font
    --[[
    html_string = regex_replace(html_string,
        "\\<div\\s+font_desc\\s*=\\s*[\"']\\s*([\a,]*)\\s+([\\a\\s]*)(\\d*)(\\a*)\\s*[\"'](.*?)\\>",
        "\\<div font:\\2 \\3\\4 \\1; \\5>")
    --]]
    ---[[
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_desc%s-=%s-[\"']%s-([%a,]-)%s+([%a%s]-)(%d-)(%a-)%s-[\"'](.-)\\>",
        "\\<div%1 font:%3 %4%5 %2; %6\\>")
    --]]
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont%s-=%s-[\"']%s-([%a,]-)%s+([%a%s]-)(%d-)(%a-)%s-[\"'](.-)\\>",
        "\\<div%1 font:%3 %4%5 %2; %6\\>")

    -- font_family, face
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_family%s-=%s-[\"']%s-([%a,]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-family:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sface%s-=%s-[\"']%s-([%a,]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-family:%2; %3\\>")

    -- font_size, size
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_size%s-=%s-[\"']%s-([%d%a]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-size:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%ssize%s-=%s-[\"']%s-([%d%a]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-size:%2; %3\\>")

    -- font_style, style
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_style%s-=%s-[\"']%s-([%a]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-style:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sstyle%s-=%s-[\"']%s-([%a]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-style:%2; %3\\>")

    -- font_weight, weight
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_weight%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-weight:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sweight%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-weight:%2; %3\\>")

    -- font_variant, variant
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_variant%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-variant:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%svariant%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-variant:%2; %3\\>")

    -- font_stretch, stretch
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfont_stretch%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-stretch:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sstretch%s-=%s-[\"']%s-([%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 font-stretch:%2; %3\\>")

    -- foreground, fgcolor, color
    html_string = string.gsub(html_string,
        "\\<div(.-)%sforeground%s-=%s-[\"']%s-([%#%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 color:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sfgcolor%s-=%s-[\"']%s-([%#%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 color:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%scolor%s-=%s-[\"']%s-([%#%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 color:%2; %3\\>")

    -- background, bgcolor
    html_string = string.gsub(html_string,
        "\\<div(.-)%sbackground%s-=%s-[\"']%s-([%#%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 background-color:%2; %3\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sbgcolor%s-=%s-[\"']%s-([%#%a%d]-)%s-[\"'](.-)\\>",
        "\\<div%1 background-color:%2; %3\\>")

    -- underline
    html_string = string.gsub(html_string,
        "\\<div(.-)%sunderline%s-=%s-[\"']%s-single%s-[\"'](.-)\\>",
        "\\<div%1 text-decoration:underline; %2\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sunderline%s-=%s[\"']%s-[%d%a]-%s-[\"'](.-)\\>",
        "\\<div%1 %2\\>")

    -- rise
    html_string = string.gsub(html_string,
        "\\<div(.-)%srise%s-=%s-[\"']%s-([%%%d%a%-]-)%s-[\"'](.-)\\>",
        "\\<div%1 vertical-align:%2; %3\\>")

    -- strikethrough
    html_string = string.gsub(html_string,
        "\\<div(.-)%sstrikethrough%s-=%s-[\"']%s-true%s-[\"'](.-)\\>",
        "\\<div%1 text-decoration:line-through; %2\\>")
    html_string = string.gsub(html_string,
        "\\<div(.-)%sstrikethrough%s-=%s-[\"']%s-false%s-[\"'](.-)\\>",
        "\\<div%1 %2\\>")

    -- convert to html entities
    html_string = regex_replace(html_string, "(?<!\\\\)<", "&lt;")
    html_string = regex_replace(html_string, "(?<!\\\\)>", "&rt;")
    --html_string = string.gsub(html_string, "<", "&lt;")
    --html_string = string.gsub(html_string, ">", "&rt;")

    -- convert {/} to </>
    --[[
    html_string = string.gsub(html_string, "([^{]){([^{])", "%1<%2")
    html_string = string.gsub(html_string, "^{([^{])", "<%1")
    html_string = string.gsub(html_string, "([^}])}([^}])", "%1>%2")
    html_string = string.gsub(html_string, "([^}])}$", "%1>")
    --]]

    -- finishing touches
    html_string = string.gsub(html_string, "\\<", "<")
    html_string = string.gsub(html_string, "\\>", ">")

    ---[[
    html_string = string.gsub(html_string, "<div(.-)>", "<span style=\"%1\">")
    html_string = string.gsub(html_string, "</div>", "</span>")
    --]]

    return html_string
end

local function handle_set_children(self, children)
    local __children = rawget(self, "__children")
    local result = {}
    for i = 1 , # children do
        local child = children[i]
        local id = rawget(child, "id")
        local T = rawget(child, "type")
        if id and T then
            table.insert( result , id )

            -- Child must know it has a parent
            -- First remove old parent
            local __parent = rawget(child, "__parent")

            if __parent then
                local __children2 = rawget(__parent.parent, "__children")
                __children2[id] = nil
            end
            
            -- Give the child its new parent
            local parent = setmetatable({parent = self}, {__mode = "v"})
            rawset(child, "__parent", parent)

            -- Set child as a child to self
            __children[id] = child
        end
    end

    return result
end

--=============================================================================

local function UIElement()
    
    local get = {}
    local set = {}
    local call = {}
    local event = {}

    function get:parent( )
        local parent = self( "get_parent" )
        if not parent then return nil end
        return self.factory:create_local( parent.id , parent.type )
    end

    function call:set(properties)
        assert(type(properties) == "table")

        local children = properties.children
        if children and type(children == "table") then
            -- Remove all children from self
            rawset(self, "__children", {})

            handle_set_children(self, children)
        end

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
        local __parent = rawget(self, "__parent")
        if __parent then
            local id = rawget(self, "id")

            -- Remove parent from child
            rawset(self, "__parent", nil)

            -- Remove child from parent
            local __children = rawget(__parent.parent, "__children")
            __children[id] = nil
        end

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

    local animation_id = 1
    function call:animate(table)
        if not rawget(self, "on_completeds") then
            rawset(self, "on_completeds", {})
        end
        if table.on_completed then
            local on_completeds = rawget(self, "on_completeds")
            on_completeds[animation_id] = table.on_completed
            table.on_completed = animation_id
            animation_id = animation_id + 1
        end
        self("animate", table)
    end

    function call:complete_animation()
        self("complete_animation")
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

    function set:markup( pango )
        if type(pango) ~= "string" then
            return nil
        end

        rawset(self, "__markup", pango)
        self("set_markup", pango_to_html(pango))
    end

    function get:markup()
        return rawget(self, "__markup")
    end

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

        -- Remove all children from self
        rawset(self, "__children", {})

        local result = handle_set_children(self, children)
        self( "set_children" , result )
    end
    
    function call:add( ... )
        -- Adding is similar to setting children, except we get passed many
        -- proxies and we simply create an array of ids.
        local children = {...}
        local result = handle_set_children(self, children)

        self( "add" , result )
    end
    
    function call:remove( ... )
        local children = {...}
        local result = {}
        for i = 1 , # children do
            local child = children[i]
            local id = rawget(child, "id")
            local T = rawget(child, "type")
            if id and T then
                table.insert( result , id )

                -- Child must know it has a parent
                local __parent = rawget(child, "__parent")
                if __parent and __parent.parent == self then
                    -- Remove parent from child
                    rawset(child, "__parent", nil)
                    -- Remove child from parent
                    local __children = rawget(__parent.parent, "__children")
                    __children[id] = nil
                end
            end
        end
        self( "remove" , result )
    end
    
    function call:clear()
        -- Remove all parent references from the children
        local __children = rawget(self, "__children")
        for id,child in pairs(__children) do
            rawset(child, "__parent", nil)
        end

        -- Remove all children from parent
        rawset(self, "__children", {})

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

local function ControllerClass()

    local get , set , call , event = GroupClass()
    
    function call:set_background(resource_name)
        return self("set_background", resource_name)
    end

    return get , set , call , event
end

local class_table =
{
    Rectangle = RectangleClass,
    Image = ImageClass,
    Text = TextClass,
    Group     = GroupClass,
    Controller = ControllerClass
}

return class_table


--=============================================================================
