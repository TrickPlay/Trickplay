
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
    
    -- Take myself out
    
    section.all_apps[ app.id ] = nil
        
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
    -- Switch to 'full screen' view of all apps
    ---------------------------------------------------------------------------

    local function show_all_apps()
    
        local app_list = {}
        
        -- Add the top apps
        
        for _ , app_id in ipairs( section.top_apps ) do        
            table.insert( app_list , section.all_apps[ app_id ] )        
        end
        
        -- Add the other apps
        
        for app_id , app in pairs( section.all_apps ) do        
            if not is_top_app( app_id ) then
                table.insert( app_list , app )
            end
        end
        
        -- Create a group to hold all the tiles
        
        local group = Group
        {
            size = { screen.w , screen.h - ui.bar.h } ,
            position = { 0 , ui.bar.h + 1 },
            clip = { 0 , 0 , screen.w , screen.h - ui.bar.h }
        }
        
        screen:add( group )
        
        group:raise_to_top()
        
        -- Prevent keys from going to the menu
        
        group:grab_key_focus()
               
        -- Figure out the spacing of tiles
        
        -- We use the width and height of a tile that is in the dropdown
        
        local TILE_W = section.items[ 3 ].w
        local TILE_H = section.items[ 3 ].h
        
        local LEFT_MARGIN   = 7
        
        local V_SPACE = ( group.h - ( TILE_H * 4 ) ) / 5
        
        local tile_x = LEFT_MARGIN
        local tile_y = V_SPACE
        
        local col = 1
        local row = 1
        
        -- Now, create new tiles
        
        local tiles = {}
        
        for i , app in ipairs( app_list ) do
        
            -- Create the tile
        
            local tile = factory.make_app_tile( assets , app.name , app.id )
            
            group:add( tile )
            
            tile.position = { tile_x , tile_y }
            
            tile.y_rotation = { 90 , tile.w / 2 , 0 }
            
            tile.opacity = 0
            
            tile.extra.col = col
            tile.extra.row = row
                    
            -- Calculate the position of the next tile

            row = row + 1
            
            if row > 4 then
            
                tile_x = tile_x + TILE_W + V_SPACE
                tile_y = V_SPACE
                row = 1
                col = col + 1
            
            else
            
                tile_y = tile_y + TILE_H + V_SPACE
            
            end
        
            table.insert( tiles , tile )            
        end
        
        -- Now, we start an idle handler to get rid of the drop down and
        -- rotate the tiles in
        
        local DURATION = 100
        
        local start = Stopwatch()
        
        function idle.on_idle( )
        
            local progress = math.min( start.elapsed / DURATION , 1 )
            
            section.dropdown.opacity = 255 - 255 * progress
            
            section.dropdown.y_rotation = { -90 * progress , section.dropdown.w / 2 , 0 }
            
            -- Once the dropdown is gone, we can bring in the tiles
            
            if progress == 1 then
            
                -- Reset the stopwatch
                
                start:start()
                
                -- This is how long each diagonal is going to wait to start
                -- its rotation
                
                local DELAY = 100
                
                -- How many ms each one will take to rotate in. Note that the total
                -- time depends on the number of diagonals. In a 4x4 grid, for
                -- example, the last one will wait 6 * DELAY and will finish
                -- DURATION ms after that. 
                
                local DURATION = 150

                -- Locals for the idle function below
                
                local done
                local delay
                local progress
                local yr
                local op
                
                function idle.on_idle( idle )
                    
                    done = true
                
                    for i , tile in ipairs( tiles ) do
                    
                        delay = DELAY * ( tile.extra.col + tile.extra.row - 2 )
                        
                        if start.elapsed > delay then
                        
                            progress = math.min( ( start.elapsed - delay ) / DURATION , 1 )
                        
                            -- See if it still needs to be rotated
                            
                            yr = tile.y_rotation[ 1 ]
                            
                            if yr > 0 then
                                yr = 90 - 90 * progress
                                tile.y_rotation = { yr , tile.w / 2 , 0 }
                                done = false
                            end
                            
                            -- See if it still needs its opacity increased
                        
                            op = tile.opacity
                            
                            if op < 255 then
                                op = 255 * progress
                                tile.opacity = op
                                done = false                                
                            end
                            
                        else
                        
                            -- This tile is not ready to start, so we need to keep going
                            
                            done = false
                            
                        end    
                    
                    end
                    
                    -- All tiles are done with their animations
                    
                    if done then
                    
                        print( "DONE AT" , start.elapsed )
                        
                        -- Focus the first tile
                        
                        tiles[1]:on_focus_in()

                        -- Get rid of the idle handler
                        
                        idle.on_idle = nil
                        

                    end
                
                end
            
            end
        
        end
    
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
    
    
        local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        
        local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )
    
        table.insert( section.items , all_apps )
        
        table.insert( section.items , categories )
        
        items_height = items_height + all_apps.h + categories.h
        
        all_apps.extra.on_activate =
        
            function()
                show_all_apps()
            end
        
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
    
    
    build_dropdown_ui()
end