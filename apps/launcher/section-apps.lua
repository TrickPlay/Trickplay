
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

    local ui = section.ui

    local assets = ui.assets
    
    local factory = ui.factory

    ---------------------------------------------------------------------------

    local TOP_APP_COUNT = 3
    
    section.top_apps = settings.top_apps or {}
    
    section.all_apps = apps:get_for_current_profile()
        
    section.items = {}
    
    ---------------------------------------------------------------------------

    local function is_top_app( app_id )
        for _ , top in ipairs( section.top_apps ) do
            if app_id == top then
                return true
            end
        end
        return false
    end
    
    ---------------------------------------------------------------------------
    -- Make sure that there are TOP_APP_COUNT apps in section.top_apps, that
    -- they are all valid and that they all have icons.
    ---------------------------------------------------------------------------
    
    local function validate_top_apps()
    
        -- Load the apps and the most used apps
    
        local top_apps = section.top_apps
    
        section.top_apps = {}
    
        -- Look for each top app in all_apps and, if it is there, add it to
        -- section.top_apps until we have TOP_APP_COUNT.
        
        -- This ensures that the ids we have saved previously in top apps still
        -- exist.
        
        for _ , app_id in ipairs( top_apps ) do
            if section.all_apps[ app_id ] then
                table.insert( section.top_apps , app_id )
                if # section.top_apps == TOP_APP_COUNT then
                    break
                end
            end
        end

        -- If ui.top_apps has less than TOP_APP_COUNT, then add some from all_apps.
        -- In a cold start, top apps will be empty - this fills it. 
        
        if # section.top_apps < TOP_APP_COUNT then
            for app_id , app in pairs( section.all_apps ) do
                if not is_top_app( app_id ) then
                    table.insert( section.top_apps , app_id )
                    if # section.top_apps == TOP_APP_COUNT then
                        break
                    end
                end
            end
        end
    
    end

    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------

    local group = section.dropdown
    
    local TOP_PADDING = 48
    local BOTTOM_PADDING = 12
    
    local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
    local items_height = 0


    local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
    
    local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )

    table.insert( section.items , all_apps )
    
    table.insert( section.items , categories )
    
    items_height = items_height + all_apps.h + categories.h
    
    
    ---------------------------------------------------------------------------
    -- The top apps
    ---------------------------------------------------------------------------
    
    validate_top_apps()
            
    for i = 1 , TOP_APP_COUNT do    
        
        local app_id = section.top_apps[ i ]
        
        local tile = factory.make_app_tile( assets , section.all_apps[ app_id ].name , app_id )
        
        table.insert( section.items , tile )
        
        items_height = items_height + tile.h
        
        tile.extra.on_activate =
        
            function( )
                if apps:launch( app_id ) then
                   table.remove( section.top_apps , i )
                   table.insert( section.top_apps , 1 , app_id )
                   settings.top_apps = section.top_apps
                end
            end
        
    end
    
    local margin = ( space - items_height ) / ( # section.items - 1 )
    
    local y = TOP_PADDING
    
    for _ , item in ipairs( section.items ) do
    
        item.x = ( group.w - item.w ) / 2
        item.y = y
        
        y = y + item.h + margin
        
        group:add( item )
        
    end
    
    ---------------------------------------------------------------------------
    -- Called each time the drop down is about to be shown
    ---------------------------------------------------------------------------

    function section.on_show( section )
    end
    
    ---------------------------------------------------------------------------
    
    local function move_focus( delta )
    
        local unfocus = section.items[ section.focus ]
        
        local focus = section.items[ section.focus + delta ]
        
        if not focus then
            if section.focus + delta == 0 then
                if unfocus then
                    unfocus:on_focus_out()
                end
                ui:on_exit_section()
            end
            return
        end
        
        if unfocus then
            unfocus:on_focus_out()
        end
        
        section.focus = section.focus + delta
    
        focus:on_focus_in()
        
    end
    
    local function activate_focused()
    
        local focused = section.items[ section.focus ]
        
        if focused and focused.on_activate then
            focused:on_activate()
        end
    
    end
    
    
    local key_map =
    {
        [ keys.Up     ] = function() move_focus( -1 ) end,
        [ keys.Down   ] = function() move_focus( 1  ) end,
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
    
end