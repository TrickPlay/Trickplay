--[[

    XMLTree uses the built-in parser to build a document tree for XML.
    Each node in the result is a table with the following properties:
    
        tag -           always there - the name of the node, including schema qualifier
        attributes -    nil if there are none, otherwise a table with each attribute's
                        name as a key and its value as a value.
        text -          nil if there is none, otherwise the text of the node.
        children -      nil if there are none, otherwise a table of nodes.
        
    Each node also has a find function that takes a string:
    
        find( path )
        
        Path is a / delimited string of node names, which may or may not
        include namespace qualifiers. The last element in the path may be
        suffixed with .text, .children or .attributes, in which case find
        will return that value and not the found node.
        
        Each element in the path is a regular expression, so make sure to
        escape magic characters with %. For example: find( "DIDL%-Lite" )
        
        
    Example:
    
        <root xmlns:a = "bar"><a:foo z="10">Hello</foo></root>
        
        Will result in this:
        
        {
            tag = "root",
            attributes = { ["xmlns:a"] = "bar" },
            children =
            {
                [1] =
                {
                    tag = "a:foo",
                    attributes = { "z" = "10" },
                    text = "Hello"
                }
            }
        }
        
        This call:
        
        tree:find( "root/foo.text" )
        
        Will return "Hello"
]]


if XMLTree then
    return
end

--------------------------------------------------------------------------------
-- locals
--------------------------------------------------------------------------------

local function split( s , separator , max )
    if max == 1 then
        return {s}
    end
    local t = {}
    local ll = 0
    local ls
    local le
    while true do
      ls,le=string.find(s,separator,ll,true)
      if ls then
        table.insert(t,string.sub(s,ll,ls-1))
        ll=le+1
        if #t+1 == max then
            break
        end
      else
        break
      end
    end
    table.insert(t,string.sub(s,ll))
    return t
end

--------------------------------------------------------------------------------

local function find_child( parent , tag )
    if not string.find(tag,":",1,true) then
        tag = "[^:]*:?"..tag
    end
    for _,child in ipairs( parent.children or {} ) do
        if string.find( child.tag , tag ) then
            return child
        end
    end
end

--------------------------------------------------------------------------------

local function xml_tree_find( self , path )

    local parts = split( path , "/" )
    
    assert( #parts >= 1 )
    
    local sub = split( parts[ #parts ] , "." , 2 )
    
    if #sub == 2 then
        parts[ #parts ] = sub[ 1 ]
        sub = sub[ 2 ]
    else
        sub = nil
    end
    
    local node = { children = { self } }
    
    while true do
        node = find_child( node , table.remove( parts , 1 ) )
        if not node then
            break
        elseif #parts == 0 then
            return choose( sub , node[ sub ] , node )
        end
    end
end

--------------------------------------------------------------------------------
-- The metatable for all xml tree nodes
    
local xml_tree_mt = {}
    
xml_tree_mt.__index = xml_tree_mt
xml_tree_mt.find = xml_tree_find

--------------------------------------------------------------------------------

function XMLTree( xml )

    -- Parser, a stack and the root node
    
    local parser = XMLParser()
    
    local stack = {}
    
    local root = nil

    function parser.on_start_element( parser , tag , attributes )

        -- Create a new node and give it the metatable
    
        local child = setmetatable( { tag = tag } , xml_tree_mt )
        
        -- If there are attributes, keep them
        
        if next( attributes ) then
            child.attributes = attributes
        end
        
        -- Attach it to the parent, if any. If there is no parent
        -- this becomes the root node.
        
        local parent = stack[ #stack ]
        
        if parent then
            if not parent.children then
                parent.children = { child }
            else
                table.insert( parent.children , child )
            end
        else
            root = child
        end
        
        -- Put it in the stack
        
        table.insert( stack , child )
    end
    
    function parser.on_end_element( parser , tag )
        table.remove( stack )
    end
    
    function parser.on_character_data( parser , text )
        local parent = stack[ #stack ]
        parent.text = ( parent.text or "" )..text
    end

    if parser:parse( xml ) then
        return root
    end
end
    

