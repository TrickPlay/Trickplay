
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

    local ui = section.ui

    local assets = ui.assets
    
    local factory = ui.factory

    ---------------------------------------------------------------------------

    -- The list of focusable items in the dropdown        
        
    local section_items = {}
    
    local showcases = dofile( "showcase/showcases.lua" )
    
    for i = 1 , # showcases do
        showcases[ i ].dropdown = assets( showcases[ i ].dropdown )
    end
    
    assert( type( showcases ) == "table" )
    assert( #showcases > 0 )
    
    local showcase_index = 1
    
    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------

    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        if not group then
            return 
        end
        
        group.name = "showcase-dropdown"
        
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 20
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
        
        local choices = {}
        for i = 1 , # showcases do
            table.insert( choices , showcases[ i ].title )
        end
        
        local selector = factory.make_text_side_selector( assets , choices )
        
        function selector.extra.on_activate( selector )
            section:on_default_action()
            selector:on_focus_out()
        end
        
        table.insert( section_items , selector )

        table.insert( section_items , showcases[ 1 ].dropdown )
        
        for i = 1 , # section_items do
            items_height = items_height + section_items[ i ].h
        end
        
        -- This spaces all items equally.
        -- TODO: If there are less than 3 app tiles, it will be wrong.
        
        local margin = ( space - items_height ) / ( # section_items - 1 )
        
        local y = TOP_PADDING
        
        for _ , item in ipairs( section_items ) do
        
            item.x = ( group.w - item.w ) / 2
            item.y = y
            
            y = y + item.h + margin
            
            group:add( item )
            
        end
        
    end
    
    ---------------------------------------------------------------------------
    
    local function switch_showcase_dropdown( index )
        if not index then
            return
        end
        
        local old = section_items[ 2 ]
        local new = showcases[ index ].dropdown
        new.position = old.position
        new.opacity = 0
        old.parent:add( new )
        section_items[ 2 ] = new
        showcase_index = index
        old:grab_key_focus()
        old.on_key_down = function() return true end
        new:animate{ duration = 200 , opacity = 255 }
        old:animate
        {
            duration = 200 ,
            opacity = 0 ,
            on_completed =
                function()
                    section_items[ 1 ]:grab_key_focus()
                    old:unparent()
                    old.on_key_down = nil
                end
        }
    end

    local function show_previous()
        if section.focus == 1 then
            local i = section_items[ section.focus ]:on_show_previous()
            switch_showcase_dropdown( i )
        end
    end
    
    local function show_next()
        if section.focus == 1 then
            local i = section_items[ section.focus ]:on_show_next()
            switch_showcase_dropdown( i )
        end
    end

    ---------------------------------------------------------------------------
    -- Called each time the drop down is about to be shown
    ---------------------------------------------------------------------------

    function section.on_show( section )
    end
    
    ---------------------------------------------------------------------------
    
    local function move_focus( delta )
    
        local unfocus = section_items[ section.focus ]
        
        local focus = section_items[ section.focus + delta ]
        
        if not focus then
            if section.focus + delta == 0 then
                if unfocus then
                    unfocus:on_focus_out()
                end
                ui:on_exit_section()
            end
            return
        end
        
        if not focus.on_focus_in then
            return
        end
        
        if unfocus then
            unfocus:on_focus_out()
        end
        
        section.focus = section.focus + delta
    
        focus:on_focus_in()
        
    end
    
    local function activate_focused()
    
        local focused = section_items[ section.focus ]
        
        if focused and focused.on_activate then
            focused:on_activate()
        end
    
    end
    
    
    local key_map =
    {
        [ keys.Up     ] = function() move_focus( -1 ) end,
        [ keys.Down   ] = function() move_focus( 1  ) end,
        [ keys.Left   ] = show_previous,
        [ keys.Right  ] = show_next,
        [ keys.Return ] = activate_focused,
    }

    ---------------------------------------------------------------------------
    -- Called when the section is entered, by pressing down from the
    -- main menu bar
    ---------------------------------------------------------------------------
    
    function section.on_enter( section )
    
        section.focus = 0
        
        move_focus( 1 )
        
        section.dropdown:grab_key_focus()
        
        section.dropdown.on_key_down =
        
            function( section , key )
                local f = key_map[ key ]
                if f then
                    f()
                end
            end
    
        return true
        
    end

    ---------------------------------------------------------------------------
    -- Called when the user presses enter on this section's menu button
    ---------------------------------------------------------------------------
    
    function section.on_default_action( section )
    
        ui:on_exit_section( section )
    
        local showcase = showcases[ showcase_index ].enter( ui )
        
        if showcase then
            ui:on_section_full_screen( showcase )
        end

        return false
    
    end
    
    
    build_dropdown_ui()
end
