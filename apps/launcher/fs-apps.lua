
-- This one implements a full screen list of apps.

return
function( ui , app_list , statistics )

    local section   = {}

    local assets    = ui.assets
    
    local factory   = ui.factory
    
    ---------------------------------------------------------------------------

    local group     = nil
    
    local tiles     = nil


    local function build_ui()
    
        if group then
            group:raise_to_top()
            group.opacity = 255
            return
        end
        
        local client_rect = ui:get_client_rect()
        
        group = Group
        {
            name = "my-apps-full-screen",
            size = { client_rect.w , client_rect.h } ,
            position = { client_rect.x , client_rect.y },
            clip = { 0 , 0 , client_rect.w , client_rect.h }
        }
        
        screen:add( group )
        
        group:raise_to_top()
                              
        -- These variables will hold the spacing for tiles
        
        local LEFT_MARGIN   = 7
        
        local COLS = 5
        local ROWS = 3
        
        local TILE_W
        local TILE_H
        
        local V_SPACE
        local H_SPACE
        
        local tile_x
        local tile_y
        
        local col = 1
        local row = 1
        
        -- Now, create new tiles
        
        tiles = {}
        
        for i , app_id in ipairs( app_list ) do
        
            -- Create the tile
        
            local tile = factory.make_app_tile( assets , app_list.all[ app_id ].name , app_id )
            
            -- Once we create the first one, we can use its dimensions to
            -- calculate spacing for all tiles
            
            if i == 1 then
                TILE_W = tile.w
                TILE_H = tile.h
                V_SPACE = ( group.h - ( TILE_H * ROWS ) ) / ( ROWS + 1 )
                H_SPACE = ( group.w - ( TILE_W * COLS ) ) / COLS
                tile_x = LEFT_MARGIN
                tile_y = V_SPACE
            end
            
            -- Configure it and add it to the group
            
            group:add( tile:set{ position = { tile_x , tile_y } } )
                
            tile.extra.col = col
            tile.extra.row = row
            
            -- Calculate the position of the next tile

            row = row + 1
            
            if row > ROWS then
            
                tile_x = tile_x + TILE_W + H_SPACE
                tile_y = V_SPACE
                row = 1
                col = col + 1
            
            else
            
                tile_y = tile_y + TILE_H + V_SPACE
            
            end
        
            table.insert( tiles , tile )
            
            tile.extra.on_activate =
            
                function()
                    if apps:launch( app_id ) then
                        statistics:app_launched( app_id )
                    end
                end
        end
        
    end

    ---------------------------------------------------------------------------
    -- Animate the app tiles
    ---------------------------------------------------------------------------
    
    function animate_tiles( callback , ... )
    
        local to_animate = {}
        
        -- Set the initial values for all visible tiles
        
        for _ , tile in ipairs( tiles ) do
        
            if tile.x < group.w then
            
                tile.opacity = 0
                tile.y_rotation = { 90 , tile.w / 2 , 0 }
                
                table.insert( to_animate , tile )
            
            end
        
        end
        
        -- The time that the animation starts
    
        local start = Stopwatch()
        
        -- This is how long each diagonal is going to wait to start
        -- its rotation
        
        local DELAY = 100
        
        -- How many ms each one will take to rotate in. Note that the total
        -- time depends on the number of diagonals. In a 4x4 grid, for
        -- example, the last one will wait 6 * DELAY and will finish
        -- DURATION ms after that. 
        
        local DURATION = 150

        local args = {...}
        
        -- Locals for the idle function below
        
        local done
        local delay
        local progress
        local yr
        local op
        
        function idle.on_idle( idle )
            
            done = true
        
            for i , tile in ipairs( to_animate ) do
            
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
                idle.on_idle = nil
                callback( unpack( args ) )
            end
                
        end
        
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    
    local focused_tile = nil
    
    local function focus_tile( tile )
        if focused_tile and tile then
            focused_tile:on_focus_out()
        end
        if tile then
            tile:on_focus_in()
            focused_tile = tile
        end
    end
    
    local function move_focus( dx , dy )
    
        if not focused_tile then
            return
        end
        
        local c = focused_tile.extra.col + dx
        local r = focused_tile.extra.row + dy
        
        -- If row is zero, we are pushing up to the menu bar
        
        if r == 0 then
            if focused_tile then
                focused_tile:on_focus_out()
            end
            ui:on_exit_section()
            return
        end
        
        -- Find the new tile to focus
        
        local new_tile = nil
        
        for _ , tile in ipairs( tiles ) do
            if tile.extra.col == c and tile.extra.row == r then
                new_tile = tile
                break
            end
        end
        
        -- TODO: scroll
        focus_tile( new_tile )
    
    end
    
    ---------------------------------------------------------------------------
    
    local function activate_focused()
    
        if focused_tile then
            focused_tile:on_activate()
        end
    
    end

    ---------------------------------------------------------------------------
    
    local key_map =
    {
        [ keys.Up       ] = function() move_focus( 0 , -1 ) end,
        [ keys.Down     ] = function() move_focus( 0 , 1 ) end,
        [ keys.Left     ] = function() move_focus( -1 , 0 ) end,
        [ keys.Right    ] = function() move_focus( 1 , 0 ) end,
        [ keys.Return   ] = function() activate_focused() end
    }
    
    ---------------------------------------------------------------------------
    -- When the menu bar shows us
    ---------------------------------------------------------------------------
    
    function section.on_show( section )
        
        -- When animations are done and we are ready to proceed
        
        local function show()
            
        end
        
        -- Build the UI if we have not done so already
    
        build_ui()
                    
        -- Animate the tiles and invoke the callback when done
        
        animate_tiles( show )
    
    end
    
    ---------------------------------------------------------------------------
    -- Arrow down from the menu bar
    ---------------------------------------------------------------------------
    
    function section.on_enter( section )
    
        focus_tile( focused_tile or tiles[1] )
        
        group:grab_key_focus()

        group.on_key_down =
            
            function( group , key )
                local f = key_map[ key ]
                if f then
                    f()
                end
            end
        
        return true
    
    end
    
    function section.on_default_action( section )
    
        ui:on_section_full_screen( section )
        
        return true
    
    end

    function section.on_hide( section )
        
        if group then
            group.opacity = 0
            group.on_key_down = nil
        end
        
    end
    
    function section.on_clear( section )
    
        if group then
            group:unparent()
            group = nil
        end
    
    end
    
    ---------------------------------------------------------------------------

    return section
    
end
