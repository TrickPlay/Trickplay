
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
    
    -- TODO: temporary
    
    profile_apps[ "com.trickplay.burberry" ] = nil

    -- The list of focusable items in the dropdown        
        
    local section_items = {}
    
    -- A persistent list of recently used apps
    
    local AppList = dofile( "app-list" )
    
    local recently_used_apps = AppList( profile_apps , "recently_used" )
    
    -- A list of apps sorted by name
    
    local alpha_apps = {}
    
    -- Insert all of the app ids
    
    for k , v in pairs( profile_apps ) do
        table.insert( alpha_apps , k )
    end
    
    -- Sort the app ids by the app name
    
    table.sort( alpha_apps , function( a , b ) return profile_apps[ a ].name < profile_apps[ b ].name end )
    
    -- Create an official AppList out of it
    
    alpha_apps = AppList( profile_apps , nil , alpha_apps )
    
    
    -- This should match the order in the category picker
    
    local app_lists = { recently_used_apps , alpha_apps }
    
    local current_app_list = settings.last_app_list or 1
    
    if current_app_list < 1 then
        current_app_list = 1
    elseif current_app_list > # app_lists then
        current_app_list = 1
    end

    ---------------------------------------------------------------------------
    
    local statistics 
    
    do
    
        local mt = {}
        
        mt.__index = mt
        
        function mt:app_launched( app_id )
            recently_used_apps:make_first( app_id )
        end
        
        statistics = setmetatable( {} , mt )
    
    end
       
    ---------------------------------------------------------------------------
    -- We're switching to a list of apps in full screen
    ---------------------------------------------------------------------------
    
    local function show_all_apps( app_list )
    
        ui:on_exit_section( section )
    
        local fs_apps = dofile( "fs-apps" )( ui , app_list , statistics )
        
        ui:on_section_full_screen( fs_apps )
    
    end

    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------

    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        group.name = "my-apps-dropdown"
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
    
--        local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        
        local categories = factory.make_text_side_selector( assets , { ui.strings[ "Recently Used" ] , ui.strings[ "By Name" ] } , current_app_list )
    
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
        
        local list = app_lists[ current_app_list ]
        
        for i = 1 , TOP_APP_COUNT do    
            
            local app_id = list[ i ]
            
            if not app_id then
                break
            end
            
            local name = list.all[ app_id ].name
            
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

    local function replace_app_tiles( list )
    
        for i = 1 , TOP_APP_COUNT do
        
            local old_tile = section_items[ i + 1 ]
            
            if not old_tile then
                break
            end
            
            local app_id = list[ i ]
            
            if not app_id then
                break
            end
            
            local name = profile_apps[ app_id ].name
            
            local tile = factory.make_app_tile( assets , name , app_id )
            
            tile.extra.on_activate =
            
                function( )
                    if apps:launch( app_id ) then
                        recently_used_apps:make_first( app_id )
                    end
                end
            
            tile.position = old_tile.position
            
            old_tile.parent:add( tile )
            
            old_tile:unparent()
            
            section_items[ i + 1 ] = tile
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
    
    ---------------------------------------------------------------------------
    -- Choosing a different sort algorithm
    
    local function show_previous()
        if section.focus == 1 then
            local i = section_items[ section.focus ]:on_show_previous()
            if i then
                replace_app_tiles( app_lists[ i ] )
                settings.last_app_list = i
                current_app_list = i
            end
        end
    end
    
    local function show_next()
        if section.focus == 1 then
            local i = section_items[ section.focus ]:on_show_next()
            if i then
                replace_app_tiles( app_lists[ i ] )
                settings.last_app_list = i
                current_app_list = i
            end
        end
    end

    ---------------------------------------------------------------------------
    
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
    
        show_all_apps( app_lists[ current_app_list ] )
        
        return true
    
    end
    
    
    build_dropdown_ui()
end