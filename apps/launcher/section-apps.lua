
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

    local ui = section.ui

    local assets = ui.assets
    
    local factory = ui.factory

    ---------------------------------------------------------------------------

    local TOP_APP_COUNT = 3
    
    local profile_apps = apps:get_for_current_profile()
    
    -- Take myself out
    
    profile_apps[ app.id ] = nil

    -- The list of focusable items in the dropdown        
        
    local section_items = {}
    
    local recently_used_apps = dofile( "app-list" )( profile_apps , "recently_used" )
        
    ---------------------------------------------------------------------------
    -- We're switching to a list of apps in full screen
    ---------------------------------------------------------------------------
    
    local function show_all_apps( app_list )
    
        ui:on_exit_section( section )
    
        local fs_apps = dofile( "fs-apps" )( ui , app_list )
        
        ui:on_section_full_screen( fs_apps )
    
    end

    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------

    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
    
--        local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        
        local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )
    
--        table.insert( section_items , all_apps )
        
        table.insert( section_items , categories )
        
--        items_height = items_height + all_apps.h + categories.h
  
        items_height = items_height + categories.h
        
--[[        
        all_apps.extra.on_activate =
        
            function()
                -- TODO: we may have several app lists, we have to choose the
                -- one that the cetegory selector is pointing to.
                
                show_all_apps( recently_used_apps )
            end
]]        
        ---------------------------------------------------------------------------
        -- The top apps
        ---------------------------------------------------------------------------
        
        for i = 1 , TOP_APP_COUNT do    
            
            local app_id = recently_used_apps[ i ]
            
            if not app_id then
                break
            end
            
            local name = recently_used_apps.all[ app_id ].name
            
            local tile = factory.make_app_tile( assets , name , app_id )
            
            table.insert( section_items , tile )
            
            items_height = items_height + tile.h
            
            tile.extra.on_activate =
            
                function( )
                    if apps:launch( app_id ) then
                        recently_used_apps:make_first( app_id )
                    end
                end
            
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
    
        show_all_apps( recently_used_apps )
        
        return true
    
    end
    
    
    build_dropdown_ui()
end